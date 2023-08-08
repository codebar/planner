// Expand/collapse toggling for coach/student group subscriptions.
// Used in the new user signup flow, to stop too many options being
// presented.

/* global $ */

$(() =>
  $(".subscriptions .codebar-toggle").click(function (e) {
    const $section = $(e.target).closest(".subscriptions");
    const $container = $(".group-container", $section);
    const $icon = $(".codebar-toggle i", $section);
    $container.slideToggle(400, () => $container.toggleClass("codebar-collapsed"));
    $icon.toggleClass("fa-chevron-right fa-chevron-down");
  })
);
