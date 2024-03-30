local environment = system.getVersion()
local oldsensors = {
    "refresh",
    "voltage",
    "rpm",
    "current",
    "temp_esc",
    "temp_mcu",
    "fuel",
    "mah",
    "rssi",
    "fm",
    "govmode"
}
local loopCounter = 0
local sensors
local supportedRADIO = false
local gfx_model
local audioAlertCounter = 0
local audioAnnounceCounter = 0
local lvTimer = false
local lvTimerStart
local lvAnnounceTimer = false
local lvAnnounceTimerStart
local linkUP = 0
local refresh = true
local isInConfiguration = false

local stopTimer = true
local startTimer = false
local voltageIsLow = false
local fuelIsLow = false

local fmsrcParam = 0
local btypeParam = 0
local lowfuelParam = 20
local alertintParam = 5
local alrthptcParam = 1
local maxminParam = 1
local titleParam = 1
local cellsParam = 6
local triggerswitchParam = nil
local govmodeParam = 0

sensorVoltageMax = 0
sensorVoltageMin = 0
sensorFuelMin = 0
sensorFuelMax = 0
sensorRPMMin = 0
sensorRPMMax = 0
sensorCurrentMin = 0
sensorCurrentMax = 0
sensorTempMCUMin = 0
sensorTempMCUMax = 0
sensorTempESCMin = 0
sensorTempESCMax = 0
sensorRSSIMin = 0
sensorRSSIMax = 0

voltageNoiseQ = 150
fuelNoiseQ = 150
rpmNoiseQ = 150
temp_mcuNoiseQ = 500
temp_escNoiseQ = 500
rssiNoiseQ = 50
currentNoiseQ = 150

local function create(widget)
    gfx_model = lcd.loadBitmap(model.bitmap())
    gfx_heli = lcd.loadBitmap("/scripts/rf2status/gfx/heli.png")
    rssiSensor = getRssiSensor()

    if tonumber(sensorMakeNumber(environment.version)) < 152 then
        screenError("ETHOS < V1.5.2")
        return
    end

    return {
        fmsrc = 0,
        btype = 0,
        lowfuel = 20,
        alertint = 5,
        alrthptc = 1,
        maxmin = 1,
        title = 1,
        cells = 6,
        triggerswitch = nil,
        govmode = 0
    }
end

local function configure(widget)
    isInConfiguration = true

    -- CELLS
    line = form.addLine("BATTERY TYPE")
    form.addChoiceField(
        line,
        nil,
        {
            {"LiPo", 0},
            {"LiHv", 1},
            {"Lion", 2},
            {"LiFe", 3},
            {"NiMh", 4}
        },
        function()
            return btypeParam
        end,
        function(newValue)
            btypeParam = newValue
        end
    )

    -- BATTERY CELLS
    line = form.addLine("BATTERY CELLS")
    field =
        form.addNumberField(
        line,
        nil,
        0,
        14,
        function()
            return cellsParam
        end,
        function(value)
            cellsParam = value
        end
    )
    field:default(6)

    -- LOW FUEL TRIGGER
    line = form.addLine("LOW FUEL ALERT %")
    field =
        form.addNumberField(
        line,
        nil,
        0,
        1000,
        function()
            return lowfuelParam
        end,
        function(value)
            lowfuelParam = value
        end
    )
    field:default(20)

    -- TRIGGER VOLTAGE READING
    line = form.addLine("VOLTAGE ANNOUNCEMENT")
    form.addSwitchField(
        line,
        form.getFieldSlots(line)[0],
        function()
            return triggerswitchParam
        end,
        function(value)
            triggerswitchParam = value
        end
    )

    -- ALERT INTERVAL
    line = form.addLine("ALERT INTERVAL")
    form.addChoiceField(
        line,
        nil,
        {{"5S", 5}, {"10S", 10}, {"15S", 15}, {"20S", 20}, {"30S", 30}},
        function()
            return alertintParam
        end,
        function(newValue)
            alertintParam = newValue
        end
    )

    -- ALERT INTERVAL
    line = form.addLine("ALERT HAPTIC")
    form.addChoiceField(
        line,
        nil,
        {{"NO", 0}, {"YES", 1}},
        function()
            return alrthptParam
        end,
        function(newValue)
            alrthptParam = newValue
        end
    )

    -- FLIGHT MODE SOURCE
    line = form.addLine("FLIGHT MODE SOURCE")
    form.addChoiceField(
        line,
        nil,
        {
            {"RF GOVERNOR", 0},
            {"ETHOS FLIGHT MODES", 1}
        },
        function()
            return fmsrcParam
        end,
        function(newValue)
            fmsrcParam = newValue
        end
    )

    -- TITLE DISPLAY
    line = form.addLine("TITLE DISPLAY")
    form.addChoiceField(
        line,
        nil,
        {{"NO", 0}, {"YES", 1}},
        function()
            return titleParam
        end,
        function(newValue)
            titleParam = newValue
        end
    )

    -- MAX MIN DISPLAY
    line = form.addLine("MAX MIN DISPLAY")
    form.addChoiceField(
        line,
        nil,
        {{"NO", 0}, {"YES", 1}},
        function()
            return maxminParam
        end,
        function(newValue)
            maxminParam = newValue
        end
    )

    return widget
end

function getRssiSensor()
    local rssiNames = {"RSSI", "RSSI 2.4G", "RSSI 900M", "Rx RSSI1", "Rx RSSI2"}
    for i, name in ipairs(rssiNames) do
        rssiSensor = system.getSource(name)
        if rssiSensor then
            return rssiSensor
        end
    end
end

function getRSSI()
    if rssiSensor ~= nil and rssiSensor:state() then
        return rssiSensor:value()
    end
    return 0
end

