// "Add to all" option at the top of the chapters dropdown on the admin event
// form. Selects every chapter so organisers don't have to pick each one.
// Chosen only renders <option>s, so the row is injected into its dropdown.

/* global $ */

$(() => {
  const $chapters = $("#event_chapter_ids");

  $chapters.on("chosen:ready", () => {
    const $addAll = $('<div class="add-all-chapters">Add to all</div>');
    $chapters.next(".chosen-container").find(".chosen-drop").prepend($addAll);

    // mousedown fires before Chosen's blur handling closes the dropdown;
    // stopPropagation keeps Chosen's container handler from reopening it
    $addAll.on("mousedown", (event) => {
      event.preventDefault();
      event.stopPropagation();
      $chapters.find("option").prop("selected", true);
      $chapters.trigger("change").trigger("chosen:updated").trigger("chosen:close");
    });
  });
});
