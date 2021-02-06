$(document).ready(function() {
  $(document).on("ajax:success", "a[data-remote]", function(e, data, status, xhr) {
    var $invitations = $("#invitations");

    $invitations.html(xhr.responseText);

    $invitations.find('select').chosen(function () {
      allow_single_deselect: true
      no_results_text: 'No results matched'
    });

    $invitations.foundation('tooltip', 'reflow');
  });
  
  $(document).on('change','#workshop_invitations ',function() {
    this.form.submit();
  })
});
