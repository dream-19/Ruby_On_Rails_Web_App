// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

//= require rails-ujs
//= require tabulator.min
//= require jquery

import "@hotwired/turbo-rails";
import "controllers";
import "popper";
import "bootstrap";

// Variables to manage locations
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
var table_current = "";
var table_past = "";
var table_future = "";
var table_sub = "";

// variables to manage photos
var photoInputCount = 0;
var maxPhotos = 3; //max number of photos
var id_counter = 0;

/* -------------- FUNCTIONS -------------------- */

// Function to update the image preview
function updateImagePreview(input, previewContainerId) {
  console.log("updateImagePreview");
  if (input.files && input.files[0]) {
    var reader = new FileReader();
    reader.onload = function (e) {
      let previewContainer = document.getElementById(previewContainerId);
      previewContainer.innerHTML = ""; // Clear existing content
      let img = document.createElement("img");
      img.src = e.target.result;
      img.style.maxWidth = "100px"; // Set the preview size here
      img.style.maxHeight = "100px";
      previewContainer.appendChild(img);
    };
    reader.readAsDataURL(input.files[0]);
  }
}

// Delete the entire input group
function deleteElement(element) {
  const elementId = element.id;
  const inputId = elementId.replace("photo-delete-", "input-");

  const inputElement = document.getElementById(inputId);
  console.log("delete " + inputElement);
  if (inputElement) {
    inputElement.remove();
    photoInputCount--;
    checkVisibility();
  }
}

//Function to check if 'add photo' button must be hidden
function checkVisibility() {
  if (photoInputCount < maxPhotos) {
    document.getElementById("add-photo-button").style.display = "block";
  } else {
    document.getElementById("add-photo-button").style.display = "none";
  }
}

//function to delete a photo
function delete_single_photo(photoId) {
  if (confirm("Are you sure you want to delete this photo?")) {
    fetch("/delete_photo", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content, // Ensure CSRF token is sent
      },
      body: JSON.stringify({ photo_id: photoId }),
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.success) {
          console.log("SUCCESS");
          photoInputCount--;
          checkVisibility();

          document.getElementById(`existing-input-${photoId}`).remove();
        } else {
          // Handle failure
          alert("Try Again");
        }
      })
      .catch((error) => console.error("Error:", error));
  }
}

// function to add the element to add photos
function add_element_photo() {
  if (photoInputCount < maxPhotos) {
    photoInputCount++;
    id_counter++;

    //add the new input group
    let inputGroup = document.createElement("div");
    inputGroup.setAttribute("class", "input-group mb-3 input-group-photo");
    inputGroup.setAttribute("id", "input-" + id_counter);

    // add the input file
    let newInput = document.createElement("input");
    newInput.setAttribute("type", "file");
    newInput.setAttribute("name", "event[photos][]");
    newInput.setAttribute("id", "photo-input-" + photoInputCount);
    newInput.setAttribute("class", "photo-input form-control");
    newInput.setAttribute("accept", "image/png,image/jpeg,image/jpg");
    newInput.addEventListener("change", function (event) {
      updateImagePreview(event.target, previewContainer.id);
    });

    //add the delete option
    const deleteButton = document.createElement("button");
    deleteButton.className = "btn btn-outline-danger photo-delete";
    deleteButton.id = "photo-delete-" + id_counter;
    deleteButton.type = "button";
    deleteButton.innerHTML = '<i class="bi bi-x-lg"></i>';
    deleteButton.addEventListener("click", function () {
      deleteElement(inputGroup);
    });

    // Create a container for the image preview
    let previewContainer = document.createElement("div");
    previewContainer.className =
      "image-preview-container d-flex justify-content-center align-items-center me-2";
    previewContainer.id = "preview-" + id_counter;

    //append child
    inputGroup.appendChild(previewContainer);
    inputGroup.appendChild(newInput);
    inputGroup.appendChild(deleteButton);

    document.getElementById("photos-input-container").appendChild(inputGroup);
  }

  //check the value of photoInputCount, when it reaches 3 the button add another photo is hidden
  checkVisibility();
}

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

