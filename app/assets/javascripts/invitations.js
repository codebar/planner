$(document).ready(function() {
  function disposeTooltips(root) {
    if (!root || !window.bootstrap || !window.bootstrap.Tooltip) return;
    root.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(function(el) {
      var instance = window.bootstrap.Tooltip.getInstance(el);
      if (instance) instance.dispose();
    });
  }

  function initTooltips(root) {
    if (!root || !window.bootstrap || !window.bootstrap.Tooltip) return;
    root.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(function(el) {
      new window.bootstrap.Tooltip(el);
    });
  }

  function showInvitationError(message) {
    var container = document.querySelector('[data-invitation-management]');
    if (!container) return;

    container.querySelectorAll('[data-invitation-management-feedback]').forEach(function(el) {
      el.remove();
    });

    var alert = document.createElement('div');
    alert.className = 'alert alert-danger alert-dismissible fade show shadow-sm invitation-management-feedback';
    alert.setAttribute('role', 'alert');
    alert.setAttribute('data-invitation-management-feedback', 'true');
    alert.textContent = message;

    var closeBtn = document.createElement('button');
    closeBtn.type = 'button';
    closeBtn.className = 'btn-close';
    closeBtn.setAttribute('data-bs-dismiss', 'alert');
    closeBtn.setAttribute('aria-label', 'Close');
    alert.appendChild(closeBtn);

    container.prepend(alert);
  }

  $(document).on("ajax:success", "#invitations [data-remote]", function(e) {
    var xhr = e.detail[2];
    var $link = $(e.currentTarget);

    if ($link.hasClass('verify_attendance')) {
      var $row = $link.closest('.row.attendee');
      var rowId = $row.attr('id');
      disposeTooltips($row[0]);
      $row.replaceWith(xhr.responseText);
      initTooltips(document.getElementById(rowId));
    } else if ($link.is('.waiting_list, .waiting_list_remove, .cancel_attendance')) {
      var container = document.querySelector('[data-invitation-management]');
      if (!container) return;
      disposeTooltips(container);
      container.innerHTML = xhr.responseText;
      initTooltips(container);
    }
  });

  $(document).on("ajax:error", "#invitations [data-remote]", function() {
    showInvitationError('Could not update attendance. Please try again.');
  });
});
