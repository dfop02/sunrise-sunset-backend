# Sunrise Sunset Backend
Backend for Sunrise Sunset, a Jumpseller code challenge, you can access Frontend by [clicking here](https://github.com/dfop02/sunrise-sunset-frontend).

## Dependences
- Ruby 3.4+
- Mysql 8+

## Getting Started

First, you need to install the required ruby version (if do not have yet), I recommend use [rvm](https://rvm.io/) for it.
```bash
rvm install 3.4.3
```

Using the correct ruby version, run bundler to install all dependences
```bash
bundle install
```

Then, run the development server:
```bash
rails s
```

Open [http://localhost:3000](http://localhost:3000) with your browser to validate server is running.

## Learn More

For this project I'm using Rails and Mysql to creating the sunrise sunset endpoint, which I called as sun events. SunEvents will receive 3 params: city, start_date and end_date from Frontend. There is validations to handle possible errors, like a request missing some params.

If all data is correct, then endpoint will trigger SunriseSunsetService, which is responsable to connect to API and manage the data back to controller. The Sunrise Sunset API only receive coordinates as params, so first we need fetch the coodinates from location (which I consider is always a city for this challenge), for this I created a new service with this responsability. I made 2 ways to get the coordinates: mock values and real data using [geocode.maps.co](https://geocode.maps.co/). You can select which way you prefer on [get_coordinates](https://github.com/dfop02/sunrise-sunset-backend/blob/main/app/services/sunset_sunrise_service.rb#L72-L75) method by commenting the lines.

After fetch coordinates, I did a big search on database to collect all dates for the searched city, making sure I'll not trigger a new SQL for each loop. Then, during the loop I just check if there is a date on my collection, if doesn't I can get from API and save it on app.