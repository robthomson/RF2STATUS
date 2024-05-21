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

rf2status = {}

local loopCounter = 0
local sensors
local supportedRADIO = false
local gfx_model
local audioAlertCounter = 0

local defineSOURCES = false

local lvTimer = false
local lvTimerStart
local lvTriggerTimer = false
local lvTriggerTimerStart
local lvaudioTriggerCounter = 0

local rpmTimer = false
local rpmTimerStart
local rpmTriggerTimer = false
local rpmTriggerTimerStart
local rpmaudioTriggerCounter = 0

local currentTimer = false
local currentTimerStart
local currentTriggerTimer = false
local currentTriggerTimerStart
local currentaudioTriggerCounter = 0

local lqTimer = false
local lqTimerStart
local lqTriggerTimer = false
local lqTriggerTimerStart
local lqaudioTriggerCounter = 0

local fuelTimer = false
local fuelTimerStart
local fuelTriggerTimer = false
local fuelTriggerTimerStart
local fuelaudioTriggerCounter = 0

local escTimer = false
local escTimerStart
local escTriggerTimer = false
local escTriggerTimerStart
local escaudioTriggerCounter = 0

local mcuTimer = false
local mcuTimerStart
local mcuTriggerTimer = false
local mcuTriggerTimerStart
local mcuaudioTriggerCounter = 0

local timerTimer = false
local timerTimerStart
local timerTriggerTimer = false
local timerTriggerTimerStart
local timeraudioTriggerCounter = 0

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

local linkUPTime = 0

local playGovernorCount = 0
local playGovernorLastState = nil

local playRPMDiffCount = 1
local playRPMDiffLastState = nil
local playRPMDiffCounter = 0


local miniBoxParam = 0
local lowvoltagStickParam = 0
local lowvoltagStickCutoffParam = 70
local fmsrcParam = 0
local btypeParam = 0
local lowfuelParam = 20
local alertintParam = 5
local alrthptcParam = 1
local maxminParam = true
local titleParam = true
local cellsParam = 6
local lowVoltageGovernorParam = true
local sagParam = 5
local rpmAlertsParam = true
local rpmAlertsPercentageParam = 2.5
local governorAlertsParam = true
local triggerVoltageSwitchParam = nil
local triggerRPMSwitchParam = nil
local triggerCurrentSwitchParam = nil
local triggerFuelSwitchParam = nil	
local triggerLQSwitchParam = nil
local triggerESCSwitchParam = nil
local triggerMCUSwitchParam = nil
local triggerTimerSwitchParam = nil
local filteringParam = 1
local lowvoltagsenseParam = 2
local triggerIntervalParam = 30


local lvStickOrder = {}
lvStickOrder[1] = {1,2,3,4}
lvStickOrder[2] = {1,2,4,5}
lvStickOrder[3] = {1,2,4,6}
lvStickOrder[4] = {2,3,4,6}

local lvStickTrigger = false

local govmodeParam = 0
local adjFunctionParam = true

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

local oldADJSOURCE = 0
local oldADJVALUE = 0
local adjfuncIdChanged = false
local adjfuncValueChanged = false
local adjJUSTUP = false	
local ADJSOURCE = nil
local ADJVALUE = nil
local noTelemTimer = 0

local closeButtonX = 0
local closeButtonY = 0 
local closeButtonW = 0
local closeButtonH = 0

local sensorVoltageMax = 0
local sensorVoltageMin = 0
local sensorFuelMin = 0
local sensorFuelMax = 0
local sensorRPMMin = 0
local sensorRPMMax = 0
local sensorCurrentMin = 0
local sensorCurrentMax = 0
local sensorTempMCUMin = 0
local sensorTempMCUMax = 0
local sensorTempESCMin = 0
local sensorTempESCMax = 0
local sensorRSSIMin = 0
local sensorRSSIMax = 0
local lastMaxMin = 0

-- defaults... we overwrite these in create
local voltageNoiseQ = 100
local fuelNoiseQ = 100
local rpmNoiseQ = 100
local temp_mcuNoiseQ = 100
local temp_escNoiseQ = 100
local rssiNoiseQ = 100
local currentNoiseQ = 100



local adjfunctions = {
    -- rates
    id5 =  { name = "Pitch Rate", wavs = { "pitch", "rate" } },
    id6 =  { name = "Roll Rate", wavs = { "roll", "rate" } },
    id7 =  { name = "Yaw Rate", wavs = { "yaw", "rate" } },
    id8 =  { name = "Pitch RC Rate", wavs = { "pitch", "rc", "rate" } },
    id9 =  { name = "Roll RC Rate", wavs = { "roll", "rc", "rate" } },
    id10 = { name = "Yaw RC Rate", wavs = { "yaw", "rc", "rate" } },
    id11 = { name = "Pitch RC Expo", wavs = { "pitch", "rc", "expo" } },
    id12 = { name = "Roll RC Expo", wavs = { "roll", "rc", "expo" } },
    id13 = { name = "Yaw RC Expo", wavs = { "yaw", "rc", "expo" } },

    -- pids
    id14 = { name = "Pitch P Gain", wavs = { "pitch", "p", "gain" } },
    id15 = { name = "Pitch I Gain", wavs = { "pitch", "i", "gain" } },
    id16 = { name = "Pitch D Gain", wavs = { "pitch", "d", "gain" } },
    id17 = { name = "Pitch F Gain", wavs = { "pitch", "f", "gain" } },
    id18 = { name = "Roll P Gain", wavs = { "roll", "p", "gain" } },
    id19 = { name = "Roll I Gain", wavs = { "roll", "i", "gain" } },
    id20 = { name = "Roll D Gain", wavs = { "roll", "d", "gain" } },
    id21 = { name = "Roll F Gain", wavs = { "roll", "f", "gain" } },
    id22 = { name = "Yaw P Gain", wavs = { "yaw", "p", "gain" } },
    id23 = { name = "Yaw I Gain", wavs = { "yaw", "i", "gain" } },
    id24 = { name = "Yaw D Gain", wavs = { "yaw", "d", "gain" } },
    id25 = { name = "Yaw F Gain", wavs = { "yaw", "f", "gain" } },

    id26 = { name = "Yaw CW Gain", wavs = { "yaw", "cw", "gain" } },
    id27 = { name = "Yaw CCW Gain", wavs = { "yaw", "ccw", "gain" } },
    id28 = { name = "Yaw Cyclic FF", wavs = { "yaw", "cyclic", "ff" } },
    id29 = { name = "Yaw Coll FF", wavs = { "yaw", "collective", "ff" } },
    id30 = { name = "Yaw Coll Dyn", wavs = { "yaw", "collective", "dyn" } },
    id31 = { name = "Yaw Coll Decay", wavs = { "yaw", "collective", "decay" } },
    id32 = { name = "Pitch Coll FF", wavs = { "pitch", "collective", "ff" } },

    -- gyro cutoffs
    id33 = { name = "Pitch Gyro Cutoff", wavs = { "pitch", "gyro", "cutoff" } },
    id34 = { name = "Roll Gyro Cutoff", wavs = { "roll", "gyro", "cutoff" } },
    id35 = { name = "Yaw Gyro Cutoff", wavs = { "yaw", "gyro", "cutoff" } },

    -- dterm cutoffs
    id36 = { name = "Pitch D-term Cutoff", wavs = { "pitch", "dterm", "cutoff" } },
    id37 = { name = "Roll D-term Cutoff", wavs = { "roll", "dterm", "cutoff" } },
    id38 = { name = "Yaw D-term Cutoff", wavs = { "yaw", "dterm", "cutoff" } },

    -- rescue
    id39 = { name = "Rescue Climb Coll", wavs = { "rescue", "climb", "collective" } },
    id40 = { name = "Rescue Hover Coll", wavs = { "rescue", "hover", "collective" } },
    id41 = { name = "Rescue Hover Alt", wavs = { "rescue", "hover", "alt" } },
    id42 = { name = "Rescue Alt P Gain", wavs = { "rescue", "alt", "p", "gain" } },
    id43 = { name = "Rescue Alt I Gain", wavs = { "rescue", "alt", "i", "gain" } },
    id44 = { name = "Rescue Alt D Gain", wavs = { "rescue", "alt", "d", "gain" } },

    -- leveling
    id45 = { name = "Angle Level Gain", wavs = { "angle", "level", "gain" } },
    id46 = { name = "Horizon Level Gain", wavs = { "horizon", "level", "gain" } },
    id47 = { name = "Acro Trainer Gain", wavs = { "acro", "gain" } },

    -- governor
    id48 = { name = "Governor Gain", wavs = { "gov", "gain" } },
    id49 = { name = "Governor P Gain", wavs = { "gov", "p", "gain" } },
    id50 = { name = "Governor I Gain", wavs = { "gov", "i", "gain" } },
    id51 = { name = "Governor D Gain", wavs = { "gov", "d", "gain" } },
    id52 = { name = "Governor F Gain", wavs = { "gov", "f", "gain" } },
    id53 = { name = "Governor TTA Gain", wavs = { "gov", "tta", "gain" } },
    id54 = { name = "Governor Cyclic FF", wavs = { "gov", "cyclic", "ff" } },
    id55 = { name = "Governor Coll FF", wavs = { "gov", "collective", "ff" } },

    -- boost gains
    id56 = { name = "Pitch B Gain", wavs = { "pitch", "b", "gain" } },
    id57 = { name = "Roll B Gain", wavs = { "roll", "b", "gain" } },
    id58 = { name = "Yaw B Gain", wavs = { "yaw", "b", "gain" } },

    -- offset gains
    id59 = { name = "Pitch O Gain", wavs = { "pitch", "o", "gain" } },
    id60 = { name = "Roll O Gain", wavs = { "roll", "o", "gain" } },

    -- cross-coupling
    id61 = { name = "Cross Coup Gain", wavs = { "crossc", "gain" } },
    id62 = { name = "Cross Coup Ratio", wavs = { "crossc", "ratio" } },
    id63 = { name = "Cross Coup Cutoff", wavs = { "crossc", "cutoff" } }
}