// Function to manage the Tabulator Table
function manageTable() {
  //Check if element with id #current-events exist (past-events is always present in the page, so no need to check it)
  if (document.getElementById("current-events") == null) {
    return;
  }


  //Take the data from the data-events attribute
  const eventData = JSON.parse(
    document.getElementById("current-events").getAttribute("data-events")
  );

  const futureData = JSON.parse(
    document.getElementById("future-events").getAttribute("data-events")
  );

  const pastEventData = JSON.parse(
    document.getElementById("past-events").getAttribute("data-events")
  );

  // Define the columns based on your old table structure
  const columns = [
    { title: "Name", field: "name", headerFilter: "input" },
    {
      title: "From",
      field: "beginning_date",
      sorter: dateSorter,
      headerFilter: "input",
    }, // Assuming format_date is handled server-side
    { title: "Time", field: "beginning_time", headerFilter: "input" }, // Assuming format_time is handled server-side
    {
      title: "To",
      field: "ending_date",
      sorter: dateSorter,
      headerFilter: "input",
    },
    { title: "Time", field: "ending_time", headerFilter: "input" },
    { title: "People", field: "participants", headerFilter: "input" },
    { title: "Max", field: "max_participants", headerFilter: "input" },
    { title: "Address", field: "address", headerFilter: "input" },
    { title: "City", field: "city", headerFilter: "input" },
    { title: "Cap", field: "cap", headerFilter: "input" },
    { title: "Province", field: "province", headerFilter: "input" },
    { title: "Country", field: "country", headerFilter: "input" },
    {
      title: "Actions",
      headerSort: false,
      formatter: function (cell, formatterParams, onRendered) {
        const rowData = cell.getRow().getData();
        if (rowData.edit_url == "") {
          return `<a href='${rowData.view_url}' class='btn btn-info'>View</a>`;
        } else {
          return `<a href='${rowData.view_url}' class='btn btn-info'>View</a>
                  <a href='${rowData.edit_url}' class='btn btn-warning'>Edit</a>`;
        }
      },
    },
  ];

  // Initialize Tabulator on the #current-events div if there is data
  if (eventData.length > 0) {
    table_current = new Tabulator("#current-events", {
      layout: "fitData",
      placeholder: "No current events available",
      data: eventData, // Set data to your events
      columns: columns,
      cellVertAlign: "middle", // Vertically align the content in cells
      cellHozAlign: "center",
      pagination: "local", // Enable local pagination
      paginationSize: 10, // Set the number of rows per page
      paginationSizeSelector: [5, 10, 20, 50],
      paginationCounter: "rows", //add pagination row counter
      initialSort: [
        // Set initial sorting
        { column: "beginning_date", dir: "asc" },
      ],

      rowHeader: {
        headerSort: false,
        resizable: false,
        frozen: true,
        headerHozAlign: "center",
        hozAlign: "center",
        formatter: "rowSelection",
        titleFormatter: "rowSelection",
        cellClick: function (e, cell) {
          cell.getRow().toggleSelect();
        },
      },
    });
  } else {
    document.getElementById(
      "current-events"
    ).innerHTML = `<div class="alert alert-info" role="alert"> There are no current events available </div>`;
  }

  //Initialize Tabulatore on the #future-events div if there is data
  if (futureData.length > 0) {
    table_future = new Tabulator("#future-events", {
      layout: "fitData",
      placeholder: "No future events available",
      data: futureData, // Set data to your events
      columns: columns,
      cellVertAlign: "middle", // Vertically align the content in cells
      cellHozAlign: "center",
      pagination: "local", // Enable local pagination
      paginationSize: 10, // Set the number of rows per page
      paginationSizeSelector: [5, 10, 20, 50],
      paginationCounter: "rows", //add pagination row counter
      initialSort: [
        // Set initial sorting
        { column: "beginning_date", dir: "asc" },
      ],

      rowHeader: {
        headerSort: false,
        resizable: false,
        frozen: true,
        headerHozAlign: "center",
        hozAlign: "center",
        formatter: "rowSelection",
        titleFormatter: "rowSelection",
        cellClick: function (e, cell) {
          cell.getRow().toggleSelect();
        },
      },
    });
  } else {
    document.getElementById(
      "current-events"
    ).innerHTML = `<div class="alert alert-info" role="alert"> There are no future events available </div>`;
  }


  // Initialize Tabulator on the #past-events div if there is data
  if (pastEventData.length > 0) {
    table_past = new Tabulator("#past-events", {
      layout: "fitData",
      placeholder: "No past events available",
      data: pastEventData, // Set data to your events
      columns: columns,
      cellVertAlign: "middle", // Vertically align the content in cells
      cellHozAlign: "center", // Horizontally align the content in cells
      paginationCounter: "rows", //add pagination row counter
      pagination: "local", // Enable local pagination
      paginationSize: 10, // Set the number of rows per page
      paginationSizeSelector: [5, 10, 20, 50],
      initialSort: [
        // Set initial sorting
        { column: "ending_date", dir: "des" },
      ],
      rowHeader: {
        headerSort: false,
        resizable: false,
        frozen: true,
        headerHozAlign: "center",
        hozAlign: "center",
        formatter: "rowSelection",
        titleFormatter: "rowSelection",
        cellClick: function (e, cell) {
          cell.getRow().toggleSelect();
        },
      },
    });
  } else {
    //show bootstrap alert
    document.getElementById(
      "past-events"
    ).innerHTML = `<div class="alert alert-info" role="alert"> No past events available </div>`;
  }
}

