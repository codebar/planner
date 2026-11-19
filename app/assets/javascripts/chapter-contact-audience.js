/* global $ */

$(() => {
  const selector = '[data-chapter-contact-audience]';
  let countRequest;

  function updateAudienceFields() {
    const $form = $(this).closest('form');
    const audience = $(this).val();
    const fieldAudiences = JSON.parse(this.getAttribute('data-contact-audience-field-map'));

    $form.find('[data-contact-audience-fields]').each(function () {
      const field = this.getAttribute('data-contact-audience-fields');
      $(this).toggleClass('d-none', !fieldAudiences[field]?.includes(audience));
    });
  }

  function updateRecipientCount() {
    const form = this.closest('form');
    const count = form.querySelector('[data-chapter-contact-recipient-count]');
    const url = new URL(count.dataset.url, window.location.origin);
    const params = new URLSearchParams();
    const fields = ['audience', 'event_id', 'rsvp_status', 'activity_months'];

    fields.forEach((field) => {
      const input = form.elements.namedItem(`chapter_contact[${field}]`);
      if (input?.value) params.set(`chapter_contact[${field}]`, input.value);
    });
    form.querySelectorAll('input[name="chapter_contact[member_ids][]"]:checked').forEach((input) => {
      params.append('chapter_contact[member_ids][]', input.value);
    });
    url.search = params.toString();

    countRequest?.abort();
    countRequest = new AbortController();

    fetch(url, { headers: { Accept: 'application/json' }, signal: countRequest.signal })
      .then((response) => {
        if (!response.ok) throw new Error(`Recipient count request failed: ${response.status}`);
        return response.json();
      })
      .then(({ count: recipientCount }) => {
        count.textContent = `${recipientCount} ${recipientCount === 1 ? 'recipient' : 'recipients'}`;
      })
      .catch((error) => {
        if (error.name === 'AbortError') return;
        count.textContent = 'Unable to update recipient count.';
        console.error(error);
      });
  }

  $(document).on('change', selector, updateAudienceFields);
  $(document).on('change', '[data-recipient-count-filter]', updateRecipientCount);
  $(selector).each(updateAudienceFields);
});
