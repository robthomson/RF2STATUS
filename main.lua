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

local showLOGS=false
local readLOGS=false
local readLOGSlast = {}


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

local timerWASActive = false
local govWasActive = false
local maxMinSaved = false

local simPreSPOOLUP=false
local simDoSPOOLUP=false
local simDODISARM=false
local simDoSPOOLUPCount = 0
local actTime

local maxminFinals1 = nil
local maxminFinals2 = nil
local maxminFinals3 = nil
local maxminFinals4 = nil
local maxminFinals5 = nil
local maxminFinals6 = nil
local maxminFinals7 = nil
local maxminFinals8 = nil

closeButtonX = 0
closeButtonY = 0 
closeButtonW = 0
closeButtonH = 0

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
lastMaxMin = 0

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
	gfx_close = lcd.loadBitmap("/scripts/rf2status/gfx/close.png")
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
        govmode = 0,
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

	resetALL()

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
	if environment.simulation == true then
		return 100
	end
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

function resetALL()
	showLOGS = false
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
            fontTITLE = FONT_XS,
			fontPopupTitle = FONT_S,
			widgetTitleOffset = 20,
			logsCOL1w = 60,
			logsCOL2w = 120,
			logsCOL3w = 120,
			logsCOL4w = 170,
			logsCOL5w = 110,
			logsCOL6w = 90,
			logsCOL7w = 90,
			logsHeaderOffset = 5
			
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
            fontTITLE = 768,
			fontPopupTitle = FONT_S,
			widgetTitleOffset = 20,
			logsCOL1w = 50,
			logsCOL2w = 100,
			logsCOL3w = 100,
			logsCOL4w = 140,
			logsCOL5w = 0,
			logsCOL6w = 0,
			logsCOL7w = 75,
			logsHeaderOffset = 5
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
            fontTITLE = 768,
			fontPopupTitle = FONT_S,
			widgetTitleOffset = 20,
			logsCOL1w = 70,
			logsCOL2w = 140,
			logsCOL3w = 120,
			logsCOL4w = 170,
			logsCOL5w = 0,
			logsCOL6w = 0,
			logsCOL7w = 120,
			logsHeaderOffset = 5
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
            fontTITLE = 768,
			fontPopupTitle = FONT_S,
			widgetTitleOffset = 20,
			logsCOL1w = 50,
			logsCOL2w = 100,
			logsCOL3w = 100,
			logsCOL4w = 140,
			logsCOL5w = 0,
			logsCOL6w = 0,
			logsCOL7w = 75,
			logsHeaderOffset = 5
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
            fontTITLE = FONT_XS,
			fontPopupTitle = FONT_S,
			widgetTitleOffset = 20,
			logsCOL1w = 50,
			logsCOL2w = 100,
			logsCOL3w = 100,
			logsCOL4w = 140,
			logsCOL5w = 0,
			logsCOL6w = 0,
			logsCOL7w = 75,
			logsHeaderOffset = 5
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


	if maxminParam == 1 then	

		if minimum ~= nil then
		
			lcd.font(theme.fontTITLE)

			if tostring(minimum) ~= "-" then
					lastMin = minimum
			end

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
		
		if maximum ~= nil then
			lcd.font(theme.fontTITLE)

			if tostring(maximum) == "-" then
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
	
end