// Function to manage tabulator 2
function manageTableSubscriptions(){
 
  //check if element is present in the page
  if (document.getElementById("events-subscriptions") == null) {

    return;
  }

  //Take the data from the data-events attribute
  const subData = JSON.parse(
    document.getElementById("events-subscriptions").getAttribute("data-events")
  );

  let past_event = document.getElementById("events-subscriptions").getAttribute("past-event");

  // Define the columns based on your old table structure
  const columns = [
    { title: "Name", field: "user_name", headerFilter: "input" },
    { title: "Surname", field: "user_surname", headerFilter: "input" },
    { title: "Email", field: "user_email", headerFilter: "input" },
    { title: "Address", field: "user_address", headerFilter: "input" },
    {
      title: "DoB",
      field: "user_date_of_birth",
      sorter: dateSorter,
      headerFilter: "input",
    },
    { 
      title: "Full Address", 
      field: "full_address", 
      headerFilter: "input",
      formatter: function(cell, formatterParams, onRendered) {
        const rowData = cell.getRow().getData();
        return rowData.user_cap + ", " + rowData.user_province + ", " + rowData.user_city + ", " + rowData.user_country;
      }
    },
    { title: "Subscriptions Date", field: "subscription_created_at", sorter:dateTimeSorter, headerFilter: "input" }, // TODO: sorter datetime
    
  ];

    past_event = past_event == "true" ? "true" : "false";
    // Initialize Tabulator if there is data
    if (subData != null && subData.length > 0) {
      table_sub = new Tabulator("#events-subscriptions", {
        layout: "fitData",
        placeholder: "No subscritpions available",
        data: subData, // Set data to your events
        columns: columns,
        cellVertAlign: "middle", // Vertically align the content in cells
        cellHozAlign: "center",
        pagination: "local", // Enable local pagination
        paginationSize: 25, // Set the number of rows per page
        paginationSizeSelector: [10, 15, 25, 50],
        paginationCounter: "rows", //add pagination row counter
        initialSort: [
          // Set initial sorting
          { column: "subscription_created_at", dir: "desc" },
        ],
        
        rowHeader: {
          headerSort: false,
          resizable: false,
          frozen: true,
          headerHozAlign: "center",
          hozAlign: "center",
          formatter: past_event == "true" ? "plaintext" : "rowSelection",
          titleFormatter: past_event == "true" ? "plaintext" : "rowSelection",
          cellClick: function (e, cell) {
            cell.getRow().toggleSelect();
          },
        },
      });
    } else {
      document.getElementById(
        "events-subscriptions"
      ).innerHTML = `<div class="alert alert-info" role="alert"> There are no subscriptions available </div>`;
    }

}