local function create(widget)
    gfx_model = lcd.loadBitmap(model.bitmap())
    gfx_heli = lcd.loadBitmap("/scripts/RF2STATUS/gfx/heli.png")
	gfx_close = lcd.loadBitmap("/scripts/RF2STATUS/gfx/close.png")
    rssiSensor = rf2status.getRssiSensor()


    if tonumber(rf2status.sensorMakeNumber(environment.version)) < 152 then
        rf2status.screenError("ETHOS < V1.5.2")
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
        triggerswitchvltg = nil,
        govmode = 0,
		governoralerts = 0,
		rpmalerts = 0,
		rpmaltp = 2.5,
		adjfunc = 0,
		triggerswitchrpm = nil,
		triggerswitchcrnt = nil,
		triggerswitchfuel = nil,
		triggerswitchlq = nil,
		triggerswitchesc = nil,
		triggerswitchmcu = nil,
		triggerswitchtmr = nil,
		filtering = 1,
		sag = 5,
		lvsense = 2,
		triggerint = 30
    }
end

function loadScriptRF2STATUS(script) 
	return loadfile(script) 
end

local function configure(widget)
    isInConfiguration = true


	batterypanel = form.addExpansionPanel("Battery")
	batterypanel:open(false) 

    -- CELLS
    line = form.addLine("Type",batterypanel)
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
    line = form.addLine("Cells",batterypanel)
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


	alertpanel = form.addExpansionPanel("Alerts")
	alertpanel:open(false) 

    -- LOW FUEL TRIGGER
    line = form.addLine("Low fuel%",alertpanel)
    field =
        form.addNumberField(
        line,
        nil,
        0,
        50,
        function()
            return lowfuelParam
        end,
        function(value)
            lowfuelParam = value
        end
    )
    field:default(20)
	field:suffix("%")

    -- ALERT INTERVAL
    line = form.addLine("Interval",alertpanel)
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

    -- HAPTIC
    line = form.addLine("Voltage haptic",alertpanel)
    form.addBooleanField(
        line,
        nil,
        function()
            return alrthptParam
        end,
        function(newValue)
            alrthptParam = newValue
        end
    )	


    -- TITLE DISPLAY
    line = form.addLine("Governor",alertpanel)
    form.addBooleanField(
        line,
        nil,
        function()
            return governorAlertsParam
        end,
        function(newValue)
            governorAlertsParam = newValue
        end
    )

    -- TITLE DISPLAY
    line = form.addLine("Rpm.",alertpanel)
    form.addBooleanField(
        line,
        nil,
        function()
            return rpmAlertsParam
        end,
        function(newValue)
            rpmAlertsParam = newValue
        end
    )
	
	

    -- TITLE DISPLAY
    line = form.addLine("Rpm. % difference",alertpanel)
    field =
        form.addNumberField(
        line,
        nil,
        0,
        200,
        function()
            return rpmAlertsPercentageParam
        end,
        function(value)
            rpmAlertsPercentageParam = value
        end
    )
    field:default(5)
	field:decimals(1)



	if system.getSource("Rx RSSI1") == nil then -- currently only supported with fport
		line = form.addLine("Adjustment sensor",alertpanel)
		form.addBooleanField(
			line,
			nil,
			function()
				return adjFunctionParam
			end,
			function(newValue)
				adjFunctionParam = newValue
			end
		)	
	end

	triggerpanel = form.addExpansionPanel("Triggers")
	triggerpanel:open(false) 
	
    -- TRIGGER VOLTAGE READING
    line = form.addLine("Voltage",triggerpanel)
    form.addSwitchField(
        line,
        form.getFieldSlots(line)[0],
        function()
            return triggerVoltageSwitchParam
        end,
        function(value)
            triggerVoltageSwitchParam = value
        end
    )

    -- TRIGGER RPM READING
    line = form.addLine("Rpm",triggerpanel)
    form.addSwitchField(
        line,
        form.getFieldSlots(line)[0],
        function()
            return triggerRPMSwitchParam
        end,
        function(value)
            triggerRPMSwitchParam = value
        end
    )

    -- TRIGGER CURRENT READING
    line = form.addLine("Current",triggerpanel)
    form.addSwitchField(
        line,
        form.getFieldSlots(line)[0],
        function()
            return triggerCurrentSwitchParam
        end,
        function(value)
            triggerCurrentSwitchParam = value
        end
    )

    -- TRIGGER FUEL READING
    line = form.addLine("Fuel",triggerpanel)
    form.addSwitchField(
        line,
        form.getFieldSlots(line)[0],
        function()
            return triggerFuelSwitchParam
        end,
        function(value)
            triggerFuelSwitchParam = value
        end
    )

    -- TRIGGER LQ READING
    line = form.addLine("LQ",triggerpanel)
    form.addSwitchField(
        line,
        form.getFieldSlots(line)[0],
        function()
            return triggerLQSwitchParam
        end,
        function(value)
            triggerLQSwitchParam = value
        end
    )

    -- TRIGGER LQ READING
    line = form.addLine("Esc temperature",triggerpanel)
    form.addSwitchField(
        line,
        form.getFieldSlots(line)[0],
        function()
            return triggerESCSwitchParam
        end,
        function(value)
            triggerESCSwitchParam = value
        end
    )

    -- TRIGGER MCU READING
    line = form.addLine("Mcu temperature",triggerpanel)
    form.addSwitchField(
        line,
        form.getFieldSlots(line)[0],
        function()
            return triggerMCUSwitchParam
        end,
        function(value)
            triggerMCUSwitchParam = value
        end
    )

    -- TRIGGER TIMER READING
    line = form.addLine("Timer",triggerpanel)
    form.addSwitchField(
        line,
        form.getFieldSlots(line)[0],
        function()
            return triggerTimerSwitchParam
        end,
        function(value)
            triggerTimerSwitchParam = value
        end
    )

	displaypanel = form.addExpansionPanel("Display")
	displaypanel:open(false) 


    -- Mini Boxes
    line = form.addLine("Mini Boxes",displaypanel)
    form.addChoiceField(
        line,
        nil,
        {
            {"LQ,TIMER,T.ESC,T.MCU", 0},
            {"LQ,TIMER", 1},
            {"TIMER", 2},
        },
        function()
            return miniBoxParam
        end,
        function(newValue)
            miniBoxParam = newValue
        end
    )

    -- FLIGHT MODE SOURCE
    line = form.addLine("Flight mode",displaypanel)
    form.addChoiceField(
        line,
        nil,
        {
            {"RF Governor", 0},
            {"Ethos flight modes", 1}
        },
        function()
            return fmsrcParam
        end,
        function(newValue)
            fmsrcParam = newValue
        end
    )

    -- TITLE DISPLAY
    line = form.addLine("Title",displaypanel)
    form.addBooleanField(
        line,
        nil,
        function()
            return titleParam
        end,
        function(newValue)
            titleParam = newValue
        end
    )

    -- MAX MIN DISPLAY
    line = form.addLine("Max/Min",displaypanel)
    form.addBooleanField(
        line,
        nil,
        function()
            return maxminParam
        end,
        function(newValue)
            maxminParam = newValue
        end
    )
	
	advpanel = form.addExpansionPanel("Advanced")
	advpanel:open(false) 
	

    line = form.addLine("Voltage",advpanel)
	
    -- LVTRIGGER DISPLAY
    line = form.addLine("    Sensitivity",advpanel)
    form.addChoiceField(
        line,
        nil,
        {
			{"HIGH", 1}, 
			{"MEDIUM", 2}, 
			{"LOW", 3}
		},
        function()
            return lowvoltagsenseParam
        end,
        function(newValue)
            lowvoltagsenseParam = newValue
        end
    )

    line = form.addLine("    Sag compensation",advpanel)
    field =
        form.addNumberField(
        line,
        nil,
        0,
        10,
        function()
            return sagParam
        end,
        function(value)
            sagParam = value
        end
    )
    field:default(5)
	field:suffix("s")
	--field:decimals(1)

    -- LVSTICK MONITORING
    line = form.addLine("    Gimbal Monitoring",advpanel)
    form.addChoiceField(
        line,
        nil,
        {
			{"DISABLED", 0},  -- recomended
			{"AECR1T23 (ELRS)", 1},  -- recomended
			{"AETRC123 (FRSKY)", 2}, -- frsky
			{"AETR1C23 (FUTABA)", 3}, --fut/hitec
			{"TAER1C23 (SPEKTRUM)",4} -- spec
		},
        function()
            return lowvoltagStickParam
        end,
        function(newValue)
            lowvoltagStickParam = newValue
        end
    )

    line = form.addLine("    Stick Cutoff",advpanel)
    field =
        form.addNumberField(
        line,
        nil,
        65,
        95,
        function()
            return lowvoltagStickCutoffParam
        end,
        function(value)
             lowvoltagStickCutoffParam = value
        end
    )
    field:default(80)
	field:suffix("%")


   -- LVTRIGGER DISPLAY 
    line = form.addLine("    Ignore Governor",advpanel)
    form.addBooleanField(
        line,
        nil,
        function()
            return lowVoltageGovernorParam
        end,
        function(newValue)
            lowVoltageGovernorParam = newValue
        end
    )


    -- FILTER
    -- MAX MIN DISPLAY
    line = form.addLine("Telemetry Filtering",advpanel)
    form.addChoiceField(
        line,
        nil,
        {
			{"LOW", 1}, 
			{"MEDIUM", 2}, 
			{"HIGH", 3}
		},
        function()
            return filteringParam
        end,
        function(newValue)
            filteringParam = newValue
        end
    )

   -- LVTRIGGER DISPLAY
    line = form.addLine("Trigger interval",advpanel)
    form.addChoiceField(
        line,
        nil,
        {
			{"5s", 5}, 
			{"10s", 10}, 
			{"15s", 15}, 
			{"20s", 20}, 
			{"25s", 25}, 
			{"30s", 30},
			{"35s", 35}, 			
			{"40s", 40},
			{"45s", 45},
			{"50s", 50},
			{"55s", 55},
			{"60s", 60},
			{"No repeat", 50000}			
		},
        function()
            return triggerIntervalParam
        end,
        function(newValue)
            triggerIntervalParam = newValue
        end
    )


	rf2status.resetALL()

    return widget
