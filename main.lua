--
-- set crsf_flight_mode_reuse = GOV_ADJFUNC
-- set crsf_gps_altitude_reuse = HEADSPEED
-- set crsf_gps_ground_speed_reuse = ESC_TEMP
-- set crsf_gps_sats_reuse = MCU_TEMP
--


local environment=system.getVersion()
local sensors = {"refresh","voltage","rpm","current","temp_esc","temp_mcu","fuel","mah","rssi","fm","govmode"}
local gfx_model
local audioAlertCounter = 0
local voltageLowCounter = 0
local initialVoltageCounter = 0
local initialRSSICounter = 0
local smallScreen = false
local badScreen = false



local function create(widget)

	gfx_model = lcd.loadBitmap(model.bitmap()) 
	sensors = getSensors(sensors)

    rssiSensor = system.getSource("RSSI")
    if not rssiSensor then
        rssiSensor = system.getSource("RSSI 2.4G")
        if not rssiSensor then
            rssiSensor = system.getSource("RSSI 900M")
            if not rssiSensor then
                rssiSensor = system.getSource("Rx Quality")
            end
        end
    end


	return {fmsrc=1,lowvoltage=2170,lowfuel=20,alertint=5,alerthaptic=0,title=1}
end

local function configure(widget)


    -- LOW VOLTAGE TRIGGER
    line = form.addLine("LOW VOLTAGE ALERT")
    field = form.addNumberField(line, nil, 0, 20000, 
		function() return widget.lowvoltage end, 
		function(value) widget.lowvoltage = value end
		);
	field:decimals(2)
    field:default(2170)

    -- LOW FUEL TRIGGER
    line = form.addLine("LOW FUEL ALERT %")
    field = form.addNumberField(line, nil, 0, 1000, 
		function() return widget.lowfuel end, 
		function(value) widget.lowfuel = value end
		);
    field:default(20)


    -- ALERT INTERVAL
    line = form.addLine("ALERT INTERVAL")
	form.addChoiceField(line, nil, {{'5S',5}, {'10S',10}, {'15S',15}, {'20S',20}, {'30S',30}}, 
		function() return widget.alertint end, 
		function(newValue) widget.alertint = newValue end
		)

    -- ALERT INTERVAL
    line = form.addLine("ALERT HAPTIC")
	form.addChoiceField(line, nil, {{'NO',0}, {'YES',1}}, 
		function() return widget.alerthaptic end, 
		function(newValue) widget.alerthaptic = newValue end
		)

	-- FLIGHT MODE SOURCE
	line = form.addLine("FLIGHT MODE SOURCE")
	form.addChoiceField(line, nil, {{'RF GOVERNOR',0}, {'ETHOS FLIGHT MODES',1}}, 
		function() return widget.fmsrc end, 
		function(newValue) widget.fmsrc = newValue end
		)

	if smallScreen == false then
    -- TITLE DISPLAY
		line = form.addLine("TITLE DISPLAY")
		form.addChoiceField(line, nil, {{'NO',0}, {'YES',1}}, 
			function() return widget.title end, 
			function(newValue) widget.title = newValue end
			)

	end



end



function getRSSI()
    if rssiSensor ~= nil and rssiSensor:state() then
      return rssiSensor:value()
    end
    return 0
end

