// Inline organiser editor for workshop attendee notes on the Pairings board.
(function () {
  function csrfToken() {
    var meta = document.querySelector('meta[name="csrf-token"]');
    return meta ? meta.content : '';
  }

  function initTooltips(root) {
    if (!root || !window.bootstrap || !window.bootstrap.Tooltip) return;
    root.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(function (el) {
      new window.bootstrap.Tooltip(el);
    });
  }

  function closeForm(form) {
    if (!form) return;
    form.classList.add('d-none');

    var container = form.closest('[data-invitation-note-container]');
    if (container) {
      var trigger = container.querySelector('[data-edit-invitation-note]');
      if (trigger) trigger.classList.remove('d-none');
    }

    var slot = form.closest('.working-group-slot');
    if (slot) {
      slot.setAttribute('draggable', 'true');
      delete slot.dataset.editingNote;
    }

    var errorEl = form.querySelector('[data-invitation-note-error]');
    if (errorEl) {
      errorEl.textContent = '';
      errorEl.classList.add('d-none');
    }
  }

  function openForm(trigger) {
    var container = trigger.closest('[data-invitation-note-container]');
    var form = container && container.querySelector('[data-invitation-note-form]');
    if (!form) return;

    document.querySelectorAll('[data-invitation-note-form]:not(.d-none)').forEach(closeForm);

    trigger.classList.add('d-none');
    form.classList.remove('d-none');

    var slot = form.closest('.working-group-slot');
    if (slot) {
      slot.setAttribute('draggable', 'false');
      slot.dataset.editingNote = 'true';
    }

    var input = form.querySelector('input[type="text"]');
    if (input) {
      input.focus();
      input.select();
    }
  }

  function showFormError(form, message) {
    var errorEl = form.querySelector('[data-invitation-note-error]');
    if (!errorEl) return;
    errorEl.textContent = message;
    errorEl.classList.remove('d-none');
  }

  function submitForm(form) {
    var submitBtn = form.querySelector('button[type="submit"]');
    var invitationId = form.dataset.invitationId;
    if (submitBtn) submitBtn.disabled = true;

    fetch(form.action, {
      method: 'PUT',
      headers: {
        'X-CSRF-Token': csrfToken(),
        'X-Requested-With': 'XMLHttpRequest',
        'Accept': 'text/html'
      },
      body: new FormData(form)
    })
      .then(function (response) {
        return response.text().then(function (text) {
          if (!response.ok) {
            throw new Error(response.status === 422 && text ? text : 'Could not save note. Please try again.');
          }
          return text;
        });
      })
      .then(function (rowHtml) {
        var row = document.getElementById('attendee-row-' + invitationId);
        if (row && rowHtml) {
          var tmp = document.createElement('div');
          tmp.innerHTML = rowHtml.trim();
          var nextRow = tmp.firstElementChild;
          if (nextRow) {
            row.replaceWith(nextRow);
            initTooltips(nextRow);
          }
        }
        closeForm(form);
        document.dispatchEvent(new CustomEvent('invitation-note:updated', { detail: { invitationId: invitationId } }));
      })
      .catch(function (err) {
        showFormError(form, err.message);
      })
      .finally(function () {
        if (submitBtn) submitBtn.disabled = false;
      });
  }

  document.addEventListener('click', function (event) {
    var editBtn = event.target.closest('[data-edit-invitation-note]');
    if (editBtn) {
      event.preventDefault();
      openForm(editBtn);
      return;
    }

    var cancelBtn = event.target.closest('[data-cancel-invitation-note]');
    if (cancelBtn) {
      event.preventDefault();
      closeForm(cancelBtn.closest('[data-invitation-note-form]'));
    }
  });

  document.addEventListener('keydown', function (event) {
    if (event.key !== 'Escape') return;
    var activeForm = event.target.closest && event.target.closest('[data-invitation-note-form]');
    if (activeForm) closeForm(activeForm);
  });

  document.addEventListener('submit', function (event) {
    var form = event.target.closest && event.target.closest('[data-invitation-note-form]');
    if (!form) return;
    event.preventDefault();
    submitForm(form);
  });
})();
