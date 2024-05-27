# Ruby On Rails Web App - Event Booking System

## Project Delivery: Event Manager

Develop a web application that allows users and organizers to manage bookings for events. The application will need to implement the following features:

### Features for Organizers
- **User Registration:** Allow users to register on the platform. They can register as a normal user or as an organizer.
- **Event Creation:** Organizers can create events with specific details:
  - Name of the event
  - Description
  - Start time and date
  - End time and date
  - Event location (country, city, province, zip, address)
  - Maximum number of participants
  - Photos can be added to the event

### Features for Users
- **Registration:** Users can register for the platform.
- **Event Search:** Users can search for events, including filtering by geographic location.
- **Event Registration and Deregistration:** Users can sign up for or deregister from events.
- **Concurrent Event Restriction:** Prevent users from registering for events that overlap with other events they are already registered for.

### Administrative Features for Organizers
- **Participant Management:** Organizers can view the list of participants for their events and remove unwanted users.

### Notifications System
- **Variation Notifications:** Notify users registered for an event about any changes, cancellations by the organizer, or if they have been removed from the event.
- **Organizer Notifications:** Notify organizers about scenarios related to their events, such as reaching maximum capacity.


## How to Run the app on Docker with docker-compose
When launched the app automatically executes the migrations and the seeders

`docker-compose up --build`


