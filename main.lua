--[[
set crsf_flight_mode_reuse = GOV_ADJFUNC
set crsf_gps_altitude_reuse = HEADSPEED
set crsf_gps_ground_speed_reuse = ESC_TEMP
set crsf_gps_sats_reuse = MCU_TEMP
]]--


local environment = system.getVersion()
local oldsensors = {"refresh","voltage","rpm","current","temp_esc","temp_mcu","fuel","mah","rssi","fm","govmode"}
local sensors
local gfx_model
local audioAlertCounter = 0
local voltageLowCounter = 0
local linkUP = 0 
local refresh = true
local isInConfiguration = false
local widgetTable = {fmsrc=1,lwvltge=2170,lowfuel=20,alertint=5,alrthptc=0,maxmin=1,title=1}

local function create(widget)

	gfx_model = lcd.loadBitmap(model.bitmap()) 

    rssiSensor = system.getSource("RSSI")
    if not rssiSensor then
        rssiSensor = system.getSource("RSSI 2.4G")
        if not rssiSensor then
            rssiSensor = system.getSource("RSSI 900M")
            if not rssiSensor then
                rssiSensor = system.getSource("Rx RSSI1")
                if not rssiSensor then
                    rssiSensor = system.getSource("Rx RSSI2")
                end
            end
        end
    end
	return widgetTable
end

local function configure(widget)

	isInConfiguration = true

	--[[
    -- IDLE UP
    line = form.addLine("IDLE UP SWITCH")
    form.addSwitchField(line, form.getFieldSlots(line)[0], 
		function() return widget.idleswtch end, 
		function(value) widget.idleswtch = value end
	);
	]]--

    -- LOW VOLTAGE TRIGGER
    line = form.addLine("LOW VOLTAGE ALERT")
    field = form.addNumberField(line, nil, 0, 20000, 
		function() return widget.lwvltge end, 
		function(value) widget.lwvltge = value end
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
		function() return widget.alrthptc end, 
		function(newValue) widget.alrthptc = newValue end
		)

	-- FLIGHT MODE SOURCE
	line = form.addLine("FLIGHT MODE SOURCE")
	form.addChoiceField(line, nil, {{'RF GOVERNOR',0}, {'ETHOS FLIGHT MODES',1}}, 
		function() return widget.fmsrc end, 
		function(newValue) widget.fmsrc = newValue end
		)

    -- TITLE DISPLAY
    line = form.addLine("TITLE DISPLAY")
	form.addChoiceField(line, nil, {{'NO',0}, {'YES',1}}, 
		function() return widget.title end, 
		function(newValue) widget.title = newValue end
		)

    -- MAX MIN DISPLAY
    line = form.addLine("MAX MIN DISPLAY")
	form.addChoiceField(line, nil, {{'NO',0}, {'YES',1}}, 
		function() return widget.maxmin end, 
		function(newValue) widget.maxmin = newValue end
		)

	
	return widgetTable

end


function getRSSI()
    if rssiSensor ~= nil and rssiSensor:state() then
      return rssiSensor:value()
    end
    return 0
end


function screenSmallError()

	local w, h = lcd.getWindowSize()

	lcd.font(FONT_STD)
	str = "DISPLAY SIZE TOO SMALL"			
	tsizeW,tsizeH= lcd.getTextSize(str)			

	if lcd.themeColor(1) == 251666692 then
		-- dark theme
		lcd.color(lcd.RGB(255, 255, 255,1))
	else
		-- light theme
		lcd.color(lcd.RGB(90, 90, 90))
	end	
	lcd.drawText((w/2)-tsizeW/2,(h/2)-tsizeH/2 , str)		
	return
end

