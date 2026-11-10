/* global $ */

$(() => {
  const selector = '[data-chapter-contact-audience]';

  function updateAudienceFields() {
    const $form = $(this).closest('form');
    const audience = $(this).val();
    const fieldAudiences = JSON.parse(this.getAttribute('data-contact-audience-field-map'));

    $form.find('[data-contact-audience-fields]').each(function () {
      const field = this.getAttribute('data-contact-audience-fields');
      $(this).toggleClass('d-none', !fieldAudiences[field]?.includes(audience));
    });
  }

  $(document).on('change', selector, updateAudienceFields);
  $(selector).each(updateAudienceFields);
});
