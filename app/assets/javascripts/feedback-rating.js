// Progressively enhance a .rating container of radio buttons into clickable stars.

(function () {
  function initRating(container) {
    const radios = container.querySelectorAll('input[type="radio"]');
    const labels = container.querySelectorAll('label');

    if (radios.length === 0 || labels.length === 0) return;

    function updateVisuals(checkedValue) {
      labels.forEach(function (label, index) {
        label.classList.toggle('selected', index < checkedValue);
      });
    }

    function previewVisuals(previewValue) {
      labels.forEach(function (label, index) {
        label.classList.toggle('preview', index < previewValue);
      });
    }

    function restoreVisuals() {
      const checked = Array.from(radios).find(function (radio) { return radio.checked; });
      updateVisuals(checked ? parseInt(checked.value, 10) : 0);
      previewVisuals(0);
    }

    labels.forEach(function (label, index) {
      const radio = radios[index];

      label.addEventListener('click', function (event) {
        if (radio.checked) {
          event.preventDefault();
          radio.checked = false;
          updateVisuals(0);
        }
      });

      label.addEventListener('mouseenter', function () {
        previewVisuals(index + 1);
      });

      radio.addEventListener('change', function () {
        updateVisuals(index + 1);
      });
    });

    container.addEventListener('mouseleave', restoreVisuals);

    restoreVisuals();
  }

  function init() {
    document.querySelectorAll('.rating').forEach(initRating);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