function screenError(msg)
    local w, h = lcd.getWindowSize()
	isDARKMODE = lcd.darkMode()
    lcd.font(FONT_STD)
    str = msg
    tsizeW, tsizeH = lcd.getTextSize(str)

    if isDARKMODE then
        -- dark theme
        lcd.color(lcd.RGB(255, 255, 255, 1))
    else
        -- light theme
        lcd.color(lcd.RGB(90, 90, 90))
    end
    lcd.drawText((w / 2) - tsizeW / 2, (h / 2) - tsizeH / 2, str)
    return
end

function noTelem()
	lcd.font(FONT_STD)
	str = "NO DATA"
	
    local theme = getThemeInfo()
    local w, h = lcd.getWindowSize()	
	boxW = math.floor(w / 2)
	boxH = 45
	tsizeW, tsizeH = lcd.getTextSize(str)

	--draw the background
	if isDARKMODE then
		lcd.color(lcd.RGB(40, 40, 40))
	else
		lcd.color(lcd.RGB(240, 240, 240))
	end
	lcd.drawFilledRectangle(w / 2 - boxW / 2, h / 2 - boxH / 2, boxW, boxH)

	--draw the border
	if isDARKMODE then
		-- dark theme
		lcd.color(lcd.RGB(255, 255, 255, 1))
	else
		-- light theme
		lcd.color(lcd.RGB(90, 90, 90))
	end
	lcd.drawRectangle(w / 2 - boxW / 2, h / 2 - boxH / 2, boxW, boxH)

	if isDARKMODE then
		-- dark theme
		lcd.color(lcd.RGB(255, 255, 255, 1))
	else
		-- light theme
		lcd.color(lcd.RGB(90, 90, 90))
	end
	lcd.drawText((w / 2) - tsizeW / 2, (h / 2) - tsizeH / 2, str)
return
end


function getThemeInfo()
    environment = system.getVersion()
    local w, h = lcd.getWindowSize()

    -- first one is unsporrted

    if
        environment.board == "XES" or environment.board == "X20" or environment.board == "X20S" or
            environment.board == "X20PRO" or
            environment.board == "X20PROAW"
     then
        ret = {
            supportedRADIO = true,
            colSpacing = 4,
            fullBoxW = 262,
            fullBoxH = h / 2,
            smallBoxSensortextOFFSET = -5,
            title_voltage = "VOLTAGE",
            title_fuel = "FUEL",
            title_rpm = "HEAD SPEED",
            title_current = "CURRENT",
            title_tempMCU = "MCU",
            title_tempESC = "ESC",
            title_time = "TIMER",
            title_governor = "GOVERNOR",
            title_fm = "FLIGHT MODE",
            title_rssi = "LQ",
            fontSENSOR = FONT_XXL,
			fontSENSORSmallBox = FONT_STD,
            fontTITLE = FONT_XS
        }
    end

    if environment.board == "X18" or environment.board == "X18S" then
        ret = {
            supportedRADIO = true,
            colSpacing = 2,
            fullBoxW = 158,
            fullBoxH = 97,
            smallBoxSensortextOFFSET = -8,
            title_voltage = "VOLTAGE",
            title_fuel = "FUEL",
            title_rpm = "RPM",
            title_current = "CURRENT",
            title_tempMCU = "MCU",
            title_tempESC = "ESC",
            title_time = "TIMER",
            title_governor = "GOVERNOR",
            title_fm = "FLIGHT MODE",
            title_rssi = "LQ",
            fontSENSOR = FONT_XXL,
			fontSENSORSmallBox = FONT_STD,			
            fontTITLE = 768
        }
    end

    if environment.board == "X14" or environment.board == "X14S" then
        ret = {
            supportedRADIO = true,
            colSpacing = 3,
            fullBoxW = 210,
            fullBoxH = 120,
            smallBoxSensortextOFFSET = -10,
            title_voltage = "VOLTAGE",
            title_fuel = "FUEL",
            title_rpm = "RPM",
            title_current = "CURRENT",
            title_tempMCU = "MCU",
            title_tempESC = "ESC",
            title_time = "TIMER",
            title_governor = "GOVERNOR",
            title_fm = "FLIGHT MODE",
            title_rssi = "LQ",
            fontSENSOR = FONT_XXL,
			fontSENSORSmallBox = FONT_STD,			
            fontTITLE = 768
        }
    end

    if environment.board == "TWXLITE" or environment.board == "TWXLITES" then
        ret = {
            supportedRADIO = true,
            colSpacing = 2,
            fullBoxW = 158,
            fullBoxH = 96,
            smallBoxSensortextOFFSET = -10,
            title_voltage = "VOLTAGE",
            title_fuel = "FUEL",
            title_rpm = "RPM",
            title_current = "CURRENT",
            title_tempMCU = "MCU",
            title_tempESC = "ESC",
            title_time = "TIMER",
            title_governor = "GOVERNOR",
            title_fm = "FLIGHT MODE",
            title_rssi = "LQ",
            fontSENSOR = FONT_XXL,
			fontSENSORSmallBox = FONT_STD,			
            fontTITLE = 768
        }
    end

    if environment.board == "X10EXPRESS" then
        ret = {
            supportedRADIO = true,
            colSpacing = 2,
            fullBoxW = 158,
            fullBoxH = 79,
            smallBoxSensortextOFFSET = -10,
            title_voltage = "VOLTAGE",
            title_fuel = "FUEL",
            title_rpm = "RPM",
            title_current = "CURRENT",
            title_tempMCU = "MCU",
            title_tempESC = "ESC",
            title_time = "TIMER",
            title_governor = "GOVERNOR",
            title_fm = "FLIGHT MODE",
            title_rssi = "LQ",
            fontSENSOR = FONT_XXL,
			fontSENSORSmallBox = FONT_STD,			
            fontTITLE = FONT_XS
        }
    end

    return ret
end



