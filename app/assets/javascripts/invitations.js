$(document).ready(function() {
  $(document).on("ajax:success", "#invitations [data-remote]", function(e) {
    var xhr = e.detail[2];
    var $link = $(e.currentTarget);

    if ($link.hasClass('verify_attendance')) {
      var $row = $link.closest('.row.attendee');
      var rowId = $row.attr('id');
      $row.replaceWith(xhr.responseText);
      $(".row.attendee[id='" + rowId + "']").find('[data-bs-toggle="tooltip"]').tooltip();
    }
  });
});
