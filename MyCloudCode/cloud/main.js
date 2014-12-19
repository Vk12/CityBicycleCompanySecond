var Stripe = require('stripe');

// Replace this with your Stripe secret key, found at https://dashboard.stripe.com/account/apikeys
var stripe_secret_key = "sk_test_45wd20YjiQTPoP8YcSwp1EcZ";

Stripe.initialize(stripe_secret_key);

Parse.Cloud.define("charge", function(request, response) {
  console.log("test");
  Stripe.Charges.create({
    amount: request.params.amount, // in cents
    currency: request.params.currency,
    card: request.params.token
  },{
    success: function(httpResponse) {
      response.success("Purchase made!");
    },
    error: function(httpResponse) {
      response.error("Uh oh, something went wrong");
    }
  });
});
