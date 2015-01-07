# Expand/collapse toggling for coach/student group subscriptions.
# Used in the new user signup flow, to stop too many options being
# presented.

$ ->
 $('.subscriptions .toggle').click (e) ->
   $section = $(e.target).closest '.subscriptions'
   $container = $ '.group-container', $section
   $icon = $ '.toggle i', $section
   $container.slideToggle 400, ->
     $container.toggleClass('collapsed')
   $icon.toggleClass('fa-chevron-right fa-chevron-down')
