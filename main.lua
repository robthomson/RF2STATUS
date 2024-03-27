

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
 
voltageNoiseQ= 150;	 
fuelNoiseQ= 150;	 
rpmNoiseQ= 150;	 
temp_mcuNoiseQ = 500;	 
temp_escNoiseQ = 500;
rssiNoiseQ = 50;
currentNoiseQ = 150;

local function create(widget)
    gfx_model = lcd.loadBitmap(model.bitmap())
	gfx_heli =  lcd.loadBitmap("/scripts/rf2status/gfx/heli.png")
    rssiSensor = getRssiSensor()

	return {fmsrc=0,btype=0,lowfuel=20,alertint=5,alrthptc=1,maxmin=1,title=1,cells=6,triggerswitch=nil,govmode=0}
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
            {"NiMh", 4},
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
		end);


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

    lcd.font(FONT_STD)
    str = msg
    tsizeW, tsizeH = lcd.getTextSize(str)

    if  lcd.darkMode() then
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
			supportedRADIO  = true,
			colSpacing = 4,
			fullBoxW = 262,
			fullBoxH = h / 2,
			smallBoxSensortextOFFSET = 0,
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
			fontTITLE = FONT_XS			
		}
    end

    if environment.board == "X18" or environment.board == "X18S" then
		ret = {	
			supportedRADIO  = true,
			colSpacing = 2,
			fullBoxW = 158,
			fullBoxH = 97,
			smallBoxSensortextOFFSET = -3,
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
			fontTITLE = 768		
			
		}	
    end

    if environment.board == "X14" or environment.board == "X14S" then
		ret = {
			supportedRADIO  = true,
			colSpacing = 3,
			fullBoxW = 210,
			fullBoxH = 120,
			smallBoxSensortextOFFSET = -5,
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
			fontTITLE = 768		
		}
    end



    if environment.board == "TWXLITE" or environment.board == "TWXLITES" then
		ret = {
		supportedRADIO  = true,
        colSpacing = 2,
        fullBoxW = 158,
        fullBoxH = 96,
		smallBoxSensortextOFFSET = -5,
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
		fontTITLE = 768			
		}
    end

    if environment.board == "X10EXPRESS" then
		ret = {
			supportedRADIO  = true,
			colSpacing = 2,
			fullBoxW = 158,
			fullBoxH = 79,
			smallBoxSensortextOFFSET = -5,
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
			fontTITLE = FONT_XS					
		}
    end
	
	
	return ret
	
end

