// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import "@hotwired/turbo-rails";
import "controllers";
import "popper";
import "bootstrap";

const username = "helloworld";
var countryNames = [];
var countryInfos = [];
var countryInput = "";
var countrySuggestions = "";
var cityInput = "";
var citySuggestions = "";
var selected_country = "";
var region = "";
var province = "";
var cap = ""; //I take the first cap
var countryCode = "";

document.addEventListener("turbo:load", () => {
  const formsWithLocations = document.querySelectorAll('.form-with-locations');
  if(formsWithLocations.length > 0) {
    // Fetch the country (only if it is required by the form)
    fetchCountries();
  }
  //Use event delegation to manage the click event on the country input (also when a form with error is submitted and reloaded with turbo)
  document.addEventListener("click", (event) => {
    // Check if the clicked element or any of its parents is the user_country element
    const isCountrySelect = event.target.matches("#user_country") || event.target.closest("#user_country");
    if (isCountrySelect) {
      // Fetch and display country suggestions
      countryInput = document.getElementById("user_country");
      countrySuggestions = document.getElementById("countrySuggestions");
      if (countryInput && countrySuggestions) {
        countryInput.addEventListener("input", () => countrySuggest());
      }
    }

    // Check if the clicked element or any of its parents is the user_city element
    const isCitySelect = event.target.matches("#user_city") || event.target.closest("#user_city");
    if (isCitySelect) {
      // Fetch and display city suggestions (only if country is specified)
      cityInput = document.getElementById("user_city");
      citySuggestions = document.getElementById("citySuggestions");
      if (cityInput && citySuggestions && countryInput) {
        cityInput.addEventListener("input", () => citySuggest());
      }
    }
  });

  // Add event listeners to all the toggle password icons
  document.addEventListener("mouseover", (event) => {
    // Add event listeners to all the toggle password icons
    const isTogglePasswordIcon = event.target.matches(".toggle-password-icon") || event.target.closest(".toggle-password-icon");
    if (isTogglePasswordIcon) {
      document.querySelectorAll(".toggle-password-icon").forEach((el) => {
        el.addEventListener("click", togglePasswordVisibility);
      });
    }
  });
  
});


//FUNCTION TO TOGGLE THE PASSWORD VISIBILITY
function togglePasswordVisibility() {
  // Determine the input field to toggle
  const input = document.querySelector(this.getAttribute("toggle"));
  const icon = this.querySelector("i"); // Target the <i> tag inside the span
  if (input.type === "text") {
    input.type = "password";
    icon.classList.remove("bi-eye-fill");
    icon.classList.add("bi-eye-slash-fill");
  } else {
    input.type = "text";
    icon.classList.remove("bi-eye-slash-fill");
    icon.classList.add("bi-eye-fill");
  }
}

//FUNCTION TO FETCH THE DATA OF THE COUNTRIES
function fetchCountries() {
  fetch(`http://api.geonames.org/countryInfoJSON?username=${username}`)
    .then((response) => response.json())
    .then((data) => {
      // List of all the contries names
      countryInfos = data;
      countryNames = data.geonames.map((country) => country.countryName);
      console.log("countries loaded");
    })
    .catch((error) => console.error("Error fetching countries:", error));
}

//FUNCTION TO SUGGEST COUNTRIES
function countrySuggest() {
  console.log("hello");
  const query = countryInput.value;
  if (query.length >= 1 && countryNames.length > 0) {
    // Start suggesting after 1 characters
    countrySuggestions.innerHTML = "";
    // Filter the list of countries based on the input, keep only the countries that start with the input
    const filteredCountries = countryNames.filter((country) =>
      country.toLowerCase().startsWith(query.toLowerCase())
    );

    // Display the filtered countries
    filteredCountries.forEach((country) => {
      const div = document.createElement("div");
      div.textContent = country;
      div.style.cursor = "pointer";
      div.classList.add("list-group-item");
      div.addEventListener("click", () => {
        countryInput.value = country;
        //clear suggestions and other fields
        countrySuggestions.innerHTML = ""; // Clear suggestions
        document.getElementById("user_cap").value = "";
        document.getElementById("user_province").value = "";
        document.getElementById("user_city").value = "";
      });
      countrySuggestions.appendChild(div);
    });
  } else {
    countrySuggestions.innerHTML = ""; // Clear suggestions if input is less than 1 characters
  }
}

//FUNCTION TO SUGGEST CITIES
function citySuggest() {
  const query = cityInput.value;

  selected_country = document.getElementById("user_country").value;
  //camel case for selected country
  selected_country = selected_country
    .replace(/\b\w/g, (c) => c.toUpperCase())
    .trim();

  var countryInfo = countryInfos.geonames.find(
    (country) => country.countryName === selected_country
  );
  if (countryInfo) {
    countryCode = countryInfo.countryCode;
    if (query.length >= 1) {
      // Fetch the list of cities based on the country and the input
      fetch(
        `http://api.geonames.org/searchJSON?name_startsWith=${query}&country=${countryCode}&username=${username}`
      )
        .then((response) => response.json())
        .then((data) => {
          // delete what isn't needed (with the same city.name, and population = 0 and if city.name != city.toponymName)
          const uniqueCities = [];
          const cityNames = new Set();
          data.geonames.forEach((city) => {
            if (
              !cityNames.has(city.name) &&
              city.population > 0 &&
              city.name == city.toponymName
            ) {
              uniqueCities.push(city);
              cityNames.add(city.name);
            }
          });
          data.geonames = uniqueCities;

          // show suggestions
          citySuggestions.innerHTML = "";
          data.geonames.forEach((city) => {
            const div = document.createElement("div");
            div.textContent = city.name;
            div.style.cursor = "pointer";
            div.classList.add("list-group-item");
            div.addEventListener("click", () => {
              cityInput.value = city.name;
              citySuggestions.innerHTML = ""; // Clear suggestions
              region = city.adminName1;
              // Find cap
              fetch(
                `http://api.geonames.org/postalCodeSearchJSON?placename=${city.name}&username=${username}`
              )
                .then((response) => response.json())
                .then((data) => {
                  if (data.postalCodes.length > 0) {
                    // Find the first postal code entry where adminName1 matches the region
                    const matchingEntry = data.postalCodes.find(
                      (pc) => pc.adminName1 === region
                    );

                    if (matchingEntry) {
                      // Extract cap and province
                      const cap = matchingEntry.postalCode;
                      const province = matchingEntry.adminName2;

                      // Add value to the fields
                      document.getElementById("user_cap").value = cap;
                      document.getElementById("user_province").value = province;
                    } else {
                      console.log(
                        `No postal codes found in the region: ${region}`
                      );
                    }
                  } else {
                    console.log(
                      "No postal codes found for the specified location."
                    );
                  }
                })
                .catch((error) =>
                  console.error("Error fetching postal codes:", error)
                );
            });
            citySuggestions.appendChild(div);
          });
        })
        .catch((error) => console.error("Error fetching cities:", error));
    } else {
      citySuggestions.innerHTML = "";
    }
  } else {
    citySuggestions.innerHTML = "";
  }
}
