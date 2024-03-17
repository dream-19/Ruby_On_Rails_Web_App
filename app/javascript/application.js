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


  

  /*fetch(`http://api.geonames.org/searchJSON?name_startsWith=${startsWith}&country=${countryCode}&username=${username}`)
    .then(response => response.json())
    .then(data => {
      data.geonames.forEach(city => {
        console.log(city.name);
        
      });
    })
    .catch(error => console.error('Error fetching cities:', error)); */

    const username = 'helloworld';
    // Fetch and display country suggestions
    const countryInput = document.getElementById('user_country');
    const countrySuggestions = document.getElementById('countrySuggestions');
  
    countryInput.addEventListener('input', function() {
      const query = countryInput.value;
      if (query.length >= 1) { // Start suggesting after 2 characters
        fetch(`http://api.geonames.org/searchJSON?q=${query}&featureClass=P&username=${username}`)
          .then(response => response.json())
          .then(data => {
            countrySuggestions.innerHTML = ''; // Clear previous suggestions
            console.log(data.geonames);
            data.geonames.forEach(country => {
              //console.log(country.countryName); //print country name to console
              const div = document.createElement('div');
              div.textContent = country.countryName; // Use countryName for GeoNames
              div.style.cursor = 'pointer';
              div.addEventListener('click', () => {
                countryInput.value = country.countryName; // Fill input on click
                countrySuggestions.innerHTML = ''; // Clear suggestions
              });
              countrySuggestions.appendChild(div);
            });
          })
          .catch(error => console.error('Error:', error));
      } else {
        console.log("clear suggestions")
        countrySuggestions.innerHTML = ''; // Clear suggestions if input is less than 2 characters
      }
    });

  });
  