local function telemetryBox(x,y,w,h,title,value,unit,smallbox,alarm,minimum,maximum)

	isVisible = lcd.isVisible()
	isDARKMODE = lcd.darkMode()
    local theme = getThemeInfo()
	
	if isDARKMODE then
		lcd.color(lcd.RGB(40, 40, 40))
	else
		lcd.color(lcd.RGB(240, 240, 240))
	end
		
	-- draw box background	
	lcd.drawFilledRectangle(x, y, w, h) 


	-- color	
	if isDARKMODE then
		lcd.color(lcd.RGB(255, 255, 255, 1))
	else
		lcd.color(lcd.RGB(90, 90, 90))
	end

	-- draw sensor text
	if value ~= nil then
	
		if smallbox == nil or smallbox == false then
			lcd.font(theme.fontSENSOR)
		else
			lcd.font(theme.fontSENSORSmallBox)
		end
		
		
		str = value .. unit
		
		if unit == "°" then
			tsizeW, tsizeH = lcd.getTextSize(value .. ".")
		else
			tsizeW, tsizeH = lcd.getTextSize(str)
		end
		
		sx = (x + w/2)-(tsizeW/2)
		if smallbox == nil or smallbox == false then
			sy = (y + h/2)-(tsizeH/2)
		else
			if maxminParam == 0 and titleParam == 0 then
			sy = (y + h/2)-(tsizeH/2) 	
			else
				sy = (y + h/2)-(tsizeH/2) + theme.smallBoxSensortextOFFSET
			end
		end

		if alarm == true then
			lcd.color(lcd.RGB(255, 0, 0, 1))
		end

		lcd.drawText(sx,sy, str)
		
		if alarm == true then
			if isDARKMODE then
				lcd.color(lcd.RGB(255, 255, 255, 1))
			else
				lcd.color(lcd.RGB(90, 90, 90))
			end		
		end	
		
	end	
	
	if title ~= nil and titleParam == 1 then
		lcd.font(theme.fontTITLE)
		str = title 
		tsizeW, tsizeH = lcd.getTextSize(str)
		
		sx = (x + w/2)-(tsizeW/2)
		sy = (y + h)-(tsizeH) - theme.colSpacing

		lcd.drawText(sx,sy, str)
	end	


	if minimum ~= nil and maxminParam == 1 then
		lcd.font(theme.fontTITLE)

		if tostring(minimum) == "-" then
			str = minimum
		else
			str = minimum .. unit
		end
		if unit == "°" then
			tsizeW, tsizeH = lcd.getTextSize(minimum .. ".")
		else
			tsizeW, tsizeH = lcd.getTextSize(str)
		end
		
		sx = (x + theme.colSpacing)
		sy = (y + h)-(tsizeH) - theme.colSpacing
		
		lcd.drawText(sx,sy, str)
	end		
	
	if maximum ~= nil and maxminParam == 1 then
		lcd.font(theme.fontTITLE)

		if tostring(minimum) == "-" then
			str = maximum
		else
			str = maximum .. unit
		end
		if unit == "°" then
			tsizeW, tsizeH = lcd.getTextSize(maximum .. ".")
		else
			tsizeW, tsizeH = lcd.getTextSize(str)
		end
		
		sx = (x + w) - tsizeW - theme.colSpacing
		sy = (y + h)-(tsizeH) - theme.colSpacing

		lcd.drawText(sx,sy, str)
	end			
	
end

local function telemetryBoxImage(x,y,w,h,gfx)

	isVisible = lcd.isVisible()
	isDARKMODE = lcd.darkMode()
    local theme = getThemeInfo()
	
	if isDARKMODE then
		lcd.color(lcd.RGB(40, 40, 40))
	else
		lcd.color(lcd.RGB(240, 240, 240))
	end
		
	-- draw box background	
	lcd.drawFilledRectangle(x, y, w, h) 

    lcd.drawBitmap(x, y, gfx, w, h)


end

