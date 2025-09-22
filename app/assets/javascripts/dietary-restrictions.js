$(document).ready(function() {
  $('#member_dietary_restrictions_other').on('change', function () {
    const $otherDietaryRestrictions = $('#member_other_dietary_restrictions');
    const $elementToToggle = $otherDietaryRestrictions.parent();
    if ($elementToToggle.hasClass('d-none')) {
      $elementToToggle.removeClass('d-none').hide().slideDown(50);
      $otherDietaryRestrictions.focus();
    } else {
      $elementToToggle.slideUp(50, () => $elementToToggle.addClass('d-none'));
    }
  });
});