local function paint(widget)


		if isInConfiguration == true then
			isInConfiguration = false
		end
			
	
		if type(widget) ~= 'table' then
			
		
			local w, h = lcd.getWindowSize()
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
		
			lcd.font(FONT_STD)
			str = "ERROR - PLEASE RESTART ETHOS"			
			boxW=math.floor(w/2)
			boxH=45
			tsizeW,tsizeH= lcd.getTextSize(str)			

			--draw the background
			if lcd.themeColor(1) == 251666692 then
				lcd.color(lcd.RGB(40, 40, 40))
			else
				lcd.color(lcd.RGB(240, 240, 240))
			end				
			lcd.drawFilledRectangle(w/2-boxW/2, h/2-boxH/2, boxW, boxH) 

			--draw the border
			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(255, 255, 255,1))
			else
				-- light theme
				lcd.color(lcd.RGB(90, 90, 90))
			end				
			lcd.drawRectangle(w/2-boxW/2, h/2-boxH/2, boxW, boxH) 

			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(255, 255, 255,1))
			else
				-- light theme
				lcd.color(lcd.RGB(90, 90, 90))
			end	
			lcd.drawText((w/2)-tsizeW/2,(h/2)-tsizeH/2 , str)		
		    return
		end
		

		if widget.fmsrc == nil then
			return
		end
		if widget.lwvltge== nil then
			return
		end
		if widget.lowfuel== nil then
			return
		end
		if widget.alertint == nil then
			return
		end
		if widget.alrthptc == nil then
			return
		end
		if widget.maxmin == nil then
			return
		end		
		if widget.title == nil then
			return
		end	
		
		-- -----------------------------------------------------------------------------------------------
		-- write values to boxes 
		-- -----------------------------------------------------------------------------------------------	

		local w, h = lcd.getWindowSize()
		
		--[[
		print("Board: " .. environment.board)
		print("Width: " .. w)
		print("Height: " .. h)
		]]--

		if environment.board == "V20" or environment.board == "XES" or environment.board == "X20" or environment.board == "X20S" or environment.board == "X20PRO" then
					if w ~= 784 or h ~= 294 then
					screenSmallError()
					return
				end
		end
		if environment.board == "X18" or environment.board == "X18S" then
					if w ~= 472 or h ~= 191 then
					screenSmallError()
					return
				end
		end
		if environment.board == "X14" or environment.board == "X14S" then
					if w ~= 630 or h ~= 236 then
					screenSmallError()
					return
				end
		end
		if environment.board == "TWXLITE" or environment.board == "TWXLITES" then
					if w ~= 472 or h ~= 191 then
					screenSmallError()
					return
				end
		end
		if environment.board == "X10EXPRESS" then
					if w ~= 472 or h ~= 158 then
					screenSmallError()
					return
				end
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
		
	   if environment.board == "XES" or environment.board == "X20" or environment.board == "X20S" or environment.board == "X20PRO" then	
			colSpacing = 5	
			fullBoxW = w/3
			fullBoxH = h/2
			textOFFSET = 10	
		end

	   if environment.board == "X18" or environment.board == "X18S" then	
			colSpacing = 3	
			fullBoxW = 158
			fullBoxH = 96
			textOFFSET = 10			
		end

	   if environment.board == "X14" or environment.board == "X14S" then	
			colSpacing = 3	
			fullBoxW = 214
			fullBoxH = 118
			textOFFSET = 12			
		end		

	   if environment.board == "TWXLITE" or environment.board == "TWXLITES" then	
			colSpacing = 2	
			fullBoxW = 158
			fullBoxH = 96
			textOFFSET = 12			
		end	

		if environment.board == "X10EXPRESS" then		
			colSpacing = 2	
			fullBoxW = 158
			fullBoxH = 79
			textOFFSET = 12			
		end	
		
		boxW = fullBoxW - colSpacing
		boxH = fullBoxH - colSpacing
		boxHs = fullBoxH/2 - colSpacing
		boxWs = fullBoxW/2 - colSpacing

		
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
		if sensors.fuel ~= nil and widget.lowfuel ~= nil then
			if sensors.fuel <= widget.lowfuel then
					lcd.color(lcd.RGB(255, 0, 0,1))			
			end		
		end
		lcd.font(FONT_XXL)
		if sensors.fuel ~= nil then
			str = "" .. sensors.fuel .. "%"
		else
			str = "0%"
		end
		tsizeW,tsizeH= lcd.getTextSize(str)
		offsetX = boxW/2-tsizeW/2
		offsetY = boxH / 2 - tsizeH/2
		lcd.drawText(col3X+(colSpacing/2) + offsetX, row1Y + offsetY, str)	
		if widget.title == 1 then
			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(255, 255, 255,1))
			else
				-- light theme
				lcd.color(lcd.RGB(90, 90, 90))
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

		if widget.maxmin == 1  and sensors.fuel ~= nil  then
			if linkUP ~= 0 then
		
				if sensors.govmode == 'SPOOLUP' then
					fuelNearlyActive = 1
				end

				if sensors.govmode == 'IDLE' then
						sensorFuelMin = 0
						sensorFuelMax = 0						
				end
		
				if sensors.govmode == 'ACTIVE' then
				
					if fuelNearlyActive == 1 then
						sensorFuelMin = sensors.fuel
						sensorFuelMax = sensors.fuel
						fuelNearlyActive = 0
					end
		
					if sensors.fuel < sensorFuelMin then
						sensorFuelMin = sensors.fuel
					end

					if sensors.fuel > sensorFuelMax then
						sensorFuelMax = sensors.fuel
					end
				end	

			else
				sensorFuelMax = 0
				sensorFuelMin = 0
			end
			
		
			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(255, 255, 255,1))
			else
				-- light theme
				lcd.color(lcd.RGB(90, 90, 90))
			end	
			lcd.font(FONT_XS)
			
				if sensorFuelMin == 0 or sensorFuelMin == nil then
					str = "-"
				else
					str = sensorFuelMin .. "%"
				end

				tsizeW,tsizeH= lcd.getTextSize(str)
				lcd.drawText(col3X+(colSpacing*2), row1Y+(boxH-colSpacing-tsizeH), str)	

				if sensorFuelMax == 0 or sensorFuelMax == nil then
					str = "-  "
				else
					str = sensorFuelMax .. "%"
				end

				tsizeW,tsizeH= lcd.getTextSize(str)
				lcd.drawText((col3X+boxW)-tsizeW, row1Y+(boxH-colSpacing-tsizeH), str)
	
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
	
		if sensors.rpm ~= nil then
			str =  "" .. sensors.rpm .. "rpm"
		else
			str =  "0rpm"
		end
		tsizeW,tsizeH = lcd.getTextSize(str)
		offsetX = boxW/2-tsizeW/2
		offsetY = boxH / 2 - tsizeH/2
		lcd.drawText(col3X+(colSpacing/2) + offsetX, row2Y + offsetY, str)	
		if widget.title == 1 then
			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(255, 255, 255,1))
			else
				-- light theme
				lcd.color(lcd.RGB(90, 90, 90))
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
		if widget.maxmin == 1  and sensors.rpm ~= nil then

			if linkUP ~= 0 then		

				if sensors.govmode == 'SPOOLUP' then
					rpmNearlyActive = 1
				end

				if sensors.govmode == 'IDLE' then
						sensorRPMMin = 0
						sensorRPMMax = 0			
				end
		
				if sensors.govmode == 'ACTIVE' then
					if rpmNearlyActive == 1 then
						sensorRPMMin = sensors.rpm
						sensorRPMMax = sensors.rpm
						rpmNearlyActive = 0
					end				
					if sensors.rpm < sensorRPMMin then
						sensorRPMMin = sensors.rpm
					end
					if sensors.rpm > sensorRPMMax then
						sensorRPMMax = sensors.rpm
					end	
				end
									
			else
				sensorRPMMin = 0
				sensorRPMMax = 0
			end

			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(255, 255, 255,1))
			else
				-- light theme
				lcd.color(lcd.RGB(90, 90, 90))
			end	
			lcd.font(FONT_XS)

				if sensorRPMMin == 0 or sensorRPMMin == nil then
					str = "-"
				else			
					str = sensorRPMMin .. "rpm"
				end	
				tsizeW,tsizeH= lcd.getTextSize(str)
				lcd.drawText(col3X+(colSpacing*2), row2Y+(boxH-colSpacing-tsizeH), str)	

				if sensorRPMMax == 0 or sensorRPMMin == nil  then
					str = "-  "
				else	
					str = sensorRPMMax .. "rpm"
				end	

				tsizeW,tsizeH= lcd.getTextSize(str)
				lcd.drawText((col3X+boxW)-tsizeW, row2Y+(boxH-colSpacing-tsizeH), str)
						
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
		if sensors.voltage <= widget.lwvltge then
				lcd.color(lcd.RGB(255, 0, 0,1))			
		end
		lcd.font(FONT_XXL)
		if sensors.voltage ~= nil then
			str = "" .. tostring(sensors.voltage/100) .. "v"
		else
			str = "0v"
		end
		tsizeW,tsizeH = lcd.getTextSize(str)
		offsetX = boxW/2-tsizeW/2
		offsetY = boxH / 2 - tsizeH/2
		lcd.drawText(col2X+(colSpacing/2) + offsetX, row1Y + offsetY, str)	
		if widget.title == 1 then
		if lcd.themeColor(1) == 251666692 then
			-- dark theme
			lcd.color(lcd.RGB(255, 255, 255,1))
		else
			-- light theme
			lcd.color(lcd.RGB(90, 90, 90))
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
				
		-- voltage should never start at 0.  we prevent this here with a bit of funny stuff			
		if widget.maxmin == 1 and sensors.voltage ~= nil then

			if linkUP ~= 0 then

				if sensors.govmode == 'SPOOLUP' then
					voltageNearlyActive = 1
				end

				if sensors.govmode == 'IDLE' then
						sensorVoltageMin =  0
						sensorVoltageMax = 0
				end
				
				if sensors.govmode == 'ACTIVE' then

					if voltageNearlyActive == 1 then
						sensorVoltageMin = sensors.voltage
						sensorVoltageMax = sensors.voltage
						voltageNearlyActive = 0
					end				
				
					if sensors.voltage < sensorVoltageMin then
						sensorVoltageMin = sensors.voltage
					end
					if sensors.voltage > sensorVoltageMax then
						sensorVoltageMax = sensors.voltage
					end	
				end	
			else
				sensorVoltageMax = 0
				sensorVoltageMin = 0
			end

		if lcd.themeColor(1) == 251666692 then
			-- dark theme
			lcd.color(lcd.RGB(255, 255, 255,1))
		else
			-- light theme
			lcd.color(lcd.RGB(90, 90, 90))
		end	
			lcd.font(FONT_XS)
			
			
			if sensorVoltageMin == 0 or sensorVoltageMax == nil then
				str = "-  "
			else
				str = sensorVoltageMin/100 .. "v"
			end
			
			tsizeW,tsizeH= lcd.getTextSize(str)
			lcd.drawText(col2X+(colSpacing*2), row1Y+(boxH-colSpacing-tsizeH), str)	

			if sensorVoltageMax == 0 or sensorVoltageMax == nil then
				str = "-"
			else
				str = sensorVoltageMax/100 .. "v"
			end	
	
			tsizeW,tsizeH= lcd.getTextSize(str)
			lcd.drawText((col2X+boxW)-tsizeW, row1Y+(boxH-colSpacing-tsizeH), str)
					
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
		if sensors.current ~= nil then
			str = "" .. sensors.current .. "A"
		else
			str = "0A"
		end
		tsizeW,tsizeH = lcd.getTextSize(str)
		offsetX = boxW/2-tsizeW/2
		offsetY = boxH / 2 - tsizeH/2
		lcd.drawText(col2X+(colSpacing/2) + offsetX, row2Y + offsetY, str)	
		if widget.title == 1 then
		if lcd.themeColor(1) == 251666692 then
			-- dark theme
			lcd.color(lcd.RGB(255, 255, 255,1))
		else
			-- light theme
			lcd.color(lcd.RGB(90, 90, 90))
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
		if widget.maxmin == 1  and sensors.current ~= nil then

			if linkUP ~= 0 then		

				if sensors.govmode == 'SPOOLUP' then
					currentNearlyActive = 1
				end

				if sensors.govmode == 'IDLE' then
						sensorCurrentMin = 0
						sensorCurrentMax = 0
				end

				if sensors.govmode == 'ACTIVE' then		
					if currentNearlyActive == 1 then
						sensorCurrentMin = sensors.current
						sensorCurrentMax = sensors.current
						currentNearlyActive = 0
					end				
					if sensors.current < sensorCurrentMin then
						sensorCurrentMin = sensors.current
					end
					if sensors.current > sensorCurrentMax then
						sensorCurrentMax = sensors.current
					end		
				end
			else
				sensorCurrentMax = 0
				sensorCurrentMin = 0
			end

			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(255, 255, 255,1))
			else
				-- light theme
				lcd.color(lcd.RGB(90, 90, 90))
			end	
			lcd.font(FONT_XS)

			if sensorCurrentMin == 0 or sensorCurrentMin == nil then
				str = "-"
			else	
				str = sensorCurrentMin .. "A"
			end	
	
			tsizeW,tsizeH= lcd.getTextSize(str)
			lcd.drawText(col2X+(colSpacing*2), row2Y+(boxH-colSpacing-tsizeH), str)	

			if sensorCurrentMax == 0 or sensorCurrentMax  == nil then
				str = "-  "
			else	
				str = sensorCurrentMax .. "A"
			end

			tsizeW,tsizeH= lcd.getTextSize(str)
			lcd.drawText((col2X+boxW)-tsizeW, row2Y+(boxH-colSpacing-tsizeH), str)
					
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
				lcd.color(lcd.RGB(255, 255, 255,1))
			else
				-- light theme
				lcd.color(lcd.RGB(90, 90, 90))
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
		if sensors.temp_esc ~= nil then
			str = "" .. sensors.temp_esc .. "°"
		else
			str = "0°"			
		end
		tsizeW, tsizeH = lcd.getTextSize(str)
		offsetX = boxWs/2+(colSpacing*2)-tsizeW/2
		offsetY = (boxHs+boxHs/2)+colSpacing - tsizeH/2
		lcd.drawText(col1X+(colSpacing/2) + offsetX, row2Y + offsetY, str)	
		if widget.title == 1 then
		if lcd.themeColor(1) == 251666692 then
			-- dark theme
			lcd.color(lcd.RGB(255, 255, 255,1))
		else
			-- light theme
			lcd.color(lcd.RGB(90, 90, 90))
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
		if widget.maxmin == 1  and sensors.temp_esc ~= nil then

			if linkUP ~= 0 then		
				if sensors.govmode == 'SPOOLUP' then
					temp_escNearlyActive = 1
				end

				if sensors.govmode == 'IDLE' then
						sensorTempESCMin = 0
						sensorTempESCMax = 0
				end				
				
				if sensors.govmode == 'ACTIVE' then			
					if temp_escNearlyActive == 1 then
						sensorTempESCMin = sensors.temp_esc
						sensorTempESCMax = sensors.temp_esc
						temp_escNearlyActive = 0
					end				
					if sensors.temp_esc < sensorTempESCMin then
						sensorTempESCMin = sensors.temp_esc
					end
					if sensors.temp_esc > sensorTempESCMax then
						sensorTempESCMax = sensors.temp_esc
					end	
				end	
			else
				sensorTempESCMax = 0
				sensorTempESCMin = 0
			end
			
			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(255, 255, 255,1))
			else
				-- light theme
				lcd.color(lcd.RGB(90, 90, 90))
			end	
			lcd.font(FONT_XS)
			
			if sensorTempESCMin == 0 or sensorTempESCMin == nil then
				str = "-"
			else	
				str = sensorTempESCMin .. "°"
			end	
			
			tsizeW,tsizeH= lcd.getTextSize(str)
			lcd.drawText(col1X+(colSpacing*2), row2Y+(boxH-colSpacing-tsizeH), str)	

			if sensorTempESCMax == 0 or sensorTempESCMax == nil then
				str = "-  "
			else	
				str = sensorTempESCMax .. "°"
			end	

			tsizeW,tsizeH= lcd.getTextSize(str)
			lcd.drawText((col1X+boxW)/2-tsizeW, row2Y+(boxH-colSpacing-tsizeH), str)
					
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
		if sensors.temp_mcu ~= nil then
			str = "" .. sensors.temp_mcu .. "°"
		else
			str = "0°"			
		end
		tsizeW, tsizeH = lcd.getTextSize(str) 
		offsetX = (boxWs/2+(colSpacing*2)-tsizeW/2)+boxWs
		offsetY = (boxHs+boxHs/2)+colSpacing - tsizeH/2
		lcd.drawText(col1X+(colSpacing/2) + offsetX, row2Y + offsetY, str)	
		if widget.title == 1 then
		if lcd.themeColor(1) == 251666692 then
			-- dark theme
			lcd.color(lcd.RGB(255, 255, 255,1))
		else
			-- light theme
			lcd.color(lcd.RGB(90, 90, 90))
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
		if widget.maxmin == 1  and sensors.temp_mcu ~= nil then

			if linkUP ~= 0 then		
				if sensors.govmode == 'SPOOLUP' then
					temp_mcuNearlyActive = 1
				end		

				if sensors.govmode == 'IDLE' then
						sensorTempMCUMin = 0
						sensorTempMCUMax = 0
				end	

				if sensors.govmode == 'ACTIVE' then			

					if temp_mcuNearlyActive == 1 then
						sensorTempMCUMin = sensors.temp_mcu
						sensorTempMCUMax = sensors.temp_mcu
						temp_mcuNearlyActive = 0
					end				
					if sensors.temp_mcu < sensorTempMCUMin then
						sensorTempMCUMin = sensors.temp_mcu
					end
					if sensors.temp_mcu > sensorTempMCUMax then
						sensorTempMCUMax = sensors.temp_mcu
					end		
				end	
			else
				sensorTempMCUMax = 0
				sensorTempMCUMin = 0
			end

			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(255, 255, 255,1))
			else
				-- light theme
				lcd.color(lcd.RGB(90, 90, 90))
			end	
			lcd.font(FONT_XS)

			if sensorTempMCUMin == 0 or sensorTempMCUMin == nil then
				str = "-"
			else	
				str = sensorTempMCUMin .. "°"
			end

			tsizeW,tsizeH= lcd.getTextSize(str)
			lcd.drawText((col1X+boxW/2)+(colSpacing*2), row2Y+(boxH-colSpacing-tsizeH), str)	

			if sensorTempMCUMax == 0 or sensorTempMCUMax == nil then
				str = "-  "
			else	
				str = sensorTempMCUMax .. "°"
			end	

			tsizeW,tsizeH= lcd.getTextSize(str)
			lcd.drawText((col1X+boxW)+(colSpacing)-tsizeW, row2Y+(boxH-colSpacing-tsizeH), str)
					
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
		lcd.drawBitmap(col1X, row1Y, gfx_model, boxW, boxH)
		
		
		if getRSSI() == 0 and environment.simulation ~= true then

			lcd.font(FONT_STD)
			str = "NO DATA"			
			boxW=math.floor(w/2)
			boxH=45
			tsizeW,tsizeH= lcd.getTextSize(str)			

			--draw the background
			if lcd.themeColor(1) == 251666692 then
				lcd.color(lcd.RGB(40, 40, 40))
			else
				lcd.color(lcd.RGB(240, 240, 240))
			end				
			lcd.drawFilledRectangle(w/2-boxW/2, h/2-boxH/2, boxW, boxH) 

			--draw the border
			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(255, 255, 255,1))
			else
				-- light theme
				lcd.color(lcd.RGB(90, 90, 90))
			end				
			lcd.drawRectangle(w/2-boxW/2, h/2-boxH/2, boxW, boxH) 

			if lcd.themeColor(1) == 251666692 then
				-- dark theme
				lcd.color(lcd.RGB(255, 255, 255,1))
			else
				-- light theme
				lcd.color(lcd.RGB(90, 90, 90))
			end	
			lcd.drawText((w/2)-tsizeW/2,(h/2)-tsizeH/2 , str)
		
		end
		
		-- -----------------------------------------------------------------------------------------------


		-- we only trigger if we have an rssi signal
		if getRSSI() ~= 0 then
			if ((sensors.voltage) <= widget.lwvltge) or  (sensors.fuel <= widget.lowfuel) then		
			
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
		
				if (tonumber(os.clock()) - tonumber(audioAlertCounter)) >=  widget.alertint then
					audioAlertCounter = os.clock()			
					system.playFile("/scripts/rf2status/sounds/lwvltge.wav")
					
					if widget.alrthptc == 1 then
							system.playHaptic("- . -")
					end
				end	
			end	
		end