end

function rf2status.getRssiSensor()
	if environment.simulation then
		return 100
	end

    local rssiNames = {"RSSI", "RSSI 2.4G", "RSSI 900M", "Rx RSSI1", "Rx RSSI2"}
    for i, name in ipairs(rssiNames) do
        rssiSensor = system.getSource(name)
        if rssiSensor then
            return rssiSensor
        end
    end
end

function rf2status.getRSSI()
	if environment.simulation == true then
		return 100
	end
    if rssiSensor ~= nil and rssiSensor:state() then
        return rssiSensor:value()
    end
    return 0
end

function rf2status.screenError(msg)
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

function rf2status.resetALL()
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

function rf2status.noTelem()



	lcd.font(FONT_STD)
	str = "NO DATA"
	
    local theme = rf2status.getThemeInfo()
    local w, h = lcd.getWindowSize()	
	boxW = math.floor(w / 2)
	boxH = 45
	tsizeW, tsizeH = lcd.getTextSize(str)

	--draw the backgrf2status.round
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


function rf2status.getThemeInfo()
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
    local theme = rf2status.getThemeInfo()
	
	if isDARKMODE then
		lcd.color(lcd.RGB(40, 40, 40))
	else
		lcd.color(lcd.RGB(240, 240, 240))
	end
		
	-- draw box backgrf2status.round	
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
			if maxminParam == false and titleParam == false then
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
	
	if title ~= nil and titleParam == true then
		lcd.font(theme.fontTITLE)
		str = title 
		tsizeW, tsizeH = lcd.getTextSize(str)
		
		sx = (x + w/2)-(tsizeW/2)
		sy = (y + h)-(tsizeH) - theme.colSpacing

		lcd.drawText(sx,sy, str)
	end	


	if maxminParam == true then	

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