local function paint(widget)

	

    isVisible = lcd.isVisible()
	isDARKMODE = lcd.darkMode()

    isInConfiguration = false

    --voltage detection
    if btypeParam ~= nil then
        if btypeParam == 0 then
            --LiPo
            cellVoltage = 3.6
        elseif btypeParam == 1 then
            --LiHv
            cellVoltage = 3.6
        elseif btypeParam == 2 then
            --Lion
            cellVoltage = 3
        elseif btypeParam == 3 then
            --LiFe
            cellVoltage = 2.9
        elseif btypeParam == 4 then
            --NiMh
            cellVoltage = 1.1
        else
            --LiPo (default)
            cellVoltage = 3.6
        end

        if sensors.voltage ~= nil then
            if sensors.voltage / 100 < (cellVoltage * cellsParam) then
                voltageIsLow = true
            else
                voltageIsLow = false
            end
        else
            voltageIsLow = false
        end
    end
	
	-- fuel detection
	if sensors.voltage ~= nil then
		if sensors.fuel < lowfuelParam then
			fuelIsLow = true
		else
			fuelIsLow = false
		end
	else
		fuelIsLow = false
	end
		
    -- -----------------------------------------------------------------------------------------------
    -- write values to boxes
    -- -----------------------------------------------------------------------------------------------

    local theme = getThemeInfo()
    local w, h = lcd.getWindowSize()

    if isVisible then
        -- blank out display
        if isDARKMODE then
            -- dark theme
            lcd.color(lcd.RGB(16, 16, 16))
        else
            -- light theme
            lcd.color(lcd.RGB(209, 208, 208))
        end
        lcd.drawFilledRectangle(0, 0, w, h)

        -- hard error
        if theme.supportedRADIO ~= true then
            screenError("UNKNOWN " .. environment.board)
            return
        end

        -- widget size
        if
            environment.board == "V20" or environment.board == "XES" or environment.board == "X20" or
                environment.board == "X20S" or
                environment.board == "X20PRO" or
                environment.board == "X20PROAW"
         then
            if w ~= 784 and h ~= 294 then
                screenError("DISPLAY SIZE INVALID")
                return
            end
        end
        if environment.board == "X18" or environment.board == "X18S" then
            smallTEXT = true
            if w ~= 472 and h ~= 191 then
                screenError("DISPLAY SIZE INVALID")
                return
            end
        end
        if environment.board == "X14" or environment.board == "X14S" then
            if w ~= 630 and h ~= 236 then
                screenError("DISPLAY SIZE INVALID")
                return
            end
        end
        if environment.board == "TWXLITE" or environment.board == "TWXLITES" then
            if w ~= 472 and h ~= 191 then
                screenError("DISPLAY SIZE INVALID")
                return
            end
        end
        if environment.board == "X10EXPRESS" then
            if w ~= 472 and h ~= 158 then
                screenError("DISPLAY SIZE INVALID")
                return
            end
        end

        boxW = theme.fullBoxW - theme.colSpacing
        boxH = theme.fullBoxH - theme.colSpacing
		
        boxHs = theme.fullBoxH / 2 - theme.colSpacing
        boxWs = theme.fullBoxW / 2 - theme.colSpacing


		--IMAGE
		posX = 0
		posY = theme.colSpacing
		if gfx_model ~= nil then
			telemetryBoxImage(posX,posY,boxW,boxHs,gfx_model)
		else
			telemetryBoxImage(posX,posY,boxW,boxHs,gfx_heli)
		end
		
		--FUEL
		if sensors.fuel ~= nil then
		
			posX =  boxW + theme.colSpacing + boxW + theme.colSpacing
			posY = theme.colSpacing
			sensorUNIT = "%"
			sensorWARN = false	
			smallBOX = false

			if fuelIsLow then
				sensorWARN = true	
			end
		
			if sensors.fuel > 5 then
				sensorVALUE = sensors.fuel
			else
				sensorVALUE = "0"
			end
		
			if titleParam == 1 then
				sensorTITLE = "FUEL"
			else
				sensorTITLE = ""		
			end

			if sensorFuelMin == 0 or sensorFuelMin == nil then
					sensorMIN = "-"
			else 
					sensorMIN = sensorFuelMin
			end
			
			if sensorFuelMax == 0 or sensorFuelMax == nil then
					sensorMAX = "-"
			else 
					sensorMAX = sensorFuelMax
			end
			
			telemetryBox(posX,posY,boxW,boxH,sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)
		end

		--RPM
		if sensors.rpm ~= nil then
		
			posX = boxW + theme.colSpacing + boxW + theme.colSpacing
			posY = boxH+(theme.colSpacing*2)
			sensorUNIT = "rpm"
			sensorWARN = false
			smallBOX = false
		
			sensorVALUE = sensors.rpm
		
			if titleParam == 1 then
				sensorTITLE = theme.title_rpm
			else
				sensorTITLE = ""		
			end

			if sensorRPMMin == 0 or sensorRPMMin == nil then
					sensorMIN = "-"
			else 
					sensorMIN = sensorRPMMin
			end
			
			if sensorRPMMax == 0 or sensorRPMMax == nil then
					sensorMAX = "-"
			else 
					sensorMAX = sensorRPMMax
			end
			
			telemetryBox(posX,posY,boxW,boxH,sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)
		end

		--VOLTAGE
		if sensors.voltage ~= nil then
		
			posX = boxW + theme.colSpacing
			posY = theme.colSpacing
			sensorUNIT = "v"
			sensorWARN = false	
			smallBOX = false

			if voltageIsLow then
				sensorWARN = true	
			end
		
			sensorVALUE = sensors.voltage/100
		
			if titleParam == 1 then
				sensorTITLE = theme.title_voltage
			else
				sensorTITLE = ""		
			end

			if sensorVoltageMin == 0 or sensorVoltageMin == nil then
					sensorMIN = "-"
			else 
					sensorMIN = sensorVoltageMin/100
			end
			
			if sensorVoltageMax == 0 or sensorVoltageMax == nil then
					sensorMAX = "-"
			else 
					sensorMAX = sensorVoltageMax/100
			end
			
			telemetryBox(posX,posY,boxW,boxH,sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)
		end
		
		--CURRENT
		if sensors.current ~= nil then
		
			posX = boxW + theme.colSpacing
			posY =  boxH+(theme.colSpacing*2)
			sensorUNIT = "A"
			sensorWARN = false	
			smallBOX = false
	

			sensorVALUE = sensors.current/100
			
			if titleParam == 1 then
				sensorTITLE = theme.title_current
			else
				sensorTITLE = ""		
			end

			if sensorCurrentMin == 0 or sensorCurrentMin == nil then
					sensorMIN = "-"
			else 
					sensorMIN = sensorCurrentMin
			end
			
			if sensorCurrentMax == 0 or sensorCurrentMax == nil then
					sensorMAX = "-"
			else 
					sensorMAX = sensorCurrentMax
			end
	
			telemetryBox(posX,posY,boxW,boxH,sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)
		end		

		--TEMP ESC
		if sensors.temp_esc ~= nil then
		
			posX = 0
			posY =  boxH+(theme.colSpacing*2)+boxHs+theme.colSpacing
			sensorUNIT = "°"
			sensorWARN = false
			smallBOX = true	
	
			sensorVALUE = round(sensors.temp_esc/100,0)
		
			if titleParam == 1 then
				sensorTITLE = theme.title_tempESC
			else
				sensorTITLE = ""		
			end

			if sensorTempESCMin == 0 or sensorTempESCMin == nil then
					sensorMIN = "-"
			else 
					sensorMIN = sensorTempESCMin
			end
			
			if sensorTempESCMax == 0 or sensorTempESCMax == nil then
					sensorMAX = "-"
			else 
					sensorMAX = sensorTempESCMax
			end
	
			telemetryBox(posX,posY,boxWs,boxHs,sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)
		end	

		--TEMP MCU
		if sensors.temp_mcu ~= nil then
		
			posX = boxWs+theme.colSpacing
			posY =  boxH+(theme.colSpacing*2)+boxHs+theme.colSpacing
			sensorUNIT = "°"
			sensorWARN = false
			smallBOX = true	
	
			sensorVALUE = round(sensors.temp_mcu/100,0)
			
			if titleParam == 1 then
				sensorTITLE = theme.title_tempMCU
			else
				sensorTITLE = ""		
			end

			if sensorTempMCUMin == 0 or sensorTempMCUMin == nil then
					sensorMIN = "-"
			else 
					sensorMIN = sensorTempMCUMin
			end
			
			if sensorTempMCUMax == 0 or sensorTempMCUMax == nil then
					sensorMAX = "-"
			else 
					sensorMAX = sensorTempMCUMax
			end
	
			telemetryBox(posX,posY,boxWs,boxHs,sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)
		end	

		--RSSI
		if sensors.rssi ~= nil then
		
			posX = 0
			posY =  boxH+(theme.colSpacing*2)
			sensorUNIT = "°"
			sensorWARN = false
			smallBOX = true	
	
			sensorVALUE = sensors.rssi
			
			if titleParam == 1 then
				sensorTITLE = theme.title_rssi
			else
				sensorTITLE = ""		
			end

			if sensorRSSIMin == 0 or sensorRSSIMin == nil then
					sensorMIN = "-"
			else 
					sensorMIN = sensorRSSIMin
			end
			
			if sensorRSSIMaxMax == 0 or sensorRSSIMax == nil then
					sensorMAX = "-"
			else 
					sensorMAX = sensorRSSIMax
			end
	
			telemetryBox(posX,posY,boxWs,boxHs,sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)
		end	

	-- TIMER
		posX = boxWs+theme.colSpacing
		posY =  boxH+(theme.colSpacing*2)
		sensorUNIT = ""
		sensorWARN = false
		smallBOX = true		
		sensorMIN = nil
		sensorMAX = nil
	
        if theTIME ~= nil or theTIME == 0 then
            str = SecondsToClock(theTIME)
        else
            str = "00:00:00"
        end
		
		if titleParam == 1 then
			sensorTITLE = theme.title_time
		else
			sensorTITLE = ""		
		end		
	   
	    sensorVALUE = str
       
	    telemetryBox(posX,posY,boxWs,boxHs,sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)


		--FLIGHT MODES
		posX = 0
		posY =  boxHs+(theme.colSpacing*2)
		sensorUNIT = ""
		sensorWARN = false
		smallBOX = true		
		sensorMIN = nil
		sensorMAX = nil

		if fmsrcParam == 0 then		
            if sensors.govmode == nil then
                sensors.govmode = "INIT"
            end
            str = sensors.govmode
			sensorTITLE = theme.title_governor
		else
			str = sensors.fm
			sensorTITLE = theme.title_fm			
		end
		sensorVALUE = str

		if titleParam ~= 1 then
			sensorTITLE = ""		
		end	

	    telemetryBox(posX,posY,boxW,boxHs,sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)

		--if linkUP == 0 then
        if linkUP == 0 and environment.simulation ~= true then
			noTelem()
		end

	end
		
	
    -- TIME
    if linkUP ~= 0 then
        if sensors.govmode == "SPOOLUP" then
            timerNearlyActive = 1
        end

        if sensors.govmode == "IDLE" then
            stopTimer = true
            stopTIME = os.clock()
            theTIME = 0
        end

        if sensors.govmode == "ACTIVE" then
            if timerNearlyActive == 1 then
                timerNearlyActive = 0
                startTIME = os.clock()
            end

            theTIME = os.clock() - startTIME
        end
    else
        -- default as no timer not not yet spooled up
        theTIME = 0
    end

    -- big conditional to trigger lvTimer if needed
    if linkUP then
        if
            sensors.govmode == "IDLE" or sensors.govmode == "SPOOLUP" or sensors.govmode == "RECOVERY" or
                sensors.govmode == "ACTIVE" or
                sensors.govmode == "LOST-HS" or
                sensors.govmode == "BAILOUT" or
                sensors.govmode == "RECOVERY"
         then
            if (voltageIsLow) or (sensors.fuel <= lowfuelParam) then
                lvTimer = true
            else
                lvTimer = false
            end
        else
            lvTimer = false
        end
    else
        lvTimer = false
    end

    if lvTimer == true then
        --start timer
        if lvTimerStart == nil then
            lvTimerStart = os.time()
        end
    else
        lvTimerStart = nil
    end

    if lvTimerStart ~= nil then
        if (os.time() - lvTimerStart >= 5) then
            -- only trigger if we have been on for 5 seconds or more
            if (tonumber(os.clock()) - tonumber(audioAlertCounter)) >= alertintParam then
                audioAlertCounter = os.clock()
                --system.playFile("/scripts/rf2status/sounds/lowvoltage.wav")
                system.playNumber(sensors.voltage / 100, 2, 2)
                if alrthptParam == 1 then
                    system.playHaptic("- . -")
                end
            end
        end
    else
        -- stop timer
        lvTimerStart = nil
    end