end








function getSensors()

	if isInConfiguration == true then
		return oldsensors
	end


	
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
			--fm = system.getSource({category=CATEGORY_FLIGHT, member=FLIGHT_CURRENT_MODE}):stringValue()
			rssi = math.random(90,100)		
	--elseif getRSSI() ~= 0 then		
	elseif linkUP ~= 0 then
			if system.getSource("Rx RSSI1") ~= nil then
				-- we are running crsf
				if system.getSource("Rx Batt") ~= nil then
					voltage = system.getSource("Rx Batt"):stringValue()
					if voltage ~= nil then
						voltage = sensorMakeNumber(voltage)*10
					else
						voltage = 0
					end
				else
					voltage = 0
				end 
				if system.getSource("GPS Alt") ~= nil then
					if system.getSource("GPS Alt"):maximum() == 1000.0 then
						system.getSource("GPS Alt"):maximum(65000)
					end
				
					rpm = system.getSource("GPS Alt"):stringValue()	
					if rpm ~= nil then
						rpm = sensorMakeNumber(rpm)	
					else
						rpm = 0
					end
				else
					rpm = 0
				end
				if system.getSource("Rx Curr") ~= nil then
					current = system.getSource("Rx Curr"):stringValue()
					if current ~= nil then
						current = sensorMakeNumber(current)		
					else
						current = 0
					end
				else
					current = 0
				end	
				if system.getSource("GPS Speed") ~= nil then
					temp_esc = system.getSource("GPS Speed"):value()
					if temp_esc ~= nil then
						temp_esc = sensorMakeNumber(temp_esc)/10
					else
						temp_esc = 0
					end
				else
					temp_esc = 0
				end
				if system.getSource("GPS Sats") ~= nil then
					temp_mcu = system.getSource("GPS Sats"):stringValue()
					if temp_mcu ~= nil then					
						temp_mcu = round(sensorMakeNumber(temp_mcu)/1.61,1)
					else
						temp_mcu = 0
					end
				else
					temp_mcu = 0
				end		
				if system.getSource("Rx Batt%") ~= nil then
					fuel = system.getSource("Rx Batt%"):stringValue()
					if fuel ~= nil then					
						fuel = sensorMakeNumber(fuel)		
					else
						fuel = 0
					end
				else
					fuel = 0
				end	
				if system.getSource("Rx Cons") ~= nil then
					mah = system.getSource("Rx Cons"):stringValue()
					if mah ~= nil then
						mah = sensorMakeNumber(mah)		
					else
						mah = 0
					end
				else
					mah = 0
				end	
				if system.getSource("Flight mode") ~= nil then
					govmode = system.getSource("Flight mode"):stringValue()
				end	
				if system.getSource({category=CATEGORY_FLIGHT, member=FLIGHT_CURRENT_MODE}):stringValue() then
					fm = system.getSource({category=CATEGORY_FLIGHT, member=FLIGHT_CURRENT_MODE}):stringValue()
				else
					fm = ''
				end
				rssi =  linkUP		
			else
				-- we are run sport	
				if system.getSource("VFAS") ~= nil then
					voltage = system.getSource("VFAS"):stringValue()
					if voltage ~= nil then
						voltage = sensorMakeNumber(voltage)
					else
						voltage = 0
					end
				else
					voltage = 0
				end 
				if system.getSource("RPM") ~= nil then
					rpm = system.getSource("RPM"):stringValue()	
					if rpm ~= nil then
						rpm = sensorMakeNumber(rpm)	
					else
						rpm = 0
					end	
				else
					rpm = 0
				end
				if system.getSource("Current") ~= nil then
					current = system.getSource("Current"):stringValue()
					if current ~= nil then
						current = sensorMakeNumber(current)		
					else
						current = 0
					end		
				else
					current = 0
				end	
				if system.getSource("ESC temp") ~= nil then
					temp_esc = system.getSource("ESC temp"):stringValue()
					if temp_esc ~= nil then
						temp_esc = sensorMakeNumber(temp_esc)/10
					else
						temp_esc = 0
					end	
				else
					temp_esc = 0
				end
				if system.getSource({category=CATEGORY_TELEMETRY_SENSOR, appId=0x0401}) ~= nil then
					temp_mcu = system.getSource({category=CATEGORY_TELEMETRY_SENSOR, appId=0x0401}):stringValue()		
					if temp_mcu ~= nil then					
						temp_mcu = sensorMakeNumber(temp_mcu)	
					else
						temp_mcu = 0
					end					
				else
					temp_mcu = 0
				end		
				if system.getSource("Fuel") ~= nil then
					fuel = system.getSource("Fuel"):stringValue()
					if fuel ~= nil then					
						fuel = sensorMakeNumber(fuel)		
					else
						fuel = 0
					end					
				else
					fuel = 0
				end	
				if system.getSource("Consumption") ~= nil then
					mah = system.getSource("Consumption"):stringValue()
					if mah ~= nil then
						mah = sensorMakeNumber(mah)		
					else
						mah = 0
					end			
				else
					mah = 0
				end		
				if system.getSource("Mode") ~= nil then
					govmode = system.getSource("Mode"):stringValue()
				else
					govmode = ''
				end					
				if system.getSource({category=CATEGORY_FLIGHT, member=FLIGHT_CURRENT_MODE}):stringValue() then
					fm = system.getSource({category=CATEGORY_FLIGHT, member=FLIGHT_CURRENT_MODE}):stringValue()
				else
					fm = ''
				end
				rssi =  linkUP

		
			end
	else
			-- we have no link.  do something
			voltage = 0
			rpm = 0
			current = 0
			temp_esc =  0
			temp_mcu = 0
			fuel = 0
			mah = 0
			govmode = '-'
			fm = '-'
			rssi = linkUP
	end
	
	-- set flag to refresh screen or not

	if oldsensors.voltage ~= voltage then
				refresh = true
	end
	if oldsensors.rpm ~= rpm then
				refresh = true
	end	
	if oldsensors.current ~= current then
				refresh = true
	end		
	if oldsensors.temp_esc ~= temp_esc then
				refresh = true
	end	
	if oldsensors.temp_mcu ~= temp_mcu then
				refresh = true
	end	
	if oldsensors.govmode ~= govmode then
				refresh = true
	end		
	if oldsensors.fuel ~= fuel then
				refresh = true
	end	
	if oldsensors.mah ~= mah then
				refresh = true
	end	
	if oldsensors.rssi ~= rssi then
				refresh = true
	end	
	if oldsensors.fm ~= CURRENT_FLIGHT_MODE then
				refresh = true
	end

	ret = {fm=fm,govmode=govmode,voltage=voltage,rpm=rpm,current=current,temp_esc=temp_esc,temp_mcu=temp_mcu,fuel=fuel,mah=mah,rssi=rssi}
	oldsensors = ret
	
	return ret
	
