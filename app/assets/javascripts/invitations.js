$(document).ready(function() {
  $(document).on("ajax:success", "a[data-remote]", function(e, data, status, xhr) {
    $("#invitations").html(xhr.responseText);

    $('select').chosen(function(){
      allow_single_deselect: true
      no_results_text: 'No results matched'
    });
    $(document).foundation();
  });
  $(document).on('change','#workshop_invitations ',function() {
    this.form.submit();
  })
});