local function paint(widget)
 
 


	if tonumber(sensorMakeNumber(environment.version)) < 152 then
            screenError("ETHOS < V1.5.2")
            return	
	end
	
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

		if sensors.voltage ~= nil  then
			if sensors.voltage/100 < (cellVoltage * cellsParam) then
				voltageIsLow = true
			else
				voltageIsLow = false	
			end
		else
				voltageIsLow = false		
		end
	end	


    -- -----------------------------------------------------------------------------------------------
    -- write values to boxes
    -- -----------------------------------------------------------------------------------------------

	local theme = getThemeInfo()
    local w, h = lcd.getWindowSize()


    -- blank out display
    if  lcd.darkMode() then
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
            screenError("DISPLAY SIZE TOO SMALL")
            return
        end
    end
    if environment.board == "X18" or environment.board == "X18S" then
		smallTEXT = true
        if w ~= 472 and h ~= 191 then
            screenError("DISPLAY SIZE TOO SMALL")
            return
        end
    end
    if environment.board == "X14" or environment.board == "X14S" then
        if w ~= 630 and h ~= 236 then
            screenError("DISPLAY SIZE TOO SMALL")
            return
        end
    end
    if environment.board == "TWXLITE" or environment.board == "TWXLITES" then
        if w ~= 472 and h ~= 191 then
            screenError("DISPLAY SIZE TOO SMALL")
            return
        end
    end
    if environment.board == "X10EXPRESS" then
        if w ~= 472 and h ~= 158 then
            screenError("DISPLAY SIZE TOO SMALL")
            return
        end
    end

    boxW = theme.fullBoxW - theme.colSpacing
    boxH = theme.fullBoxH - theme.colSpacing
    boxHs = theme.fullBoxH / 2 - theme.colSpacing
    boxWs = theme.fullBoxW / 2 - theme.colSpacing

    col1X = 0
    col2X = theme.fullBoxW
    col3X = theme.fullBoxW * 2
    row1Y = 0
    row2Y = theme.fullBoxH
    row3Y = theme.fullBoxH * 2

    if  lcd.darkMode() then
        lcd.color(lcd.RGB(40, 40, 40))
    else
        lcd.color(lcd.RGB(240, 240, 240))
    end


    lcd.drawFilledRectangle(col1X, row1Y, boxW, boxHs) -- col 1 row 1 1x1
    lcd.drawFilledRectangle(col1X, row1Y + theme.colSpacing + boxHs + (theme.colSpacing / 3), boxW, boxHs) -- col 1 row 1 1x1

    lcd.drawFilledRectangle(col1X, row2Y + (theme.colSpacing / 2), boxWs, boxHs) -- col 1 row 2 1x1
    lcd.drawFilledRectangle(col1X + boxWs + theme.colSpacing, row2Y + (theme.colSpacing / 2), boxWs, boxHs)

    lcd.drawFilledRectangle(col1X, (row2Y + boxHs + theme.colSpacing) + (theme.colSpacing), boxWs, boxHs) -- col 1 row 2 1x1
    lcd.drawFilledRectangle(col1X + boxWs + theme.colSpacing, (row2Y + boxHs + theme.colSpacing) + (theme.colSpacing), boxWs, boxHs) -- col 1 row 2 1x1

    lcd.drawFilledRectangle(col2X + (theme.colSpacing / 2), row1Y, boxW, boxH) -- col 2 row 1 1x1
    lcd.drawFilledRectangle(col2X + (theme.colSpacing / 2), row2Y + (theme.colSpacing / 2), boxW, boxH) -- col 2 row 2 1x1

    lcd.drawFilledRectangle(col3X + (theme.colSpacing), row1Y, boxW, boxH) -- col 2 row 1 1x1
    lcd.drawFilledRectangle(col3X + (theme.colSpacing), row2Y + (theme.colSpacing / 2), boxW, boxH) -- col 2 row 2 1x1
	

    if  lcd.darkMode() then
        -- dark theme
        lcd.color(lcd.RGB(255, 255, 255, 1))
    else
        -- light theme
        lcd.color(lcd.RGB(90, 90, 90))
    end

    -- FUEL
	
	-- calc fuel if sensor missing
	--print("s" .. sensors.fuel)
    if sensors.voltage ~= 0 and (sensors.fuel == 0) then
		maxCellVoltage = 4.196
		minCellVoltage = 3.2
		avgCellVoltage = sensors.voltage / cellsParam
        batteryPercentage = 100 * (avgCellVoltage - minCellVoltage) / (maxCellVoltage - minCellVoltage);	
        sensors.fuel = batteryPercentage
        if sensors.fuel > 100 then
            sensors.fuel = 100
        end
    end

    if sensors.fuel ~= nil and lowfuelParam ~= nil then
        if sensors.fuel <= lowfuelParam then
            lcd.color(lcd.RGB(255, 0, 0, 1))
        end
    end
    lcd.font(theme.fontSENSOR)
    if sensors.fuel ~= nil then
		if sensors.fuel > 5 then
			str = "" .. sensors.fuel .. "%"
		else
         str = "0%"       
		end
    else
        str = "0%"
    end
    tsizeW, tsizeH = lcd.getTextSize(str)
    offsetX = boxW / 2 - tsizeW / 2
    offsetY = boxH / 2 - tsizeH / 2
    lcd.drawText(col3X + (theme.colSpacing / 2) + offsetX, row1Y + offsetY, str)
    if titleParam == 1 then
        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontTITLE)
        str = theme.title_fuel
        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText(col3X + (theme.colSpacing / 2) + (boxW / 2) - tsizeW / 2, row1Y + (boxH - theme.colSpacing - tsizeH), str)

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontSENSOR)
    end

    if maxminParam == 1 and sensors.fuel ~= nil then
        if linkUP ~= 0 then
            if sensors.govmode == "SPOOLUP" then
                fuelNearlyActive = 1
            end

            if sensors.govmode == "IDLE" then
                sensorFuelMin = 0
                sensorFuelMax = 0
            end

            if sensors.govmode == "ACTIVE" then
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
		
		if environment.simulation == true then
                    sensorFuelMin = sensors.fuel
                    sensorFuelMax = sensors.fuel		
		end

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontTITLE)


        if sensorFuelMin == 0 or sensorFuelMin == nil then
            str = "-"
			str_unit = ""
			str_unit_fake = ""			
        else
            str = sensorFuelMin 
			str_unit = "%"
			str_unit_fake = "A"			
        end

        tsizeW, tsizeH = lcd.getTextSize(str .. str_unit_fake)
        lcd.drawText(col3X + (theme.colSpacing * 2), row1Y + (boxH - theme.colSpacing - tsizeH), str .. str_unit)

        if sensorFuelMax == 0 or sensorFuelMax == nil then
            str = "-"
			str_unit = ""
			str_unit_fake = ""	
        else
            str = sensorFuelMax
			str_unit = "%"
			str_unit_fake = "A"				
        end

        tsizeW, tsizeH = lcd.getTextSize(str .. str_unit_fake)
        lcd.drawText((col3X + boxW) - tsizeW - theme.colSpacing, row1Y + (boxH - theme.colSpacing - tsizeH), str .. str_unit)

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontSENSOR)
    end
	if sensors.fuel ~= nil and lowfuelParam ~= nil then
		if sensors.fuel <= lowfuelParam then
			if  lcd.darkMode() then
				-- dark theme
				lcd.color(lcd.RGB(255, 255, 255, 1))
			else
				-- light theme
				lcd.color(lcd.RGB(90, 90, 90))
			end
		end
	end

    -- RPM
    lcd.font(theme.fontSENSOR)

    if sensors.rpm ~= nil then
		if sensors.rpm <= 5 then
			str = "0rpm"		
		else
			str = "" .. sensors.rpm .. "rpm"
		end	
    else
        str = "0rpm"
    end
    tsizeW, tsizeH = lcd.getTextSize(str)
    offsetX = boxW / 2 - tsizeW / 2
    offsetY = boxH / 2 - tsizeH / 2
    lcd.drawText(col3X + (theme.colSpacing / 2) + offsetX, row2Y + offsetY, str)
    if titleParam == 1 then
        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontTITLE)
        str = theme.title_rpm
        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText(col3X + (theme.colSpacing / 2) + (boxW / 2) - tsizeW / 2, row2Y + (boxH - theme.colSpacing - tsizeH), str)

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontSENSOR)
    end
    if maxminParam == 1 and sensors.rpm ~= nil then
        if linkUP ~= 0 then
            if sensors.govmode == "SPOOLUP" then
                rpmNearlyActive = 1
            end

            if sensors.govmode == "IDLE" then
                sensorRPMMin = 0
                sensorRPMMax = 0
            end

            if sensors.govmode == "ACTIVE" then
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

		if environment.simulation == true then
                    sensorRPMMin = sensors.rpm
                    sensorRPMMax = sensors.rpm		
		end

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontTITLE)

        if sensorRPMMin == 0 or sensorRPMMin == nil then
            str = "-"
			str_unit = ""
			str_unit_fake = ""				
        else
            str = sensorRPMMin
			str_unit = "rpm"
			str_unit_fake = "A"				
        end
        tsizeW, tsizeH = lcd.getTextSize(str .. str_unit_fake)
        lcd.drawText(col3X + (theme.colSpacing * 2), row2Y + (boxH - theme.colSpacing - tsizeH), str .. str_unit)

        if sensorRPMMax == 0 or sensorRPMMin == nil then
            str = "-"
			str_unit = ""
			str_unit_fake = ""				
        else
            str = sensorRPMMax
			str_unit = "rpm"
			str_unit_fake = "rpm"				
        end

        tsizeW, tsizeH = lcd.getTextSize(str .. str_unit_fake)
        lcd.drawText((col3X + boxW) - tsizeW, row2Y + (boxH - theme.colSpacing - tsizeH), str .. str_unit)

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontSENSOR)
    end

    -- VOLT
    if voltageIsLow then
        lcd.color(lcd.RGB(255, 0, 0, 1))
    end
    lcd.font(theme.fontSENSOR)
    if sensors.voltage ~= nil then
		if sensors.voltage > 1 then
			str = "" .. tostring(sensors.voltage / 100) .. "v"
		else
			str = "0v"
		end
    else
        str = "0v"
    end
    tsizeW, tsizeH = lcd.getTextSize(str)
    offsetX = boxW / 2 - tsizeW / 2
    offsetY = boxH / 2 - tsizeH / 2
    lcd.drawText(col2X + (theme.colSpacing / 2) + offsetX, row1Y + offsetY, str)
    if titleParam == 1 then
        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontTITLE)
        str = theme.title_voltage
        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText(col2X + (theme.colSpacing / 2) + (boxW / 2) - tsizeW / 2, row1Y + (boxH - theme.colSpacing - tsizeH), str)

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontSENSOR)
    end

    -- voltage should never start at 0.  we prevent this here with a bit of funny stuff
    if maxminParam == 1 and sensors.voltage ~= nil then
        if linkUP ~= 0 then
            if sensors.govmode == "SPOOLUP" then
                voltageNearlyActive = 1
            end

            if sensors.govmode == "IDLE" then
                sensorVoltageMin = 0
                sensorVoltageMax = 0
            end

            if sensors.govmode == "ACTIVE" then
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

		if environment.simulation == true then
                    sensorVoltageMin = sensors.voltage
                    sensorVoltageMax = sensors.voltage	
		end

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontTITLE)

        if sensorVoltageMin == 0 or sensorVoltageMax == nil then
            str = "-"
			str_unit = ""
			str_unit_fake = ""					
        else
            str = sensorVoltageMin / 100
			str_unit = "v"
			str_unit_fake = "A"					
        end

        tsizeW, tsizeH = lcd.getTextSize(str .. str_unit_fake)
        lcd.drawText(col2X + (theme.colSpacing * 2), row1Y + (boxH - theme.colSpacing - tsizeH), str .. str_unit)

        if sensorVoltageMax == 0 or sensorVoltageMax == nil then
            str = "-"
			str_unit = ""
			str_unit_fake = ""				
        else
            str = sensorVoltageMax / 100
			str_unit = "v"
			str_unit_fake = "v"				
        end

        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText((col2X + boxW) - (theme.colSpacing*2) - tsizeW, row1Y + (boxH - theme.colSpacing - tsizeH), str .. str_unit)

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontSENSOR)
    end
    if  lcd.darkMode() then
        -- dark theme
        lcd.color(lcd.RGB(255, 255, 255, 1))
    else
        -- light theme
        lcd.color(lcd.RGB(90, 90, 90))
    end

    -- CURRENT
    lcd.font(theme.fontSENSOR)
    if sensors.current ~= nil then
		if sensors.current > 1 then
			str = "" .. (sensors.current/10) .. "A"
		else
			str = "0A"
		end
    else
        str = "0A"
    end
    tsizeW, tsizeH = lcd.getTextSize(str)
    offsetX = boxW / 2 - tsizeW / 2
    offsetY = boxH / 2 - tsizeH / 2
    lcd.drawText(col2X + (theme.colSpacing / 2) + offsetX, row2Y + offsetY, str)
    if titleParam == 1 then
        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontTITLE)
        str = theme.title_current
        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText(col2X + (theme.colSpacing / 2) + (boxW / 2) - tsizeW / 2, row2Y + (boxH - theme.colSpacing - tsizeH), str)

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontSENSOR)
    end
    if maxminParam == 1 and sensors.current ~= nil then
        if linkUP ~= 0 then
            if sensors.govmode == "SPOOLUP" then
                currentNearlyActive = 1
            end

            if sensors.govmode == "IDLE" then
                sensorCurrentMin = 0
                sensorCurrentMax = 0
            end

            if sensors.govmode == "ACTIVE" then
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

		if environment.simulation == true then
                    sensorCurrentMin = sensors.current
                    sensorCurrentMax = sensors.current
		end

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontTITLE)

        if sensorCurrentMin == 0 or sensorCurrentMin == nil then
            str = "-"
			str_unit = ""
			str_unit_fake = ""				
        else
            str = sensorCurrentMin/10
			str_unit = "A"
			str_unit_fake = "A"				
        end

        tsizeW, tsizeH = lcd.getTextSize(str .. str_unit_fake)
        lcd.drawText(col2X + (theme.colSpacing * 2), row2Y + (boxH - theme.colSpacing - tsizeH), str .. str_unit)

        if sensorCurrentMax == 0 or sensorCurrentMax == nil then
            str = "-"
			str_unit = ""
			str_unit_fake = ""				
        else
            str = sensorCurrentMax/10
			str_unit = "A"
			str_unit_fake = "A"				
        end

        tsizeW, tsizeH = lcd.getTextSize( str .. str_unit_fake)
        lcd.drawText(col2X + (theme.colSpacing) + boxW - tsizeW - theme.colSpacing, row2Y + (boxH - theme.colSpacing - tsizeH),  str .. str_unit)

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontSENSOR)
    end

    if fmsrcParam == 0 then
        -- GOVERNER
        lcd.font(FONT_STD)
        str = "" .. sensors.govmode
        tsizeW, tsizeH = lcd.getTextSize(str)
        offsetX = boxW / 2 - tsizeW / 2
        offsetY = (boxHs / 2) + theme.colSpacing - tsizeH / 2 + theme.smallBoxSensortextOFFSET
        lcd.drawText(col1X + (theme.colSpacing / 2) + offsetX, row1Y + boxHs + offsetY , str)
        if titleParam == 1 then
            if  lcd.darkMode() then
                -- dark theme
                lcd.color(lcd.RGB(255, 255, 255, 1))
            else
                -- light theme
                lcd.color(lcd.RGB(90, 90, 90))
            end
            lcd.font(theme.fontTITLE)
			str = theme.title_governor
            tsizeW, tsizeH = lcd.getTextSize(str)
            lcd.drawText(col1X + (theme.colSpacing / 2) + (boxW / 2) - tsizeW / 2,row1Y + (boxH - theme.colSpacing - tsizeH),str)

            if  lcd.darkMode() then
                -- dark theme
                lcd.color(lcd.RGB(255, 255, 255, 1))
            else
                -- light theme
                lcd.color(lcd.RGB(90, 90, 90))
            end
            lcd.font(theme.fontSENSOR)
        end
    elseif fmsrcParam == 1 then
        -- SYSTEM FM
        lcd.font(FONT_STD)
        str = "" .. sensors.fm
        tsizeW, tsizeH = lcd.getTextSize(str)
        offsetX = boxW / 2 - tsizeW / 2
        offsetY = (boxHs / 2) + theme.colSpacing - tsizeH / 2 + theme.smallBoxSensortextOFFSET
        lcd.drawText(col1X + (theme.colSpacing / 2) + offsetX, row1Y + boxHs + offsetY, str)
        if titleParam == 1 then
            if  lcd.darkMode() then
                -- dark theme
                lcd.color(lcd.RGB(114, 114, 114))
            else
                -- light theme
                lcd.color(lcd.RGB(180, 180, 180))
            end
            lcd.font(theme.fontTITLE)
             str = theme.title_fm
            tsizeW, tsizeH = lcd.getTextSize(str)
            lcd.drawText(
                col1X + (theme.colSpacing / 2) + (boxW / 2) - tsizeW / 2,
                row1Y + (boxH - theme.colSpacing - tsizeH),
                str
            )

            if  lcd.darkMode() then
                -- dark theme
                lcd.color(lcd.RGB(255, 255, 255, 1))
            else
                -- light theme
                lcd.color(lcd.RGB(90, 90, 90))
            end
            lcd.font(theme.fontSENSOR)
        end
    end

    --  RSSI
    lcd.font(FONT_STD)
    if sensors.rssi ~= nil then
        str = "" .. sensors.rssi .. "%"
    else
        str = "0"
    end
    tsizeW, tsizeH = lcd.getTextSize(str)
    offsetX = boxW / 2 + (theme.colSpacing * 2) - tsizeW / 2
    offsetY = (boxHs + boxHs / 2) + theme.colSpacing - tsizeH / 2 + theme.smallBoxSensortextOFFSET
    lcd.drawText(col1X + (theme.colSpacing / 2) + boxWs / 2 - tsizeW / 2, row1Y + boxHs + offsetY, str)
    if titleParam == 1 then
        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontTITLE)
        str = theme.title_rssi
        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText(col1X + (theme.colSpacing / 2) + boxWs / 2 - tsizeW / 2, row2Y + (boxHs - theme.colSpacing - tsizeH), str)

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontSENSOR)
    end
    if maxminParam == 1 and sensors.rssi ~= nil then
        if linkUP ~= 0 then
            if sensors.govmode == "SPOOLUP" then
                rssiNearlyActive = 1
            end

            if sensors.govmode == "IDLE" then
                sensorRSSIMin = 0
                sensorRSSIMax = 0
            end

            if sensors.govmode == "ACTIVE" then
                if rssiNearlyActive == 1 then
                    sensorRSSIMin = sensors.rssi
                    sensorRSSIMax = sensors.rssi
                    rssiNearlyActive = 0
                end
                if sensors.rssi < sensorRSSIMin then
                    sensorRSSIMin = sensors.rssi
                end
                if sensors.rssi > sensorRSSIMax then
                    sensorRSSIMax = sensors.rssi
                end
            end
        else
            sensorRSSIMax = 0
            sensorRSSIMin = 0
        end

		if environment.simulation == true then
                    sensorRSSIMin = sensors.rssi
                    sensorRSSIMax = sensors.rssi
		end

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontTITLE)

        if sensorRSSIMin == 0 or sensorRSSIMin == nil then
            str = "-"
			str_unit = ""
			str_unit_fake = ""				
        else
            str = sensorRSSIMin 
			str_unit = "%"
			str_unit_fake = "A"				
        end

        tsizeW, tsizeH = lcd.getTextSize(str .. str_unit_fake)
        lcd.drawText(col1X + (theme.colSpacing), row2Y + (boxHs - theme.colSpacing - tsizeH), str .. str_unit)

        if sensorRSSIMax == 0 or sensorRSSIMax == nil then
            str = "-"
			str_unit = ""
			str_unit_fake = ""				
        else
            str = sensorRSSIMax
			str_unit = "%"
			str_unit_fake = "A"				
        end

        tsizeW, tsizeH = lcd.getTextSize(str .. str_unit_fake)
        lcd.drawText(((col1X + boxW) / 2) - tsizeW - (theme.colSpacing*2), row2Y + (boxHs - theme.colSpacing - tsizeH), str .. str_unit)

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontSENSOR)
    end

    -- TEMP ESC
    lcd.font(FONT_STD)
    if sensors.temp_esc ~= nil then
		if sensors.temp_esc > 1 then
			str = "" .. round(sensors.temp_esc/100,1)
		else
			str = "0"
		end
    else
        str = "0"
    end
    tsizeW, tsizeH = lcd.getTextSize(str)
    offsetX = boxWs / 2 + (theme.colSpacing * 2) - tsizeW / 2
    offsetY = (boxHs + boxHs / 2) + theme.colSpacing - tsizeH / 2 + theme.smallBoxSensortextOFFSET
    lcd.drawText(col1X + (theme.colSpacing / 2) + boxWs / 2 - tsizeW / 2, row2Y + offsetY, str .. "°")
    if titleParam == 1 then
        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontTITLE)
        str = theme.title_tempESC
        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText(col1X + (theme.colSpacing / 2) + boxWs / 2 - tsizeW / 2, row2Y + (boxH - theme.colSpacing - tsizeH), str)

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontSENSOR)
    end
    if maxminParam == 1 and sensors.temp_esc ~= nil then
        if linkUP ~= 0 then
            if sensors.govmode == "SPOOLUP" then
                temp_escNearlyActive = 1
            end

            if sensors.govmode == "IDLE" then
                sensorTempESCMin = 0
                sensorTempESCMax = 0
            end

            if sensors.govmode == "ACTIVE" then
                if temp_escNearlyActive == 1 then
                    sensorTempESCMin = round(sensors.temp_esc/100,0)
                    sensorTempESCMax = round(sensors.temp_esc/100,0)
                    temp_escNearlyActive = 0
                end
                if sensors.temp_esc < sensorTempESCMin then
                    sensorTempESCMin = round(sensors.temp_esc/100,0)
                end
                if sensors.temp_esc > sensorTempESCMax then
                    sensorTempESCMax = round(sensors.temp_esc/100,0)
                end
            end
        else
            sensorTempESCMax = 0
            sensorTempESCMin = 0
        end

		if environment.simulation == true then
                    sensorTempESCMin = sensors.temp_esc
                    sensorTempESCMax = sensors.temp_esc
		end


        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontTITLE)

        if sensorTempESCMin == 0 or sensorTempESCMin == nil then
            str = "-"
			str_unit = ""
			str_unit_fake = ""				
        else
            str = sensorTempESCMin
			str_unit = "°"
			str_unit_fake = "A"				
        end

        tsizeW, tsizeH = lcd.getTextSize(str .. str_unit_fake )
        lcd.drawText(col1X + (theme.colSpacing), row2Y + (boxH - theme.colSpacing - tsizeH), str .. str_unit)

        if sensorTempESCMax == 0 or sensorTempESCMax == nil then
            str = "-"
			str_unit = ""
			str_unit_fake = ""			
        else
            str = sensorTempESCMax
			str_unit = "°"
			str_unit_fake = "."			
        end

        tsizeW, tsizeH = lcd.getTextSize(str .. str_unit_fake  )
        lcd.drawText(((col1X + boxW) / 2) - tsizeW - (theme.colSpacing*2), row2Y + (boxH - theme.colSpacing - tsizeH), str .. str_unit )

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontSENSOR)
    end

    -- TEMP MCU
    lcd.font(FONT_STD)
    if sensors.temp_mcu ~= nil then
		if sensors.temp_mcu > 1 then	
			str = "" .. round(sensors.temp_mcu/100,2) .. ""
		else
			str = "0"
		end
    else
        str = "0"
    end
    tsizeW, tsizeH = lcd.getTextSize(str)
    offsetX = (boxWs / 2 + (theme.colSpacing * 2) - tsizeW / 2) + boxWs
    offsetY = (boxHs + boxHs / 2) + theme.colSpacing - tsizeH / 2 + theme.smallBoxSensortextOFFSET
    lcd.drawText(col1X + (theme.colSpacing / 2) + boxWs + theme.colSpacing + boxWs / 2 - tsizeW / 2, row2Y + offsetY, str .. "°")
    if titleParam == 1 then
        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontTITLE)
        str = theme.title_tempMCU
        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText(
            col1X + (theme.colSpacing / 2) + boxWs + theme.colSpacing + boxWs / 2 - tsizeW / 2,
            row2Y + (boxH - theme.colSpacing - tsizeH),
            str
        )

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontSENSOR)
    end
    if maxminParam == 1 and sensors.temp_mcu ~= nil then
        if linkUP ~= 0 then
            if sensors.govmode == "SPOOLUP" then
                temp_mcuNearlyActive = 1
            end

            if sensors.govmode == "IDLE" then
                sensorTempMCUMin = 0
                sensorTempMCUMax = 0
            end

            if sensors.govmode == "ACTIVE" then
                if temp_mcuNearlyActive == 1 then
                    sensorTempMCUMin = round(sensors.temp_mcu/100,0)
                    sensorTempMCUMax = round(sensors.temp_mcu/100,0)
                    temp_mcuNearlyActive = 0
                end
                if sensors.temp_mcu < sensorTempMCUMin then
                    sensorTempMCUMin =round( sensors.temp_mcu/100,0)
                end
                if sensors.temp_mcu > sensorTempMCUMax then
                    sensorTempMCUMax = round(sensors.temp_mcu/100,0)
                end
            end
        else
            sensorTempMCUMax = 0
            sensorTempMCUMin = 0
        end

		if environment.simulation == true then
                    sensorTempMCUMin = sensors.temp_mcu
                    sensorTempMCUMax = sensors.temp_mcu
		end

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontTITLE)

        if sensorTempMCUMin == 0 or sensorTempMCUMin == nil then
            str = "-"
			str_unit = ""
			str_unit_fake = ""				
        else
            str = sensorTempMCUMin
			str_unit = "°"
			str_unit_fake = "."				
        end

        tsizeW, tsizeH = lcd.getTextSize(str .. str_unit_fake)
        lcd.drawText((col1X + boxW / 2) + (theme.colSpacing * 2), row2Y + (boxH - theme.colSpacing - tsizeH), str .. str_unit)

        if sensorTempMCUMax == 0 or sensorTempMCUMax == nil then
            str = "-"
			str_unit = ""
			str_unit_fake = ""				
        else
            str = sensorTempMCUMax
			str_unit = "°"
			str_unit_fake = "."					
        end

        tsizeW, tsizeH = lcd.getTextSize(str .. str_unit_fake)
        lcd.drawText((col1X + boxW)-tsizeW - (theme.colSpacing*2), row2Y + (boxH - theme.colSpacing - tsizeH), str .. str_unit)

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontSENSOR)
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

    lcd.font(FONT_STD)
    if theTIME ~= nil or theTIME == 0 then
        str = SecondsToClock(theTIME)
    else
        str = "00:00:00"
    end
    tsizeW, tsizeH = lcd.getTextSize(str)
    offsetX = (boxWs / 2 + (theme.colSpacing * 2) - tsizeW / 2) + boxWs
    offsetY = (boxHs + boxHs / 2) + theme.colSpacing - tsizeH / 2 + theme.smallBoxSensortextOFFSET
    lcd.drawText(col1X + (theme.colSpacing / 2) + boxWs + theme.colSpacing + boxWs / 2 - tsizeW / 2, row1Y + boxHs + offsetY, str)

    if titleParam == 1 then
        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontTITLE)
        str = theme.title_time
        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText(
            col1X + (theme.colSpacing / 2) + boxWs + theme.colSpacing + boxWs / 2 - tsizeW / 2,
            row2Y + (boxHs - theme.colSpacing - tsizeH),
            str
        )
        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(theme.fontSENSOR)
    end

    -- IMAGE

	if gfx_model ~= nil then
		lcd.drawBitmap(col1X, row1Y, gfx_model, boxW, boxHs)
	else
		lcd.drawBitmap(col1X, row1Y, gfx_heli, boxW, boxHs)
	end

    if getRSSI() == 0 and environment.simulation ~= true then
        lcd.font(FONT_STD)
        str = "NO DATA"
        boxW = math.floor(w / 2)
        boxH = 45
        tsizeW, tsizeH = lcd.getTextSize(str)

        --draw the background
        if  lcd.darkMode() then
            lcd.color(lcd.RGB(40, 40, 40))
        else
            lcd.color(lcd.RGB(240, 240, 240))
        end
        lcd.drawFilledRectangle(w / 2 - boxW / 2, h / 2 - boxH / 2, boxW, boxH)

        --draw the border
        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.drawRectangle(w / 2 - boxW / 2, h / 2 - boxH / 2, boxW, boxH)

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.drawText((w / 2) - tsizeW / 2, (h / 2) - tsizeH / 2, str)
    end


	-- big conditional to trigger lvTimer if needed
	if getRSSI() ~= 0 then
		if  sensors.govmode == "IDLE" or sensors.govmode == "SPOOLUP" or sensors.govmode == "RECOVERY" or sensors.govmode == "ACTIVE" or sensors.govmode == "LOST-HS" or sensors.govmode == "BAILOUT" or sensors.govmode == "RECOVERY" then
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
		
	if 	lvTimer == true then
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
				system.playFile("/scripts/rf2status/sounds/lowvoltage.wav")

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
        --elseif getRSSI() ~= 0 then
        -- we are running simulation
        tv = math.random(2100, 2274)
        voltage = sensorMakeNumber(tv)
        rpm = sensorMakeNumber(math.random(0, 1510))
        current = sensorMakeNumber(math.random(0, 17))
        temp_esc = sensorMakeNumber(math.random(0, 32))
        temp_mcu = sensorMakeNumber(math.random(0, 12))
        fuel = sensorMakeNumber(math.floor(((tv / 10 * 100) / 252)))
        mah = sensorMakeNumber(math.random(10000, 10100))
        govmode = "ACTIVE"
        fm = "DISABLED"
        --fm = system.getSource({category=CATEGORY_FLIGHT, member=FLIGHT_CURRENT_MODE}):stringValue()
        rssi = math.random(90, 100)
    elseif linkUP ~= 0 then
        if system.getSource("Rx RSSI1") ~= nil then
            -- we are running crsf
            if system.getSource("Rx Batt") ~= nil then
                voltage = system.getSource("Rx Batt"):stringValue()
                if voltage ~= nil then
                    voltage = sensorMakeNumber(voltage) * 10
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
                if system.getSource("Rx Curr"):maximum() == 50.0 then
                    system.getSource("Rx Curr"):maximum(400.0)
                end			
			
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
                    temp_esc = (sensorMakeNumber(temp_esc) /10) *100
                else
                    temp_esc = 0
                end
            else
                temp_esc = 0
            end
            if system.getSource("GPS Sats") ~= nil then
                temp_mcu = system.getSource("GPS Sats"):stringValue()
                if temp_mcu ~= nil then
                    temp_mcu = (sensorMakeNumber(temp_mcu) * 100) 
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
            if system.getSource({category = CATEGORY_FLIGHT, member = FLIGHT_CURRENT_MODE}):stringValue() then
                fm = system.getSource({category = CATEGORY_FLIGHT, member = FLIGHT_CURRENT_MODE}):stringValue()
            else
                fm = ""
            end
            if system.getSource("Rx Quality") ~= nil then
                rssi = system.getSource("Rx Quality"):stringValue()
                if rssi ~= nil then
                    rssi = sensorMakeNumber(rssi)
                else
                    rssi = 0
                end
            else
                rssi = 0
            end
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
            if system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x0500}) ~= nil then
                rpm = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x0500}):stringValue()
                if rpm ~= nil then
                    rpm = sensorMakeNumber(rpm)
                else
                    rpm = 0
                end
            else
                rpm = 0
            end
            if system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x0200}) ~= nil then
                current = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x0200}):stringValue()
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
                    temp_esc = sensorMakeNumber(temp_esc)*100
                else
                    temp_esc = 0
                end
            else
                temp_esc = 0
            end
            if system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x0401}) ~= nil then
                temp_mcu = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x0401}):stringValue()
                if temp_mcu ~= nil then
                    temp_mcu = sensorMakeNumber(temp_mcu)*100
                else
                    temp_mcu = 0
                end
            else
                temp_mcu = 0
            end
            if system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x0600}) ~= nil then
                fuel = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x0600}):stringValue()
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
            if system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x5450}) ~= nil then
                govId = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x5450}):stringValue()
                govId = sensorMakeNumber(govId)
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

    -- set flag to refresh screen or not
	
	voltage = kalmanVoltage(voltage,oldsensors.voltage)
	voltage = round(voltage,0)

	rpm = kalmanRPM(rpm,oldsensors.rpm)
	rpm = round(rpm,0)

	temp_mcu = kalmanTempMCU(temp_mcu,oldsensors.temp_mcu)
	temp_mcu = round(temp_mcu,0)

	temp_esc = kalmanTempESC(temp_esc,oldsensors.temp_esc)
	temp_esc = round(temp_esc,0)
	
	
	current = kalmanCurrent(current,oldsensors.current)
	current = round(current,0)	


	rssi = kalmanRSSI(rssi,oldsensors.rssi)
	rssi = round(rssi,0)

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

