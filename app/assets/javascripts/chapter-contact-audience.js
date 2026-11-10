/* global $ */

$(() => {
  const selector = '[data-chapter-contact-audience]';
  const fieldAudiences = {
    custom_list: ['custom_list'],
    event_rsvp: ['event_rsvp'],
    activity_period: ['active_last_month', 'inactive_last_month']
  };

  function updateAudienceFields() {
    const $form = $(this).closest('form');
    const audience = $(this).val();

    $form.find('[data-contact-audience-fields]').each(function () {
      const field = this.getAttribute('data-contact-audience-fields');
      $(this).toggleClass('d-none', !fieldAudiences[field].includes(audience));
    });
  }

  $(document).on('change', selector, updateAudienceFields);
  $(selector).each(updateAudienceFields);
});
