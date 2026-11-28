// Declarative working groups ("Pairings") board: drag-and-drop *:* grouping,
// unlink & undo-check-in actions, and 15s ETag re-render of check-ins + pairings.
(function () {
  var dragState = null;
  var requestInFlight = false;
  var lastSyncEtag = null;
  var syncVersion = 0;
  var autoScrollVelocity = 0;
  var autoScrollFrameId = null;
  var autoScrollLastTime = null;
  var POLL_INTERVAL_MS = 15000;
  var SCROLL_TOP_ZONE_PX = 140;
  var SCROLL_BOTTOM_ZONE_PX = 100;
  var SCROLL_MIN_PX_PER_SEC = 260;
  var SCROLL_MAX_PX_PER_SEC = 960;
  var BOARD_TOP_MARGIN_PX = 110;
  var BOARD_BOTTOM_MARGIN_PX = 24;

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

  function computeAutoScrollVelocity(clientY, viewportHeight) {
    if (clientY < SCROLL_TOP_ZONE_PX) {
      var upRatio = Math.min(1, Math.max(0, (SCROLL_TOP_ZONE_PX - clientY) / SCROLL_TOP_ZONE_PX));
      return -(SCROLL_MIN_PX_PER_SEC + upRatio * (SCROLL_MAX_PX_PER_SEC - SCROLL_MIN_PX_PER_SEC));
    }
    var bottomThreshold = viewportHeight - SCROLL_BOTTOM_ZONE_PX;
    if (clientY > bottomThreshold) {
      var downRatio = Math.min(1, Math.max(0, (clientY - bottomThreshold) / SCROLL_BOTTOM_ZONE_PX));
      return SCROLL_MIN_PX_PER_SEC + downRatio * (SCROLL_MAX_PX_PER_SEC - SCROLL_MIN_PX_PER_SEC);
    }
    return 0;
  }

  function stopAutoScroll() {
    autoScrollVelocity = 0;
    autoScrollLastTime = null;
    if (autoScrollFrameId !== null) {
      window.cancelAnimationFrame(autoScrollFrameId);
      autoScrollFrameId = null;
    }
  }

  function stepAutoScroll(now) {
    autoScrollFrameId = null;
    var board = currentBoard();
    if (!dragState || !board || autoScrollVelocity === 0) {
      autoScrollLastTime = null;
      return;
    }

    var rect = board.getBoundingClientRect();
    if (autoScrollVelocity < 0 && rect.top >= BOARD_TOP_MARGIN_PX) {
      stopAutoScroll();
      return;
    }
    if (autoScrollVelocity > 0 && rect.bottom <= window.innerHeight - BOARD_BOTTOM_MARGIN_PX) {
      stopAutoScroll();
      return;
    }

    var dtSec = autoScrollLastTime === null ? 0.016 : Math.min(0.05, (now - autoScrollLastTime) / 1000);
    autoScrollLastTime = now;
    window.scrollBy(0, Math.round(autoScrollVelocity * dtSec));
    autoScrollFrameId = window.requestAnimationFrame(stepAutoScroll);
  }

  function updateAutoScroll(event) {
    if (event.clientX === 0 && event.clientY === 0) return;
    autoScrollVelocity = computeAutoScrollVelocity(event.clientY, window.innerHeight);
    if (autoScrollVelocity === 0) {
      stopAutoScroll();
    } else if (autoScrollFrameId === null) {
      autoScrollFrameId = window.requestAnimationFrame(stepAutoScroll);
    }
  }

  function clearDragVisuals(board) {
    stopAutoScroll();
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

  function initTooltips(root) {
    if (!root || !window.bootstrap || !window.bootstrap.Tooltip) return;
    root.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(function (el) {
      new window.bootstrap.Tooltip(el);
    });
  }

  function updateSignedInBadges(counts) {
    if (!counts) return;
    var root = document.querySelector('[data-invitation-management]');
    if (!root) return;
    var badges = root.querySelectorAll('.badge.bg-success');
    if (badges[0]) badges[0].textContent = counts.checked_in_students + ' students have been signed in';
    if (badges[1]) badges[1].textContent = counts.checked_in_coaches + ' coaches have been signed in';
  }

  function replaceInvitationsHtml(html) {
    var container = document.querySelector('[data-invitation-management]');
    if (!container || !html) return;
    container.innerHTML = html;
    initTooltips(container);
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
    initTooltips(nextBoard);

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

    syncVersion += 1;
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
        replaceInvitationsHtml(result.data.invitations_html);
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

  function sendUndoCheckIn(form) {
    var board = currentBoard();
    if (!board || requestInFlight) return;

    syncVersion += 1;
    var invId = form.dataset.invitationId;
    requestInFlight = true;
    board.dataset.loading = 'true';

    fetch(form.action, {
      method: 'PUT',
      headers: {
        'X-CSRF-Token': csrfToken(),
        'X-Requested-With': 'XMLHttpRequest',
        'Accept': 'text/html'
      }
    })
      .then(function (response) {
        if (!response.ok) throw new Error('Unable to undo check-in right now.');
        return response.text();
      })
      .then(function (rowHtml) {
        var row = document.getElementById('attendee-row-' + invId);
        if (row && rowHtml) {
          var tmp = document.createElement('div');
          tmp.innerHTML = rowHtml.trim();
          if (tmp.firstElementChild) row.replaceWith(tmp.firstElementChild);
        }
        requestInFlight = false;
        pollLiveBoard(true);
      })
      .catch(function (err) {
        requestInFlight = false;
        var liveBoard = currentBoard();
        if (liveBoard) delete liveBoard.dataset.loading;
        showBoardError(err.message);
      });
  }

  function pollLiveBoard(force, boardOnly) {
    var board = currentBoard();
    if (!board || requestInFlight || (dragState && !force) || (document.hidden && !force)) return;

    initializeEtag();
    var version = ++syncVersion;
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
        if (!result || version !== syncVersion || requestInFlight || dragState) return;
        if (result.etag && !boardOnly) lastSyncEtag = result.etag;
        replaceBoardHtml(result.data.board_html, true);
        if (boardOnly) {
          updateSignedInBadges(result.data.counts);
        } else {
          replaceInvitationsHtml(result.data.invitations_html);
        }
      })
      .catch(function () {
        // Silent retry on transient network hiccups during background sync
      })
      .finally(function () {
        var liveBoard = currentBoard();
        if (liveBoard && !requestInFlight) delete liveBoard.dataset.loading;
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
    if (waitingZone && waitingZone.dataset.targetEntryId !== activeState.entryId) {
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
    if (!dragState || !board) return;

    updateAutoScroll(event);

    if (!board.contains(event.target)) {
      if (autoScrollVelocity !== 0) {
        event.preventDefault();
        event.dataTransfer.dropEffect = 'move';
      }
      clearHoverTargets(board);
      return;
    }

    event.preventDefault();
    event.dataTransfer.dropEffect = 'move';
    clearHoverTargets(board);

    var dropEl =
      event.target.closest('[data-dropzone="group"]') ||
      event.target.closest('[data-dropzone="waiting"]') ||
      event.target.closest('[data-dropzone="unpair"]');

    if (!dropEl) return;
    if (dropEl.dataset.dropzone === 'group' && dropEl.dataset.workingGroupId === dragState.sourceGroupId) return;
    if (dropEl.dataset.dropzone === 'waiting' && dropEl.dataset.targetEntryId === dragState.entryId) return;
    if (dropEl.dataset.dropzone === 'unpair' && !dragState.sourceGroupId) return;

    dropEl.dataset.dropHover = 'true';
  });

  document.addEventListener('drop', function (event) {
    stopAutoScroll();
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

  window.addEventListener('blur', stopAutoScroll);

  document.addEventListener('submit', function (event) {
    var board = currentBoard();
    if (!board || !board.contains(event.target)) return;

    var unpairForm = event.target.closest('form[data-working-groups-unpair-form]');
    if (unpairForm) {
      event.preventDefault();
      sendMutation(unpairForm.action, 'DELETE', null);
      return;
    }

    var uncheckForm = event.target.closest('form[data-working-groups-uncheck-form]');
    if (uncheckForm) {
      event.preventDefault();
      sendUndoCheckIn(uncheckForm);
    }
  });

  document.addEventListener('ajax:beforeSend', function (event) {
    var target = event.target;
    if (target && target.closest && target.closest('.verify_attendance')) {
      syncVersion += 1;
    }
  });

  document.addEventListener('ajax:success', function (event) {
    var target = event.target;
    if (target && target.closest && target.closest('.verify_attendance')) {
      pollLiveBoard(true, true);
    }
  });

  document.addEventListener('DOMContentLoaded', initializeEtag);
  document.addEventListener('visibilitychange', function () {
    if (!document.hidden) pollLiveBoard(false);
  });
  window.setInterval(function () { pollLiveBoard(false); }, POLL_INTERVAL_MS);
})();
