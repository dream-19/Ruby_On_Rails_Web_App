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

    //LOCATIONS 
    const username = 'helloworld';
    var countryNames = [];

    //Fetch the list of all the countries when the form are loaded
    const formsWithLocations = document.querySelectorAll('.form-with-locations');
  
    if(formsWithLocations.length > 0) {
      fetch(`http://api.geonames.org/countryInfoJSON?username=${username}`)
        .then(response => response.json())
        .then(data => {
          // List of all the contries names
          countryNames = data.geonames.map(country => country.countryName);
        })
        .catch(error => console.error('Error fetching countries:', error));
    }


  /*fetch(`http://api.geonames.org/searchJSON?name_startsWith=${startsWith}&country=${countryCode}&username=${username}`)
    .then(response => response.json())
    .then(data => {
      data.geonames.forEach(city => {
        console.log(city.name);
        
      });
    })
    .catch(error => console.error('Error fetching cities:', error)); */

    // Fetch and display country suggestions
    var countryInput = document.getElementById('user_country');
    var countrySuggestions = document.getElementById('countrySuggestions');
  
    if (countryInput && countrySuggestions) {
      countryInput.addEventListener('input', function() {
        const query = countryInput.value;
        if (query.length >= 1 && countryNames.length > 0) { // Start suggesting after 1 characters
          countrySuggestions.innerHTML = '';
          // Filter the list of countries based on the input, keep only the countries that start with the input
          const filteredCountries = countryNames.filter(country => country.toLowerCase().startsWith(query.toLowerCase()));
         
          // Display the filtered countries
          filteredCountries.forEach(country => {
            const div = document.createElement('div');
            div.textContent = country;
            div.style.cursor = 'pointer';
            div.classList.add('list-group-item');
            div.addEventListener('click', () => {
              countryInput.value = country;
              countrySuggestions.innerHTML = ''; // Clear suggestions
            });
            countrySuggestions.appendChild(div);
          });
          
        } else {
          countrySuggestions.innerHTML = ''; // Clear suggestions if input is less than 1 characters
        }
      });
    }

  });
  