end



function getSensors()
    if isInConfiguration == true then
        return oldsensors
    end

    if environment.simulation == true then
        -- we are running simulation
        tv = math.random(2100, 2274)
        voltage = tv
        rpm = math.random(0, 1510)		
        current = math.random(0, 17)
        temp_esc = math.random(1510, 1520)
        temp_mcu = math.random(1510, 1520)
        fuel = math.floor(math.random(15, 25))
        mah = math.random(10000, 10100)
        govmode = "ACTIVE"
        fm = "DISABLED"
        rssi = math.random(90, 100)
		
		
		
    elseif linkUP ~= 0 then
        local telemetrySOURCE = system.getSource("Rx RSSI1")
        if telemetrySOURCE ~= nil then
            -- we are running crsf
            local voltageSOURCE = system.getSource("Rx Batt")
            if voltageSOURCE ~= nil then
                voltage = voltageSOURCE:value()
                if voltage ~= nil then
                    voltage = voltage * 100
                else
                    voltage = 0
                end
            else
                voltage = 0
            end
            local rpmSOURCE = system.getSource("GPS Alt")
            if rpmSOURCE ~= nil then
                if rpmSOURCE:maximum() == 1000.0 then
                    rpmSOURCE:maximum(65000)
                end

                rpm = rpmSOURCE:value()
                if rpm ~= nil then
                    rpm = rpm
                else
                    rpm = 0
                end
            else
                rpm = 0
            end
            local currentSOURCE = system.getSource("Rx Curr")
            if currentSOURCE ~= nil then
                if currentSOURCE:maximum() == 50.0 then
                    currentSOURCE:maximum(400.0)
                end

                current = currentSOURCE:value()
                if current ~= nil then
                    current = current * 10
                else
                    current = 0
                end
            else
                current = 0
            end

            temp_escSOURCE = system.getSource("GPS Speed")
            if temp_escSOURCE ~= nil then
                temp_esc = temp_escSOURCE:value()
                if temp_esc ~= nil then
                    temp_esc = temp_esc * 1000
                else
                    temp_esc = 0
                end
            else
                temp_esc = 0
            end
            local temp_mcuSOURCE = system.getSource("GPS Sats")
            if temp_mcuSOURCE ~= nil then
                temp_mcu = temp_mcuSOURCE:value()
                if temp_mcu ~= nil then
                    temp_mcu = (temp_mcu) * 100
                else
                    temp_mcu = 0
                end
            else
                temp_mcu = 0
            end
            local fuelSOURCE = system.getSource("Rx Batt%")
            if fuelSOURCE ~= nil then
                fuel = fuelSOURCE:value()
                if fuel ~= nil then
                    fuel = fuel
                else
                    fuel = 0
                end
            else
                fuel = 0
            end
            local mahSOURCE = system.getSource("Rx Cons")
            if mahSOURCE ~= nil then
                mah = mahSOURCE:value()
                if mah ~= nil then
                    mah = mah
                else
                    mah = 0
                end
            else
                mah = 0
            end
            local govSOURCE = system.getSource("Flight mode")
            if govSOURCE ~= nil then
                govmode = govSOURCE:stringValue()
            end
            if system.getSource({category = CATEGORY_FLIGHT, member = FLIGHT_CURRENT_MODE}):stringValue() then
                fm = system.getSource({category = CATEGORY_FLIGHT, member = FLIGHT_CURRENT_MODE}):stringValue()
            else
                fm = ""
            end
            local rssiSOURCE = system.getSource("Rx Quality")
            if rssiSOURCE ~= nil then
                rssi = rssiSOURCE:value()
                if rssi ~= nil then
                    rssi = rssi
                else
                    rssi = 0
                end
            else
                rssi = 0
            end
        else
            -- we are run sport
            voltageSOURCE = system.getSource("VFAS")
            if voltageSOURCE ~= nil then
                voltage = voltageSOURCE:value()
                if voltage ~= nil then
                    voltage = voltage * 100
                else
                    voltage = 0
                end
            else
                voltage = 0
            end
            rpmSOURCE = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x0500})
            if rpmSOURCE ~= nil then
                rpm = rpmSOURCE:value()
                if rpm ~= nil then
                    rpm = rpm
                else
                    rpm = 0
                end
            else
                rpm = 0
            end
            local currentSOURCE = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x0200})
            if currentSOURCE ~= nil then
                current = currentSOURCE:value()
                if current ~= nil then
                    current = current * 10
                else
                    current = 0
                end
            else
                current = 0
            end
            local temp_escSOURCE = system.getSource("ESC temp")
            if temp_escSOURCE ~= nil then
                temp_esc = temp_escSOURCE:value()
                if temp_esc ~= nil then
                    temp_esc = temp_esc * 100
                else
                    temp_esc = 0
                end
            else
                temp_esc = 0
            end
            local temp_mcuSOURCE = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x0401})
            if temp_mcuSOURCE ~= nil then
                temp_mcu = temp_mcuSOURCE:value()
                if temp_mcu ~= nil then
                    temp_mcu = temp_mcu * 100
                else
                    temp_mcu = 0
                end
            else
                temp_mcu = 0
            end
            local fuelSOURCE = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x0600})
            if fuelSOURCE ~= nil then
                fuel = fuelSOURCE:value()
                if fuel ~= nil then
                    fuel = fuel
                else
                    fuel = 0
                end
            else
                fuel = 0
            end
            local mahSOURCE = system.getSource("Consumption")
            if mahSOURCE ~= nil then
                mah = mahSOURCE:value()
                if mah ~= nil then
                    mah = mah
                else
                    mah = 0
                end
            else
                mah = 0
            end
            local govSOURCE = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x5450})
            if govSOURCE ~= nil then
                govId = govSOURCE:value()

                --print(govId)
                if govId == 0 then
                    govmode = "OFF"
                elseif govId == 1 then
                    govmode = "IDLE"
                elseif govId == 2 then
                    govmode = "SPOOLUP"
                elseif govId == 3 then
                    govmode = "RECOVERY"
                elseif govId == 4 then
                    govmode = "ACTIVE"
                elseif govId == 5 then
                    govmode = "THR-OFF"
                elseif govId == 6 then
                    govmode = "LOST-HS"
                elseif govId == 7 then
                    govmode = "SPOOLUP"
                elseif govId == 8 then
                    govmode = "BAILOUT"
                elseif govId == 100 then
                    govmode = "DISABLED"
                elseif govId == 101 then
                    govmode = "DISARMED"
                else
                    govmode = "UNKNOWN"
                end
            else
                govmode = ""
            end
            if system.getSource({category = CATEGORY_FLIGHT, member = FLIGHT_CURRENT_MODE}):stringValue() then
                fm = system.getSource({category = CATEGORY_FLIGHT, member = FLIGHT_CURRENT_MODE}):stringValue()
            else
                fm = ""
            end

            rssi = linkUP
						
        end
    else
        -- we have no link.  do something
        voltage = 0
        rpm = 0
        current = 0
        temp_esc = 0
        temp_mcu = 0
        fuel = 0
        mah = 0
        govmode = "-"
        fm = "-"
        rssi = linkUP
    end

    if voltage ~= 0 and (fuel == 0) then
        maxCellVoltage = 4.196
        minCellVoltage = 3.2
        avgCellVoltage = voltage / cellsParam
        batteryPercentage = 100 * (avgCellVoltage - minCellVoltage) / (maxCellVoltage - minCellVoltage)
        sensors.fuel = batteryPercentage
        if fuel > 100 then
            fuel = 100
        end
    end


    -- set flag to refresh screen or not

    voltage = kalmanVoltage(voltage, oldsensors.voltage)
    voltage = round(voltage, 0)

    rpm = kalmanRPM(rpm, oldsensors.rpm)
    rpm = round(rpm, 0)

    temp_mcu = kalmanTempMCU(temp_mcu, oldsensors.temp_mcu)
    temp_mcu = round(temp_mcu, 0)

    temp_esc = kalmanTempESC(temp_esc, oldsensors.temp_esc)
    temp_esc = round(temp_esc, 0)

    current = kalmanCurrent(current, oldsensors.current)
    current = round(current, 0)

    rssi = kalmanRSSI(rssi, oldsensors.rssi)
    rssi = round(rssi, 0)

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

    ret = {
        fm = fm,
        govmode = govmode,
        voltage = voltage,
        rpm = rpm,
        current = current,
        temp_esc = temp_esc,
        temp_mcu = temp_mcu,
        fuel = fuel,
        mah = mah,
        rssi = rssi
    }
    oldsensors = ret

    return ret
