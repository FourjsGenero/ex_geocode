# ex_geocode
Example showing Genero accessing a RESTful Web Service that returns JSON.

The Web Service used is the Google GeoCode Web Service that returns a latitude/longitude for a passed in address.  More details can be found here  https://developers.google.com/maps/documentation/geocoding/

The program then uses another Google API, the static maps API https://developers.google.com/maps/documentation/static-maps/?csw=1 to draw a map centered on this latitude/longitude

PLEASE note the example code uses my personal API keys that are in googlemaps.fglprofile.  Please do not use these keys in production, please acquire your own API keys from Google.

When running the program, follow these steps

1. Click on a flag to select an address (a 4Js office around the world), or enter an address (such as your own) manually 
2. click on the first button that will take that address, send it to the Google GeoCode Web Service and return a latitude/longitude
3. click on the second button to draw a map centered on this latitude/longitude

If your Genero application has an address field, then the techniques here can be used in your application to draw a map based on that address.
The same technique can be used to access a wide range of web services that are out there.


