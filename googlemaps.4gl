IMPORT com
IMPORT util

-- A record holding address information
DEFINE m_address RECORD
    address1 STRING,
    address2 STRING,
    city  STRING,
    state STRING,
    country STRING,
    latlong STRING,
    postcode STRING
END RECORD

DEFINE m_zoom SMALLINT 



MAIN 
    DEFER INTERRUPT 
    DEFER QUIT 
    OPTIONS INPUT WRAP 
    OPTIONS FIELD ORDER FORM

    CLOSE WINDOW SCREEN
    CALL ui.Interface.LoadStyles("googlemaps")
    OPEN WINDOW w WITH FORM "googlemaps"

    CALL key_warning_dialog()

    -- Initial zoom setting
    LET m_zoom = 14

    INPUT m_address.address1, m_address.address2, m_address.city, m_address.state, m_address.country, m_address.postcode,  m_address.latlong , m_zoom
    FROM address1, address2, city, state, country, postcode, latlong, zoom ATTRIBUTES(UNBUFFERED, WITHOUT DEFAULTS=TRUE, ACCEPT=FALSE, CANCEL=FALSE)
        BEFORE INPUT
            MESSAGE "Enter an address, get the latitude/longitude, and then draw map"
            CALL dialog_state(DIALOG)

        -- Get the lat/long for address
        ON ACTION getdetails
            IF NOT geocode() THEN
                INITIALIZE m_address.latlong TO NULL
            END IF
            CALL dialog_state(DIALOG)

        -- Select a 4Js office address
        &define on_action(p1) ON ACTION p1 \
            CALL populate_address(#p1) \
            CALL dialog_state(DIALOG)

        on_action(headoffice)
        on_action(france)
        on_action(usa)
        on_action(uk)
        on_action(germany)
        on_action(italy)
        on_action(spain)
        on_action(mexico)
        on_action(nz)
        on_action(australia)
        on_action(ireland)

        -- Draw the map
        ON ACTION drawmap
            CALL drawmap()
            CALL dialog_state(DIALOG)

        -- Respond to changes with the slider
        ON CHANGE zoom
            CALL drawmap()
            CALL dialog_state(DIALOG)

        ON ACTION close
            EXIT INPUT
    END INPUT
END MAIN



-- Set properties of dialog
FUNCTION dialog_state(d)
DEFINE d ui.Dialog

    -- If lat/long popualted then allow drawmap, zoom
    IF m_address.latlong.getLength() > 0 THEN
        CALL d.setActionActive("drawmap", TRUE)
        CALL d.setFieldActive("zoom", TRUE)
    ELSE
        CALL d.setActionActive("drawmap", FALSE)
        CALL d.setFieldActive("zoom", FALSE)
    END IF
    CALL d.setFieldActive("latlong", FALSE)
END FUNCTION



-- Get the lat/long of an address using google maps geocoding API 
-- https://developers.google.com/maps/documentation/geocoding/
FUNCTION geocode()
DEFINE l_http_req com.HTTPRequest
DEFINE l_http_resp com.HTTPResponse
DEFINE url STRING
DEFINE l_result_str STRING
DEFINE l_result_rec RECORD
    results DYNAMIC ARRAY OF RECORD
        address_components DYNAMIC ARRAY OF RECORD
            long_name STRING,
            short_name STRING,
            types DYNAMIC ARRAY OF STRING
        END RECORD,
        formatted_address STRING,
        geometry RECORD
            location RECORD
                lat FLOAT,
                lng FLOAT
            END RECORD,
            location_type STRING,
            viewport RECORD
                northeast RECORD
                    lat FLOAT,
                    lng FLOAT
                END RECORD,
                southwest RECORD
                    lat FLOAT,
                    lng FLOAT
                END RECORD
            END RECORD
        END RECORD,
        place_id STRING,
        types DYNAMIC ARRAY OF STRING
    END RECORD,
    status STRING
END RECORD
DEFINE l_status INTEGER

    LET url = SFMT("https://maps.googleapis.com/maps/api/geocode/json?address=%1,%2,%3,%4,%5,%6&key=%7",m_address.address1, m_address.address2, m_address.city, m_address.state, m_address.country,m_address.postcode,FGL_GETRESOURCE("key.google.geocode"))
    TRY 
        LET l_http_req = com.HTTPRequest.Create(url)
        CALL l_http_req.doRequest()
        LET l_http_resp = l_http_req.getResponse()
        IF l_http_resp.getStatusCode() != 200 THEN
            DISPLAY SFMT("HTTP ERROR(%1) %2",l_http_resp.getStatusCode(), l_http_resp.getStatusDescription())
            RETURN FALSE
        ELSE
            LET l_result_str = l_http_resp.getTextResponse()
        END IF
    CATCH
        LET l_status = STATUS
        DISPLAY SFMT("ERROR (%1) %2", l_status, err_get(l_status))
        RETURN FALSE
    END TRY

   #DISPLAY util.JSON.proposeType(l_result_str) -- uncomment this to determine the record layour of l_result_rec
    CALL util.JSON.parse(l_result_str, l_result_rec)
    IF l_result_rec.results.getLength() = 1 THEN
        LET m_address.latlong=SFMT("%1,%2",l_result_rec.results[1].geometry.location.lat,l_result_rec.results[1].geometry.location.lng)
        RETURN TRUE
    ELSE
        ERROR "ERROR Address not found"
        RETURN FALSE
    END IF
END FUNCTION 



-- Draw the map using Google Static Maps API as documented 
-- https://developers.google.com/maps/documentation/static-maps/
FUNCTION drawmap()
DEFINE url STRING

    CALL FGL_WINMESSAGE("Info","Google is now charging for this.\nYou will have to use your own key in order to draw a map using this technique","stop")
    #LET url = SFMT("https://maps.googleapis.com/maps/api/staticmap?center=%1&zoom=%3&size=512x512&key=%2&markers=%1,reda",m_address.latlong, FGL_GETRESOURCE("key.google.maps"), m_zoom USING "<<")
    #DISPLAY url TO url
END FUNCTION



-- Populate the address fields with a selected 4Js office
FUNCTION populate_address(l_office)
DEFINE l_office STRING

   INITIALIZE m_address.* TO NULL
   CASE l_office
        WHEN "headoffice"
            LET m_address.address1 = "28 Quai Gallieni"
            LET m_address.address2 = "Suresnes"
            LET m_address.city = "Paris"
            LET m_address.country = "France"
            LET m_address.postcode = "92150"
    
        WHEN "france"
            LET m_address.address1 = "7 Rue de Dublin"
            LET m_address.address2 = "Schitigheim"
            LET m_address.city = "Strasbourg"
            LET m_address.state = ""
            LET m_address.country = "France"
            LET m_address.postcode = "F-67300"

        WHEN "usa"
            LET m_address.address1 = "251 O Connor Ridge Boulevard"
            LET m_address.address2 = ""
            LET m_address.city = "Irving"
            LET m_address.state = "Texas"
            LET m_address.country = "USA"
            LET m_address.postcode = "75038"

        WHEN "uk"
            LET m_address.address1 = "Regus House"
            LET m_address.address2 = "Victory Way, Admirals Park"
            LET m_address.city = "Crossways, Dartford"
            LET m_address.state = ""
            LET m_address.country = "UK"
            LET m_address.postcode = "DA2 6QD"

        WHEN "mexico"
            LET m_address.address1 = "Insurgentes Sur 1602"
            LET m_address.address2 = "Col. Credito Constructor"
            LET m_address.city = "Mexico City"
            LET m_address.state = ""
            LET m_address.country = "Mexico"
            LET m_address.postcode = "DF 03940"

        WHEN "germany"
            LET m_address.address1 = "Ottobrunner Strasse 41"
            LET m_address.address2 = "Admirals Park"
            LET m_address.city = "Unterhaching"
            LET m_address.state = ""
            LET m_address.country = "Germany"
            LET m_address.postcode = "82008"

        WHEN "italy"
            LET m_address.address1 = "Via Ciprani, 2"
            LET m_address.address2 = ""
            LET m_address.city = "Reggio Emilia"
            LET m_address.state = ""
            LET m_address.country = "Italy"
            LET m_address.postcode = "42124"

        WHEN "spain"
            LET m_address.address1 = "Lagasca 61, 2 Ext. Izp."
            LET m_address.address2 = ""
            LET m_address.city = "Madrid"
            LET m_address.state = ""
            LET m_address.country = "Spain"
            LET m_address.postcode = "28001"
            
        WHEN "australia"
            LET m_address.address1 = "Suite 210 29 Kiora Road"
            LET m_address.address2 = "Miranda"
            LET m_address.city = "Sydney"
            LET m_address.state = "New South Wales"
            LET m_address.country = "Australia"
      
        WHEN "nz"
            LET m_address.address1 = "2 Kalmia Street"
            LET m_address.address2 = "Ellerslie"
            LET m_address.city = "Auckland"
            LET m_address.country = "New Zealand"

        WHEN "ireland"
            LET m_address.address1 = "Unit L6B"
            LET m_address.address2 = "Smithstown Industrial Estate"
            LET m_address.city = "Shannon"
            LET m_address.state = "County Clare"
            LET m_address.country = "Ireland"
   END CASE
END FUNCTION

FUNCTION key_warning_dialog()
DEFINE l_text STRING
    IF FGL_GETRESOURCE("key.google.maps") = "ABQIAAAAgg35UlaF7bP0AXZjRMf8WRSSAVt8jDhBFa1zz53EcnyyKZXBCBRyGAdLwDZ67Xwbpnm0bCOytzag0A"
    OR FGL_GETRESOURCE("key.google.geocode") = "AIzaSyArvZnPO4J6klxnQCTdCcWNzIdl9T8Awzs" THEN
        LET l_text = "This example is using my personal API keys to access the Google GeoCode and Static Maps API.\n",
                     "If you plan to use this code in production, please get your own API keys to access the Google services.\n",
                     "See the README for URL's that will point you in the right direction to get your own API keys" 
        CALL FGL_WINMESSAGE("Info",l_text,"info")
    END IF
END FUNCTION