function logsBOX()

	

	if readLOGS == false then
		local history = readHistory()	
		readLOGSlast = history
		readLOGS = true
	else	
		history = readLOGSlast
	end

    local theme = getThemeInfo()
    local w, h = lcd.getWindowSize()
	if w < 500 then
		boxW = w
	else
		boxW = w - math.floor((w * 2)/100)	
	end
	if h < 200 then
		boxH = h-2
	else
		boxH = h - math.floor((h * 4)/100)
	end

	--draw the background
	if isDARKMODE then
		lcd.color(lcd.RGB(40, 40, 40,50))
	else
		lcd.color(lcd.RGB(240, 240, 240,50))
	end
	lcd.drawFilledRectangle(w / 2 - boxW / 2, h / 2 - boxH / 2, boxW, boxH)

	--draw the border
	lcd.color(lcd.RGB(248, 176, 56))
	lcd.drawRectangle(w / 2 - boxW / 2, h / 2 - boxH / 2, boxW, boxH)

	--draw the title
	lcd.color(lcd.RGB(248, 176, 56))
	lcd.drawFilledRectangle(w / 2 - boxW / 2, h / 2 - boxH / 2, boxW, boxH/9)

	if isDARKMODE then
		-- dark theme
		lcd.color(lcd.RGB(0, 0, 0, 1))
	else
		-- light theme
		lcd.color(lcd.RGB(255, 255, 255))
	end
	str = "Log History"
	lcd.font(theme.fontPopupTitle)
	tsizeW, tsizeH = lcd.getTextSize(str)
	
	boxTh = boxH/9	
	boxTy = h / 2 - boxH / 2
	boxTx = w / 2 - boxW / 2
	lcd.drawText((w / 2) - tsizeW / 2, boxTy + (boxTh / 2) - tsizeH / 2, str)
	
	-- close button
    lcd.drawBitmap(boxTx + boxW - boxTh, boxTy, gfx_close, boxTh, boxTh)	
	closeButtonX = math.floor(boxTx + boxW - boxTh)
	closeButtonY = math.floor(boxTy) + theme.widgetTitleOffset
	closeButtonW = math.floor(boxTh)
	closeButtonH = math.floor(boxTh)

	lcd.color(lcd.RGB(255, 255, 255))
	



	--[[ header column format 
		TIME VOLTAGE AMPS RPM LQ MCU ESC
	]]--
	colW = boxW/7


	col1x = boxTx
	col2x = boxTx + theme.logsCOL1w
	col3x = boxTx + theme.logsCOL1w + theme.logsCOL2w
	col4x = boxTx + theme.logsCOL1w + theme.logsCOL2w + theme.logsCOL3w
	col5x = boxTx + theme.logsCOL1w + theme.logsCOL2w + theme.logsCOL3w + theme.logsCOL4w
	col6x = boxTx + theme.logsCOL1w + theme.logsCOL2w + theme.logsCOL3w + theme.logsCOL4w + theme.logsCOL5w
	col7x = boxTx + theme.logsCOL1w + theme.logsCOL2w + theme.logsCOL3w + theme.logsCOL4w + theme.logsCOL5w + theme.logsCOL6w
	
	lcd.color(lcd.RGB(90, 90, 90))

	--LINES
	lcd.drawLine(boxTx + boxTh/2, boxTy + (boxTh*2), boxTx + boxW - (boxTh/2), boxTy + (boxTh*2))
		
	lcd.drawLine(col2x, boxTy + boxTh + boxTh/2, col2x, boxTy + boxH - (boxTh/2))
	lcd.drawLine(col3x, boxTy + boxTh + boxTh/2, col3x, boxTy + boxH - (boxTh/2))		
	lcd.drawLine(col4x, boxTy + boxTh + boxTh/2, col4x, boxTy + boxH - (boxTh/2))
	lcd.drawLine(col5x, boxTy + boxTh + boxTh/2, col5x, boxTy + boxH - (boxTh/2))		
	lcd.drawLine(col6x, boxTy + boxTh + boxTh/2, col6x, boxTy + boxH - (boxTh/2))	
	lcd.drawLine(col7x, boxTy + boxTh + boxTh/2, col7x, boxTy + boxH - (boxTh/2))
	
	--HEADER text
	if isDARKMODE then
		-- dark theme
		lcd.color(lcd.RGB(255, 255, 255, 1))
	else
		-- light theme
		lcd.color(lcd.RGB(0, 0, 0))
	end
	lcd.font(theme.fontPopupTitle)
	

	
	if theme.logsCOL1w ~= 0 then
		str = "TIME"
		tsizeW, tsizeH = lcd.getTextSize(str)					 
		lcd.drawText(col1x + (theme.logsCOL1w/2) - (tsizeW / 2), theme.logsHeaderOffset +(boxTy + boxTh)  + ((boxTh/2) - (tsizeH / 2)) , str)
	end

	if theme.logsCOL2w ~= 0 then
		str = "VOLTAGE"
		tsizeW, tsizeH = lcd.getTextSize(str)
		lcd.drawText((col2x) + (theme.logsCOL2w/2) - (tsizeW / 2), theme.logsHeaderOffset +(boxTy + boxTh)  + (boxTh/2) - (tsizeH / 2) , str)
	end
	
	if theme.logsCOL3w ~= 0 then	
		str = "AMPS"
		tsizeW, tsizeH = lcd.getTextSize(str)
		lcd.drawText((col3x) + (theme.logsCOL3w/2) - (tsizeW / 2), theme.logsHeaderOffset +(boxTy + boxTh)  + (boxTh/2) - (tsizeH / 2) , str)
	end

	if theme.logsCOL4w ~= 0 then
		str = "RPM"
		tsizeW, tsizeH = lcd.getTextSize(str)
		lcd.drawText((col4x) + (theme.logsCOL4w/2) - (tsizeW / 2), theme.logsHeaderOffset +(boxTy + boxTh)  + (boxTh/2) - (tsizeH / 2) , str)
	end

	if theme.logsCOL5w ~= 0 then
		str = "LQ"
		tsizeW, tsizeH = lcd.getTextSize(str)
		lcd.drawText((col5x) + (theme.logsCOL5w/2) - (tsizeW / 2), theme.logsHeaderOffset +(boxTy + boxTh)  + (boxTh/2) - (tsizeH / 2) , str)
	end

	if theme.logsCOL6w ~= 0 then
		str = "MCU"
		tsizeW, tsizeH = lcd.getTextSize(str)
		lcd.drawText((col6x) + (theme.logsCOL6w/2) - (tsizeW / 2), theme.logsHeaderOffset +(boxTy + boxTh)  + (boxTh/2) - (tsizeH / 2) , str)	
	end

	if theme.logsCOL7w ~= 0 then	
		str = "ESC"
		tsizeW, tsizeH = lcd.getTextSize(str)
		lcd.drawText((col7x) + (theme.logsCOL7w/2) - (tsizeW / 2), theme.logsHeaderOffset +(boxTy + boxTh)  + (boxTh/2) - (tsizeH / 2) , str)
	end
	
	c = 0


	
	for index,value in ipairs(history) do
		

		if value ~= nil then
			if value ~= "" and value ~= nil then
				rowH = c * boxTh


				
				local rowData = explode(value,",")
	
	
				--[[ rowData is a csv string as follows
				
						theTIME,sensorVoltageMin,sensorVoltageMax,sensorFuelMin,sensorFuelMax,
						sensorRPMMin,sensorRPMMax,sensorCurrentMin,sensorCurrentMax,sensorRSSIMin,
						sensorRSSIMax,sensorTempMCUMin,sensorTempMCUMax,sensorTempESCMin,sensorTempESCMax	
				]]--
				-- loop of rowData and extract each value bases on idx
				if rowData ~= nil then
				
					for idx,snsr in pairs(rowData) do
					
					
						snsr = snsr:gsub("%s+", "")
					
						if snsr ~= nil and snsr ~= "" then			
							-- time
							if idx == 1 and theme.logsCOL1w ~= 0 then
								str = SecondsToClockAlt(snsr)
								tsizeW, tsizeH = lcd.getTextSize(str)
								lcd.drawText(col1x + (theme.logsCOL1w/2) - (tsizeW / 2), boxTy + tsizeH/2 + (boxTh *2) + rowH , str)
							end
							-- voltagemin
							if idx == 2 then
								vstr = snsr
							end
							-- voltagemax
							if idx == 3 and theme.logsCOL2w ~= 0 then
								str = round(vstr/100,1) .. 'v / ' .. round(snsr/100,1) .. 'v'
								tsizeW, tsizeH = lcd.getTextSize(str)
								lcd.drawText(col2x + (theme.logsCOL2w/2) - (tsizeW / 2), boxTy + tsizeH/2 + (boxTh *2) + rowH , str)	
							end			
							-- fuelmin
							if idx == 4 then
								local logFUELmin = snsr
							end					
							-- fuelmax
							if idx == 5 then
								local logFUELmax = snsr
							end					
							-- rpmmin
							if idx == 6 then
								rstr = snsr
							end					
							-- rpmmax
							if idx == 7 and theme.logsCOL4w ~= 0 then
								str = rstr .. 'rpm / ' .. snsr .. 'rpm'
								tsizeW, tsizeH = lcd.getTextSize(str)
								lcd.drawText(col4x + (theme.logsCOL4w/2) - (tsizeW / 2), boxTy + tsizeH/2 + (boxTh *2) + rowH , str)	
							end							
							-- currentmin
							if idx == 8 then
								cstr = snsr
							end					
							-- currentmax
							if idx == 9 and theme.logsCOL3w ~= 0 then
								str = math.floor(cstr/10) .. 'A / ' .. math.floor(snsr/10) .. 'A'
								tsizeW, tsizeH = lcd.getTextSize(str)
								lcd.drawText(col3x + (theme.logsCOL3w/2) - (tsizeW / 2), boxTy + tsizeH/2 + (boxTh *2) + rowH , str)	
							end							
							-- rssimin
							if idx == 10 then
								lqstr = snsr
								
							end					
							-- rssimax
							if idx == 11 and theme.logsCOL5w ~= 0 then
								str = lqstr .. '% / ' .. snsr .. '%'
								tsizeW, tsizeH = lcd.getTextSize(str)
								lcd.drawText(col5x + (theme.logsCOL5w/2) - (tsizeW / 2), boxTy + tsizeH/2 + (boxTh *2) + rowH , str)
							end				
							-- mcumin
							if idx == 12 then
								mcustr = snsr
							end					
							-- mcumax
							if idx == 13 and theme.logsCOL6w ~= 0 then
								str = mcustr .. '° / ' .. snsr .. '°'
								strf = mcustr .. '. / ' .. snsr .. '.'
								tsizeW, tsizeH = lcd.getTextSize(strf)
								lcd.drawText(col6x + (theme.logsCOL6w/2) - (tsizeW / 2), boxTy + tsizeH/2 + (boxTh *2) + rowH , str)
							end		
							-- escmin
							if idx == 14 then
								escstr = snsr
							end					
							-- escmax
							if idx == 15 and theme.logsCOL7w ~= 0 then
								str = escstr .. '° / ' .. snsr .. '°'
								strf = escstr .. '. / ' .. snsr .. '.'
								tsizeW, tsizeH = lcd.getTextSize(strf)
								lcd.drawText(col7x + (theme.logsCOL7w/2) - (tsizeW / 2), boxTy + tsizeH/2 + (boxTh *2) + rowH , str)
							end
						end	
					-- end loop of each storage line		
					end			
					c = c+1
				
					if h < 200 then
						if c > 5 then
							break
						end						
					else
						if c > 7 then
							break
						end
					end
					--end of each log storage slot
				end
			end	
		end	
	end


	--lcd.drawText((w / 2) - tsizeW / 2, (h / 2) - tsizeH / 2, str)
