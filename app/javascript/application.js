// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import "@hotwired/turbo-rails"
import "controllers"
import "popper"
import "bootstrap"

document.addEventListener("turbo:load", () => {

    // Toggle password visibility
    document.querySelectorAll('.toggle-password-icon').forEach(el => {
      el.addEventListener('click', function (e) {
        console.log('clicked');
        // Determine the input field to toggle
        const input = document.querySelector(this.getAttribute('toggle'));
        const icon = this.querySelector('i'); // Target the <i> tag inside the span
        console.log(input);
        if (input.type === "text") {
          input.type = "password";
          icon.classList.remove('bi-eye-fill');
          icon.classList.add('bi-eye-slash-fill');
        } else {
          input.type = "text";
          icon.classList.remove('bi-eye-slash-fill');
          icon.classList.add('bi-eye-fill');
        }
      });
    });


    console.log("hey")
  const startsWith = "lus";
  const countryCode = 'IT'; // Set this to the selected country's code
  const username = 'helloworld'; // Replace with your GeoNames username

  /*fetch(`http://api.geonames.org/searchJSON?name_startsWith=${startsWith}&country=${countryCode}&username=${username}`)
    .then(response => response.json())
    .then(data => {
      data.geonames.forEach(city => {
        console.log(city.name);
        
      });
    })
    .catch(error => console.error('Error fetching cities:', error)); */

  });
  