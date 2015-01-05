var Stripe = require('stripe');

// Replace this with your Stripe secret key, found at https://dashboard.stripe.com/account/apikeys
var stripe_secret_key = "sk_test_45wd20YjiQTPoP8YcSwp1EcZ";

Stripe.initialize(stripe_secret_key);

var Mailgun = require('mailgun');
Mailgun.initialize("sandbox7dc4ae0462d74d1c8846ff7559a7192e.mailgun.org", "key-a8098b96ad2e4acd3d9d34067fca60b2");


Parse.Cloud.define("charge", function(request, response) {

var order;

order = new Parse.Object('Order');
order.set('name', request.params.name);
order.set('email', request.params.email);
order.set('address', request.params.address);
order.set('zip', request.params.zipcode);
order.set('cityState', request.params.cityState);
order.set('lineItems', request.params.lineItems);
order.set('fulfilled', false);


Stripe.Charges.create({
    amount: request.params.amount, // in cents
    currency: request.params.currency,
    card: request.params.token
  },{
    success: function(httpResponse) {
      response.success("Purchase made!");

      // Credit card charged and order item updated properly!
    // We're done, so let's send an email to the user.

    // Generate the email body string.
    var body = "We've received and processed your City Bicycle Co. order. \n\n" +
                "Price: $" + request.params.amount / 100 + "\n\n" +
                "Shipping Address: \n" +
                request.params.name + "\n" +
                request.params.address + "\n" +
                request.params.cityState + ", " +
                "United States, " + request.params.zipcode + "\n" + 
                "\nWe will send your item as soon as possible. " +
                "Let us know if you have any questions!\n\n" +
                "Thank you,\n" +
                "City Bicycle Co.";



    // Send the email.
    return Mailgun.sendEmail({
      to: request.params.email,
      from: 'support@citybicycleco.com',
      subject: 'Your order was successful!',
      text: body
    }).then(null, function(error) {
      return Parse.Promise.error('Your purchase was successful, but we were not able to ' +
                                 'send you an email. Contact us at store@parse.com if ' +
                                 'you have any questions.');
    });
    },
    error: function(httpResponse) {
      response.error("Uh oh, something went wrong");
    }
  });

// Create new order
return order.save().then(null,function(error) {
  console.log('Creating order object failed.  Error: ' + error);
  return Parse.Promise.error('An error has occurred.  Your credit card was not charged');



});



});