return
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

    lcd.drawBitmap(x, y, gfx, w-theme.colSpacing, h-theme.colSpacing)


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
		
			sensorVALUE = sensors.fuel
		
			if sensors.fuel < 5 then
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
			
			if sensors.rpm < 5 then
				sensorVALUE = 0
			end
		
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
			
			if sensorVALUE < 1 then
				sensorVALUE = 0
			end
		
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
	
	
			sensorVALUE = sensors.current/10

			if sensorVALUE <= 0.5 then
				sensorVALUE = 0
			end

			
			if titleParam == 1 then
				sensorTITLE = theme.title_current
			else
				sensorTITLE = ""		
			end

			if sensorCurrentMin == 0 or sensorCurrentMin == nil then
					sensorMIN = "-"
			else 
					sensorMIN = sensorCurrentMin/10
			end
			
			if sensorCurrentMax == 0 or sensorCurrentMax == nil then
					sensorMAX = "-"
			else 
					sensorMAX = sensorCurrentMax/10
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
			
			if sensorVALUE < 1 then
				sensorVALUE = 0 
			end
		
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
		
			if sensorVALUE < 1 then
				sensorVALUE = 0 
			end
			
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
			sensorUNIT = "%"
			sensorWARN = false
			smallBOX = true	
	
			sensorVALUE = sensors.rssi
			
			if sensorVALUE < 1 then
				sensorVALUE = 0 
			end
			
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

			if sensorRSSIMax == 0 or sensorRSSIMax == nil then
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
        if linkUP == 0 then
			noTelem()
		end
		
		if showLOGS then
			logsBOX()
		end

	end
		
	
    -- TIME
    if linkUP ~= 0 then
        if sensors.govmode == "SPOOLUP" then
            timerNearlyActive = 1
        end

        if sensors.govmode == "IDLE" then
			if timerWASActive == true then
				stopTimer = true
				stopTIME = os.clock()
			
			else	
				stopTimer = true
				stopTIME = os.clock()
				theTIME = 0			
			end		
        end

        if sensors.govmode == "ACTIVE" then
            if timerNearlyActive == 1 then
                timerNearlyActive = 0
                startTIME = os.clock()
            end

            theTIME = os.clock() - startTIME
			timerWASActive = true
			
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
                system.playFile("/scripts/rf2status/sounds/lowvoltage.wav")
                --system.playNumber(sensors.voltage / 100, 2, 2)
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