function rf2status.logsBOX()

	

	if readLOGS == false then
		local history = rf2status.readHistory()	
		readLOGSlast = history
		readLOGS = true
	else	
		history = readLOGSlast
	end

    local theme = rf2status.getThemeInfo()
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

	--draw the backgrf2status.round
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


				
				local rowData = rf2status.explode(value,",")
	
	
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
								str = rf2status.SecondsToClockAlt(snsr)
								tsizeW, tsizeH = lcd.getTextSize(str)
								lcd.drawText(col1x + (theme.logsCOL1w/2) - (tsizeW / 2), boxTy + tsizeH/2 + (boxTh *2) + rowH , str)
							end
							-- voltagemin
							if idx == 2 then
								vstr = snsr
							end
							-- voltagemax
							if idx == 3 and theme.logsCOL2w ~= 0 then
								str = rf2status.round(vstr/100,1) .. 'v / ' .. rf2status.round(snsr/100,1) .. 'v'
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
								str = rf2status.round(mcustr/100,0) .. '° / ' .. rf2status.round(snsr/100,0) .. '°'
								strf = rf2status.round(mcustr/100,0) .. '. / ' .. rf2status.round(snsr/100,0) .. '.'
								tsizeW, tsizeH = lcd.getTextSize(strf)
								lcd.drawText(col6x + (theme.logsCOL6w/2) - (tsizeW / 2), boxTy + tsizeH/2 + (boxTh *2) + rowH , str)
							end		
							-- escmin
							if idx == 14 then
								escstr = snsr
							end					
							-- escmax
							if idx == 15 and theme.logsCOL7w ~= 0 then
								str = rf2status.round(escstr/100,0) .. '° / ' .. rf2status.round(snsr/100,0) .. '°'
								strf = rf2status.round(escstr/100,0) .. '. / ' .. rf2status.round(snsr/100,0) .. '.'
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
    local theme = rf2status.getThemeInfo()
	
	if isDARKMODE then
		lcd.color(lcd.RGB(40, 40, 40))
	else
		lcd.color(lcd.RGB(240, 240, 240))
	end
		
	-- draw box backgrf2status.round	
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
			-- we use lowvoltagsenseParam is use to raise or lower sensitivity
			if lowvoltagsenseParam == 1 then
				zippo = 0.2
			elseif lowvoltagsenseParam == 2 then
				zippo = 0.1
			else
				zippo = 0
			end
            if sensors.voltage / 100 < ((cellVoltage * cellsParam)+zippo) then
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

    local theme = rf2status.getThemeInfo()
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
            rf2status.screenError("UNKNOWN " .. environment.board)
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
                rf2status.screenError("DISPLAY SIZE INVALID")
                return
            end
        end
        if environment.board == "X18" or environment.board == "X18S" then
            smallTEXT = true
            if w ~= 472 and h ~= 191 then
                rf2status.screenError("DISPLAY SIZE INVALID")
                return
            end
        end
        if environment.board == "X14" or environment.board == "X14S" then
            if w ~= 630 and h ~= 236 then
                rf2status.screenError("DISPLAY SIZE INVALID")
                return
            end
        end
        if environment.board == "TWXLITE" or environment.board == "TWXLITES" then
            if w ~= 472 and h ~= 191 then
                rf2status.screenError("DISPLAY SIZE INVALID")
                return
            end
        end
        if environment.board == "X10EXPRESS" then
            if w ~= 472 and h ~= 158 then
                rf2status.screenError("DISPLAY SIZE INVALID")
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
		
			if titleParam == true then
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
		
			if titleParam == true then
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
		
			if titleParam == true then
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

			
			if titleParam == true then
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
		if sensors.temp_esc ~= nil and miniBoxParam == 0 then
		
			posX = 0
			posY =  boxH+(theme.colSpacing*2)+boxHs+theme.colSpacing
			sensorUNIT = "°"
			sensorWARN = false
			smallBOX = true	
	
			sensorVALUE = rf2status.round(sensors.temp_esc/100,0)
			
			if sensorVALUE < 1 then
				sensorVALUE = 0 
			end
		
			if titleParam == true then
				sensorTITLE = theme.title_tempESC
			else
				sensorTITLE = ""		
			end

			if sensorTempESCMin == 0 or sensorTempESCMin == nil then
					sensorMIN = "-"
			else 
					sensorMIN = rf2status.round(sensorTempESCMin/100,0)
			end
			
			if sensorTempESCMax == 0 or sensorTempESCMax == nil then
					sensorMAX = "-"
			else 
					sensorMAX = rf2status.round(sensorTempESCMax/100,0)
			end
	
			telemetryBox(posX,posY,boxWs,boxHs,sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)
		end	

		--TEMP MCU
		if sensors.temp_mcu ~= nil and miniBoxParam == 0 then
		
			posX = boxWs+theme.colSpacing
			posY =  boxH+(theme.colSpacing*2)+boxHs+theme.colSpacing
			sensorUNIT = "°"
			sensorWARN = false
			smallBOX = true	
	
			sensorVALUE = rf2status.round(sensors.temp_mcu/100,0)
		
			if sensorVALUE < 1 then
				sensorVALUE = 0 
			end
			
			if titleParam == true then
				sensorTITLE = theme.title_tempMCU
			else
				sensorTITLE = ""		
			end

			if sensorTempMCUMin == 0 or sensorTempMCUMin == nil then
					sensorMIN = "-"
			else 
					sensorMIN = rf2status.round(sensorTempMCUMin/100,0)
			end
			
			if sensorTempMCUMax == 0 or sensorTempMCUMax == nil then
					sensorMAX = "-"
			else 
					sensorMAX = rf2status.round(sensorTempMCUMax/100,0)
			end

	
			telemetryBox(posX,posY,boxWs,boxHs,sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)
		end	

		--RSSI
		if sensors.rssi ~= nil and (miniBoxParam == 0 or miniBoxParam == 1)then
		
		
			if miniBoxParam == 0 then
				posX = 0
				posY =  boxH+(theme.colSpacing*2)
				sensorUNIT = "%"
				sensorWARN = false
				smallBOX = true	
				thisBoxW = boxWs
				thisBoxH = boxHs
			elseif 	miniBoxParam == 1 then
				posX = 0
				posY =  boxH+(theme.colSpacing*2)
				sensorUNIT = "%"
				sensorWARN = false
				smallBOX = true	
				thisBoxW = boxW
				thisBoxH = boxHs			
			end
	
			sensorVALUE = sensors.rssi
			
			if sensorVALUE < 1 then
				sensorVALUE = 0 
			end
			
			if titleParam == true then
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
	
			telemetryBox(posX,posY,thisBoxW,thisBoxH,sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)
		end	

	-- TIMER
	if miniBoxParam == 0 or miniBoxParam == 1 or miniBoxParam == 2 then
			if miniBoxParam == 0 then
				posX = boxWs+theme.colSpacing
				posY =  boxH+(theme.colSpacing*2)
				sensorUNIT = ""
				sensorWARN = false
				smallBOX = true	
				thisBoxW = boxWs
				thisBoxH = boxHs			
			elseif miniBoxParam == 1 then
				posX = 0
				posY =  boxH+(theme.colSpacing*2)+boxHs+theme.colSpacing
				sensorUNIT = ""
				sensorWARN = false
				smallBOX = true		
				thisBoxW = boxW
				thisBoxH = boxHs			
			elseif miniBoxParam == 2 then
				posX = 0
				posY =  boxH+(theme.colSpacing*2)
				sensorUNIT = ""
				sensorWARN = false
				smallBOX = false		
				thisBoxW = boxW
				thisBoxH = boxH			
			end		
			
			sensorMIN = nil
			sensorMAX = nil
		
			if theTIME ~= nil or theTIME == 0 then
				str = rf2status.SecondsToClock(theTIME)
			else
				str = "00:00:00"
			end
			
			
			if titleParam == true then
				sensorTITLE = theme.title_time
			else
				sensorTITLE = ""		
			end		
		   
			sensorVALUE = str
		   
			telemetryBox(posX,posY,thisBoxW,thisBoxH,sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)
		end

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

		if titleParam ~= true then
			sensorTITLE = ""		
		end	

	    telemetryBox(posX,posY,boxW,boxHs,sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)

		--if linkUP == 0 then
        if linkUP == 0 then
			rf2status.noTelem()
		end
		
		if showLOGS then
			rf2status.logsBOX()
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
    if linkUP ~= 0 then
        if
            sensors.govmode == "IDLE" or sensors.govmode == "SPOOLUP" or sensors.govmode == "RECOVERY" or
                sensors.govmode == "ACTIVE" or
                sensors.govmode == "LOST-HS" or
                sensors.govmode == "BAILOUT" or
                sensors.govmode == "RECOVERY" or
				lowVoltageGovernorParam == true
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
        if (os.time() - lvTimerStart >= sagParam) then
            -- only trigger if we have been on for 5 seconds or more
            if (tonumber(os.clock()) - tonumber(audioAlertCounter)) >= alertintParam then
                audioAlertCounter = os.clock()
				
				if lvStickTrigger == false then -- do not play if sticks at high end points
					system.playFile("/scripts/RF2STATUS/sounds/alerts/lowvoltage.wav")

					--system.playNumber(sensors.voltage / 100, 2, 2)
					if alrthptParam == true then
						system.playHaptic("- . -")
					end
				else
					print("Alarm supressed due to stick positions")
				end
	
            end
        end
    else
        -- stop timer
        lvTimerStart = nil
    end
end

