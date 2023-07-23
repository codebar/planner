$(document).ready(function() {
  $(document).on("ajax:success", "#invitations [data-remote]", function(e) {
    var xhr = e.detail.xhr;
    var $invitations = $("#invitations");

    $invitations.html(xhr.responseText);

    $invitations.find('select').chosen(function () {
      allow_single_deselect: true
      no_results_text: 'No results matched'
    });
  });
  
  $(document).on('change','#workshop_invitations ',function() {
    this.form.submit();
    // https://stackoverflow.com/questions/12683524/with-rails-ujs-how-to-submit-a-remote-form-from-a-function
    Rails.fire(this.form, 'submit');
  })
});