function ReverseTable(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end

function getSensors()
    if isInConfiguration == true then
        return oldsensors
    end

    if environment.simulation == true then
	
		lcd.resetFocusTimeout()	

		tv = math.random(2100, 2274)
		voltage = tv
		temp_esc = math.random(1510, 2250)
		temp_mcu = math.random(1510, 1850)
		mah = math.random(10000, 10100)
		fuel = 0
		fm = "DISABLED"
		rssi = math.random(90, 100)		

		if simDoSPOOLUP == false then
			-- these ones do a scale up in simulation
			rpm = math.random(0, 0)		
			current = math.random(10, 20)
			govmode = "OFF"
		end
		
		if simDoSPOOLUP == true and simDoSPOOLUPCount == 0 then
			govmode = "SPOOLUP"
			rpm = math.random(750, 800)		
			current = math.random(1000, 1100)			
			simDoSPOOLUPCount = simDoSPOOLUPCount + 1
		end

		if simDoSPOOLUP == true and simDoSPOOLUPCount ~= 0 then
			govmode = "SPOOLUP"
			rpm = math.random(800, 810)	
			current = math.random(1100, 1150)					
			simDoSPOOLUPCount = simDoSPOOLUPCount + 1
		end
		
		
		
		if simDoSPOOLUP == true and simDoSPOOLUPCount >= 20 then
			govmode = "ACTIVE"
			rpm = math.random(810, 820)	
			current = math.random(1150, 1200)			
			simDoSPOOLUPCount = simDoSPOOLUPCount + 1
		end		

		
		if simDoSPOOLUP == true and simDoSPOOLUPCount >= actTime + 10 then
			govmode = "THR-OFF"
			rpm = math.random(200, 300)	
			current = math.random(100, 200)				
			simDoSPOOLUPCount = simDoSPOOLUPCount + 1
		end		

		if simDoSPOOLUP == true and simDoSPOOLUPCount >= actTime + 20 then
			govmode = "IDLE"
			rpm = math.random(0, 0)	
			current = math.random(20, 20)				
			simDoSPOOLUPCount = simDoSPOOLUPCount + 1
		end		

		if simDoSPOOLUP == true and simDoSPOOLUPCount >= actTime + 50 then
			govmode = "OFF"
			simDoSPOOLUPCount = 0
			simDoSPOOLUP = false
		end			
		
		
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
        fuel = batteryPercentage
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

	
        if sensors.govmode == "DISARMED" then
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
            if sensors.temp_esc < sensorTempESCMin then
                sensorTempESCMin = round(sensors.temp_esc / 100, 0)
            end
            if sensors.temp_esc > sensorTempESCMax then
                sensorTempESCMax = round(sensors.temp_esc / 100, 0)
            end
			
			govWasActive = true
        end
		
		-- store the last values
		if govWasActive and (sensors.govmode == 'OFF' or sensors.govmode == 'DISABLED' or sensors.govmode == 'DISARMED' or sensors.govmode == 'UNKNOWN') then
			govWasActive = false	

			local maxminFinals = readHistory()	


			local maxminRow = theTIME .. "," 
						.. sensorVoltageMin .. "," 
						.. sensorVoltageMax .. ","
						.. sensorFuelMin .. ","
						.. sensorFuelMax .. ","
						.. sensorRPMMin .. ","
						.. sensorRPMMax .. ","
						.. sensorCurrentMin .. ","
						.. sensorCurrentMax .. ","
						.. sensorRSSIMin .. ","
						.. sensorRSSIMax .. ","
						.. sensorTempMCUMin .. ","
						.. sensorTempMCUMax .. ","
						.. sensorTempESCMin .. ","
						.. sensorTempESCMax
		
			print("Row: ".. maxminRow )

			table.insert(maxminFinals,1,maxminRow)
			if tablelength(maxminFinals) >= 9 then
				table.remove(maxminFinals,9)			
			end

			print("Writing history")

			name = string.gsub(model.name(), "%s+", "_")	
			name = string.gsub(name, "%W", "_")		
			
			file = "/scripts/rf2status/logs/" .. name .. ".log"	
			f = io.open(file,'w')
			f:write("")
			io.close(f)	
			
			f = io.open(file,'a')
			for k,v in ipairs(maxminFinals) do
				if v ~= nil then
					v = v:gsub("%s+", "")
					--if v ~= "" then
						print(v)
						f:write(v .. "\n")
					--end
				end
			end
			io.close(f)			
		
			readLOGS = false	
			
			system.playFile("/scripts/rf2status/sounds/savelog.wav")
			
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

end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function print_r(arr, indentLevel)
    local str = ""
    local indentStr = "#"

    if(indentLevel == nil) then
        print(print_r(arr, 0))
        return
    end

    for i = 0, indentLevel do
        indentStr = indentStr.."\t"
    end

    for index,value in ipairs(arr) do
        if type(value) == "table" then
            str = str..indentStr..index..": \n"..print_r(value, (indentLevel + 1))
        else 
            str = str..indentStr..index..": "..value.."\n"
        end
    end
    return str
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

function SecondsToClockAlt(seconds)
    local seconds = tonumber(seconds)

    if seconds <= 0 then
        return "00:00"
    else
        hours = string.format("%02.f", math.floor(seconds / 3600))
        mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)))
        secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60))
        return  mins .. ":" .. secs
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

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function explode (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

function ReadLine(f, line)
    local i = 1 -- line counter
    for l in f:lines() do -- lines iterator, "l" returns the line
        if i == line then return l end -- we found this line, return it
        i = i + 1 -- counting lines
    end
    return "" -- Doesn't have that line
end


function readHistory()

	local history = {}
	print("Reading history")
	
	name = string.gsub(model.name(), "%s+", "_")	
	name = string.gsub(name, "%W", "_")
	file = "/scripts/rf2status/logs/" .. name .. ".log"
	local f = io.open(file, "rb")
	
	if f ~= nil then
		--file exists
		local rData
		c = 0
		tc = 1
		while c <= 10 do
			if c == 0 then
				rData = io.read(f,"l")
			else
				rData = io.read(f,"L")
			end
			if rData ~= "" or rData ~= nil then
				history[tc] = rData
				tc = tc+1
			end
			c = c+1
		end
		io.close(f)
	else
		return history
	end	


	return history
		
	

end



local function read()
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
				
		resetALL()
end

local function write()
	


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

local function event(widget, category, value, x, y)

	print("Event received:", category, value, x, y)
	
	-- disable menu if governor active
	if environment.simulation ~= true then
		if sensors.govmode == "IDLE" or sensors.govmode == "SPOOLUP" or sensors.govmode == "RECOVERY" or
					sensors.govmode == "ACTIVE" or
					sensors.govmode == "LOST-HS" or
					sensors.govmode == "BAILOUT" or
					sensors.govmode == "RECOVERY" then
			if category == EVT_TOUCH then
				return true
			end
		end	
	end

	if closingLOGS then
		if category == EVT_TOUCH and (value == 16640 or value == 16641)  then				
				closingLOGS = false
				return true
		end	
		
	end
		
	
	if showLOGS then
		if value == 35 then
			showLOGS = false
		end
		
		if category == EVT_TOUCH and (value == 16640 or value == 16641)  then		
			if (x >= (closeButtonX) and  (x <= (closeButtonX + closeButtonW))) and 
			   (y >= (closeButtonY) and  (y <= (closeButtonY + closeButtonH))) then
				showLOGS = false		
				closingLOGS = true
			end
			return true
		else
			if category == EVT_TOUCH then
				return true
			end
		end	
		
	end
	
  	
  -- if in simlation we capture a  page  press  to trigger a fake govenor spool up and then down
   
  if environment.simulation == true then

	
	-- fire up  governor
	if (sensors.govmode == 'OFF' or sensors.govmode == 'DISABLED' or sensors.govmode == 'DISARMED' or sensors.govmode == 'UNKNOWN') and value == 32 then
		simDoSPOOLUP = true
		govNearlyActive = 1
		timerNearlyActive = 1
		actTime = math.random(200,400) -- random run time when simulation of govener
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

local function viewLogs()
	showLOGS = true
	
end

local function menu(widget)

return {
      { "View logs", function() viewLogs() end},
    }
	
end


local function init()
    system.registerWidget(
        {
            key = "xkshss",
            name = "Rotorflight Flight Status",
            create = create,
            configure = configure,
            paint = paint,
            wakeup = wakeup,
            read = read,
            write = write,
			event = event,
			menu = menu,
			persistent = false,
        }
    )

    system.compile("/scripts/rf2status/main.lua")
end

return {init = init}