end

function sensorsMAXMIN(sensors)


    if linkUP ~= 0 then
        if sensors.govmode == "SPOOLUP" then
            govNearlyActive = 1
        end

        if sensors.govmode == "IDLE" then
            sensorVoltageMin = 0
            sensorVoltageMax = 0
            sensorFuelMin = 0
            sensorFuelMax = 0
            sensorRPMMin = 0
            sensorRPMMax = 0
            sensorCurrentMin = 0
            sensorCurrentMax = 0
            sensorRSSIMin = 0
            sensorRSSIMax = 0
            sensorTempMCUMin = 0
            sensorTempMCUMax = 0
            sensorTempESCMin = 0
            sensorTempESCMax = 0
        end

        if sensors.govmode == "ACTIVE" then
            if govNearlyActive == 1 then
                sensorVoltageMin = sensors.voltage
                sensorVoltageMax = sensors.voltage
                sensorFuelMin = sensors.fuel
                sensorFuelMax = sensors.fuel
                sensorRPMMin = sensors.rpm
                sensorRPMMax = sensors.rpm
                sensorCurrentMin = sensors.current
                sensorCurrentMax = sensors.current
                sensorRSSIMin = sensors.rssi
                sensorRSSIMax = sensors.rssi
                sensorTempMCUMin = round(sensors.temp_mcu / 100, 0)
                sensorTempMCUMax = round(sensors.temp_mcu / 100, 0)
                sensorTempESCMin = round(sensors.temp_esc / 100, 0)
                sensorTempESCMax = round(sensors.temp_esc / 100, 0)
                govNearlyActive = 0
            end

            if sensors.voltage < sensorVoltageMin then
                sensorVoltageMin = sensors.voltage
            end
            if sensors.voltage > sensorVoltageMax then
                sensorVoltageMax = sensors.voltage
            end

            if sensors.fuel < sensorFuelMin then
                sensorFuelMin = sensors.fuel
            end

            if sensors.fuel > sensorFuelMax then
                sensorFuelMax = sensors.fuel
            end

            if sensors.rpm < sensorRPMMin then
                sensorRPMMin = sensors.rpm
            end
            if sensors.rpm > sensorRPMMax then
                sensorRPMMax = sensors.rpm
            end
            if sensors.current < sensorCurrentMin then
                sensorCurrentMin = sensors.current
            end
            if sensors.current > sensorCurrentMax then
                sensorCurrentMax = sensors.current
            end
            if sensors.rssi < sensorRSSIMin then
                sensorRSSIMin = sensors.rssi
            end
            if sensors.rssi > sensorRSSIMax then
                sensorRSSIMax = sensors.rssi
            end
            if sensors.temp_mcu < sensorTempMCUMin then
                sensorTempMCUMin = round(sensors.temp_mcu / 100, 0)
            end
            if sensors.temp_mcu > sensorTempMCUMax then
                sensorTempMCUMax = round(sensors.temp_mcu / 100, 0)
            end
        end
    else
        sensorVoltageMax = 0
        sensorVoltageMin = 0
        sensorFuelMin = 0
        sensorFuelMax = 0
        sensorRPMMin = 0
        sensorRPMMax = 0
        sensorCurrentMin = 0
        sensorCurrentMax = 0
        sensorTempMCUMin = 0
        sensorTempMCUMax = 0
        sensorTempESCMin = 0
        sensorTempESCMax = 0
    end

    if environment.simulation == true then
        sensorVoltageMin = sensors.voltage
        sensorVoltageMax = sensors.voltage
        sensorFuelMin = sensors.fuel
        sensorFuelMax = sensors.fuel
        sensorRPMMin = sensors.rpm
        sensorRPMMax = sensors.rpm
        sensorCurrentMin = sensors.current
        sensorCurrentMax = sensors.current
        sensorRSSIMin = sensors.rssi
        sensorRSSIMax = sensors.rssi
        sensorTempMCUMin = round(sensors.temp_mcu / 100, 0)
        sensorTempMCUMax = round(sensors.temp_mcu / 100, 0)
        sensorTempESCMin = round(sensors.temp_esc / 100, 0)
        sensorTempESCMax = round(sensors.temp_esc / 100, 0)
    end  
