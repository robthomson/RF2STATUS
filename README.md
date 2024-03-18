# rf2status
Rotorflight 2 / Ethos Flight Status Widget

This is a Widget designed to show key information in ethos for telemetry delivered by rotorflight.

The script supports telemetry from:L

FPORT
SPORT
CRSF

To use CRSF in rotorflight you will need the following parameters:


set crsf_flight_mode_reuse = GOV_ADJFUNC
set crsf_gps_altitude_reuse = HEADSPEED
set crsf_gps_ground_speed_reuse = ESC_TEMP
set crsf_gps_sats_reuse = MCU_TEMP

You will also need to edit the GPS Altitude sensor and 'max' the default sensor value or you will only ever display rpm at 1000rpm.

Currently the 'governer' modes being sent to the CRSF flight mode have a bug in lua.  It will not work as expected until the bug is fixed.  Suggest you use ethos flight modes for now!

