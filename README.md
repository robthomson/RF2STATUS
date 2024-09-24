**RF2STATUS**

<img src="https://github.com/robthomson/RF2STATUS/blob/main/git/rf2status-main.png?raw=true" width="800" alt="MAIN PAGE">

RF2STATUS is a widget that has been designed to run on Frsky Radios; directly supporting and displaying all the key telemetry that is provided by Rotorflight.

Fully supported is:

- FPORT
- S.PORT
- ELRS
- CROSSFIRE
- ROTORFLIGHT TELEMETRY LUA

---

**RF2STATUS LOGGING**

<img src="https://github.com/robthomson/RF2STATUS/blob/main/git/rf2status-logs.png?raw=true" width="800" alt="LOGS PAGE">

RF2STATUS will log your flights - showing you minimum and maximum recorded values.

-----
Note: 

When using this widget you will need to enable certain features on rotorflight to make thins play ball as expected.  See details below.

**CRSF*
Please enter the following commands in your rotorflight config.  

Due to the limited number of sensors in CRSF we have to map some existing functions to alternative sensor names for the widget to use.

set crsf_flight_mode_reuse = GOV_ADJFUNC

set crsf_gps_altitude_reuse = HEADSPEED

set crsf_gps_ground_speed_reuse = ESC_TEMP

set crsf_gps_sats_reuse = MCU_TEMP

**CRSF CUSTOM TELEMETRY**

set crsf_telemetry_mode = CUSTOM

set crsf_telemetry_sensors = 3,4,5,61,50,51,52,60,99,93,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


**SPORT FPORT**

Please enter the following commands in your rotorflight config.  

set telemetry_enable_gov_mode = ON

set telemetry_enable_adjustment = ON

-----

Like what you see.  Consider donating..

[![Donate](https://github.com/robthomson/RF2STATUS/blob/main/git/paypal-donate-button.png?raw=true)](https://www.paypal.com/donate/?hosted_button_id=SJVE2326X5R7A)

