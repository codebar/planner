// Declarative working groups ("Pairings") board: drag-and-drop swap/pair,
// form fallback, immediate refresh on attendance checkbox toggle, and 15s ETag sync.
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
    return document.querySelector('.working-groups-board');
  }

  function initializeEtag() {
    var board = currentBoard();
    if (board && board.dataset.boardEtag && !lastSyncEtag) {
      lastSyncEtag = board.dataset.boardEtag;
    }
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

  function showBoardError(message) {
    var board = currentBoard();
    var el = board && board.querySelector('[data-working-groups-error]');
    if (!el) return;
    el.textContent = message;
    el.classList.remove('d-none');
  }

  function groupSignatures(board) {
    var map = {};
    if (!board) return map;
    board.querySelectorAll('[data-working-group-id]').forEach(function (card) {
      var ids = Array.from(card.querySelectorAll('.working-group-slot[data-entry-id]'))
        .map(function (s) { return s.dataset.entryId; })
        .sort()
        .join(',');
      map[card.dataset.workingGroupId] = ids;
    });
    return map;
  }

  function pulseGroup(groupId) {
    var card = document.getElementById('working-group-' + groupId);
    if (!card) return;
    card.dataset.pulse = 'true';
    window.setTimeout(function () {
      delete card.dataset.pulse;
    }, 1800);
  }

  function updateSignedInBadges(counts) {
    if (!counts) return;
    var studentsBadge = document.querySelector('[data-checked-in-students-badge]');
    if (studentsBadge) {
      studentsBadge.textContent = counts.checked_in_students + ' students have been signed in';
    }
    var coachesBadge = document.querySelector('[data-checked-in-coaches-badge]');
    if (coachesBadge) {
      coachesBadge.textContent = counts.checked_in_coaches + ' coaches have been signed in';
    }
  }

  function replaceBoardHtml(html, highlightChanges) {
    var liveBoard = currentBoard();
    if (!liveBoard || !html) return;

    var prevSigs = highlightChanges ? groupSignatures(liveBoard) : {};
    var wrapper = document.createElement('div');
    wrapper.innerHTML = html.trim();
    var nextBoard = wrapper.firstElementChild;
    if (!nextBoard) return;

    liveBoard.replaceWith(nextBoard);
    nextBoard.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(function (el) {
      if (window.bootstrap && window.bootstrap.Tooltip) {
        new window.bootstrap.Tooltip(el);
      }
    });

    if (highlightChanges) {
      var nextSigs = groupSignatures(nextBoard);
      Object.keys(nextSigs).forEach(function (id) {
        if (prevSigs[id] !== nextSigs[id]) pulseGroup(id);
      });
    }
  }

  function sendMutation(url, method, body) {
    var board = currentBoard();
    if (!board || requestInFlight) return;

    requestInFlight = true;
    board.dataset.loading = 'true';

    var options = {
      method: method,
      headers: {
        'X-CSRF-Token': csrfToken(),
        'X-Requested-With': 'XMLHttpRequest',
        'Accept': 'application/json'
      }
    };

    if (body) {
      options.headers['Content-Type'] = 'application/json';
      options.body = JSON.stringify(body);
    }

    fetch(url, options)
      .then(function (response) {
        if (!response.ok) throw new Error('Unable to update pairings right now.');
        var etag = response.headers.get('ETag');
        return response.json().then(function (data) {
          return { data: data, etag: etag || data.etag };
        });
      })
      .then(function (result) {
        if (result.etag) lastSyncEtag = result.etag;
        replaceBoardHtml(result.data.board_html, true);
        updateSignedInBadges(result.data.counts);
      })
      .catch(function (err) {
        var liveBoard = currentBoard();
        if (liveBoard) delete liveBoard.dataset.loading;
        showBoardError(err.message);
      })
      .finally(function () {
        requestInFlight = false;
      });
  }

  function pollLiveBoard(force) {
    var board = currentBoard();
    if (!board || requestInFlight || (dragState && !force)) return;

    initializeEtag();
    var headers = { 'X-Requested-With': 'XMLHttpRequest', 'Accept': 'application/json' };
    if (lastSyncEtag && !force) headers['If-None-Match'] = lastSyncEtag;

    fetch(board.dataset.boardUrl, { method: 'GET', headers: headers })
      .then(function (response) {
        if (response.status === 304) return null;
        if (!response.ok) return null;
        var etag = response.headers.get('ETag');
        return response.json().then(function (data) {
          return { data: data, etag: etag || data.etag };
        });
      })
      .then(function (result) {
        if (!result) return;
        if (result.etag) lastSyncEtag = result.etag;
        replaceBoardHtml(result.data.board_html, true);
        updateSignedInBadges(result.data.counts);
      })
      .catch(function () {
        // Silent retry on transient network hiccups during background sync
      });
  }

  function resolveDropAction(target, activeState, board) {
    var unpairZone = target.closest('[data-dropzone="unpair"]');
    if (unpairZone && activeState.sourceGroupId) {
      return { url: activeState.unpairUrl, method: 'DELETE', body: null };
    }

    var groupZone = target.closest('[data-dropzone="group"]');
    if (groupZone && groupZone.dataset.workingGroupId !== activeState.sourceGroupId) {
      return {
        url: board.dataset.assignUrl,
        method: 'POST',
        body: {
          invitation_id: activeState.entryId,
          target_group_id: groupZone.dataset.workingGroupId
        }
      };
    }

    var waitingZone = target.closest('[data-dropzone="waiting"]');
    if (
      waitingZone &&
      waitingZone.dataset.targetEntryId !== activeState.entryId &&
      waitingZone.dataset.role !== activeState.role
    ) {
      return {
        url: board.dataset.assignUrl,
        method: 'POST',
        body: {
          invitation_id: activeState.entryId,
          target_invitation_id: waitingZone.dataset.targetEntryId
        }
      };
    }

    return null;
  }

  document.addEventListener('dragstart', function (event) {
    var board = currentBoard();
    var slot = event.target.closest('.working-group-slot[data-entry-id]');
    if (!slot || !board || !board.contains(slot)) return;

    dragState = {
      entryId: slot.dataset.entryId,
      role: slot.dataset.role,
      sourceGroupId: slot.dataset.sourceGroupId || '',
      unpairUrl: slot.dataset.unpairUrl
    };

    slot.dataset.draggingSlot = 'true';
    board.dataset.dragging = 'true';
    event.dataTransfer.effectAllowed = 'move';
    event.dataTransfer.setData('text/plain', dragState.entryId);
  });

  document.addEventListener('dragover', function (event) {
    var board = currentBoard();
    if (!dragState || !board || !board.contains(event.target)) return;

    event.preventDefault();
    event.dataTransfer.dropEffect = 'move';
    clearHoverTargets(board);

    var dropEl =
      event.target.closest('[data-dropzone="group"]') ||
      event.target.closest('[data-dropzone="waiting"]') ||
      event.target.closest('[data-dropzone="unpair"]');

    if (!dropEl) return;
    if (dropEl.dataset.dropzone === 'group' && dropEl.dataset.workingGroupId === dragState.sourceGroupId) return;
    if (dropEl.dataset.dropzone === 'waiting' &&
        (dropEl.dataset.targetEntryId === dragState.entryId || dropEl.dataset.role === dragState.role)) return;
    if (dropEl.dataset.dropzone === 'unpair' && !dragState.sourceGroupId) return;

    dropEl.dataset.dropHover = 'true';
  });

  document.addEventListener('drop', function (event) {
    var board = currentBoard();
    if (!dragState || !board || !board.contains(event.target)) return;

    event.preventDefault();
    var activeState = dragState;
    dragState = null;
    clearDragVisuals(board);

    var action = resolveDropAction(event.target, activeState, board);
    if (action) sendMutation(action.url, action.method, action.body);
  });

  document.addEventListener('dragend', function () {
    dragState = null;
    clearDragVisuals(currentBoard());
  });

  document.addEventListener('submit', function (event) {
    var board = currentBoard();
    if (!board || !board.contains(event.target)) return;

    var unpairForm = event.target.closest('form[data-working-groups-unpair-form]');
    if (unpairForm) {
      event.preventDefault();
      sendMutation(unpairForm.action, 'DELETE', null);
      return;
    }

    var pairForm = event.target.closest('form[data-working-groups-pair-form]');
    if (pairForm) {
      event.preventDefault();
      var invId = pairForm.querySelector('[name="invitation_id"]').value;
      var targetInvId = pairForm.querySelector('[name="target_invitation_id"]').value;
      sendMutation(pairForm.action, 'POST', { invitation_id: invId, target_invitation_id: targetInvId });
    }
  });

  document.addEventListener('workshop:attendance-updated', function () {
    pollLiveBoard(true);
  });

  document.addEventListener('DOMContentLoaded', initializeEtag);
  window.setInterval(function () { pollLiveBoard(false); }, POLL_INTERVAL_MS);
})();
