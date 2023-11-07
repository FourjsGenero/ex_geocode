# ex_geocode
Example showing Genero accessing a RESTful Web Service that returns JSON.

The Web Service used is the Google GeoCode Web Service that returns a latitude/longitude for a passed in address.  More details can be found here  https://developers.google.com/maps/documentation/geocoding/

The program then uses another Google API, the static maps API https://developers.google.com/maps/documentation/static-maps/?csw=1 to draw a map centered on this latitude/longitude

PLEASE note The example code used to include my API keys.  Google detected them in the GitHub repository and sent me email so I have removed them from the Github Repository.  You will have to insert your keys in order to run the example

When running the program, follow these steps

1. Click on a flag to select an address (a 4Js office around the world), or enter an address (such as your own) manually 
2. click on the first button that will take that address, send it to the Google GeoCode Web Service and return a latitude/longitude
3. click on the second button to draw a map centered on this latitude/longitude

<img alt="Geocode Map Example" src="https://user-images.githubusercontent.com/13615993/32221510-aad55894-be9a-11e7-8333-0d5bd4e37c66.png" width="90%" />

If your Genero application has an address field, then the techniques here can be used in your application to draw a map based on that address.
The same technique can be used to access a wide range of web services that are out there.

(Disclaimer: the flag images I sourced from various Wikipedia pages)

    (Small change to update language associated with repository)


