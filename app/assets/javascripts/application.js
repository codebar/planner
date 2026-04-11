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
//= require popper
//= require bootstrap
//= require rails-ujs
//= require activestorage
//= require chosen.jquery
//= require 'jsimple-star-rating.min.js'
//= require pickadate/picker
//= require pickadate/picker.date
//= require pickadate/picker.time
//= require subscriptions-toggle
//= require invitations
//= require dietary-restrictions
//= require cocoon
//= require font_awesome5
//= require how-you-found-us

$(function() {
  $("body").removeClass("no-js");

  $('#event_local_date, #meeting_local_date, #workshop_local_date, #workshop_rsvp_open_local_date').pickadate({
    format: 'dd/mm/yyyy'
  });
  $('#announcement_expires_at, #ban_expires_at').pickadate();
  $(
    "#meeting_local_time, #meeting_local_end_time, #event_local_time, #event_local_end_time, #workshop_local_time, #workshop_local_end_time, #workshop_rsvp_open_local_time"
  ).pickatime({
    format: "HH:i",
  });

  // TomSelect for admin member lookup
  if ($('#member_lookup_id').length) {
    new TomSelect('#member_lookup_id', {
      placeholder: 'Type to search members...',
      valueField: 'id',
      labelField: 'full_name',
      searchField: ['full_name', 'email'],
      create: false,
      loadThrottle: 300,
      shouldLoad: function(query) {
        return query.length >= 3;
      },
      load: function(query, callback) {
        fetch('/admin/members/search?q=' + encodeURIComponent(query))
          .then(response => response.json())
          .then(json => callback(json))
          .catch(() => callback());
      },
      render: {
        option: function(item, escape) {
          return '<div>' + escape(item.full_name) + ' <small class="text-muted">' + escape(item.email) + '</small></div>';
        }
      }
    });

    $('#member_lookup_id').on('change', function() {
      $('#view_profile').attr('href', '/admin/members/' + $(this).val());
    });
  }

  // Chosen for all other selects (exclude #member_lookup_id)
  // Chosen hides inputs and selects, which becomes problematic when they are
  // required: browser validation doesn't get shown to the user.
  // This fix places "the original input behind the Chosen input, matching the
  // height and width so that the warning appears in the correct position."
  // https://github.com/harvesthq/chosen/issues/515#issuecomment-474588057
  $('select').not('#member_lookup_id').on('chosen:ready', function () {
    var height = $(this).next('.chosen-container').height();
    var width = $(this).next('.chosen-container').width();

    $(this).css({
      position: 'absolute',
      height: height,
      width: width,
      opacity: 0
    }).show();
  });

  $('select').not('#member_lookup_id').chosen({
    allow_single_deselect: true,
    no_results_text: 'No results matched'
  });

  $('[data-bs-toggle="tooltip"]').tooltip();
});
