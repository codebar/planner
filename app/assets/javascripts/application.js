// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require autocomplete-rails
//= require chosen-jquery
//= require foundation
//= require 'jsimple-star-rating.min.js'
//= require pickadate/picker
//= require pickadate/picker.date
//= require pickadate/picker.time
//= require analytics
//= require gosquared
//= require subscriptions-toggle
//= require invitations

$(function(){
  $(document).foundation();
  $('#workshop_local_date, #event_date_and_time, #workshop_rsvp_open_local_date').pickadate({
    format: 'dd/mm/yyyy'
  });

  $('#announcement_expires_at, #ban_expires_at').pickadate();
  $('#workshop_local_time, #event_begins_at, #event_ends_at, #workshop_rsvp_open_local_time').pickatime({
    format: 'HH:i'
  });

  $('body').removeClass('no-js');

  $('select').chosen(function(){
    allow_single_deselect: true
    no_results_text: 'No results matched'
  });

  $('#member_lookup_id').chosen().change(function(e) {
    $('#view_profile').attr('href', '/admin/members/' + $(this).val())
  });
  
  // Prevent tabbing through side menu links when menu is hidden.
  // This somewhat hacky approach is required because Foundation doesn't
  // allow us to modify the functionality directly :(
  var $menuContainer = $('.off-canvas-wrap');
  var $menuLinks = $('.left-off-canvas-menu').find('a');
  var toggleMenuLinkTabindex = function() {
    // Use rAF to delay the call a frame, to wait until the class has been updated:
    window.requestAnimationFrame(function(){
      var menuIsVisible = $menuContainer.hasClass('move-right');
      $menuLinks.attr('tabindex', menuIsVisible ? 0 : -1);
    });
  };
  toggleMenuLinkTabindex();
  $(document).on('click', toggleMenuLinkTabindex);
});