end

function kalmanCurrent(new, old)
    if old == nil then
        old = 0
    end
    if new == nil then
        new = 0
    end
    x = old
    local p = 100
    local k = 0
    p = p + 0.05
    k = p / (p + currentNoiseQ)
    x = x + k * (new - x)
    p = (1 - k) * p
    return x
end

function kalmanRSSI(new, old)
    if old == nil then
        old = 0
    end
    if new == nil then
        new = 0
    end
    x = old
    local p = 100
    local k = 0
    p = p + 0.05
    k = p / (p + rssiNoiseQ)
    x = x + k * (new - x)
    p = (1 - k) * p
    return x
end

function kalmanTempMCU(new, old)
    if old == nil then
        old = 0
    end
    if new == nil then
        new = 0
    end
    x = old
    local p = 100
    local k = 0
    p = p + 0.05
    k = p / (p + temp_mcuNoiseQ)
    x = x + k * (new - x)
    p = (1 - k) * p
    return x
end

function kalmanTempESC(new, old)
    if old == nil then
        old = 0
    end
    if new == nil then
        new = 0
    end
    x = old
    local p = 100
    local k = 0
    p = p + 0.05
    k = p / (p + temp_escNoiseQ)
    x = x + k * (new - x)
    p = (1 - k) * p
    return x
