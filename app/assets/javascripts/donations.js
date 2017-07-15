$(function() {
  var handler = StripeCheckout.configure({
   key: stripePublishableKey,
   image: "https://avatars1.githubusercontent.com/u/5642384?v=3&s=300",
   currency: 'GBP',
   token: function(token) {
     var name = $('#donation_name').val();
     var amount = $('#donation_amount').val();
     $.ajax({
       type: "POST",
       url: '/donations',
       data: { amount: amount*100, name: name, data: token }
     }).done(function(response) {
       $('.donation-container').html(response);
     }).fail(function(xhr, status,  e){
       $('.message').html("Your transaction has not been succesful. Please try again.");
     });
   }
  });

  $('#donate').on('click', function(e) {
   var amount = $('#donation_amount').val();
   if (!$.isNumeric(amount)) {
     $('.message').html("You have not entered a valid amount.");
     return;
   }

   $('.message').html("");

   handler.open({
     name: 'codebar',
     description: 'Donation of £' + amount,
     amount: amount*100
   });
   e.preventDefault();
  });

  $(window).on('popstate', function() {
    handler.close();
  });
});
