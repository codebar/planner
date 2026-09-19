// Prefills the RSVP close time on the workshop form with the default
// (start time minus 3.5 hours). Only fills fields the organiser has left
// empty or that this script filled earlier — an already set or saved close
// time is never overwritten. The subtraction uses browser-local calendar
// minutes, which can differ from the server's absolute-seconds deadline
// across a DST transition inside the 3.5-hour window.
(function () {
  'use strict';

  var CLOSE_OFFSET_MINUTES = 210; // 3.5 hours
  var START_FIELDS = /^workshop\[local_(date|time)\]$/;
  var CLOSE_DATE = 'workshop[rsvp_close_local_date]';
  var CLOSE_TIME = 'workshop[rsvp_close_local_time]';

  function pad(value) {
    return String(value).padStart(2, '0');
  }

  function field(form, name) {
    return form.querySelector('[name="' + name + '"]');
  }

  function defaultCloseValues(startDate, startTime) {
    if (!startDate) return null;

    var start = new Date(startDate + 'T' + (startTime || '00:00'));
    if (isNaN(start.getTime())) return null;

    start.setMinutes(start.getMinutes() - CLOSE_OFFSET_MINUTES);

    return {
      date: start.getFullYear() + '-' + pad(start.getMonth() + 1) + '-' + pad(start.getDate()),
      time: pad(start.getHours()) + ':' + pad(start.getMinutes())
    };
  }

  function prefill(form) {
    var closeDate = field(form, CLOSE_DATE);
    var closeTime = field(form, CLOSE_TIME);
    if (!closeDate || !closeTime) return;

    var close = defaultCloseValues(field(form, 'workshop[local_date]').value,
                                   field(form, 'workshop[local_time]').value);
    if (!close) return;

    fillIfDefault(closeDate, close.date);
    fillIfDefault(closeTime, close.time);
  }

  // Fills empty fields and refreshes values this script previously filled,
  // so a corrected start time keeps its default close time. Values the
  // organiser typed or that were saved with the workshop are never touched.
  function fillIfDefault(field, value) {
    if (!field.value || field.value === field.dataset.rsvpPrefilled) {
      field.value = value;
      field.dataset.rsvpPrefilled = value;
    }
  }

  document.addEventListener('change', function (event) {
    var target = event.target;
    if (!target.name || !START_FIELDS.test(target.name)) return;

    var form = target.closest('form');
    if (form) prefill(form);
  });
})();
