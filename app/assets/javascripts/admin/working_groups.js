// Declarative working groups ("Pairings") board: drag-and-drop *:* grouping,
// unlink & undo-check-in actions, and 15s ETag re-render of check-ins + pairings.
(function () {
  var dragState = null;
  var requestInFlight = false;
  var lastSyncEtag = null;
  var syncVersion = 0;
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

  function isPickerOpen() {
    return !!document.querySelector('[data-group-picker-panel]:not(.d-none)');
  }

  function boardParticipants(board) {
    if (!board || !board.dataset.boardParticipants) return [];
    try {
      return JSON.parse(board.dataset.boardParticipants);
    } catch (_e) {
      return [];
    }
  }

  function closeAllPickers() {
    document.querySelectorAll('[data-group-picker-panel]:not(.d-none)').forEach(function (panel) {
      panel.classList.add('d-none');
      var container = panel.closest('[data-group-picker]');
      var toggle = container && container.querySelector('[data-group-picker-toggle]');
      if (toggle) toggle.setAttribute('aria-expanded', 'false');
    });
  }

  function filterPickerCandidates(participants, container, query) {
    var targetGroupId = container.dataset.targetGroupId ? parseInt(container.dataset.targetGroupId, 10) : null;
    var targetEntryId = container.dataset.targetEntryId ? parseInt(container.dataset.targetEntryId, 10) : null;
    var q = (query || '').trim().toLowerCase();

    return participants.filter(function (p) {
      if (targetGroupId !== null && p.group_id === targetGroupId) return false;
      if (targetEntryId !== null && p.entry_id === targetEntryId) return false;
      if (!q) return true;

      var haystack = [p.name, p.role, p.tutorial, p.note, p.group_summary, p.group_id ? 'paired' : 'unpaired']
        .filter(Boolean)
        .join(' ')
        .toLowerCase();
      return haystack.indexOf(q) !== -1;
    });
  }

  function buildPickerOptionEl(person, isSelected) {
    var btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'working-group-picker__option';
    btn.setAttribute('role', 'option');
    btn.setAttribute('aria-selected', isSelected ? 'true' : 'false');
    btn.dataset.pickerEntryId = String(person.entry_id);

    var header = document.createElement('div');
    header.className = 'd-flex flex-wrap align-items-center gap-2';

    var nameEl = document.createElement('strong');
    nameEl.className = 'small text-dark';
    nameEl.textContent = person.name;
    header.appendChild(nameEl);

    var roleBadge = document.createElement('span');
    roleBadge.className = 'badge rounded-pill ' + (person.role === 'Coach' ? 'bg-info text-dark' : 'bg-light text-dark border');
    roleBadge.textContent = person.role;
    header.appendChild(roleBadge);

    var statusBadge = document.createElement('span');
    if (person.group_id) {
      statusBadge.className = 'badge rounded-pill bg-secondary bg-opacity-10 text-secondary';
      statusBadge.textContent = person.group_summary ? ('Paired with ' + person.group_summary) : 'In another group';
    } else {
      statusBadge.className = 'badge rounded-pill working-groups-badge--waiting';
      statusBadge.textContent = 'Unpaired';
    }
    header.appendChild(statusBadge);
    btn.appendChild(header);

    var details = [];
    if (person.tutorial) details.push('Tutorial: ' + person.tutorial);
    if (person.note) details.push(person.note);
    if (details.length > 0) {
      var meta = document.createElement('div');
      meta.className = 'working-group-picker__option-meta mt-1';
      meta.textContent = details.join(' — ');
      btn.appendChild(meta);
    }

    return btn;
  }

  function renderPickerOptions(container, query) {
    var board = currentBoard();
    var listEl = container && container.querySelector('[data-group-picker-list]');
    if (!board || !listEl) return;

    var candidates = filterPickerCandidates(boardParticipants(board), container, query);
    listEl.innerHTML = '';

    if (candidates.length === 0) {
      var empty = document.createElement('div');
      empty.className = 'working-group-picker__empty';
      empty.textContent = 'No matching checked-in attendees.';
      listEl.appendChild(empty);
      return;
    }

    candidates.forEach(function (person, index) {
      listEl.appendChild(buildPickerOptionEl(person, index === 0));
    });
  }

  function selectPickerOption(container, entryId) {
    var board = currentBoard();
    if (!board || !entryId) return;

    var body = { invitation_id: entryId };
    if (container.dataset.targetGroupId) {
      body.target_group_id = container.dataset.targetGroupId;
    } else if (container.dataset.targetEntryId) {
      body.target_invitation_id = container.dataset.targetEntryId;
    } else {
      return;
    }

    closeAllPickers();
    sendMutation(board.dataset.assignUrl, 'POST', body);
  }

  function movePickerSelection(panel, delta) {
    var options = Array.from(panel.querySelectorAll('.working-group-picker__option'));
    if (options.length === 0) return;

    var currentIndex = options.findIndex(function (opt) { return opt.getAttribute('aria-selected') === 'true'; });
    var nextIndex = currentIndex === -1 ? 0 : (currentIndex + delta + options.length) % options.length;

    options.forEach(function (opt, idx) {
      opt.setAttribute('aria-selected', idx === nextIndex ? 'true' : 'false');
    });
    if (options[nextIndex] && options[nextIndex].scrollIntoView) {
      options[nextIndex].scrollIntoView({ block: 'nearest' });
    }
  }

  function pollLiveBoard(force, boardOnly) {
    var board = currentBoard();
    if (!board || requestInFlight || (dragState && !force) || (document.hidden && !force) || (isPickerOpen() && !force)) return;

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
    if (dropEl.dataset.dropzone === 'waiting' && dropEl.dataset.targetEntryId === dragState.entryId) return;
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

  document.addEventListener('click', function (event) {
    var toggle = event.target.closest && event.target.closest('[data-group-picker-toggle]');
    if (toggle) {
      event.preventDefault();
      var container = toggle.closest('[data-group-picker]');
      var panel = container && container.querySelector('[data-group-picker-panel]');
      if (!panel) return;

      var wasOpen = !panel.classList.contains('d-none');
      closeAllPickers();
      if (!wasOpen) {
        panel.classList.remove('d-none');
        toggle.setAttribute('aria-expanded', 'true');
        var search = panel.querySelector('[data-group-picker-search]');
        if (search) search.value = '';
        renderPickerOptions(container, '');
        if (search) search.focus();
      }
      return;
    }

    var option = event.target.closest && event.target.closest('.working-group-picker__option');
    if (option) {
      event.preventDefault();
      var pickerContainer = option.closest('[data-group-picker]');
      selectPickerOption(pickerContainer, option.dataset.pickerEntryId);
      return;
    }

    if (!event.target.closest || !event.target.closest('[data-group-picker]')) {
      closeAllPickers();
    }
  });

  document.addEventListener('input', function (event) {
    var search = event.target.closest && event.target.closest('[data-group-picker-search]');
    if (!search) return;
    renderPickerOptions(search.closest('[data-group-picker]'), search.value);
  });

  document.addEventListener('keydown', function (event) {
    var panel = event.target.closest && event.target.closest('[data-group-picker-panel]');
    if (!panel) return;

    if (event.key === 'Escape') {
      event.preventDefault();
      closeAllPickers();
    } else if (event.key === 'ArrowDown') {
      event.preventDefault();
      movePickerSelection(panel, 1);
    } else if (event.key === 'ArrowUp') {
      event.preventDefault();
      movePickerSelection(panel, -1);
    } else if (event.key === 'Enter') {
      var selected =
        (event.target.closest && event.target.closest('.working-group-picker__option')) ||
        panel.querySelector('.working-group-picker__option[aria-selected="true"]');
      if (selected) {
        event.preventDefault();
        selectPickerOption(panel.closest('[data-group-picker]'), selected.dataset.pickerEntryId);
      }
    }
  });

  document.addEventListener('DOMContentLoaded', initializeEtag);
  document.addEventListener('visibilitychange', function () {
    if (!document.hidden) pollLiveBoard(false);
  });
  window.setInterval(function () { pollLiveBoard(false); }, POLL_INTERVAL_MS);
})();
