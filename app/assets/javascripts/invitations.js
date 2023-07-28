$(document).ready(function() {
  $(document).on("ajax:success", "#invitations [data-remote]", function(e) {
    var xhr = e.detail[2];
    var $invitations = $("#invitations");

    $invitations.html(xhr.responseText);

    $invitations.find('select').chosen(function () {
      allow_single_deselect: true
      no_results_text: 'No results matched'
    });
  });
  
  $(document).on('change','#workshop_invitations ',function() {
    // Rails 5.1 has dropped jquery as a dependency and therefore has replaced jquery-ujs with a complete rewritten rails-ujs.
    // See:
    // + http://weblog.rubyonrails.org/2017/4/27/Rails-5-1-final/
    // + https://stackoverflow.com/questions/12683524/with-rails-ujs-how-to-submit-a-remote-form-from-a-function
    // As such, you'll have to trigger the proper CustomEvent object in rails-ujs.
    //
    // NOTE: Without this, if we simply call this.form.submit() then we get a 500 HTTP status code and the following logs:
    // Can't verify CSRF token authenticity.
    // ActionController::InvalidAuthenticityToken
    Rails.fire(this.form, 'submit');
  })
});
