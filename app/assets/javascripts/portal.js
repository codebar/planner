'use strict';

$(document).ready(function(){
  function hideTabs(time) {
    $("#tabs-content").children().each(function() {
      $(this).hide(time);
    });
  }

  hideTabs(0);

  $("#tabs").children(':not(.active)').on("click", function() {
    $("#tabs").children(".active").removeClass("active");
    hideTabs(1000);
    $(this).addClass("active");
    $($(this).attr("href")).show(1000);
  });

  $("#tabs").children().first().click();
});
