Property Booking API

* Ruby version - 2.5.1

* Rails version - 5.2.1

* App Server - Puma

* Database - Postgres

* Cache - Redis

Easy launch of all the components is being done by docker.

Don't have docker?

Run: brew install docker docker-compose

How to run the app:

docker-compose up

After all three components are up - from a new terminal run:
docker-compose run web rake db:create db:migrate db:seed

Tests can be run with:
docker-compose run web rails test

* Notes & Assumptions
    - Order can reserve one room
    - Booking a dorm room will check if there are any spots left in any of the rooms - so no same room gurantee for the whole time period
    - Booking a private room will check if there is a specific room available for the whole time period - no switching of rooms