function dateSorter(a, b, aRow, bRow, column, dir, sorterParams) {
  // Convert dd-mm-yyyy formatted string to a comparable format
  // Example: "12-03-2022" becomes "20220312"
  function formatDate(dateStr) {
    let parts = dateStr.split("-");
    return parts[2] + parts[1] + parts[0]; // Reorder to YYYYMMDD
  }

  let formattedA = formatDate(a);
  let formattedB = formatDate(b);

  // Perform the comparison
  if (formattedA < formattedB) {
    return -1; // a is less than b
  } else if (formattedA > formattedB) {
    return 1; // a is greater than b
  } else {
    return 0; // a and b are equal
  }
}

//datetime sorter (the datetime is in format dd-mm-yyyy HH:mm)
function dateTimeSorter(a, b, aRow, bRow, column, dir, sorterParams) {
  // Convert datetime strings to comparable format
  // Example: "12-03-2022 10:30" becomes "2022-03-12T10:30:00"
  function formatDateTime(dateTimeStr) {
    let parts = dateTimeStr.split(" ");
    let dateParts = parts[0].split("-");
    let timeParts = parts[1].split(":");
    let formattedDate = `${dateParts[2]}-${dateParts[1]}-${dateParts[0]}`;
    let formattedTime = `${timeParts[0]}:${timeParts[1]}:00`;
    return `${formattedDate}T${formattedTime}`;
  }

  let formattedA = formatDateTime(a);
  let formattedB = formatDateTime(b);

  // Perform the comparison
  if (formattedA < formattedB) {
    return -1; // a is less than b
  } else if (formattedA > formattedB) {
    return 1; // a is greater than b
  } else {
    return 0; // a is equal to b
  }
}

// Function to manage the multiple deletion of events
function manageBulkDelete() {

  const selectedData =
    table_current != "" ? table_current.getSelectedData() : [];
  const selectedDataPast = table_past != "" ? table_past.getSelectedData() : [];
  const selectedDataFuture = table_future != "" ? table_future.getSelectedData() : [];
  const selectedDataAll = selectedData.concat(selectedDataPast.concat(selectedDataFuture));
  const eventIds = selectedDataAll.map((event) => event.id);
  console.log("selected data id " + eventIds);

  if (eventIds.length === 0) {
    alert("Please select at least one event to delete.");
    return;
  }

  if (!confirm("Are you sure you want to delete the selected events?")) return;

  fetch("/bulk_destroy", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content, // Ensure CSRF token is sent
    },
    body: JSON.stringify({ event_ids: eventIds }),
  })
    .then((response) => response.json())
    .then((data) => {
      if (data.success) {
        console.log("SUCCESS");
        // Reload the table or remove deleted rows from the table view
        if (table_current != "") {
          table_current.setData("/events/data?event_type=current");
        }
        if (table_future != ""){
          table_future.setData("/events/data?event_type=future");
        }

        if (table_past != "") {
          table_past.setData("/events/data?event_type=past");
        }
        console.log("table reloaded");
      } else {
        // Handle failure
        alert("There was an issue deleting the selected events.");
      }
    })
    .catch((error) => console.error("Error:", error));
}

// Manage bulk delete for subscriptions
function manageBulkDeleteSub() {

  const selectedData = table_sub != "" ? table_sub.getSelectedData() : [];

  const subIds = selectedData.map((sub) => sub.id);
  console.log("selected data id " + subIds);

  if (subIds.length === 0) {
    alert("Please select at least one subscription to delete.");
    return;
  }

   // Trigger the modal
   var deleteModal = new bootstrap.Modal(document.getElementById('deleteConfirmationModal'));
   deleteModal.show();
 
   document.getElementById('confirmDeletion').onclick = function() {
     deleteModal.hide();
     console.log("deleting");
     fetch("/bulk_destroy_sub", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content, // Ensure CSRF token is sent
      },
      body: JSON.stringify({ sub_ids: subIds }),
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.success) {
          console.log("SUCCESS");
          // Reload the entire page (yes, I need to update the counters)
          window.location.reload(); // Reload the page to reflect the changes
        } else {
          // Handle failure
          alert("There was an issue deleting the selected subscriptions.");
        }
      })
      .catch((error) => console.error("Error:", error));
   };
  

}