function kalmanCurrent(new,old)
  if old == nil then
	old = 0
  end
  if new == nil then
	new = 0
  end
  x=old; 
  local p=100; 
  local k=0; 
  p = p + 0.05;
  k = p / (p + currentNoiseQ);
  x = x + k * (new - x);
  p = (1 - k) * p;
  return x;
end


function kalmanRSSI(new,old)
  if old == nil then
	old = 0
  end
  if new == nil then
	new = 0
  end
  x=old; 
  local p=100; 
  local k=0; 
  p = p + 0.05;
  k = p / (p + rssiNoiseQ);
  x = x + k * (new - x);
  p = (1 - k) * p;
  return x;
end
 


function kalmanTempMCU(new,old)
  if old == nil then
	old = 0
  end
  if new == nil then
	new = 0
  end
  x=old; 
  local p=100; 
  local k=0; 
  p = p + 0.05;
  k = p / (p + temp_mcuNoiseQ);
  x = x + k * (new - x);
  p = (1 - k) * p;
  return x;
end
 


function kalmanTempESC(new,old)
  if old == nil then
	old = 0
  end
  if new == nil then
	new = 0
  end
  x=old; 
  local p=100; 
  local k=0; 
  p = p + 0.05;
  k = p / (p + temp_escNoiseQ);
  x = x + k * (new - x);
  p = (1 - k) * p;
  return x;
