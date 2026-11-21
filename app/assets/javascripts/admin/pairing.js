// Declarative drag-and-drop pairing on the admin event page.
//
// Delegated at the document level so in-place board swaps keep working
// without re-binding listeners. Visual states are driven purely through
// data attributes (`data-dragging`, `data-drop-hover`, `data-dragging-slot`)
// styled in app/assets/stylesheets/partials/_pairing.scss.
(function () {
  var dragState = null;

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

  function showError(board, message) {
    if (!board) return;
    var alertEl = board.querySelector('[data-pairing-error]');
    if (!alertEl) return;
    alertEl.textContent = message;
    alertEl.classList.remove('d-none');
  }

  // Pure target resolver: maps a DOM event target + active drag state to a
  // declarative action descriptor.
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

  function applyAction(board, action) {
    if (action.kind === 'noop') return;

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
        var wrapper = document.createElement('div');
        wrapper.innerHTML = html.trim();
        var nextBoard = wrapper.querySelector('.pairing-board');
        if (nextBoard && board.parentNode) {
          board.parentNode.replaceChild(nextBoard, board);
        } else {
          window.location.reload();
        }
      })
      .catch(function (err) {
        delete board.dataset.loading;
        showError(board, err.message || 'Unable to update pairing right now.');
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

    // Clear state synchronously before async network work so duplicate drop
    // events cannot replay the same transition.
    var activeState = dragState;
    dragState = null;
    clearDragVisuals(board);

    var action = resolveAction(event.target, activeState, board);
    applyAction(board, action);
  });

  document.addEventListener('dragend', function () {
    dragState = null;
    clearDragVisuals(currentBoard());
  });

  // Declarative non-drag fallback: "Move into a new solo group" icon button
  // updates the board in-place via the same endpoint without scroll jump.
  document.addEventListener('submit', function (event) {
    var form = event.target.closest('form[data-pairing-split-form]');
    var board = currentBoard();
    if (!form || !board || !board.contains(form)) return;

    event.preventDefault();
    applyAction(board, {
      kind: 'unpair',
      url: form.action,
      method: 'DELETE',
      body: null
    });
  });
})();
