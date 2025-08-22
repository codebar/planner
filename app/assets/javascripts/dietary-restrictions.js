$(document).ready(function() {
  $('#member_dietary_restrictions_other').on('change', function () {
    const $el = $('#member_other_dietary_restrictions').parent();
    if ($el.hasClass('d-none')) {
      $el.removeClass('d-none').hide().slideDown(50);
    } else {
      $el.slideUp(50, () => $el.addClass('d-none'));
    }
  });
});
