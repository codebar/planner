$(document).ready(function() {
  const $otherRadioButton = $('#member_how_you_found_us_other');
  const $otherReason = $('#member_how_you_found_us_other_reason');
  const $elementToToggle = $otherReason.parent();

  function toggleOtherReason() {
    if ($otherRadioButton.is(':checked')) {
      $elementToToggle.removeClass('d-none').hide().slideDown(50);
      $otherReason.prop('disabled', false).focus(); // Optional — disabling is not needed
    } else {
      $elementToToggle.slideUp(50, function() {
        $elementToToggle.addClass('d-none');
        $otherReason.val('');
      });
    }
  }

  toggleOtherReason();
  $('input[name="member[how_you_found_us]"]').on('change', toggleOtherReason);
});