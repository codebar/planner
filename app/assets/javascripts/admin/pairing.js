// Declarative pairing board, in-place check-in/undo, and ETag live sync.
//
// Delegated at the document level so in-place board swaps preserve all
// handlers. Visual states are driven through data attributes styled in
// app/assets/stylesheets/partials/_pairing.scss.
(function () {
  var dragState = null;
  var requestInFlight = false;
  var lastSyncEtag = null;
  var POLL_INTERVAL_MS = 15000;

  function csrfToken() {
    var meta = document.querySelector('meta[name="csrf-token"]');
    return meta ? meta.content : '';
  }

  function currentBoard() {
    return document.querySelector('.pairing-board');
  }

  function clearHoverTargets(board) {
    if (!board) return;
    board.querySelectorAll('[data-drop-hover]').forEach(function (el) {
      delete el.dataset.dropHover;
    });
  }

  function clearDragVisuals(board) {
    if (!board) return;
    delete board.dataset.dragging;
    clearHoverTargets(board);
    board.querySelectorAll('[data-dragging-slot]').forEach(function (el) {
      delete el.dataset.draggingSlot;
    });
  }

  function showAlert(container, selector, message) {
    var el = container && container.querySelector(selector);
    if (!el) return;
    el.textContent = message;
    el.classList.remove('d-none');
  }

  function hideAlert(container, selector) {
    var el = container && container.querySelector(selector);
    if (!el) return;
    el.classList.add('d-none');
  }

  function pluralize(count, singular, plural) {
    return count + ' ' + (count === 1 ? singular : (plural || singular + 's'));
  }

  function pulseGroup(groupId) {
    if (!groupId) return;
    var el = document.getElementById('pairing-group-' + groupId);
    if (!el) return;
    el.dataset.pulse = 'true';
    window.setTimeout(function () {
      delete el.dataset.pulse;
    }, 1800);
  }

  // Pure DOM snapshot: maps each pairing group ID to its sorted member IDs
  // so we can highlight changed cards after live sync.
  function boardSignatureByGroup(board) {
    var map = {};
    if (!board) return map;
    board.querySelectorAll('[data-pairing-id]').forEach(function (group) {
      var ids = Array.from(group.querySelectorAll('[data-pairing-invitation-id]'))
        .map(function (s) { return s.dataset.pairingInvitationId; })
        .sort()
        .join(',');
      map[group.dataset.pairingId] = ids;
    });
    return map;
  }

  // Derive each settled Expected row's partner status directly from the live
  // pairing board DOM (single source of truth).
  function setRowState(row, nextState) {
    if (!row) return;
    row.dataset.state = nextState;
    var pending = row.querySelector('.expected-row__pending');
    var settled = row.querySelector('.expected-row__settled');
    if (pending) pending.hidden = nextState === 'settled';
    if (settled) settled.hidden = nextState !== 'settled';
  }

  function syncSettledRowsFromBoard(board) {
    if (!board) return;
    document.querySelectorAll('.expected-row[data-state="settled"]').forEach(function (row) {
      var invId = row.dataset.invitationId;
      var role = row.dataset.role;
      var slot = board.querySelector('[data-pairing-invitation-id="' + invId + '"]');
      var group = slot && slot.closest('[data-pairing-id]');
      var statusEl = row.querySelector('[data-settled-status]');
      var jumpBtn = row.querySelector('[data-pairing-jump-btn]');

      if (!group) {
        setRowState(row, 'expected');
        delete row.dataset.pairingId;
        return;
      }

      row.dataset.pairingId = group.dataset.pairingId;
      if (jumpBtn) {
        jumpBtn.dataset.targetGroupId = group.dataset.pairingId;
        jumpBtn.classList.remove('d-none');
      }

      var partners = Array.from(group.querySelectorAll('[data-pairing-invitation-id]'))
        .filter(function (s) { return s.dataset.pairingInvitationId !== invId; })
        .map(function (s) {
          var nameEl = s.querySelector('.pairing-slot__name');
          return nameEl ? nameEl.textContent.trim() : '';
        })
        .filter(Boolean);

      if (statusEl) {
        if (partners.length > 0) {
          statusEl.textContent = 'Checked in · Paired with ' + partners.join(', ');
        } else {
          var waitingFor = role === 'Student' ? 'a coach' : 'a student';
          statusEl.textContent = 'Checked in · Waiting for ' + waitingFor;
        }
      }
    });
  }

  function updateCheckInHeaderBadges(counts) {
    var workspace = document.querySelector('[data-attendance-workspace]') || document;
    if (!counts) return;

    var studentsEl = workspace.querySelector('[data-students-checked-in-badge]');
    if (studentsEl) {
      studentsEl.textContent = counts.students_checked_in + '/' + counts.students_total + ' students checked in';
    }

    var coachesEl = workspace.querySelector('[data-coaches-checked-in-badge]');
    if (coachesEl) {
      coachesEl.textContent = counts.coaches_checked_in + '/' + counts.coaches_total + ' coaches checked in';
    }
  }

  function replaceBoardHtml(board, html, highlightDiff) {
    var prevSigs = highlightDiff ? boardSignatureByGroup(board) : null;
    var wrapper = document.createElement('div');
    wrapper.innerHTML = html.trim();
    var nextBoard = wrapper.querySelector('.pairing-board');
    if (!nextBoard || !board || !board.parentNode) return null;

    board.parentNode.replaceChild(nextBoard, board);
    syncSettledRowsFromBoard(nextBoard);
    document.dispatchEvent(new CustomEvent('pairing:board-updated', { detail: { board: nextBoard } }));

    if (highlightDiff && prevSigs) {
      var nextSigs = boardSignatureByGroup(nextBoard);
      Object.keys(nextSigs).forEach(function (groupId) {
        if (prevSigs[groupId] !== nextSigs[groupId]) pulseGroup(groupId);
      });
    }

    return nextBoard;
  }

  function resolveAction(eventTarget, state, board) {
    if (!state || !board) return { kind: 'noop' };

    var group = eventTarget.closest('[data-pairing-dropzone="group"]');
    if (group) {
      var targetGroupId = group.dataset.pairingId;
      if (targetGroupId === state.sourceGroupId) return { kind: 'noop' };
      return {
        kind: 'assign',
        url: board.dataset.pairingCreateUrl,
        method: 'POST',
        body: { invitation_id: state.invitationId, pairing_id: targetGroupId }
      };
    }

    var unpairZone = eventTarget.closest('[data-pairing-dropzone="unpair"]');
    if (unpairZone || eventTarget.closest('.pairing-board')) {
      return {
        kind: 'unpair',
        url: state.unpairUrl,
        method: 'DELETE',
        body: null
      };
    }

    return { kind: 'noop' };
  }

  function applyBoardAction(board, action) {
    if (action.kind === 'noop') return;

    requestInFlight = true;
    board.dataset.loading = 'true';
    fetch(action.url, {
      method: action.method,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken(),
        'X-Requested-With': 'XMLHttpRequest',
        'Accept': 'text/html'
      },
      body: action.body ? JSON.stringify(action.body) : undefined
    })
      .then(function (response) {
        if (!response.ok) throw new Error('Unable to update pairing right now.');
        return response.text();
      })
      .then(function (html) {
        lastSyncEtag = null;
        if (!replaceBoardHtml(board, html, true)) window.location.reload();
      })
      .catch(function (err) {
        delete board.dataset.loading;
        showAlert(board, '[data-pairing-error]', err.message || 'Unable to update pairing right now.');
      })
      .finally(function () {
        requestInFlight = false;
      });
  }

  function submitCheckInToggle(form, method, nextState, targetRow) {
    var row = targetRow || form.closest('[data-expected-row]');
    var section = (row && row.closest('[data-expected-section]')) || document.querySelector('[data-expected-section]');
    var board = currentBoard();
    if (!row || !board) return;

    requestInFlight = true;
    row.dataset.loading = 'true';
    hideAlert(section, '[data-expected-error]');

    fetch(form.action, {
      method: method,
      headers: {
        'X-CSRF-Token': csrfToken(),
        'X-Requested-With': 'XMLHttpRequest',
        'Accept': 'application/json'
      }
    })
      .then(function (response) {
        if (!response.ok) throw new Error('Unable to update check-in right now.');
        return response.json();
      })
      .then(function (data) {
        lastSyncEtag = null;
        setRowState(row, nextState);
        replaceBoardHtml(board, data.board_html, true);
        updateCheckInHeaderBadges(data.check_in_counts);
      })
      .catch(function (err) {
        showAlert(section, '[data-expected-error]', err.message || 'Unable to update check-in right now.');
      })
      .finally(function () {
        delete row.dataset.loading;
        requestInFlight = false;
      });
  }

  function syncExpectedRowsFromIds(checkedInIds) {
    if (!Array.isArray(checkedInIds)) return;
    var checkedSet = new Set(checkedInIds.map(String));
    document.querySelectorAll('.expected-row[data-invitation-id]').forEach(function (row) {
      setRowState(row, checkedSet.has(row.dataset.invitationId) ? 'settled' : 'expected');
    });
  }

  function pollLiveBoard() {
    var board = currentBoard();
    if (!board || !board.dataset.pairingSyncUrl) return;
    if (dragState || requestInFlight || document.hidden) return;

    var headers = { 'X-Requested-With': 'XMLHttpRequest', 'Accept': 'application/json' };
    if (lastSyncEtag) headers['If-None-Match'] = lastSyncEtag;

    fetch(board.dataset.pairingSyncUrl, { headers: headers, cache: 'no-cache' })
      .then(function (response) {
        if (response.status === 304) return null;
        if (!response.ok) return null;
        var nextEtag = response.headers.get('ETag');
        return response.json().then(function (payload) {
          return { payload: payload, etag: nextEtag };
        });
      })
      .then(function (result) {
        if (!result || dragState || requestInFlight) return;
        var hadEtag = Boolean(lastSyncEtag);
        lastSyncEtag = result.etag;
        if (hadEtag) {
          var liveBoard = currentBoard();
          syncExpectedRowsFromIds(result.payload.checked_in_ids);
          if (liveBoard && result.payload.board_html) {
            replaceBoardHtml(liveBoard, result.payload.board_html, true);
          }
          updateCheckInHeaderBadges(result.payload.check_in_counts);
        }
      })
      .catch(function () {
        // Silent retry on transient network hiccups during background sync
      });
  }

  document.addEventListener('dragstart', function (event) {
    var slot = event.target.closest('[data-pairing-invitation-id]');
    var board = currentBoard();
    if (!slot || !board || !board.contains(slot)) return;

    dragState = {
      invitationId: slot.dataset.pairingInvitationId,
      sourceGroupId: slot.dataset.pairingSourceGroupId,
      unpairUrl: slot.dataset.pairingUnpairUrl
    };

    slot.dataset.draggingSlot = 'true';
    board.dataset.dragging = 'true';
    event.dataTransfer.effectAllowed = 'move';
    event.dataTransfer.setData('text/plain', dragState.invitationId);
  });

  document.addEventListener('dragover', function (event) {
    var board = currentBoard();
    if (!dragState || !board || !board.contains(event.target)) return;

    event.preventDefault();
    event.dataTransfer.dropEffect = 'move';

    var dropEl =
      event.target.closest('[data-pairing-dropzone="group"]') ||
      event.target.closest('[data-pairing-dropzone="unpair"]');

    clearHoverTargets(board);
    if (dropEl && dropEl.dataset.pairingId !== dragState.sourceGroupId) {
      dropEl.dataset.dropHover = 'true';
    }
  });

  document.addEventListener('drop', function (event) {
    var board = currentBoard();
    if (!dragState || !board || !board.contains(event.target)) return;

    event.preventDefault();
    var activeState = dragState;
    dragState = null;
    clearDragVisuals(board);

    applyBoardAction(board, resolveAction(event.target, activeState, board));
  });

  document.addEventListener('dragend', function () {
    dragState = null;
    clearDragVisuals(currentBoard());
  });

  document.addEventListener('submit', function (event) {
    var splitForm = event.target.closest('form[data-pairing-split-form]');
    if (splitForm) {
      var board = currentBoard();
      if (!board || !board.contains(splitForm)) return;
      event.preventDefault();
      applyBoardAction(board, { kind: 'unpair', url: splitForm.action, method: 'DELETE', body: null });
      return;
    }

    var checkInForm = event.target.closest('form[data-pairing-checkin-form]');
    if (checkInForm) {
      event.preventDefault();
      submitCheckInToggle(checkInForm, 'POST', 'settled');
      return;
    }

    var undoForm = event.target.closest('form[data-pairing-undo-form]');
    if (undoForm) {
      event.preventDefault();
      submitCheckInToggle(undoForm, 'DELETE', 'expected');
      return;
    }

    var uncheckForm = event.target.closest('form[data-pairing-uncheck-form]');
    if (uncheckForm) {
      var targetBoard = currentBoard();
      if (!targetBoard || !targetBoard.contains(uncheckForm)) return;
      event.preventDefault();
      var invId = uncheckForm.dataset.invitationId;
      var matchingRow = document.querySelector('.expected-row[data-invitation-id="' + invId + '"]');
      if (matchingRow) {
        submitCheckInToggle(uncheckForm, 'DELETE', 'expected', matchingRow);
      } else {
        requestInFlight = true;
        targetBoard.dataset.loading = 'true';
        fetch(uncheckForm.action, {
          method: 'DELETE',
          headers: { 'X-CSRF-Token': csrfToken(), 'X-Requested-With': 'XMLHttpRequest', 'Accept': 'application/json' }
        })
          .then(function (r) { if (!r.ok) throw new Error('Unable to uncheck in right now.'); return r.json(); })
          .then(function (data) {
            lastSyncEtag = null;
            replaceBoardHtml(targetBoard, data.board_html, true);
            updateCheckInHeaderBadges(data.check_in_counts);
          })
          .catch(function (err) {
            delete targetBoard.dataset.loading;
            showAlert(targetBoard, '[data-pairing-error]', err.message);
          })
          .finally(function () { requestInFlight = false; });
      }
    }
  });

  document.addEventListener('click', function (event) {
    var jumpBtn = event.target.closest('[data-pairing-jump-btn]');
    if (!jumpBtn) return;

    var groupId = jumpBtn.dataset.targetGroupId;
    var target = groupId && document.getElementById('pairing-group-' + groupId);
    if (!target) return;

    target.scrollIntoView({ behavior: 'smooth', block: 'center' });
    pulseGroup(groupId);
  });

  window.setInterval(pollLiveBoard, POLL_INTERVAL_MS);
  document.addEventListener('DOMContentLoaded', pollLiveBoard);
})();