function rf2status.ReverseTable(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end

local function getChannelValue(ich)
  local src = system.getSource ({category=CATEGORY_CHANNEL, member=(ich-1), options=0})
  return math.floor ((src:value() / 10.24) +0.5)
end


function rf2status.getSensors()
    if isInConfiguration == true then
        return oldsensors
    end

    if environment.simulation == true then
	
		lcd.resetFocusTimeout()	

		tv = math.random(2100, 2274)
		voltage = tv
		temp_esc = math.random(500, 2250)*10
		temp_mcu = math.random(500, 1850)*10
		mah = math.random(10000, 10100)
		fuel = 0
		fm = "DISABLED"
		rssi = math.random(90, 100)	
		adjsource = 0
		adjvalue = 0

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

		
		if simDoSPOOLUP == true and simDoSPOOLUPCount >= actTime + 20 then
			govmode = "THR-OFF"
			rpm = math.random(200, 300)	
			current = math.random(100, 200)				
			simDoSPOOLUPCount = simDoSPOOLUPCount + 1
		end		

		if simDoSPOOLUP == true and simDoSPOOLUPCount >= actTime + 40 then
			govmode = "IDLE"
			rpm = math.random(0, 0)	
			current = math.random(20, 20)				
			simDoSPOOLUPCount = simDoSPOOLUPCount + 1
		end		

		if simDoSPOOLUP == true and simDoSPOOLUPCount >= actTime + 70 then
			govmode = "OFF"
			simDoSPOOLUPCount = 0
			simDoSPOOLUP = false
		end			
		
		
    elseif linkUP ~= 0 then
        local telemetrySOURCE = system.getSource("Rx RSSI1")
	

        if telemetrySOURCE ~= nil then
	        -- we are running crsf
	
			-- set sources for everthing below

			voltageSOURCE = system.getSource("Rx Batt")
			rpmSOURCE = system.getSource("GPS Alt")
			currentSOURCE = system.getSource("Rx Curr")
			temp_escSOURCE = system.getSource("GPS Speed")
			temp_mcuSOURCE = system.getSource("GPS Sats")
			fuelSOURCE = system.getSource("Rx Batt%")
			mahSOURCE = system.getSource("Rx Cons")
			govSOURCE = system.getSource("Flight mode")
			rssiSOURCE = system.getSource("Rx Quality")	

	
		
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

            if govSOURCE ~= nil then
                govmode = govSOURCE:stringValue()
            end
            if system.getSource({category = CATEGORY_FLIGHT, member = FLIGHT_CURRENT_MODE}):stringValue() then
                fm = system.getSource({category = CATEGORY_FLIGHT, member = FLIGHT_CURRENT_MODE}):stringValue()
            else
                fm = ""
            end
			

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
			
			-- note.
			-- need to modify firmware to allow this to work for crsf correctly
			adjsource = 0
			adjvalue = 0
        else
            -- we are run sport	
			-- set sources for everthing below

			voltageSOURCE = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x0210})
			rpmSOURCE = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x0500})
			currentSOURCE = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x0200})
			temp_escSOURCE = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x0B70})
			temp_mcuSOURCE = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x0401})
			fuelSOURCE = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x0600})
			mahSOURCE = system.getSource("Consumption") -- this is fake.  does not exist
			govSOURCE = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x5450})
			adjSOURCE = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x5110})
			adjVALUE = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x5111})
	

            --voltageSOURCE = system.getSource("VFAS")
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
			
            if adjSOURCE ~= nil then
                adjsource = adjSOURCE:value()
			end	
			
            if adjVALUE ~= nil then
                adjvalue = adjVALUE:value()
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
		adjsource = 0
		adjvalue = 0
		defineSOURCES = false
    end

	--calc fuel percentage if needed
    if voltage ~= 0 and (fuel == 0) then
	
        if btypeParam == 0 then
            --LiPo
			maxCellVoltage = 4.2
			minCellVoltage = 3.2
        elseif btypeParam == 1 then
            --LiHv
			maxCellVoltage = 4.35
			minCellVoltage = 3.4
        elseif btypeParam == 2 then
            --Lion
			maxCellVoltage = 2.4
			minCellVoltage = 3
        elseif btypeParam == 3 then
            --LiFe
			maxCellVoltage = 3.65
			minCellVoltage = 2.5
        elseif btypeParam == 4 then
            --NiMh
			maxCellVoltage = 1.2
			minCellVoltage = 0.9
        else
            --LiPo (default)
			maxCellVoltage = 4.196
			minCellVoltage = 3.2
        end	

        --maxCellVoltage = 4.196
        --minCellVoltage = 3.2
        avgCellVoltage = voltage / cellsParam
        batteryPercentage = 100 * (avgCellVoltage - minCellVoltage) / (maxCellVoltage - minCellVoltage)
        fuel = batteryPercentage
        if fuel > 100 then
            fuel = 100
        end
    end


    -- set flag to refresh screen or not

    voltage = rf2status.kalmanVoltage(voltage, oldsensors.voltage)
    voltage = rf2status.round(voltage, 0)

    rpm = rf2status.kalmanRPM(rpm, oldsensors.rpm)
    rpm = rf2status.round(rpm, 0)

    temp_mcu = rf2status.kalmanTempMCU(temp_mcu, oldsensors.temp_mcu)
    temp_mcu = rf2status.round(temp_mcu, 0)

    temp_esc = rf2status.kalmanTempESC(temp_esc, oldsensors.temp_esc)
    temp_esc = rf2status.round(temp_esc, 0)

    current = rf2status.kalmanCurrent(current, oldsensors.current)
    current = rf2status.round(current, 0)

    rssi = rf2status.kalmanRSSI(rssi, oldsensors.rssi)
    rssi = rf2status.round(rssi, 0)
	
	-- do / dont do voltage based on stick position
	if lowvoltagStickParam == nil then
		lowvoltagStickParam = 0
	end
	if lowvoltagStickCutoffParam == nil then
		lowvoltagStickCutoffParam = 80
	end

	if(lowvoltagStickParam ~= 0) then
			lvStickTrigger = false
			for i, v in ipairs(lvStickOrder[lowvoltagStickParam]) do
				if lvStickTrigger == false then  -- we skip more if any stick has resulted in trigger
					if math.abs(getChannelValue(v)) >= lowvoltagStickCutoffParam then 
							lvStickTrigger = true
					end
				end
			end
	end		

	

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
        rssi = rssi,
		adjsource = adjsource,
		adjvalue = adjvalue
    }
    oldsensors = ret

    return ret
end




function sensorsMAXMIN(sensors)


    if linkUP ~= 0 then

		if sensors.govmode == "OFF" then
			spoolupNearlyActive = 1
		end
	
	
        if sensors.govmode == "SPOOLUP" then
            govNearlyActive = 1
			
			if spoolupNearlyActive == 1 then
				spoolupNearlyActive = 0				
			end	
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
                sensorTempMCUMin = sensors.temp_mcu 
                sensorTempMCUMax = sensors.temp_mcu
                sensorTempESCMin = sensors.temp_esc
                sensorTempESCMax = sensors.temp_esc
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
                sensorTempMCUMin = sensors.temp_mcu
            end
            if sensors.temp_mcu > sensorTempMCUMax then
                sensorTempMCUMax = sensors.temp_mcu
            end
            if sensors.temp_esc < sensorTempESCMin then
                sensorTempESCMin = sensors.temp_esc
            end
            if sensors.temp_esc > sensorTempESCMax then
                sensorTempESCMax = sensors.temp_esc
            end
			
			govWasActive = true
        end
		

		
		-- store the last values
		if govWasActive and (sensors.govmode == 'OFF' or sensors.govmode == 'DISABLED' or sensors.govmode == 'DISARMED' or sensors.govmode == 'UNKNOWN') then
			govWasActive = false	



			local maxminFinals = rf2status.readHistory()	


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
		
			--print("Last data: ".. maxminRow )

			table.insert(maxminFinals,1,maxminRow)
			if tablelength(maxminFinals) >= 9 then
				table.remove(maxminFinals,9)			
			end



			name = string.gsub(model.name(), "%s+", "_")	
			name = string.gsub(name, "%W", "_")		
		
			file = "/scripts/RF2STATUS/logs/" .. name .. ".log"	
			f = io.open(file,'w')
			f:write("")
			io.close(f)	

			--print("Writing history to: " .. file)
			
			f = io.open(file,'a')
			for k,v in ipairs(maxminFinals) do
				if v ~= nil then
					v = v:gsub("%s+", "")
					--if v ~= "" then
						--print(v)
						f:write(v .. "\n")
					--end
				end
			end
			io.close(f)			
		
			readLOGS = false	
			
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