local function paint(widget)


	
		sensors = getSensors(sensors)
		local w, h = lcd.getWindowSize()

		if w <= 700 and h <= 250 then
				smallScreen  = true
		end
		
		if w <= 300 then
				badScreen  = true
		end
		if h <= 200 then
				badScreen  = true
		end
		if badScreen == true then
			if w >= 600 and h >= 250 then
					badScreen = false
			end		
		end
		
		
		if smallScreen == true then
				widget.title = 0
		end


		if badScreen == true then
			lcd.font(FONT_XS)
			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(114, 114, 114))
			else
				-- light theme
				lcd.color(lcd.RGB(180, 180, 180))
			end				
			str = "WIDGET TOO SMALL"
			tsizeW,tsizeH= lcd.getTextSize(str)
			--lcd.drawText(w / 2)-tsizeW/2, (h/2)-tsizeH/2, str)	
			lcd.drawText((w / 2)-tsizeW/2, (h / 2)-tsizeH/2, str)				
			return
		end

		-- blank out display
			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(16, 16, 16))
			else
				-- light theme
				lcd.color(lcd.RGB(209, 208, 208))
			end		
		lcd.drawFilledRectangle(0, 0, w, h)


		if lcd.themeColor(1) == 251666692 then
			lcd.color(lcd.RGB(40, 40, 40))
		else
			lcd.color(lcd.RGB(240, 240, 240))
		end			
		
		
		colSpacing = 5	
		
		fullBoxW = w/3
		fullBoxH = h/2
		boxW = fullBoxW - colSpacing
		boxH = fullBoxH - colSpacing
		boxHs = fullBoxH/2 - colSpacing
		boxWs = fullBoxW/2 - colSpacing
		textOFFSET = 10
		
		col1X = 0
		col2X = fullBoxW
		col3X = fullBoxW*2
		row1Y = 0
		row2Y = fullBoxH		
		row3Y = fullBoxH*2		
		
		lcd.drawFilledRectangle(col1X, row1Y, boxW, boxH) 									-- col 1 row 1 1x1	
		lcd.drawFilledRectangle(col1X, row2Y+(colSpacing/2), boxW, boxHs) 					-- col 1 row 2 1x1			
		lcd.drawFilledRectangle(col1X, (row2Y+boxHs+colSpacing)+(colSpacing/2), boxWs, boxHs) 					-- col 1 row 2 1x1	
		lcd.drawFilledRectangle(col1X+boxWs+colSpacing, (row2Y+boxHs+colSpacing)+(colSpacing/2), boxWs, boxHs) 					-- col 1 row 2 1x1	
		
		lcd.drawFilledRectangle(col2X+(colSpacing/2), row1Y, boxW, boxH) 					-- col 2 row 1 1x1	
		lcd.drawFilledRectangle(col2X+(colSpacing/2), row2Y+(colSpacing/2), boxW, boxH) 	-- col 2 row 2 1x1			

		lcd.drawFilledRectangle(col3X+(colSpacing/2), row1Y, boxW, boxH) 					-- col 2 row 1 1x1	
		lcd.drawFilledRectangle(col3X+(colSpacing/2), row2Y+(colSpacing/2), boxW, boxH) 	-- col 2 row 2 1x1			



		if lcd.themeColor(1) == 251666692 then
			-- dark theme
			lcd.color(lcd.RGB(255, 255, 255,1))
		else
			-- light theme
			lcd.color(lcd.RGB(90, 90, 90))
		end	
		
		-- FUEL
		if sensors.fuel <= widget.lowfuel then
				lcd.color(lcd.RGB(255, 0, 0,1))			
		end		
		lcd.font(FONT_XXL)
		str = "" .. sensors.fuel .. "%"
		tsizeW,tsizeH= lcd.getTextSize(str)
		offsetX = boxW/2-tsizeW/2
		offsetY = boxH / 2 - tsizeH/2
		lcd.drawText(col3X+(colSpacing/2) + offsetX, row1Y + offsetY, str)	
		if widget.title == 1 then
			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(114, 114, 114))
			else
				-- light theme
				lcd.color(lcd.RGB(180, 180, 180))
			end	
			lcd.font(FONT_XS)
			str = "FUEL"
			tsizeW,tsizeH= lcd.getTextSize(str)
			lcd.drawText(col3X+(colSpacing/2) + (boxW / 2)-tsizeW/2, row1Y+(boxH-colSpacing-tsizeH), str)	
	
			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(255, 255, 255,1))
			else
				-- light theme
				lcd.color(lcd.RGB(90, 90, 90))
			end			
			lcd.font(FONT_XXL)
		end		
		if sensors.fuel <= widget.lowfuel then
			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(255, 255, 255,1))
			else
				-- light theme
				lcd.color(lcd.RGB(90, 90, 90))
			end	
		end	
		
		-- RPM
		lcd.font(FONT_XXL)
	
		str =  "" .. sensors.rpm .. "rpm"
		tsizeW,tsizeH = lcd.getTextSize(str)
		offsetX = boxW/2-tsizeW/2
		offsetY = boxH / 2 - tsizeH/2
		lcd.drawText(col3X+(colSpacing/2) + offsetX, row2Y + offsetY, str)	
		if widget.title == 1 then
			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(114, 114, 114))
			else
				-- light theme
				lcd.color(lcd.RGB(180, 180, 180))
			end	
			lcd.font(FONT_XS)
			str = "HEAD SPEED"
			tsizeW,tsizeH= lcd.getTextSize(str)
			lcd.drawText(col3X+(colSpacing/2) + (boxW / 2)-tsizeW/2, row2Y+(boxH-colSpacing-tsizeH), str)	
	
			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(255, 255, 255,1))
			else
				-- light theme
				lcd.color(lcd.RGB(90, 90, 90))
			end			
			lcd.font(FONT_XXL)
		end		

		-- VOLT		
		if sensors.voltage <= widget.lowvoltage then
				lcd.color(lcd.RGB(255, 0, 0,1))			
		end
		lcd.font(FONT_XXL)
		str = "" .. tostring(sensors.voltage/100) .. "v"
		tsizeW,tsizeH = lcd.getTextSize(str)
		offsetX = boxW/2-tsizeW/2
		offsetY = boxH / 2 - tsizeH/2
		lcd.drawText(col2X+(colSpacing/2) + offsetX, row1Y + offsetY, str)	
		if widget.title == 1 then
			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(114, 114, 114))
			else
				-- light theme
				lcd.color(lcd.RGB(180, 180, 180))
			end	
			lcd.font(FONT_XS)
			str = "VOLTAGE"
			tsizeW,tsizeH= lcd.getTextSize(str)
			lcd.drawText(col2X+(colSpacing/2) + (boxW / 2)-tsizeW/2, row1Y+(boxH-colSpacing-tsizeH), str)	
	
			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(255, 255, 255,1))
			else
				-- light theme
				lcd.color(lcd.RGB(90, 90, 90))
			end			
			lcd.font(FONT_XXL)
		end	
				

		if lcd.themeColor(1) == 251666692 then
			-- dark theme
			lcd.color(lcd.RGB(255, 255, 255,1))
		else
			-- light theme
			lcd.color(lcd.RGB(90, 90, 90))
		end	

		

		-- CURRENT
		lcd.font(FONT_XXL)
		str = "" .. sensors.current .. "AMP"
		tsizeW,tsizeH = lcd.getTextSize(str)
		offsetX = boxW/2-tsizeW/2
		offsetY = boxH / 2 - tsizeH/2
		lcd.drawText(col2X+(colSpacing/2) + offsetX, row2Y + offsetY, str)	
		if widget.title == 1 then
			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(114, 114, 114))
			else
				-- light theme
				lcd.color(lcd.RGB(180, 180, 180))
			end	
			lcd.font(FONT_XS)
			str = "CURRENT"
			tsizeW,tsizeH= lcd.getTextSize(str)
			lcd.drawText(col2X+(colSpacing/2) + (boxW / 2)-tsizeW/2, row2Y+(boxH-colSpacing-tsizeH), str)	
	
			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(255, 255, 255,1))
			else
				-- light theme
				lcd.color(lcd.RGB(90, 90, 90))
			end			
			lcd.font(FONT_XXL)
		end	


		if widget.fmsrc == 0 then
			-- GOVERNER
			lcd.font(FONT_STD)
			str = "" .. sensors.govmode 
			tsizeW, tsizeH = lcd.getTextSize(str)
			offsetX = boxW/2-tsizeW/2
			offsetY = (boxHs/2)+colSpacing - tsizeH/2
			lcd.drawText(col1X+(colSpacing/2) + offsetX, row2Y + offsetY, str)
			if widget.title == 1 then
				if lcd.themeColor(1) == 251666692 then
					-- dark theme
					lcd.color(lcd.RGB(114, 114, 114))
				else
					-- light theme
					lcd.color(lcd.RGB(180, 180, 180))
				end	
				lcd.font(FONT_XS)
				str = "GOVERNOR"
				tsizeW,tsizeH= lcd.getTextSize(str)
				lcd.drawText(col1X+(colSpacing/2) + (boxW / 2)-tsizeW/2, row2Y+(boxH/2-colSpacing-tsizeH), str)	
		
				if lcd.themeColor(1) == 251666692 then
					-- dark theme
					lcd.color(lcd.RGB(255, 255, 255,1))
				else
					-- light theme
					lcd.color(lcd.RGB(90, 90, 90))
				end			
				lcd.font(FONT_XXL)
			end				
		elseif widget.fmsrc == 1 then
			-- SYSTEM FM
			lcd.font(FONT_STD)
			str = "" .. sensors.fm
			tsizeW, tsizeH = lcd.getTextSize(str)
			offsetX = boxW/2-tsizeW/2
			offsetY = (boxHs/2)+colSpacing - tsizeH/2
			lcd.drawText(col1X+(colSpacing/2) + offsetX, row2Y + offsetY, str)
			if widget.title == 1 then
				if lcd.themeColor(1) == 251666692 then
					-- dark theme
					lcd.color(lcd.RGB(114, 114, 114))
				else
					-- light theme
					lcd.color(lcd.RGB(180, 180, 180))
				end	
				lcd.font(FONT_XS)
				str = "FLIGHT MODE"
				tsizeW,tsizeH= lcd.getTextSize(str)
				lcd.drawText(col1X+(colSpacing/2) + (boxW / 2)-tsizeW/2, row2Y+(boxH/2-colSpacing-tsizeH), str)	
		
				if lcd.themeColor(1) == 251666692 then
					-- dark theme
					lcd.color(lcd.RGB(255, 255, 255,1))
				else
					-- light theme
					lcd.color(lcd.RGB(90, 90, 90))
				end			
				lcd.font(FONT_XXL)
			end				
		end

		-- TEMP ESC
		lcd.font(FONT_STD)
		str = "" .. sensors.temp_esc .. "°"
		tsizeW, tsizeH = lcd.getTextSize(str)
		offsetX = boxWs/2+(colSpacing*2)-tsizeW/2
		offsetY = (boxHs+boxHs/2)+colSpacing - tsizeH/2
		lcd.drawText(col1X+(colSpacing/2) + offsetX, row2Y + offsetY, str)	
		if widget.title == 1 then
			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(114, 114, 114))
			else
				-- light theme
				lcd.color(lcd.RGB(180, 180, 180))
			end	
			lcd.font(FONT_XS)
			str = "ESC"
			tsizeW,tsizeH= lcd.getTextSize(str)
			lcd.drawText(col1X+(colSpacing/2) + boxWs/2-tsizeW/2, row2Y+(boxH-colSpacing-tsizeH), str)	
	
			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(255, 255, 255,1))
			else
				-- light theme
				lcd.color(lcd.RGB(90, 90, 90))
			end			
			lcd.font(FONT_XXL)
		end			

		
		-- TEMP MCU
		lcd.font(FONT_STD)
		str = "" .. sensors.temp_mcu  .. "°"
		tsizeW, tsizeH = lcd.getTextSize(str) 
		offsetX = (boxWs/2+(colSpacing*2)-tsizeW/2)+boxWs
		offsetY = (boxHs+boxHs/2)+colSpacing - tsizeH/2
		lcd.drawText(col1X+(colSpacing/2) + offsetX, row2Y + offsetY, str)	
		if widget.title == 1 then
			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(114, 114, 114))
			else
				-- light theme
				lcd.color(lcd.RGB(180, 180, 180))
			end	
			lcd.font(FONT_XS)
			str = "MCU"
			tsizeW,tsizeH= lcd.getTextSize(str)
			lcd.drawText(col1X+(colSpacing/2) + (boxWs/2-tsizeW/2)+boxWs, row2Y+(boxH-colSpacing-tsizeH), str)	
	
			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(255, 255, 255,1))
			else
				-- light theme
				lcd.color(lcd.RGB(90, 90, 90))
			end			
			lcd.font(FONT_XXL)
		end				

		
		-- IMAGE
		if gfx_model ~= nil then
			lcd.drawBitmap(col1X, row1Y, gfx_model, boxW, boxH)
		end
		if widget.title == 1 then
			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(114, 114, 114))
			else
				-- light theme
				lcd.color(lcd.RGB(180, 180, 180))
			end	
			lcd.font(FONT_XS)
			str = "RSSI"
			tsizeW,tsizeH= lcd.getTextSize(str)
			lcd.drawText(col1X+(colSpacing/2) + (boxW / 2)-tsizeW/2, row1Y+(boxH-colSpacing-tsizeH), str)	
	
			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(255, 255, 255,1))
			else
				-- light theme
				lcd.color(lcd.RGB(90, 90, 90))
			end			
			lcd.font(FONT_XXL)
		end			
		
		
		-- -----------------------------------------------------------------------------------------------

		-- we only trigger if we have been in alarm level for more than 3 seconds
		if sensors.rssi > 0 then
			if ((sensors.voltage) <= widget.lowvoltage) or  (sensors.fuel <= widget.lowfuel) then		
			
					lvTime = tonumber(os.clock()) - tonumber(voltageLowCounter) 
					if lvTime >=  2 then
			
						lvAlarm = true
					else
						lvAlarm = false
						voltageLowCounter = 0 
					end
			else	
					lvAlarm = false
					voltageLowCounter = 0 
			end
			
	

			-- play alarm - but no more than interval
			if lvAlarm == true then
				--only play every interval
				if widget.alertinterval == nil then
					widget.alertinterval = 10
				end
					
				if (tonumber(os.clock()) - tonumber(audioAlertCounter)) >=  widget.alertinterval then
					audioAlertCounter = os.clock()		
					if sensors.voltage >= 3 then --no point alerting if voltage is so low that its flyable		
							system.playFile("/scripts/rf2flog/sounds/lowvoltage.wav")
							
							if widget.alerthaptic == 1 then
									system.playHaptic("- . -")
							end
							
							
					end
				end	
			end	
		end