end
 
function kalmanRPM(new,old)
  if old == nil then
	old = 0
  end
  if new == nil then
	new = 0
  end
  x=old; 
  local p=100; 
  local k=0; 
  p = p + 0.05;
  k = p / (p + rpmNoiseQ);
  x = x + k * (new - x);
  p = (1 - k) * p;
  return x;
end
 
 
function kalmanVoltage(new,old)
  if old == nil then
	old = 0
  end
  if new == nil then
	new = 0
  end
  x=old; 
  local p=100; 
  local k=0; 
  p = p + 0.05;
  k = p / (p + voltageNoiseQ);
  x = x + k * (new - x);
  p = (1 - k) * p;
  return x;
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
   local fmtStr = string.format('%%0.%sf',precision)
   number = string.format(fmtStr,number)
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
	storage.write("govmode", govmodeParam )


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
				if 	lvAnnounceTimer == true then
					--start timer
					if lvAnnounceTimerStart == nil and doneFirst == false then
						lvAnnounceTimerStart = os.time()
						system.playNumber(sensors.voltage/100,2,2)	
						doneFirst = true			
					end	
				else
					lvAnnounceTimerStart = nil
				end
				
				if lvAnnounceTimerStart ~= nil then
					if doneFirst == false then
						if ((tonumber(os.clock()) - tonumber(audioAnnounceCounter)) >= 30) then
								audioAnnounceCounter = os.clock()
								system.playNumber(sensors.voltage/100,2,2)	
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

	if loopCounter == 2 then
		sensors = getSensors()
		loopCounter = 0
	else
		sensors = oldsensors
		loopCounter = loopCounter + 1
	end

    linkUP = getRSSI()


    if refresh == true then
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
end

return {init = init}