end

function sensorMakeNumber(x)
			if x == nil or x == "" then
				x = 0
			end	
			
			x = string.gsub(x,"%D+","")
			x = tonumber(x)	
			if x == nil or x == "" then
				x = 0
			end		

			return x
end

function round(num, dp)
    local mult = 10^(dp or 0)
    return math.floor(num * mult + 0.5)/mult
end

local function read(widget)
        widget.fmsrc = storage.read("fmsrc")
		widget.lwvltge = storage.read("lwvltge")	
		widget.lowfuel = storage.read("lowfuel")	
		widget.alertint = storage.read("alertint")
		widget.alrthptc = storage.read("alrthptc")
		widget.maxmin = storage.read("maxmin")
		widget.title = storage.read("title")
	
		return widget
end

local function write(widget)

        storage.write("fmsrc",widget.fmsrc)
        storage.write("lwvltge",widget.lwvltge)
        storage.write("lowfuel",widget.lowfuel)
        storage.write("alertint",widget.alertint)
        storage.write("alrthptc",widget.alrthptc)
        storage.write("maxmin",widget.maxmin)
        storage.write("title",widget.title)

		return widget
end


local function wakeup(widget)


	refresh = false
	sensors = getSensors()	
	
	linkUP = getRSSI()

	if refresh == true then
		lcd.invalidate()
	end
	
	
	return
end




local function init()
  system.registerWidget({key="rf2st1", name="RF2 Flight Status", create=create, configure=configure,paint=paint, wakeup=wakeup,read=read, write=write})
end

return {init=init}