end








function getSensors(oldvalues)


	if environment.simulation == true then
		-- we are running simulation
			tv = math.random(1164, 2274)
			voltage = sensorMakeNumber(tv)
			rpm = sensorMakeNumber(math.random(0, 1510)) 
			current = sensorMakeNumber(math.random(0, 17)) 
			temp_esc =  sensorMakeNumber(math.random(0, 32)) 
			temp_mcu = sensorMakeNumber(math.random(0, 12)) 
			fuel = sensorMakeNumber(math.floor(((tv/10 * 100)/252)))
			mah = sensorMakeNumber(math.random(10000, 10100)) 
			govmode = 'DISABLED'
			fm = 'DISABLED'
			rssi = math.random(90,100)		
			refresh = true
	elseif system.getSource("Rx RSSI1") ~= nil then
		-- we are running crsf

		rssi =  getRSSI()

		
		if system.getSource("Rx Batt") ~= nil then
			voltage = system.getSource("Rx Batt"):stringValue()
			voltage = sensorMakeNumber(voltage)*10			
		else
			voltage = ''
		end 
		if system.getSource("GPS Alt") ~= nil then
			rpm = system.getSource("GPS Alt"):stringValue()	
			rpm = sensorMakeNumber(rpm)				
		else
			rpm = ''
		end
		if system.getSource("Rx Curr") ~= nil then
			current = system.getSource("Rx Curr"):stringValue()
			current = sensorMakeNumber(current)/10		
			current = math.floor(current)			
		else
			current = ''
		end	
		if system.getSource("GPS Speed") ~= nil then
			temp_esc = system.getSource("GPS Speed"):value()
			temp_esc = sensorMakeNumber(temp_esc)/10	
			if oldvalues.temp_esc ~= nil then
				temp_esc = (temp_esc + oldvalues.temp_esc)/2		
			end
			temp_esc = math.floor(temp_esc)				
		else
			temp_esc = ''
		end
		if system.getSource("GPS Sats") ~= nil then
			temp_mcu = system.getSource("GPS Sats"):stringValue()
			temp_mcu = sensorMakeNumber(temp_mcu)/2	
			if oldvalues.temp_mcu ~= nil then			
				temp_mcu = (temp_mcu + oldvalues.temp_mcu)/2		
			end
			temp_mcu = math.floor(temp_mcu)				
		else
			temp_mcu = ''
		end		
		if system.getSource("Rx Batt%") ~= nil then
			fuel = system.getSource("Rx Batt%"):stringValue()
			fuel = sensorMakeNumber(fuel)				
		else
			fuel = ''
		end	
		if system.getSource("Rx Cons") ~= nil then
			mah = system.getSource("Rx Cons"):stringValue()
			mah = sensorMakeNumber(mah)			
		else
			mah = ''
		end
		if system.getSource("Flight mode ") ~= nil then
			govmode = system.getSource("Flight mode "):stringValue()
		end	
		if system.getSource({category=CATEGORY_FLIGHT_VALUE, member=CURRENT_FLIGHT_MODE}):stringValue() then
			fm = system.getSource({category=CATEGORY_FLIGHT_VALUE, member=CURRENT_FLIGHT_MODE}):stringValue()
		else
			fm = ''
		end
	else
		-- we are run sport
		rssi =  getRSSI()

		if system.getSource("VFAS") ~= nil then
			voltage = system.getSource("VFAS"):stringValue()
			voltage = sensorMakeNumber(voltage)					
		else
			voltage = 0
		end 
		if system.getSource("RPM") ~= nil then
			rpm = system.getSource("RPM"):stringValue()	
			rpm = sensorMakeNumber(rpm)						
		else
			rpm = 0
		end
		if system.getSource("Current") ~= nil then
			current = system.getSource("Current"):stringValue()
			current = sensorMakeNumber(current)/10
			current = math.floor(current)			
		else
			current = 0
		end	
		if system.getSource("ESC temp") ~= nil then
			temp_esc = system.getSource("ESC temp"):stringValue()
			temp_esc = sensorMakeNumber(temp_esc)		
			if oldvalues.temp_esc ~= nil then
				temp_esc = (temp_esc + oldvalues.temp_esc)/2		
			end			
			temp_esc = math.floor(temp_esc)				
		else
			temp_esc = 0
		end
		if system.getSource({category=CATEGORY_TELEMETRY_SENSOR, appId=0x0401}) ~= nil then
			temp_mcu = system.getSource({category=CATEGORY_TELEMETRY_SENSOR, appId=0x0401}):stringValue()
			temp_mcu = sensorMakeNumber(temp_mcu)		
			if oldvalues.temp_mcu ~= nil then			
				temp_mcu = (temp_mcu + oldvalues.temp_mcu)/2		
			end			
			temp_mcu = math.floor(temp_mcu)	
		else
			temp_mcu = 0
		end		
		if system.getSource("Fuel") ~= nil then
			fuel = system.getSource("Fuel"):stringValue()
			fuel = sensorMakeNumber(fuel)			
		else
			fuel = 0
		end	
		if system.getSource("Consumption") ~= nil then
			mah = system.getSource("Consumption"):stringValue()
			mah = sensorMakeNumber(mah)	
		else
			mah = 0
		end		
		if system.getSource("Mode") ~= nil then
			govmode = system.getSource("Mode"):stringValue()
		else
			govmode = ''
		end			
		if system.getSource({category=CATEGORY_FLIGHT_VALUE, member=CURRENT_FLIGHT_MODE}):stringValue() then
			fm = system.getSource({category=CATEGORY_FLIGHT_VALUE, member=CURRENT_FLIGHT_MODE}):stringValue()
		else
			fm = ''
		end
		
	end
	

	
	-- set flag to refresh screen or not
	if oldvalues.voltage ~= voltage then
				refresh = true
	end
	if oldvalues.rpm ~= rpm then
				refresh = true
	end	
	if oldvalues.current ~= current then
				refresh = true
	end		
	if oldvalues.temp_esc ~= temp_esc then
				refresh = true
	end	
	if oldvalues.temp_mcu ~= temp_mcu then
				refresh = true
	end	
	if oldvalues.govmode ~= govmode then
				refresh = true
	end		
	if oldvalues.fuel ~= fuel then
				refresh = true
	end	
	if oldvalues.mah ~= mah then
				refresh = true
	end	
	if oldvalues.rssi ~= rssi then
				refresh = true
	end	
	if oldvalues.fm ~= CURRENT_FLIGHT_MODE then
				refresh = true
	end	
	

	return {fm=fm,refresh=refresh,voltage=voltage,rpm=rpm,current=current,temp_esc=temp_esc,temp_mcu=temp_mcu,fuel=fuel,mah=mah,rssi=rssi,govmode=govmode}
	
