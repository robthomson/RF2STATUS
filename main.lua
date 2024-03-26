

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
temp_mcuNoiseQ= 500;	 
temp_escNoiseQ= 500;
rssiNoiseQ= 50;

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
			print(newValue)
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

local function paint(widget)
  
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

    local w, h = lcd.getWindowSize()

	--print(sensorMakeNumber(environment.version))


	if tonumber(sensorMakeNumber(environment.version)) < 152 then
            screenError("ETHOS < V1.5.3")
            return	
	end


    if
        environment.board == "V20" or environment.board == "XES" or environment.board == "X20" or
            environment.board == "X20S" or
            environment.board == "X20PRO" or
			environment.board == "X20PROAW"
     then
		supportedRADIO = true
        if w ~= 784 and h ~= 294 then
            screenError("DISPLAY SIZE TOO SMALL")
            return
        end
    end
    if environment.board == "X18" or environment.board == "X18S" then
		supportedRADIO = true
        if w ~= 472 and h ~= 191 then
            screenError("DISPLAY SIZE TOO SMALL")
            return
        end
    end
    if environment.board == "X14" or environment.board == "X14S" then
		supportedRADIO = true
        if w ~= 630 and h ~= 236 then
            screenError("DISPLAY SIZE TOO SMALL")
            return
        end
    end
    if environment.board == "TWXLITE" or environment.board == "TWXLITES" then
		supportedRADIO = true
        if w ~= 472 and h ~= 191 then
            screenError("DISPLAY SIZE TOO SMALL")
            return
        end
    end
    if environment.board == "X10EXPRESS" then
		supportedRADIO = true
        if w ~= 472 and h ~= 158 then
            screenError("DISPLAY SIZE TOO SMALL")
            return
        end
    end

    -- blank out display
    if  lcd.darkMode() then
        -- dark theme
        lcd.color(lcd.RGB(16, 16, 16))
    else
        -- light theme
        lcd.color(lcd.RGB(209, 208, 208))
    end
    lcd.drawFilledRectangle(0, 0, w, h)



    if
        environment.board == "XES" or environment.board == "X20" or environment.board == "X20S" or
            environment.board == "X20PRO" or
			environment.board == "X20PROAW"			
     then
        colSpacing = 4
        fullBoxW = 262
        fullBoxH = h / 2
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
	
	if supportedRADIO == false then
		            screenError("UNKNOWN " .. environment.board)
					return
	end

    boxW = fullBoxW - colSpacing
    boxH = fullBoxH - colSpacing
    boxHs = fullBoxH / 2 - colSpacing
    boxWs = fullBoxW / 2 - colSpacing

    col1X = 0
    col2X = fullBoxW
    col3X = fullBoxW * 2
    row1Y = 0
    row2Y = fullBoxH
    row3Y = fullBoxH * 2

    if  lcd.darkMode() then
        lcd.color(lcd.RGB(40, 40, 40))
    else
        lcd.color(lcd.RGB(240, 240, 240))
    end


    lcd.drawFilledRectangle(col1X, row1Y, boxW, boxHs) -- col 1 row 1 1x1
    lcd.drawFilledRectangle(col1X, row1Y + colSpacing + boxHs + (colSpacing / 3), boxW, boxHs) -- col 1 row 1 1x1

    lcd.drawFilledRectangle(col1X, row2Y + (colSpacing / 2), boxWs, boxHs) -- col 1 row 2 1x1
    lcd.drawFilledRectangle(col1X + boxWs + colSpacing, row2Y + (colSpacing / 2), boxWs, boxHs)

    lcd.drawFilledRectangle(col1X, (row2Y + boxHs + colSpacing) + (colSpacing), boxWs, boxHs) -- col 1 row 2 1x1
    lcd.drawFilledRectangle(col1X + boxWs + colSpacing, (row2Y + boxHs + colSpacing) + (colSpacing), boxWs, boxHs) -- col 1 row 2 1x1

    lcd.drawFilledRectangle(col2X + (colSpacing / 2), row1Y, boxW, boxH) -- col 2 row 1 1x1
    lcd.drawFilledRectangle(col2X + (colSpacing / 2), row2Y + (colSpacing / 2), boxW, boxH) -- col 2 row 2 1x1

    lcd.drawFilledRectangle(col3X + (colSpacing), row1Y, boxW, boxH) -- col 2 row 1 1x1
    lcd.drawFilledRectangle(col3X + (colSpacing), row2Y + (colSpacing / 2), boxW, boxH) -- col 2 row 2 1x1
	

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
    lcd.font(FONT_XXL)
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
    lcd.drawText(col3X + (colSpacing / 2) + offsetX, row1Y + offsetY, str)
    if titleParam == 1 then
        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(FONT_XS)
        str = "FUEL"
        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText(col3X + (colSpacing / 2) + (boxW / 2) - tsizeW / 2, row1Y + (boxH - colSpacing - tsizeH), str)

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(FONT_XXL)
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

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
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

        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText(col3X + (colSpacing * 2), row1Y + (boxH - colSpacing - tsizeH), str)

        if sensorFuelMax == 0 or sensorFuelMax == nil then
            str = "-  "
        else
            str = sensorFuelMax .. "%"
        end

        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText((col3X + boxW) - tsizeW, row1Y + (boxH - colSpacing - tsizeH), str)

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(FONT_XXL)
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
    lcd.font(FONT_XXL)

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
    lcd.drawText(col3X + (colSpacing / 2) + offsetX, row2Y + offsetY, str)
    if titleParam == 1 then
        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(FONT_XS)
        str = "HEAD SPEED"
        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText(col3X + (colSpacing / 2) + (boxW / 2) - tsizeW / 2, row2Y + (boxH - colSpacing - tsizeH), str)

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(FONT_XXL)
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

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
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
        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText(col3X + (colSpacing * 2), row2Y + (boxH - colSpacing - tsizeH), str)

        if sensorRPMMax == 0 or sensorRPMMin == nil then
            str = "-  "
        else
            str = sensorRPMMax .. "rpm"
        end

        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText((col3X + boxW) - tsizeW, row2Y + (boxH - colSpacing - tsizeH), str)

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(FONT_XXL)
    end

    -- VOLT
    if voltageIsLow then
        lcd.color(lcd.RGB(255, 0, 0, 1))
    end
    lcd.font(FONT_XXL)
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
    lcd.drawText(col2X + (colSpacing / 2) + offsetX, row1Y + offsetY, str)
    if titleParam == 1 then
        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(FONT_XS)
        str = "VOLTAGE"
        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText(col2X + (colSpacing / 2) + (boxW / 2) - tsizeW / 2, row1Y + (boxH - colSpacing - tsizeH), str)

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(FONT_XXL)
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

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(FONT_XS)

        if sensorVoltageMin == 0 or sensorVoltageMax == nil then
            str = "-  "
        else
            str = sensorVoltageMin / 100 .. "v"
        end

        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText(col2X + (colSpacing * 2), row1Y + (boxH - colSpacing - tsizeH), str)

        if sensorVoltageMax == 0 or sensorVoltageMax == nil then
            str = "-"
        else
            str = sensorVoltageMax / 100 .. "v"
        end

        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText((col2X + boxW) - tsizeW, row1Y + (boxH - colSpacing - tsizeH), str)

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(FONT_XXL)
    end
    if  lcd.darkMode() then
        -- dark theme
        lcd.color(lcd.RGB(255, 255, 255, 1))
    else
        -- light theme
        lcd.color(lcd.RGB(90, 90, 90))
    end

    -- CURRENT
    lcd.font(FONT_XXL)
	--print(sensors.current)
    if sensors.current ~= nil then
		if sensors.current > 1 then
			str = "" .. sensors.current .. "A"
		else
			str = "0A"
		end
    else
        str = "0A"
    end
    tsizeW, tsizeH = lcd.getTextSize(str)
    offsetX = boxW / 2 - tsizeW / 2
    offsetY = boxH / 2 - tsizeH / 2
    lcd.drawText(col2X + (colSpacing / 2) + offsetX, row2Y + offsetY, str)
    if titleParam == 1 then
        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(FONT_XS)
        str = "CURRENT"
        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText(col2X + (colSpacing / 2) + (boxW / 2) - tsizeW / 2, row2Y + (boxH - colSpacing - tsizeH), str)

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(FONT_XXL)
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

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
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

        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText(col2X + (colSpacing * 2), row2Y + (boxH - colSpacing - tsizeH), str)

        if sensorCurrentMax == 0 or sensorCurrentMax == nil then
            str = "-  "
        else
            str = sensorCurrentMax .. "A"
        end

        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText((col2X + boxW) - tsizeW, row2Y + (boxH - colSpacing - tsizeH), str)

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(FONT_XXL)
    end

    if fmsrcParam == 0 then
        -- GOVERNER
        lcd.font(FONT_STD)
        str = "" .. sensors.govmode
        tsizeW, tsizeH = lcd.getTextSize(str)
        offsetX = boxW / 2 - tsizeW / 2
        offsetY = (boxHs / 2) + colSpacing - tsizeH / 2
        lcd.drawText(col1X + (colSpacing / 2) + offsetX, row1Y + boxHs + offsetY, str)
        if titleParam == 1 then
            if  lcd.darkMode() then
                -- dark theme
                lcd.color(lcd.RGB(255, 255, 255, 1))
            else
                -- light theme
                lcd.color(lcd.RGB(90, 90, 90))
            end
            lcd.font(FONT_XS)
            str = "GOVERNOR"
            tsizeW, tsizeH = lcd.getTextSize(str)
            lcd.drawText(
                col1X + (colSpacing / 2) + (boxW / 2) - tsizeW / 2,
                row1Y + (boxH / 2 - colSpacing - tsizeH) + boxHs,
                str
            )

            if  lcd.darkMode() then
                -- dark theme
                lcd.color(lcd.RGB(255, 255, 255, 1))
            else
                -- light theme
                lcd.color(lcd.RGB(90, 90, 90))
            end
            lcd.font(FONT_XXL)
        end
    elseif fmsrcParam == 1 then
        -- SYSTEM FM
        lcd.font(FONT_STD)
        str = "" .. sensors.fm
        tsizeW, tsizeH = lcd.getTextSize(str)
        offsetX = boxW / 2 - tsizeW / 2
        offsetY = (boxHs / 2) + colSpacing - tsizeH / 2
        lcd.drawText(col1X + (colSpacing / 2) + offsetX, row1Y + boxHs + offsetY, str)
        if titleParam == 1 then
            if  lcd.darkMode() then
                -- dark theme
                lcd.color(lcd.RGB(114, 114, 114))
            else
                -- light theme
                lcd.color(lcd.RGB(180, 180, 180))
            end
            lcd.font(FONT_XS)
            str = "FLIGHT MODE"
            tsizeW, tsizeH = lcd.getTextSize(str)
            lcd.drawText(
                col1X + (colSpacing / 2) + (boxW / 2) - tsizeW / 2,
                row1Y + (boxH / 2 - colSpacing - tsizeH) + boxHs,
                str
            )

            if  lcd.darkMode() then
                -- dark theme
                lcd.color(lcd.RGB(255, 255, 255, 1))
            else
                -- light theme
                lcd.color(lcd.RGB(90, 90, 90))
            end
            lcd.font(FONT_XXL)
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
    offsetX = boxW / 2 + (colSpacing * 2) - tsizeW / 2
    offsetY = (boxHs + boxHs / 2) + colSpacing - tsizeH / 2
    lcd.drawText(col1X + (colSpacing / 2) + boxWs / 2 - tsizeW / 2, row1Y + boxHs + offsetY, str)
    if titleParam == 1 then
        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(FONT_XS)
        str = "LQ"
        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText(col1X + (colSpacing / 2) + boxWs / 2 - tsizeW / 2, row2Y + (boxHs - colSpacing - tsizeH), str)

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(FONT_XXL)
    end
    if maxminParam == 1 and sensors.rssi ~= nil then
        if linkUP ~= 0 then
            if sensors.govmode == "SPOOLUP" then
                rssiNearlyActive = 1
            end

            if sensors.govmode == "IDLE" then
                sensorTempRSSIMin = 0
                sensorTempRSSIMax = 0
            end

            if sensors.govmode == "ACTIVE" then
                if rssiNearlyActive == 1 then
                    sensorTempRSSIMin = sensors.rssi
                    sensorTempRSSIMax = sensors.rssi
                    rssiNearlyActive = 0
                end
                if sensors.rssi < sensorTempRSSIMin then
                    sensorTempRSSIMin = sensors.rssi
                end
                if sensors.rssi > sensorTempRSSIMax then
                    sensorTempRSSIMax = sensors.rssi
                end
            end
        else
            sensorTempRSSIMax = 0
            sensorTempRSSIMin = 0
        end

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(FONT_XS)

        if sensorTempRSSIMin == 0 or sensorTempRSSIMin == nil then
            str = "-"
        else
            str = sensorTempRSSIMin .. "%"
        end

        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText(col1X + (colSpacing * 2), row2Y + (boxHs + -colSpacing - tsizeH), str)

        if sensorTempRSSIMax == 0 or sensorTempRSSIMax == nil then
            str = "-  "
        else
            str = sensorTempRSSIMax .. "% "
        end

        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText((col1X + boxW) / 2 - tsizeW, row2Y + (boxHs + -colSpacing - tsizeH), str)

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(FONT_XXL)
    end

    -- TEMP ESC
    lcd.font(FONT_STD)
    if sensors.temp_esc ~= nil then
		if sensors.temp_esc > 1 then
			str = "" .. sensors.temp_esc
		else
			str = "0"
		end
    else
        str = "0"
    end
    tsizeW, tsizeH = lcd.getTextSize(str)
    offsetX = boxWs / 2 + (colSpacing * 2) - tsizeW / 2
    offsetY = (boxHs + boxHs / 2) + colSpacing - tsizeH / 2
    lcd.drawText(col1X + (colSpacing / 2) + boxWs / 2 - tsizeW / 2, row2Y + offsetY, str .. "°")
    if titleParam == 1 then
        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(FONT_XS)
        str = "ESC"
        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText(col1X + (colSpacing / 2) + boxWs / 2 - tsizeW / 2, row2Y + (boxH - colSpacing - tsizeH), str)

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(FONT_XXL)
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

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
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

        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText(col1X + (colSpacing * 2), row2Y + (boxH - colSpacing - tsizeH), str)

        if sensorTempESCMax == 0 or sensorTempESCMax == nil then
            str = "-  "
        else
            str = sensorTempESCMax .. "°"
        end

        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText((col1X + boxW) / 2 - tsizeW, row2Y + (boxH - colSpacing - tsizeH), str)

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(FONT_XXL)
    end

    -- TEMP MCU
    lcd.font(FONT_STD)
    if sensors.temp_mcu ~= nil then
		if sensors.temp_mcu > 1 then	
			str = "" .. sensors.temp_mcu .. ""
		else
			str = "0"
		end
    else
        str = "0"
    end
    tsizeW, tsizeH = lcd.getTextSize(str)
    offsetX = (boxWs / 2 + (colSpacing * 2) - tsizeW / 2) + boxWs
    offsetY = (boxHs + boxHs / 2) + colSpacing - tsizeH / 2
    lcd.drawText(col1X + (colSpacing / 2) + boxWs + colSpacing + boxWs / 2 - tsizeW / 2, row2Y + offsetY, str .. "°")
    if titleParam == 1 then
        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(FONT_XS)
        str = "MCU"
        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText(
            col1X + (colSpacing / 2) + boxWs + colSpacing + boxWs / 2 - tsizeW / 2,
            row2Y + (boxH - colSpacing - tsizeH),
            str
        )

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(FONT_XXL)
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

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
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

        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText((col1X + boxW / 2) + (colSpacing * 2), row2Y + (boxH - colSpacing - tsizeH), str)

        if sensorTempMCUMax == 0 or sensorTempMCUMax == nil then
            str = "-  "
        else
            str = sensorTempMCUMax .. "°"
        end

        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText((col1X + boxW) + (colSpacing) - tsizeW, row2Y + (boxH - colSpacing - tsizeH), str)

        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(FONT_XXL)
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
    offsetX = (boxWs / 2 + (colSpacing * 2) - tsizeW / 2) + boxWs
    offsetY = (boxHs + boxHs / 2) + colSpacing - tsizeH / 2
    lcd.drawText(col1X + (colSpacing / 2) + boxWs + colSpacing + boxWs / 2 - tsizeW / 2, row1Y + boxHs + offsetY, str)

    if titleParam == 1 then
        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(FONT_XS)
        str = "TIME"
        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText(
            col1X + (colSpacing / 2) + boxWs + colSpacing + boxWs / 2 - tsizeW / 2,
            row2Y + (boxHs - colSpacing - tsizeH),
            str
        )
        if  lcd.darkMode() then
            -- dark theme
            lcd.color(lcd.RGB(255, 255, 255, 1))
        else
            -- light theme
            lcd.color(lcd.RGB(90, 90, 90))
        end
        lcd.font(FONT_XXL)
    end

    -- IMAGE

	if gfx_model ~= nil then
		lcd.drawBitmap(col1X, row1Y - boxHs / 3, gfx_model, boxW, boxH - boxHs / 2)
	else
		lcd.drawBitmap(col1X, row1Y - boxHs / 3, gfx_heli, boxW, boxH - boxHs / 2)
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
        govmode = "DISABLED"
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
                    current = sensorMakeNumber(current) / 10
                else
                    current = 0
                end
            else
                current = 0
            end
            if system.getSource("GPS Speed") ~= nil then
                temp_esc = system.getSource("GPS Speed"):value()
                if temp_esc ~= nil then
                    temp_esc = sensorMakeNumber(temp_esc) / 10
                else
                    temp_esc = 0
                end
            else
                temp_esc = 0
            end
            if system.getSource("GPS Sats") ~= nil then
                temp_mcu = system.getSource("GPS Sats"):stringValue()
                if temp_mcu ~= nil then
                    temp_mcu = round(sensorMakeNumber(temp_mcu) / 1.61, 1)
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
                    temp_esc = sensorMakeNumber(temp_esc) / 10
                else
                    temp_esc = 0
                end
            else
                temp_esc = 0
            end
            if system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x0401}) ~= nil then
                temp_mcu = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x0401}):stringValue()
                if temp_mcu ~= nil then
                    temp_mcu = sensorMakeNumber(temp_mcu)
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

	temp_esc = kalmanTempESC(temp_mcu,oldsensors.temp_esc)
	temp_esc = round(temp_esc,0)

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
    sensors = getSensors()
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