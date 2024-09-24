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
CRSF CUSTOM TELEMETRY (RF2.1)
-------------------

set crsf_telemetry_mode = CUSTOM
set crsf_telemetry_sensors = 3,4,5,61,50,51,52,60,99,93,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


--------------------
SPORT FPORT
-------------------

Please enter the following commands in your rotorflight config.  

set telemetry_enable_gov_mode = ON
set telemetry_enable_adjustment = ON