local function updateFILTERING()
	if filteringParam == 2 then
		--print("Filtering: medium")
		local voltageNoiseQ = 150
		local fuelNoiseQ = 150
		local rpmNoiseQ = 150
		local temp_mcuNoiseQ = 150
		local temp_escNoiseQ = 150
		local rssiNoiseQ = 150
		local currentNoiseQ = 150
	elseif filteringParam == 3 then
		--print("Filtering: high")
		local voltageNoiseQ = 200
		local fuelNoiseQ = 200
		local rpmNoiseQ = 200
		local temp_mcuNoiseQ = 200
		local temp_escNoiseQ = 200
		local rssiNoiseQ = 200
		local currentNoiseQ = 200
	else
		--print("Filtering: low")
		local voltageNoiseQ = 100
		local fuelNoiseQ = 100
		local rpmNoiseQ = 100
		local temp_mcuNoiseQ = 100
		local temp_escNoiseQ = 100
		local rssiNoiseQ = 100
		local currentNoiseQ = 100
	end
end

function rf2status.kalmanCurrent(new, old)
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

function rf2status.kalmanRSSI(new, old)
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

function rf2status.kalmanTempMCU(new, old)
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

function rf2status.kalmanTempESC(new, old)
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

function rf2status.kalmanRPM(new, old)
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

function rf2status.kalmanVoltage(new, old)
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

function rf2status.sensorMakeNumber(x)
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

function rf2status.round(number, precision)
    local fmtStr = string.format("%%0.%sf", precision)
    number = string.format(fmtStr, number)
    number = tonumber(number)
    return number
end

function rf2status.SecondsToClock(seconds)
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

function rf2status.SecondsToClockAlt(seconds)
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

function rf2status.SecondsFromTime(seconds)
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

function rf2status.spairs(t, order)
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