end

function sensorMakeNumber(x)
			x = string.gsub(x,"%D+","")
			x = tonumber(x)		
			return x
end

local function read(widget)


		widget.fmsrc = storage.read("fmsrc")
		if widget.fmsrc == nil then
			widget.fmsrc = 1
		end
	
		widget.lowvoltage = tonumber(storage.read("lowvoltage"))
		if widget.lowvoltage == nil then
			widget.lowvoltage = 2170
		end
	
		widget.lowfuel = tonumber(storage.read("lowfuel"))
		if widget.lowfuel == nil then
			widget.lowfuel = 20  
		end
	
		widget.alertint = tonumber(storage.read("alertint"))
		if widget.alertint == nil then
			widget.alertint = 5  
		end		

		widget.alerthaptic = tonumber(storage.read("alerthaptic"))
		if widget.alerthaptic == nil then
			widget.alerthaptic = 0  
		end		
			

		widget.title = tonumber(storage.read("title"))
		if widget.title == nil then
			widget.title = 1  
		end		

		
		return
end

local function write(widget)
	
        storage.write("fmsrc",widget.fmsrc)
        storage.write("lowvoltage",widget.lowvoltage)
        storage.write("lowfuel",widget.lowfuel)
        storage.write("alertint",widget.alertint)
        storage.write("alerthaptic",widget.alerthaptic)
        storage.write("title",widget.title)
		return
end


local function wakeup(widget)
	if sensors.refresh == true then
		lcd.invalidate()
	end
	return
end



local function init()
  system.registerWidget({key="rf2stat", name="RF2 Flight Status", create=create, configure=configure,paint=paint, wakeup=wakeup,read=read, write=write})
end

return {init=init}