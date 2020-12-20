function sponsorshipsLevelInputs(type) {
  if (type == "levelled") {
    $(".standard-sponsor-input").prop("disabled", true);
    $(".sponsor-levels").removeClass("hide");
    $(".levels-sponsor-input").prop("disabled", false);
  } else {
    $(".levels-sponsor-input").prop("disabled", true);
    $(".sponsor-levels").addClass("hide");
    $(".standard-sponsor-input").prop("disabled", false);
  }
}

$(document).ready(function() {

  $("input[type=radio][name=sponsorships-type]").change(function() {
    sponsorshipsLevelInputs($(this).val());
  });

  $("#sponsorships").on("click", "button.remove-in-db-sponsor-button", function() {
    var parent = $(this).closest(".sponsorship");
    var destroyInput = parent.find(".remove-sponsor-input");
    destroyInput.val(true);
    parent.addClass("hide");
  });

  $("#sponsorships").on("click", "button.remove-new-sponsor-button", function() {
    $(this).closest(".sponsorship").remove();
  });

  $("#sponsorships").on("newChild", function() {
    sponsorshipsLevelInputs($("input[type=radio][name=sponsorships-type]:checked").val());
    $('select').chosen(function() {
      allow_single_deselect: true
      no_results_text: 'No results matched'
    });
  })
});