//SETTING UP EVENT LISTENERS FOR THE PHOTO MANAGEMENT
function setUpEventListenersPhotos() {
  id_counter = 0;
  //manage form with photos
  const formsWithPhotos = document.querySelectorAll(".form-with-photos");
  if (formsWithPhotos.length > 0) {
    // delete button for existing photos (send delete requests to Rails server)
    document.querySelectorAll(".photo-delete-existing").forEach((button) => {
      button.removeEventListener("click", delete_single_photo); // Remove existing event listeners
      button.addEventListener("click", function () {
        const photoId = this.getAttribute("data-photo-id");
        console.log("deleting photo with id: " + photoId);
        delete_single_photo(photoId);
      });
    });

    //Count how many photo are already present
    var existingPhotos = document.querySelectorAll(".input-group-photo").length;
    photoInputCount = existingPhotos; // Initialize with the number of already displayed photos
    //id_counter = existingPhotos;

    // When we click 'add photo' a field to add the photo is added
    document
      .getElementById("add-photo-button")
      .removeEventListener("click", add_element_photo); // Remove existing event listeners
    document
      .getElementById("add-photo-button")
      .addEventListener("click", () => add_element_photo());

    //First element automatically added (if needed)
    if (photoInputCount < maxPhotos && id_counter == 0) {
      document.getElementById("add-photo-button").click();
    }
  }
}

//Setting up event listeners to manage events (tabulator included)
function setUpEventListeners() {
  //Tabulator
  manageTable(); //tables for the list of events (owner side)
  manageTableSubscriptions(); //tables for the list of subscriptions to an event (owner side)

  // Bulk delete for events
  if (document.getElementById("bulk-delete") != null) {
    document
      .getElementById("bulk-delete")
      .removeEventListener("click", manageBulkDelete); // Remove existing event listeners
    document
      .getElementById("bulk-delete")
      .addEventListener("click", () => manageBulkDelete());
  }

  //Bulk delete for subscriptions
  if (document.getElementById("bulk-delete-sub") != null) {
    document
      .getElementById("bulk-delete-sub")
      .removeEventListener("click", manageBulkDeleteSub); // Remove existing event listeners
    document
      .getElementById("bulk-delete-sub")
      .addEventListener("click", () => manageBulkDeleteSub());
  }
}

//setting up event listeners for the location management
function setUpLocationListeners() {
  const formsWithLocations = document.querySelectorAll(".form-with-locations");
  if (formsWithLocations.length > 0) {
    // Fetch the country (only if it is required by the form)
    fetchCountries();

    // Fetch and display country suggestions
    countryInput = document.getElementById("user_country");
    countrySuggestions = document.getElementById("countrySuggestions");
    if (countryInput && countrySuggestions) {
      countryInput.addEventListener("input", () => countrySuggest());
    }

    // Fetch and display city suggestions (only if country is specified)
    cityInput = document.getElementById("user_city");
    citySuggestions = document.getElementById("citySuggestions");
    if (cityInput && citySuggestions && countryInput) {
      cityInput.addEventListener("input", () => citySuggest());
    }
  }

  // password toggle
  document.querySelectorAll(".toggle-password-icon").forEach((el) => {
    el.addEventListener("click", togglePasswordVisibility);
  });
}

/* -------------- LOAD THE PAGE-------------------- */

// Variable to manage the loading of the page
var loading = 0;

// Render is called every time I change the page (and even if the form fails!)
document.addEventListener("turbo:render", () => {
  loading++;
  setUpEventListenersPhotos();
  setUpEventListeners();
  setUpLocationListeners();
});

// Load is called only the first time I load the page
document.addEventListener("turbo:load", () => {
  if (loading == 0) { // Only run the setup once
    setUpEventListenersPhotos();
    setUpEventListeners();
    setUpLocationListeners();
    loading++;
  }
});
