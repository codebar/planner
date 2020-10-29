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
//= require popper
//= require bootstrap
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
//= require cocoon

$(function(){
  $(document).foundation();
  $('#meeting_local_date, #workshop_local_date, #event_date_and_time, #workshop_rsvp_open_local_date').pickadate({
    format: 'dd/mm/yyyy'
  });

  $('#announcement_expires_at, #ban_expires_at').pickadate();
  $('#meeting_local_time, #workshop_local_time, #workshop_local_end_time, #event_begins_at, #event_ends_at, #meeting_local_end_time, #workshop_rsvp_open_local_time').pickatime({
    format: 'HH:i'
  });

  $('#job_expiry_date').pickadate({
    format: 'dd/mm/yyyy'
  });

  $('body').removeClass('no-js');

  $('select').chosen(function(){
    allow_single_deselect: true
    no_results_text: 'No results matched'
  });

  $('#member_lookup_id').chosen().change(function(e) {
    $('#view_profile').attr('href', '/admin/members/' + $(this).val())
  });
});
