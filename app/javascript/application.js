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
    var countryInfos = [];

    //Fetch the list of all the countries when the form are loaded
    const formsWithLocations = document.querySelectorAll('.form-with-locations');
  
    if(formsWithLocations.length > 0) {
      fetch(`http://api.geonames.org/countryInfoJSON?username=${username}`)
        .then(response => response.json())
        .then(data => {
          // List of all the contries names
          countryInfos = data;
          countryNames = data.geonames.map(country => country.countryName);
          console.log("countries loaded");
        })
        .catch(error => console.error('Error fetching countries:', error));
    }


    // Fetch and display country suggestions
    var countryInput = document.getElementById('user_country');
    var countrySuggestions = document.getElementById('countrySuggestions');
  
    if (countryInput && countrySuggestions) {
      //INPUT COUNTRY
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
              //clear suggestions and other fields
              countrySuggestions.innerHTML = ''; // Clear suggestions
              document.getElementById('user_cap').value = "";
              document.getElementById('user_province').value = "";
              document.getElementById('user_city').value = "";

            });
            countrySuggestions.appendChild(div);
          });
          
        } else {
          countrySuggestions.innerHTML = ''; // Clear suggestions if input is less than 1 characters
        }
      });
    }

   
    // Fetch and display city suggestions (only if country is specified)
    var cityInput = document.getElementById('user_city');
    var citySuggestions = document.getElementById('citySuggestions');
    var selected_country = '';
    var region = '';
    var province = '';
    var cap = ''; //I take the first cap
    var countryCode = '';
  
    if (cityInput && citySuggestions && countryInput) {
     

      //INPUT CITY
      cityInput.addEventListener('input', function() {
       
      const query = cityInput.value;
      
      selected_country = document.getElementById('user_country').value;
      //camel case for selected country
      selected_country = selected_country.replace(/\b\w/g, (c) => c.toUpperCase()).trim();

      
      console.log("try to find code");
      var countryInfo = countryInfos.geonames.find(country => country.countryName === selected_country);
      if (countryInfo) {
          countryCode = countryInfo.countryCode;
        if (query.length >= 1 ){
          console.log("query " + query);
          console.log("selected_country " + selected_country);
          console.log("countryCode: " + countryCode);
        // Fetch the list of cities based on the country and the input
        fetch(`http://api.geonames.org/searchJSON?name_startsWith=${query}&country=${countryCode}&username=${username}`)
          .then(response => response.json())
          .then(data => {
            console.log("cities found: "+ data.length);
            // delete what isn't needed (with the same city.name, and population = 0 and if city.name != city.toponymName)
            const uniqueCities = [];
            const cityNames = new Set();
            data.geonames.forEach(city => {
              if (!cityNames.has(city.name) && city.population > 0 && city.name == city.toponymName) {
                uniqueCities.push(city);
                cityNames.add(city.name);
              }
            });
            data.geonames = uniqueCities;
          

            // show suggestions
            citySuggestions.innerHTML = '';
            data.geonames.forEach(city => {
              
            console.log("city: " + city);
            const div = document.createElement('div');
            div.textContent = city.name;
            div.style.cursor = 'pointer';
            div.classList.add('list-group-item');
            div.addEventListener('click', () => {
              cityInput.value = city.name;
              citySuggestions.innerHTML = ''; // Clear suggestions
              region = city.adminName1;
              // Find cap
              fetch(`http://api.geonames.org/postalCodeSearchJSON?placename=${city.name}&username=${username}`)
              .then(response => response.json())
              .then(data => {
                if (data.postalCodes.length > 0) {
                  // Find the first postal code entry where adminName1 matches the region
                  const matchingEntry = data.postalCodes.find(pc => pc.adminName1 === region);

                  if (matchingEntry) {
                    // Extract cap and province
                    const cap = matchingEntry.postalCode;
                    const province = matchingEntry.adminName2;

                    console.log("cap " + cap);
                    console.log("province " + province);

                    // Add value to the fields
                    document.getElementById('user_cap').value = cap;
                    document.getElementById('user_province').value = province;
                  } else {
                    console.log(`No postal codes found in the region: ${region}`);
                  }

                } else {
                  console.log('No postal codes found for the specified location.');
                }
              })
              .catch(error => console.error('Error fetching postal codes:', error));

              console.log("provincia: " + province);
            });
            citySuggestions.appendChild(div);
          
            });
          })
          .catch(error => console.error('Error fetching cities:', error));
        }
        else{
          citySuggestions.innerHTML = '';
        }
    }
    else{
      console.log("cant find code");
      citySuggestions.innerHTML = '';
    }
      
       });
      
    } //fine controllo esistenza cityInput

    


  });
  