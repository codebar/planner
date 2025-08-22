$(document).ready(function() {
  $('#member_dietary_restrictions_other').on('change', function () {
    const $elementToToggle = $('#member_other_dietary_restrictions').parent();
    if ($elementToToggle.hasClass('d-none')) {
      $elementToToggle.removeClass('d-none').hide().slideDown(50);
    } else {
      $elementToToggle.slideUp(50, () => $elementToToggle.addClass('d-none'));
    }
  });
});