end

function kalmanRPM(new, old)
    if old == nil then
        old = 0
    end
    if new == nil then
        new = 0
    end
    x = old
    local p = 100
    local k = 0
    p = p + 0.05
    k = p / (p + rpmNoiseQ)
    x = x + k * (new - x)
    p = (1 - k) * p
    return x
end

function kalmanVoltage(new, old)
    if old == nil then
        old = 0
    end
    if new == nil then
        new = 0
    end
    x = old
    local p = 100
    local k = 0
    p = p + 0.05
    k = p / (p + voltageNoiseQ)
    x = x + k * (new - x)
    p = (1 - k) * p
    return x
end

function sensorMakeNumber(x)
    if x == nil or x == "" then
        x = 0
    end

    x = string.gsub(x, "%D+", "")
    x = tonumber(x)
    if x == nil or x == "" then
        x = 0
    end

    return x
end

function round(number, precision)
    local fmtStr = string.format("%%0.%sf", precision)
    number = string.format(fmtStr, number)
    number = tonumber(number)
    return number
end

function SecondsToClock(seconds)
    local seconds = tonumber(seconds)

    if seconds <= 0 then
        return "00:00:00"
    else
        hours = string.format("%02.f", math.floor(seconds / 3600))
        mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)))
        secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60))
        return hours .. ":" .. mins .. ":" .. secs
    end
end

function SecondsFromTime(seconds)
    local seconds = tonumber(seconds)

    if seconds <= 0 then
        return "0"
    else
        hours = string.format("%02.f", math.floor(seconds / 3600))
        mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)))
        secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60))
        return tonumber(secs)
    end
end

local function read(widget)
    fmsrcParam = storage.read("fmsrc")
    btypeParam = storage.read("btype")
    lowfuelParam = storage.read("lowfuel")
    alertintParam = storage.read("alertint")
    alrthptParam = storage.read("alrthptc")
    maxminParam = storage.read("maxmin")
    titleParam = storage.read("title")
    cellsParam = storage.read("cells")
    triggerswitchParam = storage.read("triggerswitch")
    govmodeParam = storage.read("govmode")
end

local function write(widget)
    storage.write("fmsrc", fmsrcParam)
    storage.write("btype", btypeParam)
    storage.write("lowfuel", lowfuelParam)
    storage.write("alertint", alertintParam)
    storage.write("alrthptc", alrthptParam)
    storage.write("maxmin", maxminParam)
    storage.write("title", titleParam)
    storage.write("cells", cellsParam)
    storage.write("triggerswitch", triggerswitchParam)
    storage.write("govmode", govmodeParam)
end

function playVoltage(widget)
    if triggerswitchParam ~= nil then
        if triggerswitchParam:state() then
            lvAnnounceTimer = true
            doneFirst = false
        else
            lvAnnounceTimer = false
            doneFirst = true
        end

        if isInConfiguration == false then
            if sensors.voltage ~= nil then
                if lvAnnounceTimer == true then
                    --start timer
                    if lvAnnounceTimerStart == nil and doneFirst == false then
                        lvAnnounceTimerStart = os.time()
                        system.playNumber(sensors.voltage / 100, 2, 2)
                        doneFirst = true
                    end
                else
                    lvAnnounceTimerStart = nil
                end

                if lvAnnounceTimerStart ~= nil then
                    if doneFirst == false then
                        if ((tonumber(os.clock()) - tonumber(audioAnnounceCounter)) >= 30) then
                            audioAnnounceCounter = os.clock()
                            system.playNumber(sensors.voltage / 100, 2, 2)
                        end
                    end
                else
                    -- stop timer
                    lvAnnounceTimerStart = nil
                end
            end
        end
    end
end

local function wakeup(widget)
    refresh = false

    linkUP = getRSSI()
    sensors = getSensors()

    if refresh == true then
        sensorsMAXMIN(sensors)	
        lcd.invalidate()
    end

    playVoltage(widget)
    return
end

local function init()
    system.registerWidget(
        {
            key = "xkshss",
            name = "RF2 Flight Status",
            create = create,
            configure = configure,
            paint = paint,
            wakeup = wakeup,
            read = read,
            write = write
        }
    )

    system.compile("/scripts/rf2status/main.lua")
end

return {init = init}
