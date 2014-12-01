


// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("stripe", function(request, response) {

var Stripe = require('stripe');
Stripe.initialize('sk_test_wmuSPJ1EnPYWsGXejdHC9Aj5')

Stripe.Charges.create({
  amount: 100 * 10, // $10 expressed in cents
  currency: "usd",
  card: "tok_3TnIVhEv9P24T0" // the token id should be sent from the client
},{
  success: function(httpResponse) {
    response.success("Purchase made!");
  },
  error: function(httpResponse) {
    response.error("Uh oh, something went wrong");
  }
});

});




