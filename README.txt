--------------------
CRSF
-------------------

Please enter the following commands in your rotorflight config.  

Due to the limited number of sensors in CRSF we have to map some existing functions to alternative sensor names for the widget to use.

set crsf_flight_mode_reuse = GOV_ADJFUNC
set crsf_gps_altitude_reuse = HEADSPEED
set crsf_gps_ground_speed_reuse = ESC_TEMP
set crsf_gps_sats_reuse = MCU_TEMP


--------------------
SPORT FPORT
-------------------

Please enter the following commands in your rotorflight config.  

set telemetry_enable_gov_mode = ON

You will further need to go into ethos and create a range of DIY sensors as follows:

ADJFUNC    5110 
ADJVALUE   5111
GOV_MODE   5450
mAh   	   5250

If you do not physically scan and create these sensors - the widget will not be able to display all vales.