function rf2status.explode (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

function rf2status.ReadLine(f, line)
    local i = 1 -- line counter
    for l in f:lines() do -- lines iterator, "l" returns the line
        if i == line then return l end -- we found this line, return it
        i = i + 1 -- counting lines
    end
    return "" -- Doesn't have that line
end


function rf2status.readHistory()

	local history = {}
	--print("Reading history")
	
	name = string.gsub(model.name(), "%s+", "_")	
	name = string.gsub(name, "%W", "_")
	file = "/scripts/RF2STATUS/logs/" .. name .. ".log"
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
		triggerVoltageSwitchParam = storage.read("triggerswitchvltg")
		govmodeParam = storage.read("govmode")
		governorAlertsParam = storage.read("governoralerts")
		rpmAlertsParam = storage.read("rpmalerts")				
		rpmAlertsPercentageParam = storage.read("rpmaltp")	
		adjFunctionParam = storage.read("adjfunc")	
		triggerRPMSwitchParam = storage.read("triggerswitchrpm")
		triggerCurrentSwitchParam = storage.read("triggerswitchcrnt")
		triggerFuelSwitchParam = storage.read("triggerswitchfuel")		
		triggerLQSwitchParam = storage.read("triggerswitchlq")
		triggerESCSwitchParam = storage.read("triggerswitchesc")
		triggerMCUSwitchParam = storage.read("triggerswitchmcu")
		triggerTimerSwitchParam = storage.read("triggerswitchtmr")
		filteringParam = storage.read("filtering")		
		sagParam = storage.read("sag")	
		lowvoltagsenseParam = storage.read("lvsense")		
		triggerIntervalParam = storage.read("triggerint")	
		lowVoltageGovernorParam = storage.read("lvgovernor")
		lowvoltagStickParam = storage.read("lvstickmon")
		miniBoxParam = storage.read('minibox')
		lowvoltagStickCutoffParam = storage.read("lvstickcutoff")

		-- fix some legacy params values if bad
		if miniBoxParam == nil then miniBoxParam = 0 end
		if titleParam == 0 then titleParam = false end
		if titleParam == 1 then titleParam = true end		
		if maxminParam == 0 then maxminParam = false end
		if maxminParam == 1 then maxminParam = true end		
		if lowVoltageGovernorParam == 0 then lowVoltageGovernorParam = false end
		if lowVoltageGovernorParam == 1 then lowVoltageGovernorParam = true end		
		if alrthptParam == 0 then alrthptParam = false end
		if alrthptParam == 1 then alrthptParam = true end		
		if governorAlertsParam == 0 then governorAlertsParam = false end
		if governorAlertsParam == 1 then governorAlertsParam = true end				
		if rpmAlertsParam == 0 then rpmAlertsParam = false end
		if rpmAlertsParam == 1 then rpmAlertsParam = true end	
		if adjFunctionParam == 0 then adjFunctionParam = false end
		if adjFunctionParam == 1 then adjFunctionParam = true end
		
		rf2status.resetALL()
		updateFILTERING()		
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
		storage.write("triggerswitchvltg", triggerVoltageSwitchParam)
		storage.write("govmode", govmodeParam)	
		storage.write("governoralerts",governorAlertsParam)
		storage.write("rpmalerts",rpmAlertsParam)
		storage.write("rpmaltp",rpmAlertsPercentageParam)
		storage.write("adjfunc",adjFunctionParam)	
		storage.write("triggerswitchrpm",triggerRPMSwitchParam)
		storage.write("triggerswitchcrnt",triggerCurrentSwitchParam)
		storage.write("triggerswitchfuel",triggerFuelSwitchParam)		
		storage.write("triggerswitchlq",triggerLQSwitchParam)		
		storage.write("triggerswitchesc",triggerESCSwitchParam)	
		storage.write("triggerswitchmcu",triggerMCUSwitchParam)		
		storage.write("triggerswitchtmr",triggerTimerSwitchParam)
		storage.write("filtering",filteringParam)	
		storage.write("sag",sagParam)
		storage.write("lvsense",lowvoltagsenseParam)
		storage.write("triggerint",triggerIntervalParam)
		storage.write("lvgovernor",lowVoltageGovernorParam)
		storage.write("lvstickmon",lowvoltagStickParam)
		storage.write("minibox",miniBoxParam)
		storage.write("lvstickcutoff",lowvoltagStickCutoffParam)
		
		updateFILTERING()		
end

function rf2status.playCurrent(widget)
    if triggerCurrentSwitchParam ~= nil then
        if triggerCurrentSwitchParam:state() then
            currentTriggerTimer = true
            currentDoneFirst = false
        else
            currentTriggerTimer = false
            currentDoneFirst = true
        end

        if isInConfiguration == false then
            if sensors.current ~= nil then
                if currentTriggerTimer == true then
                    --start timer
                    if currentTriggerTimerStart == nil and currentDoneFirst == false then
                        currentTriggerTimerStart = os.time()
						currentaudioTriggerCounter = os.clock()
						--print ("Play Current Alert (first)")
                        system.playNumber(sensors.current/10, UNIT_AMPERE, 2)
                        currentDoneFirst = true
                    end
                else
                    currentTriggerTimerStart = nil
                end

                if currentTriggerTimerStart ~= nil then
                    if currentDoneFirst == false then
                        if ((tonumber(os.clock()) - tonumber(currentaudioTriggerCounter)) >= triggerIntervalParam) then
							--print ("Play Current Alert (repeat)")
                            currentaudioTriggerCounter = os.clock()
                            system.playNumber(sensors.current/10, UNIT_AMPERE, 2)
                        end
                    end
                else
                    -- stop timer
                    currentTriggerTimerStart = nil
                end
            end
        end
    end
end

function rf2status.playLQ(widget)
    if triggerLQSwitchParam ~= nil then
        if triggerLQSwitchParam:state() then
            lqTriggerTimer = true
            lqDoneFirst = false
        else
            lqTriggerTimer = false
            lqDoneFirst = true
        end

        if isInConfiguration == false then
            if sensors.rssi ~= nil then
                if lqTriggerTimer == true then
                    --start timer
                    if lqTriggerTimerStart == nil and lqDoneFirst == false then
                        lqTriggerTimerStart = os.time()
						lqaudioTriggerCounter = os.clock()
						--print ("Play LQ Alert (first)")
						system.playFile("/scripts/RF2STATUS/sounds/alerts/lq.wav")						
                        system.playNumber(sensors.rssi, UNIT_PERCENT, 2)
                        lqDoneFirst = true
                    end
                else
                    lqTriggerTimerStart = nil
                end

                if lqTriggerTimerStart ~= nil then
                    if lqDoneFirst == false then
                        if ((tonumber(os.clock()) - tonumber(lqaudioTriggerCounter)) >= triggerIntervalParam) then
                            lqaudioTriggerCounter = os.clock()
							--print ("Play LQ Alert (repeat)")
							system.playFile("/scripts/RF2STATUS/sounds/alerts/lq.wav")
                            system.playNumber(sensors.rssi, UNIT_PERCENT, 2)
                        end
                    end
                else
                    -- stop timer
                    lqTriggerTimerStart = nil
                end
            end
        end
    end
end

function rf2status.playMCU(widget)
    if triggerMCUSwitchParam ~= nil then
        if triggerMCUSwitchParam:state() then
            mcuTriggerTimer = true
            mcuDoneFirst = false
        else
            mcuTriggerTimer = false
            mcuDoneFirst = true
        end

        if isInConfiguration == false then
            if sensors.temp_mcu ~= nil then
                if mcuTriggerTimer == true then
                    --start timer
                    if mcuTriggerTimerStart == nil and mcuDoneFirst == false then
                        mcuTriggerTimerStart = os.time()
						mcuaudioTriggerCounter = os.clock()
						--print ("Playing MCU (first)")
						system.playFile("/scripts/RF2STATUS/sounds/alerts/mcu.wav")
                        system.playNumber(sensors.temp_mcu/100, UNIT_DEGREE, 2)
                        mcuDoneFirst = true
                    end
                else
                    mcuTriggerTimerStart = nil
                end

                if mcuTriggerTimerStart ~= nil then
                    if mcuDoneFirst == false then
                        if ((tonumber(os.clock()) - tonumber(mcuaudioTriggerCounter)) >= triggerIntervalParam) then
                            mcuaudioTriggerCounter = os.clock()
							--print ("Playing MCU (repeat)")
							system.playFile("/scripts/RF2STATUS/sounds/alerts/mcu.wav")
                            system.playNumber(sensors.temp_mcu/100, UNIT_DEGREE, 2)
                        end
                    end
                else
                    -- stop timer
                    mcuTriggerTimerStart = nil
                end
            end
        end
    end
end

function rf2status.playESC(widget)
    if triggerESCSwitchParam ~= nil then
        if triggerESCSwitchParam:state() then
            escTriggerTimer = true
            escDoneFirst = false
        else
            escTriggerTimer = false
            escDoneFirst = true
        end

        if isInConfiguration == false then
            if sensors.temp_esc ~= nil then
                if escTriggerTimer == true then
                    --start timer
                    if escTriggerTimerStart == nil and escDoneFirst == false then
                        escTriggerTimerStart = os.time()
						escaudioTriggerCounter = os.clock()
						--print ("Playing ESC (first)")
						system.playFile("/scripts/RF2STATUS/sounds/alerts/esc.wav")
                        system.playNumber(sensors.temp_esc/100, UNIT_DEGREE, 2)
                        escDoneFirst = true
                    end
                else
                    escTriggerTimerStart = nil
                end

                if escTriggerTimerStart ~= nil then
                    if escDoneFirst == false then
                        if ((tonumber(os.clock()) - tonumber(escaudioTriggerCounter)) >= triggerIntervalParam) then
                            escaudioTriggerCounter = os.clock()
							--print ("Playing ESC (repeat)")
							system.playFile("/scripts/RF2STATUS/sounds/alerts/esc.wav")
                            system.playNumber(sensors.temp_esc/100, UNIT_DEGREE, 2)
                        end
                    end
                else
                    -- stop timer
                    escTriggerTimerStart = nil
                end
            end
        end
    end
end

function rf2status.playTIMER(widget)
    if triggerTimerSwitchParam ~= nil then

        if triggerTimerSwitchParam:state() then
            timerTriggerTimer = true
            timerDoneFirst = false
        else
            timerTriggerTimer = false
            timerDoneFirst = true
        end

        if isInConfiguration == false then
		
			if theTIME == nil then
				alertTIME = 0
			else
				alertTIME = theTIME
			end
		
		
            if alertTIME ~= nil then
			
			    hours = string.format("%02.f", math.floor(alertTIME / 3600))
				mins = string.format("%02.f", math.floor(alertTIME / 60 - (hours * 60)))
				secs = string.format("%02.f", math.floor(alertTIME - hours * 3600 - mins * 60))
			
                if timerTriggerTimer == true then
                    --start timer
                    if timerTriggerTimerStart == nil and timerDoneFirst == false then
                        timerTriggerTimerStart = os.time()
						timeraudioTriggerCounter = os.clock()
						--print ("Playing TIMER (first)" .. alertTIME)
	
						if mins ~= "00" then
							system.playNumber(mins, UNIT_MINUTE, 2)
						end
						system.playNumber(secs, UNIT_SECOND, 2)

                        timerDoneFirst = true
                    end
                else
                    timerTriggerTimerStart = nil
                end

                if timerTriggerTimerStart ~= nil then
                    if timerDoneFirst == false then
                        if ((tonumber(os.clock()) - tonumber(timeraudioTriggerCounter)) >= triggerIntervalParam) then
                            timeraudioTriggerCounter = os.clock()
							--print ("Playing TIMER (repeat)" .. alertTIME)
							if mins ~= "00" then
								system.playNumber(mins, UNIT_MINUTE, 2)
							end
							system.playNumber(secs, UNIT_SECOND, 2)
                        end
                    end
                else
                    -- stop timer
                    timerTriggerTimerStart = nil
                end
            end
        end
    end
end

function rf2status.playFuel(widget)
    if triggerFuelSwitchParam ~= nil then
        if triggerFuelSwitchParam:state() then
            fuelTriggerTimer = true
            fuelDoneFirst = false
        else
            fuelTriggerTimer = false
            fuelDoneFirst = true
        end

        if isInConfiguration == false then
            if sensors.fuel ~= nil then
                if fuelTriggerTimer == true then
                    --start timer
                    if fuelTriggerTimerStart == nil and fuelDoneFirst == false then
                        fuelTriggerTimerStart = os.time()
						fuelaudioTriggerCounter = os.clock()
						--print("Play fuel alert (first)")
						system.playFile("/scripts/RF2STATUS/sounds/alerts/fuel.wav")	
                        system.playNumber(sensors.fuel, UNIT_PERCENT, 2)				
                        fuelDoneFirst = true
                    end
                else
                    fuelTriggerTimerStart = nil
                end

                if fuelTriggerTimerStart ~= nil then
                    if fuelDoneFirst == false then
                        if ((tonumber(os.clock()) - tonumber(fuelaudioTriggerCounter)) >= triggerIntervalParam) then
                            fuelaudioTriggerCounter = os.clock()
							--print("Play fuel alert (repeat)")
							system.playFile("/scripts/RF2STATUS/sounds/alerts/fuel.wav")	
                            system.playNumber(sensors.fuel, UNIT_PERCENT, 2)
													
                        end
                    end
                else
                    -- stop timer
                    fuelTriggerTimerStart = nil
                end
            end
        end
    end
end

function rf2status.playRPM(widget)
    if triggerRPMSwitchParam ~= nil then
        if triggerRPMSwitchParam:state() then
            rpmTriggerTimer = true
            rpmDoneFirst = false
        else
            rpmTriggerTimer = false
            rpmDoneFirst = true
        end

        if isInConfiguration == false then
            if sensors.rpm ~= nil then
                if rpmTriggerTimer == true then
                    --start timer
                    if rpmTriggerTimerStart == nil and rpmDoneFirst == false then
                        rpmTriggerTimerStart = os.time()
						rpmaudioTriggerCounter = os.clock()
						--print("Play rpm alert (first)")
                        system.playNumber(sensors.rpm, UNIT_RPM, 2)
                        rpmDoneFirst = true
                    end
                else
                    rpmTriggerTimerStart = nil
                end

                if rpmTriggerTimerStart ~= nil then
                    if rpmDoneFirst == false then
                        if ((tonumber(os.clock()) - tonumber(rpmaudioTriggerCounter)) >= triggerIntervalParam) then
							--print("Play rpm alert (repeat)")
                            rpmaudioTriggerCounter = os.clock()
                            system.playNumber(sensors.rpm, UNIT_RPM, 2)
                        end
                    end
                else
                    -- stop timer
                    rpmTriggerTimerStart = nil
                end
            end
        end
    end
end

function rf2status.playVoltage(widget)
    if triggerVoltageSwitchParam ~= nil then
        if triggerVoltageSwitchParam:state() then
            lvTriggerTimer = true
            voltageDoneFirst = false
        else
            lvTriggerTimer = false
            voltageDoneFirst = true
        end

        if isInConfiguration == false then
            if sensors.voltage ~= nil then
                if lvTriggerTimer == true then
                    --start timer
                    if lvTriggerTimerStart == nil and voltageDoneFirst == false then
                        lvTriggerTimerStart = os.time()
						lvaudioTriggerCounter = os.clock()
						--print("Play voltage alert (first)")
						--system.playFile("/scripts/RF2STATUS/sounds/alerts/voltage.wav")						
                        system.playNumber(sensors.voltage / 100, 2, 2)
                        voltageDoneFirst = true
                    end
                else
                    lvTriggerTimerStart = nil
                end

                if lvTriggerTimerStart ~= nil then
                    if voltageDoneFirst == false then
                        if ((tonumber(os.clock()) - tonumber(lvaudioTriggerCounter)) >= triggerIntervalParam) then
                            lvaudioTriggerCounter = os.clock()
							--print("Play voltage alert (repeat)")
							--system.playFile("/scripts/RF2STATUS/sounds/alerts/voltage.wav")								
                            system.playNumber(sensors.voltage / 100, 2, 2)
                        end
                    end
                else
                    -- stop timer
                    lvTriggerTimerStart = nil
                end
            end
        end
    end
end

local function event(widget, category, value, x, y)

	--print("Event received:", category, value, x, y)
	
	-- disable menu if governor active
		if sensors.govmode == "IDLE" or sensors.govmode == "SPOOLUP" or sensors.govmode == "RECOVERY" or
					sensors.govmode == "ACTIVE" or
					sensors.govmode == "LOST-HS" or
					sensors.govmode == "BAILOUT" or
					sensors.govmode == "RECOVERY" then
			if category == EVT_TOUCH then
				return true
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



local function playGovernor()
	if governorAlertsParam == true then
		if playGovernorLastState == nil then
			playGovernorLastState = sensors.govmode
		end
		
		if sensors.govmode ~= playGovernorLastState then
			playGovernorCount = 0
			playGovernorLastState = sensors.govmode
		end
		
		if playGovernorCount == 0 then
				--print("Governor: " .. sensors.govmode)
				playGovernorCount = 1
				system.playFile("/scripts/RF2STATUS/sounds/gov/"..string.lower(sensors.govmode)..".wav")
		end
	
	end
end



function rf2status.playRPMDiff()
	if rpmAlertsParam == true then
	
	    if sensors.govmode == "ACTIVE" or sensors.govmode == "LOST-HS" or sensors.govmode == "BAILOUT" or sensors.govmode == "RECOVERY" then
	
			if playRPMDiffLastState == nil then
				playRPMDiffLastState = sensors.rpm
			end
		
			-- we take a reading every 5 second
			if (tonumber(os.clock()) - tonumber(rf2status.playRPMDiffCounter)) >= 5 then
				playRPMDiffCounter = os.clock()
				playRPMDiffLastState = sensors.rpm
			end
			
			-- check if current state withing % of last state
			local percentageDiff = 0
			if sensors.rpm > rf2status.playRPMDiffLastState then
				percentageDiff = math.abs(100 - (sensors.rpm / rf2status.playRPMDiffLastState * 100))
			elseif rf2status.playRPMDiffLastState < sensors.rpm then
				percentage = math.abs(100 - (rf2status.playRPMDiffLastState/sensors.rpm * 100))
			else
				percentageDiff = 0
			end		

			if percentageDiff > rpmAlertsPercentageParam/10 then
				playRPMDiffCount = 0
			end

			if playRPMDiffCount == 0 then
					--print("RPM Difference: " .. percentageDiff)
					playRPMDiffCount = 1
					system.playNumber(sensors.rpm ,  UNIT_RPM, 2)
			end		
		end
	end
end


local adjTimerStart = os.time()
local adjJUSTUPCounter = 0
local function playADJ()


	if adjFunctionParam  == true then

		ADJSOURCE = math.floor(sensors.adjsource)
		ADJVALUE = math.floor(sensors.adjvalue)
		
		if oldADJSOURCE ~= ADJSOURCE then
				adjfuncIdChanged = true
		end
		if oldADJVALUE ~= ADJVALUE then
				adjfuncValueChanged = true
		end
		
		if adjJUSTUP == true then
			adjJUSTUPCounter = adjJUSTUPCounter + 1
			adjfuncIdChanged = false
			adjfuncValueChanged = false
			
			if adjJUSTUPCounter == 10 then
				adjJUSTUP = false
			end
			
		else
			adjJUSTUPCounter = 0
			if (os.time() - adjTimerStart >= 1) then
				if adjfuncIdChanged == true then
					-- play function that has changed
					adjfunction = adjfunctions["id"..ADJSOURCE]
					if adjfunction ~= nil then
						--print("ADJfunc triggered for: " .. "id".. ADJSOURCE)
						for wavi, wavv in ipairs(adjfunction.wavs) do
							system.playFile("/scripts/RF2STATUS/sounds/adjfunc/"..wavv..".wav")
						end
					end	
					adjfuncIdChanged = false
				end
				if adjfuncValueChanged == true or adjfuncIdChanged == true then	
						showADJWAITINGAlert = true
						system.playNumber(ADJVALUE)

						adjfuncValueChanged = false
						adjTimerStart = os.time()
						
				end	
			end
		end
		
		oldADJSOURCE = ADJSOURCE
		oldADJVALUE = ADJVALUE

	end

end


local function wakeup(widget)
    refresh = false

    linkUP = rf2status.getRSSI()
    sensors = rf2status.getSensors()
	
    if refresh == true then
        sensorsMAXMIN(sensors)	
        lcd.invalidate()
    end
	
	if linkUP == 0 then
		linkUPTime = os.clock()
	end
	
	if linkUP ~= 0 then
	
		 if ((tonumber(os.clock()) - tonumber(linkUPTime)) >= 5) then
			-- voltage alerts
			rf2status.playVoltage(widget)
			-- governor callouts
			playGovernor(widget)
			-- rpm diff
			rf2status.playRPMDiff(widget)	
			-- rpm
			rf2status.playRPM(widget)	
			-- current
			rf2status.playCurrent(widget)	
			-- fuel
			rf2status.playFuel(widget)	
			-- lq
			rf2status.playLQ(widget)	
			-- esc
			rf2status.playESC(widget)
			-- mcu
			rf2status.playMCU(widget)
			-- timer
			rf2status.playTIMER(widget)
			-- adjValues
			playADJ(widget)
		else
			adjJUSTUP = true	
		end	
	end
	
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

end

return {init = init}
