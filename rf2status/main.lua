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


local theTIME = 0
local sensors = {}


local sensordisplay = {}

local lvTimer = false
local lvTimerStart
local lvannouncementTimer = false
local lvannouncementTimerStart
local lvaudioannouncementCounter = 0
local lvAudioAlertCounter = 0

local motorWasActive = false

local lfTimer = false
local lfTimerStart
local lfannouncementTimer = false
local lfannouncementTimerStart
local lfaudioannouncementCounter = 0
local lfAudioAlertCounter = 0

local rpmtime = {}
rpmtime.rpmTimer = false
rpmtime.rpmTimerStart = nil
rpmtime.announcementTimer = false
rpmtime.announcementTimerStart = nil
rpmtime.audioannouncementCounter = 0

local currenttime = {}
currenttime.currentTimer = false
currenttime.currentTimerStart = nil
currenttime.currentannouncementTimer = false
currenttime.currentannouncementTimerStart = nil
currenttime.currentaudioannouncementCounter = 0


local lqtime = {}
lqtime.lqTimer = false
lqtime.lqTimerStart = nil
lqtime.lqannouncementTimer = false
lqtime.lqannouncementTimerStart = nil
lqtime.lqaudioannouncementCounter = 0

local fueltime = {}
fueltime.fuelTimer = false
fueltime.fuelTimerStart = nil
fueltime.fuelannouncementTimer = false
fueltime.fuelannouncementTimerStart = nil
fueltime.fuelaudioannouncementCounter = 0

local esctime = {}
esctime.escTimer = false
esctime.escTimerStart = nil
esctime.escannouncementTimer = false
esctime.escannouncementTimerStart = nil
esctime.escaudioannouncementCounter = 0

local mcutime = {}
mcutime.mcuTimer = false
mcutime.mcuTimerStart = nil
mcutime.mcuannouncementTimer = false
mcutime.mcuannouncementTimerStart = nil
mcutime.mcuaudioannouncementCounter = 0

local timetime = {}
timetime.timerTimer = false
timetime.timerTimerStart = nil
timetime.timerannouncementTimer = false
timetime.timerannouncementTimerStart = nil
timetime.timeraudioannouncementCounter = 0

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

local playrpmdiff = {}
playrpmdiff.playRPMDiffCount = 1
playrpmdiff.playRPMDiffLastState = nil
playrpmdiff.playRPMDiffCounter = 0

local switchstatus = {}

local quadBoxParam = 0
local lowvoltagStickParam = 0
local lowvoltagStickCutoffParam = 70
local govmodeParam = 0
local btypeParam = 0
local lowfuelParam = 20
local alertintParam = 5
local alrthptcParam = 1
local maxminParam = true
local titleParam = true
local modelImageParam = true
local cellsParam = 6
local lowVoltageGovernorParam = true
local sagParam = 5
local rpmAlertsParam = false
local rpmAlertsPercentageParam = 100
local governorAlertsParam = true
local announcementVoltageSwitchParam = nil
local announcementRPMSwitchParam = nil
local announcementCurrentSwitchParam = nil
local announcementFuelSwitchParam = nil	
local announcementLQSwitchParam = nil
local announcementESCSwitchParam = nil
local announcementMCUSwitchParam = nil
local announcementTimerSwitchParam = nil
local filteringParam = 1
local lowvoltagsenseParam = 2
local announcementIntervalParam = 30
local lowVoltageGovernorParam = nil
local lowvoltagStickParam = nil
local lowvoltagStickCutoffParam = nil
local governorUNKNOWNParam = true
local governorDISARMEDParam  = true
local governorDISABLEDParam = true
local governorBAILOUTParam = true
local governorAUTOROTParam = true
local governorLOSTHSParam = true
local governorTHROFFParam = true
local governorACTIVEParam = true
local governorRECOVERYParam = true
local governorSPOOLUPParam = true
local governorIDLEParam = true
local governorOFFParam = true
local alertonParam = 0
local calcfuelParam = false
local tempconvertParamESC = 1
local tempconvertParamMCU = 1
local lowvoltagStickCutoffParam = 80
local idleupdelayParam = 20
local switchIdlelowParam = nil
local switchIdlemediumParam = nil
local switchIdlehighParam = nil
local switchrateslowParam = nil
local switchratesmediumParam = nil
local switchrateshighParam = nil
local switchrescueonParam = nil
local switchrescueoffParam = nil
local switchbblonParam = nil
local switchbbloffParam = nil
local idleupswitchParam = nil

local lvStickOrder = {}
lvStickOrder[1] = {1,2,3,4}
lvStickOrder[2] = {1,2,4,5}
lvStickOrder[3] = {1,2,4,6}
lvStickOrder[4] = {2,3,4,6}

local lvStickannouncement = false

local govmodeParam = 0
local adjFunctionParam = false

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



local layoutOptions = {
		{"TIMER",1},
		{"VOLTAGE",2},
		{"FUEL",3},	
		{"CURRENT",4},
		{"MAH",17},		
		{"RPM",5},
		{"LQ", 6},
		{"T.ESC", 7},			
		{"T.MCU", 8},
		{"IMAGE",9},
		{"GOVERNOR",10},		
		{"IMAGE, GOV", 11},			
		{"LQ,TIMER", 12},	
		{"T.ESC,T.MCU", 13},
		{"VOLTAGE,FUEL", 14},
		{"VOLTAGE,CURRENT", 15},			
		{"VOLTAGE,MAH", 16},		
		{"LQ,TIMER,T.ESC,T.MCU", 20},
	}

-- default layout as follows
local layoutBox1Param = 10 	-- IMAGE, GOV
local layoutBox2Param = 2  	-- VOLTAGE
local layoutBox3Param = 3 	-- FUEL
local layoutBox4Param = 11 	-- LQ,TIMER
local layoutBox5Param = 4 	-- CURRENT
local layoutBox6Param = 5	-- RPM


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
    gfx_heli = lcd.loadBitmap("/scripts/rf2status/gfx/heli.png")
	gfx_close = lcd.loadBitmap("/scripts/rf2status/gfx/close.png")
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
        announcementswitchvltg = nil,
        govmode = 0,
		governoralerts = 0,
		rpmalerts = 0,
		rpmaltp = 2.5,
		adjfunc = 0,
		announcementswitchrpm = nil,
		announcementswitchcrnt = nil,
		announcementswitchfuel = nil,
		announcementswitchlq = nil,
		announcementswitchesc = nil,
		announcementswitchmcu = nil,
		announcementswitchtmr = nil,
		filtering = 1,
		sag = 5,
		lvsense = 2,
		announcementint = 30,
		lvgovernor = false,
		lvstickmon = 0,
		lvstickcutoff = 1,
		governorUNKNOWN = true,
		governorDISARMED = true,
		governorDISABLED = true,
		governorBAILOUT = true,
		governorAUTOROT = true,
		governorLOSTHS = true,
		governorTHROFF = true,
		governorACTIVE = true,
		governorRECOVERY = true,
		governorSPOOLUP = true,
		governorIDLE = true,
		governorOFF	 = true,
		alerton = 0,
		tempconvertesc = 1
    }
end

function loadScriptrf2status(script) 
	return loadfile(script) 
end

local function configure(widget)
    isInConfiguration = true



	triggerpanel = form.addExpansionPanel("Triggers")
	triggerpanel:open(false) 


    line = triggerpanel:addLine("Arm switch")	
    armswitch = form.addSwitchField(
        line,
        form.getFieldSlots(line)[0],
        function()
            return armswitchParam
        end,
        function(value)
            armswitchParam = value
        end
    )

    line = triggerpanel:addLine("Idleup switch")	
    idleupswitch = form.addSwitchField(
        line,
        form.getFieldSlots(line)[0],
        function()
            return idleupswitchParam
        end,
        function(value)
            idleupswitchParam = value
        end
    )


    line = triggerpanel:addLine("    Delay before active")
    field =
        form.addNumberField(
        line,
        nil,
        5,
        60,
        function()
            return idleupdelayParam
        end,
        function(value)
            idleupdelayParam = value
        end
    )
    field:default(5)
	field:suffix("s")



	batterypanel = form.addExpansionPanel("Battery configuration")
	batterypanel:open(false) 


    -- CELLS

    line = batterypanel:addLine("Type")
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
    line = batterypanel:addLine("Cells")
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




   -- LOW FUEL announcement
    line = batterypanel:addLine("Low fuel%")
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

    -- ALERT ON
    line = batterypanel:addLine("Play alert on")
    form.addChoiceField(
        line,
        nil,
        {{"Low voltage", 0}, {"Low fuel", 1},{"Low fuel & Low voltage", 2},{"Disabled", 3}},
        function()
            return alertonParam
        end,
        function(newValue)
			if newValue == 3 then
				plalrtint:enable(false)
				plalrthap:enable(false)
			else
				plalrtint:enable(true)
				plalrthap:enable(true)			
			end
            alertonParam = newValue
        end
    )

    -- ALERT INTERVAL
    line = batterypanel:addLine("     Interval")
    plalrtint = form.addChoiceField(
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
	if alertonParam == 3 then
		plalrtint:enable(false)
	else
		plalrtint:enable(true)	
	end	

    -- HAPTIC
    line = batterypanel:addLine("     Vibrate")
    plalrthap = form.addBooleanField(
        line,
        nil,
        function()
            return alrthptParam
        end,
        function(newValue)
            alrthptParam = newValue
        end
    )	
	if alertonParam == 3 then
		plalrthap:enable(false)
	else
		plalrthap:enable(true)	
	end	


	switchpanel = form.addExpansionPanel("Switch announcements")
	switchpanel:open(false) 


    line = switchpanel:addLine("Idle speed low")
    form.addSwitchField(
        line,
        nil,
        function()
            return switchIdlelowParam
        end,
        function(value)
            switchIdlelowParam = value
        end
    )

    line = switchpanel:addLine("Idle speed medium")
    form.addSwitchField(
        line,
        nil,
        function()
            return switchIdlemediumParam
        end,
        function(value)
            switchIdlemediumParam = value
        end
    )

    line = switchpanel:addLine("Idle speed high")
    form.addSwitchField(
        line,
        nil,
        function()
            return switchIdlehighParam
        end,
        function(value)
            switchIdlehighParam = value
        end
    )

    line = switchpanel:addLine("Rates low")
    form.addSwitchField(
        line,
        nil,
        function()
            return switchrateslowParam
        end,
        function(value)
            switchrateslowParam = value
        end
    )

    line = switchpanel:addLine("Rates medium")
    form.addSwitchField(
        line,
        nil,
        function()
            return switchratesmediumParam
        end,
        function(value)
            switchratesmediumParam = value
        end
    )

    line = switchpanel:addLine("Rates high")
    form.addSwitchField(
        line,
        nil,
        function()
            return switchrateshighParam
        end,
        function(value)
            switchrateshighParam = value
        end
    )


    line = switchpanel:addLine("Rescue on")
    form.addSwitchField(
        line,
        nil,
        function()
            return switchrescueonParam
        end,
        function(value)
            switchrescueonParam = value
        end
    )

    line = switchpanel:addLine("Rescue off")
    form.addSwitchField(
        line,
        nil,
        function()
            return switchrescueoffParam
        end,
        function(value)
            switchrescueoffParam = value
        end
    )

    line = switchpanel:addLine("BBL enabled")
    form.addSwitchField(
        line,
        nil,
        function()
            return switchbblonParam
        end,
        function(value)
            switchbblonParam = value
        end
    )

    line = switchpanel:addLine("BBL disabled")
    form.addSwitchField(
        line,
        nil,
        function()
            return switchbbloffParam
        end,
        function(value)
            switchbbloffParam = value
        end
    )
	
	
	announcementpanel = form.addExpansionPanel("Telemetry announcements")
	announcementpanel:open(false) 
	
    -- announcement VOLTAGE READING
    line = announcementpanel:addLine("Voltage")
    form.addSwitchField(
        line,
        form.getFieldSlots(line)[0],
        function()
            return announcementVoltageSwitchParam
        end,
        function(value)
            announcementVoltageSwitchParam = value
        end
    )

    -- announcement RPM READING
    line = announcementpanel:addLine("Rpm")
    form.addSwitchField(
        line,
        nil,
        function()
            return announcementRPMSwitchParam
        end,
        function(value)
            announcementRPMSwitchParam = value
        end
    )

    -- announcement CURRENT READING
    line = announcementpanel:addLine("Current")
    form.addSwitchField(
        line,
        nil,
        function()
            return announcementCurrentSwitchParam
        end,
        function(value)
            announcementCurrentSwitchParam = value
        end
    )

    -- announcement FUEL READING
    line = announcementpanel:addLine("Fuel")
    form.addSwitchField(
        line,
        form.getFieldSlots(line)[0],
        function()
            return announcementFuelSwitchParam
        end,
        function(value)
            announcementFuelSwitchParam = value
        end
    )

    -- announcement LQ READING
    line = announcementpanel:addLine("LQ")
    form.addSwitchField(
        line,
        form.getFieldSlots(line)[0],
        function()
            return announcementLQSwitchParam
        end,
        function(value)
            announcementLQSwitchParam = value
        end
    )

    -- announcement LQ READING
    line = announcementpanel:addLine("Esc temperature")
    form.addSwitchField(
        line,
        form.getFieldSlots(line)[0],
        function()
            return announcementESCSwitchParam
        end,
        function(value)
            announcementESCSwitchParam = value
        end
    )

    -- announcement MCU READING
    line = announcementpanel:addLine("Mcu temperature")
    form.addSwitchField(
        line,
        form.getFieldSlots(line)[0],
        function()
            return announcementMCUSwitchParam
        end,
        function(value)
            announcementMCUSwitchParam = value
        end
    )

    -- announcement TIMER READING
    line = announcementpanel:addLine("Timer")
    form.addSwitchField(
        line,
        form.getFieldSlots(line)[0],
        function()
            return announcementTimerSwitchParam
        end,
        function(value)
            announcementTimerSwitchParam = value
        end
    )
	

	govalertpanel = form.addExpansionPanel("Governor announcements")
	govalertpanel:open(false) 


    -- TITLE DISPLAY
    line = govalertpanel:addLine("  OFF")
    form.addBooleanField(
        line,
        nil,
        function()
            return governorOFFParam
        end,
        function(newValue)
            governorOFFParam = newValue
        end
    )

    -- TITLE DISPLAY
    line = govalertpanel:addLine("  IDLE")
    form.addBooleanField(
        line,
        nil,
        function()
            return governorIDLEParam
        end,
        function(newValue)
            governorIDLEParam = newValue
        end
    )

    -- TITLE DISPLAY
    line = govalertpanel:addLine("  SPOOLUP")
    form.addBooleanField(
        line,
        nil,
        function()
            return governorSPOOLUPParam
        end,
        function(newValue)
            governorSPOOLUPParam = newValue
        end
    )

    line = govalertpanel:addLine("  RECOVERY")
    form.addBooleanField(
        line,
        nil,
        function()
            return governorRECOVERYParam
        end,
        function(newValue)
            governorRECOVERYParam = newValue
        end
    )

    line = govalertpanel:addLine("  ACTIVE")
    form.addBooleanField(
        line,
        nil,
        function()
            return governorACTIVEParam
        end,
        function(newValue)
            governorACTIVEParam = newValue
        end
    )

    line = govalertpanel:addLine("  THR-OFF")
    form.addBooleanField(
        line,
        nil,
        function()
            return governorTHROFFParam
        end,
        function(newValue)
            governorTHROFFParam = newValue
        end
    )

    line = govalertpanel:addLine("  LOST-HS")
    form.addBooleanField(
        line,
        nil,
        function()
            return governorLOSTHSParam
        end,
        function(newValue)
            governorLOSTHSParam = newValue
        end
    )

    line = govalertpanel:addLine("  AUTOROT")
    form.addBooleanField(
        line,
        nil,
        function()
            return governorAUTOROTParam
        end,
        function(newValue)
            governorAUTOROTParam = newValue
        end
    )

    line = govalertpanel:addLine("  BAILOUT")
    form.addBooleanField(
        line,
        nil,
        function()
            return governorBAILOUTParam
        end,
        function(newValue)
            governorBAILOUTParam = newValue
        end
    )

    line = govalertpanel:addLine("  DISABLED")
    form.addBooleanField(
        line,
        nil,
        function()
            return governorDISABLEDParam
        end,
        function(newValue)
            governorDISABLEDParam = newValue
        end
    )	

    line = govalertpanel:addLine("  DISARMED")
    form.addBooleanField(
        line,
        nil,
        function()
            return governorDISARMEDParam
        end,
        function(newValue)
            governorDISARMEDParam = newValue
        end
    )	

    line = govalertpanel:addLine("    UNKNOWN")
    form.addBooleanField(
        line,
        nil,
        function()
            return governorUNKNOWNParam
        end,
        function(newValue)
            governorUNKNOWNParam = newValue
        end
    )
	

	displaypanel = form.addExpansionPanel("Customise display")
	displaypanel:open(false) 


    line = displaypanel:addLine("Box1")
    form.addChoiceField(
        line,
        nil,
		layoutOptions,
        function()
            return layoutBox1Param
        end,
        function(newValue)
            layoutBox1Param = newValue		
        end
    )

    line = displaypanel:addLine("Box2")
    form.addChoiceField(
        line,
        nil,
		layoutOptions,
        function()
            return layoutBox2Param
        end,
        function(newValue)
            layoutBox2Param = newValue		
        end
    )

    line = displaypanel:addLine("Box3")
    form.addChoiceField(
        line,
        nil,
		layoutOptions,
        function()
            return layoutBox3Param
        end,
        function(newValue)
            layoutBox3Param = newValue		
        end
    )	

    line = displaypanel:addLine("Box4")
    form.addChoiceField(
        line,
        nil,
		layoutOptions,
        function()
            return layoutBox4Param
        end,
        function(newValue)
            layoutBox4Param = newValue		
        end
    )	

    line = displaypanel:addLine("Box5")
    form.addChoiceField(
        line,
        nil,
		layoutOptions,
        function()
            return layoutBox5Param
        end,
        function(newValue)
            layoutBox5Param = newValue		
        end
    )	
	
    line = displaypanel:addLine("Box6")
    form.addChoiceField(
        line,
        nil,
		layoutOptions,
        function()
            return layoutBox6Param
        end,
        function(newValue)
            layoutBox6Param = newValue		
        end
    )	


    -- TITLE DISPLAY
    line = displaypanel:addLine("Display title")
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
    line = displaypanel:addLine("Display max/min")
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


    line = advpanel:addLine("Governor")
    extgov = form.addChoiceField(
        line,
        nil,
        {
            {"RF Governor", 0},
			{"External Governor",1},
        },
        function()
            return govmodeParam
        end,
        function(newValue)
            govmodeParam = newValue		
        end
    )


    line = form.addLine("Temperature conversion",advpanel)

    line = advpanel:addLine("    ESC")
    form.addChoiceField(
        line,
        nil,
        {
			{"Disable", 1}, 
			{"°C -> °F", 2}, 
			{"°F -> °C", 3}, 
		},
        function()
            return tempconvertParamESC
        end,
        function(newValue)
            tempconvertParamESC = newValue
        end
    )
	

    line = advpanel:addLine("    MCU")
    form.addChoiceField(
        line,
        nil,
        {
			{"Disable", 1}, 
			{"°C -> °F", 2}, 
			{"°F -> °C", 3}, 
		},
        function()
            return tempconvertParamMCU
        end,
        function(newValue)
            tempconvertParamMCU = newValue
        end
    )

    line = form.addLine("Voltage",advpanel)
	
    -- LVannouncement DISPLAY
    line = advpanel:addLine("    Sensitivity")
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

    line = advpanel:addLine("    Sag compensation")
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
    line = advpanel:addLine("    Gimbal monitoring")
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
			if newValue == 0 then
				fieldstckcutoff:enable(false)
			else
				fieldstckcutoff:enable(true)			
			end
            lowvoltagStickParam = newValue
        end
    )

    line = advpanel:addLine("       Stick cutoff")
    fieldstckcutoff =
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
    fieldstckcutoff:default(80)
	fieldstckcutoff:suffix("%")
	if lowvoltagStickParam == 0 then
		fieldstckcutoff:enable(false)
	else
		fieldstckcutoff:enable(true)	
	end


    line = form.addLine("Headspeed",advpanel)

    -- TITLE DISPLAY
    line = advpanel:addLine("   Alert on RPM difference")
    form.addBooleanField(
        line,
        nil,
        function()
            return rpmAlertsParam
        end,
        function(newValue)
			if newValue == false then
				rpmperfield:enable(false)
			else
				rpmperfield:enable(true)
			end
	
            rpmAlertsParam = newValue
        end
    )
	
	

    -- TITLE DISPLAY
    line = advpanel:addLine("   Alert if difference > than")
    rpmperfield =
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
	if rpmAlertsParam  == false then
	rpmperfield:enable(false)
	else
	rpmperfield:enable(true)
	end
    rpmperfield:default(100)
	rpmperfield:decimals(1)
	rpmperfield:suffix("%")

    -- FILTER
    -- MAX MIN DISPLAY
    line = advpanel:addLine("Telemetry filtering")
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

   -- LVannouncement DISPLAY
    line = advpanel:addLine("Announcement interval")
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
            return announcementIntervalParam
        end,
        function(newValue)
            announcementIntervalParam = newValue
        end
    )



	if system.getSource("Rx RSSI1") == nil then -- currently only supported with fport
		line = advpanel:addLine("Adjustment sensor")
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


    -- calcfuel
    line = advpanel:addLine("Calculate fuel locally")
    form.addBooleanField(
        line,
        nil,
        function()
            return calcfuelParam
        end,
        function(newValue)
            calcfuelParam = newValue
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

	-- this is just to force height calc to end up on whole numbers to avoid
	-- scaling issues
	h = (math.floor((h / 4))*4)
	w = (math.floor((w / 6))*6)

    -- first one is unsporrted

    if
        environment.board == "XES" or environment.board == "X20" or environment.board == "X20S" or
            environment.board == "X20PRO" or
            environment.board == "X20PROAW" or
           environment.board == "X20R" or
           environment.board == "X20RS" 		   
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
			title_mah = "MAH",
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
			title_mah = "MAH",			
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
			title_mah = "MAH",			
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
			title_mah = "MAH",			
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
			title_mah = "MAH",			
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




		
		--FUEL
		if sensors.fuel ~= nil then
		
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

			if sensorFuelMin == 0 or sensorFuelMin == nil or theTIME == 0 then
					sensorMIN = "-"
			else 
					sensorMIN = sensorFuelMin
			end
			
			if sensorFuelMax == 0 or sensorFuelMax == nil or theTIME == 0 then
					sensorMAX = "-"
			else 
					sensorMAX = sensorFuelMax
			end
			
		
			sensorUNIT = "%"

		
			
			local sensorTGT = 'fuel'
			sensordisplay[sensorTGT] = {}
			sensordisplay[sensorTGT]['title'] = sensorTITLE
			sensordisplay[sensorTGT]['value'] = sensorVALUE
			sensordisplay[sensorTGT]['warn'] = sensorWARN
			sensordisplay[sensorTGT]['min'] = sensorMIN
			sensordisplay[sensorTGT]['max'] = sensorMAX			
			sensordisplay[sensorTGT]['unit'] = sensorUNIT		
		
		end

		--RPM
		if sensors.rpm ~= nil then
		

			sensorVALUE = sensors.rpm
			
			if sensors.rpm < 5 then
				sensorVALUE = 0
			end
		
			if titleParam == true then
				sensorTITLE = theme.title_rpm
			else
				sensorTITLE = ""		
			end

			if sensorRPMMin == 0 or sensorRPMMin == nil or theTIME == 0 then
					sensorMIN = "-"
			else 
					sensorMIN = sensorRPMMin
			end
			
			if sensorRPMMax == 0 or sensorRPMMax == nil or theTIME == 0 then
					sensorMAX = "-"
			else 
					sensorMAX = sensorRPMMax
			end


			sensorUNIT = "rpm"
			sensorWARN = false


			local sensorTGT = 'rpm'
			sensordisplay[sensorTGT] = {}
			sensordisplay[sensorTGT]['title'] = sensorTITLE
			sensordisplay[sensorTGT]['value'] = sensorVALUE
			sensordisplay[sensorTGT]['warn'] = sensorWARN
			sensordisplay[sensorTGT]['min'] = sensorMIN
			sensordisplay[sensorTGT]['max'] = sensorMAX		
			sensordisplay[sensorTGT]['unit'] = sensorUNIT				

		end

		--VOLTAGE
		if sensors.voltage ~= nil then
		
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

			if sensorVoltageMin == 0 or sensorVoltageMin == nil or theTIME == 0 then
					sensorMIN = "-"
			else 
					sensorMIN = sensorVoltageMin/100
			end
			
			if sensorVoltageMax == 0 or sensorVoltageMax == nil or theTIME == 0 then
					sensorMAX = "-"
			else 
					sensorMAX = sensorVoltageMax/100
			end

			sensorUNIT = "v"
	

			local sensorTGT = 'voltage'
			sensordisplay[sensorTGT] = {}
			sensordisplay[sensorTGT]['title'] = sensorTITLE
			sensordisplay[sensorTGT]['value'] = sensorVALUE
			sensordisplay[sensorTGT]['warn'] = sensorWARN
			sensordisplay[sensorTGT]['min'] = sensorMIN
			sensordisplay[sensorTGT]['max'] = sensorMAX			
			sensordisplay[sensorTGT]['unit'] = sensorUNIT				

		end
		
		--CURRENT
		if sensors.current ~= nil then
			
	
			sensorVALUE = sensors.current/10
			if linkUP == 0 then
				sensorVALUE = 0
			else
				if sensorVALUE == 0 then
					local fakeC
					if sensors.rpm > 5 then
						fakeC = 1
					elseif sensors.rpm > 50 then
						fakeC = 2
					elseif sensors.rpm > 100 then
						fakeC = 3
					elseif sensors.rpm > 200 then
						fakeC = 4
					elseif sensors.rpm > 500 then
						fakeC = 5
					elseif sensors.rpm > 1000 then
						fakeC = 6
					else
						fakeC = math.random(1, 3)/10
					end
					sensorVALUE = fakeC
				end
			end
	
			if titleParam == true then
				sensorTITLE = theme.title_current
			else
				sensorTITLE = ""		
			end

			if sensorCurrentMin == 0 or sensorCurrentMin == nil or theTIME == 0 then
					sensorMIN = "-"
			else 
					sensorMIN = sensorCurrentMin/10
			end
			
			if sensorCurrentMax == 0 or sensorCurrentMax == nil or theTIME == 0 then
					sensorMAX = "-"
			else 
					sensorMAX = sensorCurrentMax/10
			end

			sensorUNIT = "A"
			sensorWARN = false	

			
			local sensorTGT = 'current'
			sensordisplay[sensorTGT] = {}
			sensordisplay[sensorTGT]['title'] = sensorTITLE
			sensordisplay[sensorTGT]['value'] = sensorVALUE
			sensordisplay[sensorTGT]['warn'] = sensorWARN
			sensordisplay[sensorTGT]['min'] = sensorMIN
			sensordisplay[sensorTGT]['max'] = sensorMAX	
			sensordisplay[sensorTGT]['unit'] = sensorUNIT				

		end		

		--TEMP ESC
		if sensors.temp_esc ~= nil then
		

			sensorVALUE = rf2status.round(sensors.temp_esc/100,0)
			
			if sensorVALUE < 1 then
				sensorVALUE = 0 
			end
		
			if titleParam == true then
				sensorTITLE = theme.title_tempESC
			else
				sensorTITLE = ""		
			end

			if sensorTempESCMin == 0 or sensorTempESCMin == nil  or theTIME == 0 then
					sensorMIN = "-"
			else 
					sensorMIN = rf2status.round(sensorTempESCMin/100,0)
			end
			
			if sensorTempESCMax == 0 or sensorTempESCMax == nil  or theTIME == 0 then
					sensorMAX = "-"
			else 
					sensorMAX = rf2status.round(sensorTempESCMax/100,0)
			end

			sensorUNIT = "°"
			sensorWARN = false


			local sensorTGT = 'temp_esc'
			sensordisplay[sensorTGT] = {}
			sensordisplay[sensorTGT]['title'] = sensorTITLE
			sensordisplay[sensorTGT]['value'] = sensorVALUE
			sensordisplay[sensorTGT]['warn'] = sensorWARN
			sensordisplay[sensorTGT]['min'] = sensorMIN
			sensordisplay[sensorTGT]['max'] = sensorMAX		
			sensordisplay[sensorTGT]['unit'] = sensorUNIT				

		end	

		--TEMP MCU
		if sensors.temp_mcu ~= nil then
		

			sensorVALUE = rf2status.round(sensors.temp_mcu/100,0)
		
			if sensorVALUE < 1 then
				sensorVALUE = 0 
			end
			
			if titleParam == true then
				sensorTITLE = theme.title_tempMCU
			else
				sensorTITLE = ""		
			end

			if sensorTempMCUMin == 0 or sensorTempMCUMin == nil  or theTIME == 0 then
					sensorMIN = "-"
			else 
					sensorMIN = rf2status.round(sensorTempMCUMin/100,0)
			end
			
			if sensorTempMCUMax == 0 or sensorTempMCUMax == nil or theTIME == 0 then
					sensorMAX = "-"
			else 
					sensorMAX = rf2status.round(sensorTempMCUMax/100,0)
			end

			sensorUNIT = "°"
			sensorWARN = false

			local sensorTGT = 'temp_mcu'
			sensordisplay[sensorTGT] = {}
			sensordisplay[sensorTGT]['title'] = sensorTITLE
			sensordisplay[sensorTGT]['value'] = sensorVALUE
			sensordisplay[sensorTGT]['warn'] = sensorWARN
			sensordisplay[sensorTGT]['min'] = sensorMIN
			sensordisplay[sensorTGT]['max'] = sensorMAX	
			sensordisplay[sensorTGT]['unit'] = sensorUNIT				

		end	

		--RSSI
		if sensors.rssi ~= nil and (quadBoxParam == 0 or quadBoxParam == 1)then
		
		
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



			sensorUNIT = "%"
			sensorWARN = false


			local sensorTGT = 'rssi'
			sensordisplay[sensorTGT] = {}
			sensordisplay[sensorTGT]['title'] = sensorTITLE
			sensordisplay[sensorTGT]['value'] = sensorVALUE
			sensordisplay[sensorTGT]['warn'] = sensorWARN
			sensordisplay[sensorTGT]['min'] = sensorMIN
			sensordisplay[sensorTGT]['max'] = sensorMAX		
			sensordisplay[sensorTGT]['unit'] = sensorUNIT				

		end	

	-- mah
	if sensors.mah ~= nil then
	
		sensorVALUE = sensors.mah
		
		if sensorVALUE < 1 then
			sensorVALUE = 0 
		end
		
		if titleParam == true then
			sensorTITLE = theme.title_mah
		else
			sensorTITLE = ""		
		end

		if sensorMAHMin == 0 or sensorMAHMin == nil then
				sensorMIN = "-"
		else 
				sensorMIN = sensorMAHMin
		end

		if sensorMAHMax == 0 or sensorMAHMax == nil then
				sensorMAX = "-"
		else 
				sensorMAX = sensorMAHMax
		end



		sensorUNIT = ""
		sensorWARN = false


		local sensorTGT = 'mah'
		sensordisplay[sensorTGT] = {}
		sensordisplay[sensorTGT]['title'] = sensorTITLE
		sensordisplay[sensorTGT]['value'] = sensorVALUE
		sensordisplay[sensorTGT]['warn'] = sensorWARN
		sensordisplay[sensorTGT]['min'] = sensorMIN
		sensordisplay[sensorTGT]['max'] = sensorMAX		
		sensordisplay[sensorTGT]['unit'] = sensorUNIT	
	end

	-- TIMER
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


	sensorUNIT = ""
	sensorWARN = false

	local sensorTGT = 'timer'
	sensordisplay[sensorTGT] = {}
	sensordisplay[sensorTGT]['title'] = sensorTITLE
	sensordisplay[sensorTGT]['value'] = sensorVALUE
	sensordisplay[sensorTGT]['warn'] = sensorWARN
	sensordisplay[sensorTGT]['min'] = sensorMIN
	sensordisplay[sensorTGT]['max'] = sensorMAX	
	sensordisplay[sensorTGT]['unit'] = sensorUNIT				


	--GOV MODE
	if govmodeParam == 0 then		
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
	
	sensorUNIT = ""
	sensorWARN = false	
	sensorMIN = nil
	sensorMAX = nil		

	local sensorTGT = 'governor'
	sensordisplay[sensorTGT] = {}
	sensordisplay[sensorTGT]['title'] = sensorTITLE
	sensordisplay[sensorTGT]['value'] = sensorVALUE
	sensordisplay[sensorTGT]['warn'] = sensorWARN
	sensordisplay[sensorTGT]['min'] = sensorMIN
	sensordisplay[sensorTGT]['max'] = sensorMAX		
	sensordisplay[sensorTGT]['unit'] = sensorUNIT		



	-- loop throught 6 box and link into sensordisplay to choose where to put things
	local c = 1
	while c <= 6 do
	
		--reset all values
		sensorVALUE = nil
		sensorUNIT = nil
		sensorMIN = nil
		sensorMAX = nil
		sensorWARN = nil
		sensorTITLE = nil
		sensorTGT = nil
		smallBOX = false

		-- column positions and tgt
		if c == 1 then
			posX = 0
			posY = theme.colSpacing
			sensorTGT = layoutBox1Param
		end
		if c == 2 then
			posX = 0 + theme.colSpacing + boxW
			posY = theme.colSpacing
			sensorTGT = layoutBox2Param
		end			
		if c == 3 then
			posX = 0 + theme.colSpacing + boxW  + theme.colSpacing + boxW
			posY = theme.colSpacing
			sensorTGT = layoutBox3Param
		end		
		if c == 4 then
			posX = 0 
			posY = theme.colSpacing + boxH + theme.colSpacing
			sensorTGT = layoutBox4Param
		end	
		if c == 5 then
			posX = 0 + theme.colSpacing + boxW
			posY = theme.colSpacing + boxH + theme.colSpacing
			sensorTGT = layoutBox5Param
		end	
		if c == 6 then
			posX = 0 + theme.colSpacing + boxW  + theme.colSpacing + boxW
			posY = theme.colSpacing + boxH + theme.colSpacing
			sensorTGT = layoutBox6Param
		end	
		
		-- remap sensorTGT
		if sensorTGT == 1 then
			sensorTGT = 'timer'
		end
		if sensorTGT == 2 then
			sensorTGT = 'voltage'
		end		
		if sensorTGT == 3 then
			sensorTGT = 'fuel'
		end	
		if sensorTGT == 4 then
			sensorTGT = 'current'
		end			
		if sensorTGT == 17 then
			sensorTGT = 'mah'
		end	
		if sensorTGT == 5 then
			sensorTGT = 'rpm'
		end	
		if sensorTGT == 6 then
			sensorTGT = 'rssi'
		end	
		if sensorTGT == 7 then
			sensorTGT = 'temp_esc'
		end	
		if sensorTGT == 8 then
			sensorTGT = 'temp_mcu'
		end	
		if sensorTGT == 9 then
			sensorTGT = 'image'
		end	
		if sensorTGT == 10 then
			sensorTGT = 'governor'
		end	
		if sensorTGT == 11 then
			sensorTGT = 'image__gov'
		end	
		if sensorTGT == 12 then
			sensorTGT = 'rssi__timer'
		end	
		if sensorTGT == 13 then
			sensorTGT = 'temp_esc__temp_mcu'
		end			
		if sensorTGT == 14 then
			sensorTGT = 'voltage__fuel'
		end		
		if sensorTGT == 15 then
			sensorTGT = 'voltage__current'
		end	
		if sensorTGT == 16 then
			sensorTGT = 'voltage__mah'
		end	
		if sensorTGT == 20 then
			sensorTGT = 'rssi_timer_temp_esc_temp_mcu'
		end	


		--set sensor values based on sensorTGT
		if sensordisplay[sensorTGT] ~= nil then
			-- all std values.  =
			sensorVALUE = sensordisplay[sensorTGT]['value']
			sensorUNIT = sensordisplay[sensorTGT]['unit']
			sensorMIN = sensordisplay[sensorTGT]['min']
			sensorMAX = sensordisplay[sensorTGT]['max']
			sensorWARN = sensordisplay[sensorTGT]['warn']
			sensorTITLE = sensordisplay[sensorTGT]['title']
			telemetryBox(posX,posY,boxW,boxH,sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)
		else
		
			if sensorTGT == 'image' then
				--IMAGE
				if gfx_model ~= nil then		
					telemetryBoxImage(posX,posY,boxW,boxH,gfx_model)
				else
					telemetryBoxImage(posX,posY,boxW,boxH,gfx_heli)
				end
			end	
			
			if sensorTGT == 'image__gov' then
				--IMAGE + GOVERNOR
					if gfx_model ~= nil then		
						telemetryBoxImage(posX,posY,boxW,boxH/2-(theme.colSpacing/2),gfx_model)
					else
						telemetryBoxImage(posX,posY,boxW,boxH/2-(theme.colSpacing/2),gfx_heli)
					end

					sensorTGT = "governor"
					sensorVALUE = sensordisplay[sensorTGT]['value']
					sensorUNIT = sensordisplay[sensorTGT]['unit']
					sensorMIN = sensordisplay[sensorTGT]['min']
					sensorMAX = sensordisplay[sensorTGT]['max']
					sensorWARN = sensordisplay[sensorTGT]['warn']
					sensorTITLE = sensordisplay[sensorTGT]['title']		
					
					smallBOX = true
					telemetryBox(posX,posY+boxH/2+(theme.colSpacing/2),boxW,boxH/2-theme.colSpacing/2,sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)
	
			end
	
			if sensorTGT == 'rssi__timer' then
	
					sensorTGT = "rssi"
					sensorVALUE = sensordisplay[sensorTGT]['value']
					sensorUNIT = sensordisplay[sensorTGT]['unit']
					sensorMIN = sensordisplay[sensorTGT]['min']
					sensorMAX = sensordisplay[sensorTGT]['max']
					sensorWARN = sensordisplay[sensorTGT]['warn']
					sensorTITLE = sensordisplay[sensorTGT]['title']		
					
					smallBOX = true
					telemetryBox(posX,posY,boxW,boxH/2-(theme.colSpacing/2),sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)					
					

					sensorTGT = "timer"
					sensorVALUE = sensordisplay[sensorTGT]['value']
					sensorUNIT = sensordisplay[sensorTGT]['unit']
					sensorMIN = sensordisplay[sensorTGT]['min']
					sensorMAX = sensordisplay[sensorTGT]['max']
					sensorWARN = sensordisplay[sensorTGT]['warn']
					sensorTITLE = sensordisplay[sensorTGT]['title']		
					
					smallBOX = true
					telemetryBox(posX,posY+boxH/2+(theme.colSpacing/2),boxW,boxH/2-theme.colSpacing/2,sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)
	
			end


			if sensorTGT == 'temp_esc__temp_mcu' then
	
					sensorTGT = "temp_esc"
					sensorVALUE = sensordisplay[sensorTGT]['value']
					sensorUNIT = sensordisplay[sensorTGT]['unit']
					sensorMIN = sensordisplay[sensorTGT]['min']
					sensorMAX = sensordisplay[sensorTGT]['max']
					sensorWARN = sensordisplay[sensorTGT]['warn']
					sensorTITLE = sensordisplay[sensorTGT]['title']		
					
					smallBOX = true
					telemetryBox(posX,posY,boxW,boxH/2-(theme.colSpacing/2),sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)					
					

					sensorTGT = "temp_mcu"
					sensorVALUE = sensordisplay[sensorTGT]['value']
					sensorUNIT = sensordisplay[sensorTGT]['unit']
					sensorMIN = sensordisplay[sensorTGT]['min']
					sensorMAX = sensordisplay[sensorTGT]['max']
					sensorWARN = sensordisplay[sensorTGT]['warn']
					sensorTITLE = sensordisplay[sensorTGT]['title']		
					
					smallBOX = true
					telemetryBox(posX,posY+boxH/2+(theme.colSpacing/2),boxW,boxH/2-theme.colSpacing/2,sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)
	
			end


			if sensorTGT == 'voltage__fuel' then
	
					sensorTGT = "voltage"
					sensorVALUE = sensordisplay[sensorTGT]['value']
					sensorUNIT = sensordisplay[sensorTGT]['unit']
					sensorMIN = sensordisplay[sensorTGT]['min']
					sensorMAX = sensordisplay[sensorTGT]['max']
					sensorWARN = sensordisplay[sensorTGT]['warn']
					sensorTITLE = sensordisplay[sensorTGT]['title']		
					
					smallBOX = true
					telemetryBox(posX,posY,boxW,boxH/2-(theme.colSpacing/2),sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)					
					

					sensorTGT = "fuel"
					sensorVALUE = sensordisplay[sensorTGT]['value']
					sensorUNIT = sensordisplay[sensorTGT]['unit']
					sensorMIN = sensordisplay[sensorTGT]['min']
					sensorMAX = sensordisplay[sensorTGT]['max']
					sensorWARN = sensordisplay[sensorTGT]['warn']
					sensorTITLE = sensordisplay[sensorTGT]['title']		
					
					smallBOX = true
					telemetryBox(posX,posY+boxH/2+(theme.colSpacing/2),boxW,boxH/2-theme.colSpacing/2,sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)
	
			end

			if sensorTGT == 'voltage__current' then
	
					sensorTGT = "voltage"
					sensorVALUE = sensordisplay[sensorTGT]['value']
					sensorUNIT = sensordisplay[sensorTGT]['unit']
					sensorMIN = sensordisplay[sensorTGT]['min']
					sensorMAX = sensordisplay[sensorTGT]['max']
					sensorWARN = sensordisplay[sensorTGT]['warn']
					sensorTITLE = sensordisplay[sensorTGT]['title']		
					
					smallBOX = true
					telemetryBox(posX,posY,boxW,boxH/2-(theme.colSpacing/2),sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)					
					

					sensorTGT = "current"
					sensorVALUE = sensordisplay[sensorTGT]['value']
					sensorUNIT = sensordisplay[sensorTGT]['unit']
					sensorMIN = sensordisplay[sensorTGT]['min']
					sensorMAX = sensordisplay[sensorTGT]['max']
					sensorWARN = sensordisplay[sensorTGT]['warn']
					sensorTITLE = sensordisplay[sensorTGT]['title']		
					
					smallBOX = true
					telemetryBox(posX,posY+boxH/2+(theme.colSpacing/2),boxW,boxH/2-theme.colSpacing/2,sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)
	
			end


			if sensorTGT == 'voltage__mah' then
	
					sensorTGT = "voltage"
					sensorVALUE = sensordisplay[sensorTGT]['value']
					sensorUNIT = sensordisplay[sensorTGT]['unit']
					sensorMIN = sensordisplay[sensorTGT]['min']
					sensorMAX = sensordisplay[sensorTGT]['max']
					sensorWARN = sensordisplay[sensorTGT]['warn']
					sensorTITLE = sensordisplay[sensorTGT]['title']		
					
					smallBOX = true
					telemetryBox(posX,posY,boxW,boxH/2-(theme.colSpacing/2),sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)					
					

					sensorTGT = "mah"
					sensorVALUE = sensordisplay[sensorTGT]['value']
					sensorUNIT = sensordisplay[sensorTGT]['unit']
					sensorMIN = sensordisplay[sensorTGT]['min']
					sensorMAX = sensordisplay[sensorTGT]['max']
					sensorWARN = sensordisplay[sensorTGT]['warn']
					sensorTITLE = sensordisplay[sensorTGT]['title']		
					
					smallBOX = true
					telemetryBox(posX,posY+boxH/2+(theme.colSpacing/2),boxW,boxH/2-theme.colSpacing/2,sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)
	
			end
	
			if sensorTGT == 'rssi_timer_temp_esc_temp_mcu' then
	
					sensorTGT = "rssi"
					sensorVALUE = sensordisplay[sensorTGT]['value']
					sensorUNIT = sensordisplay[sensorTGT]['unit']
					sensorMIN = sensordisplay[sensorTGT]['min']
					sensorMAX = sensordisplay[sensorTGT]['max']
					sensorWARN = sensordisplay[sensorTGT]['warn']
					sensorTITLE = sensordisplay[sensorTGT]['title']		
					
					smallBOX = true
					telemetryBox(posX,posY,boxW/2-(theme.colSpacing/2),boxH/2-(theme.colSpacing/2),sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)					

					sensorTGT = "timer"
					sensorVALUE = sensordisplay[sensorTGT]['value']
					sensorUNIT = sensordisplay[sensorTGT]['unit']
					sensorMIN = sensordisplay[sensorTGT]['min']
					sensorMAX = sensordisplay[sensorTGT]['max']
					sensorWARN = sensordisplay[sensorTGT]['warn']
					sensorTITLE = sensordisplay[sensorTGT]['title']		
					
					smallBOX = true
					telemetryBox(posX+boxW/2+(theme.colSpacing/2),posY,boxW/2-(theme.colSpacing/2),boxH/2-(theme.colSpacing/2),sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)	
					

					sensorTGT = "temp_esc"
					sensorVALUE = sensordisplay[sensorTGT]['value']
					sensorUNIT = sensordisplay[sensorTGT]['unit']
					sensorMIN = sensordisplay[sensorTGT]['min']
					sensorMAX = sensordisplay[sensorTGT]['max']
					sensorWARN = sensordisplay[sensorTGT]['warn']
					sensorTITLE = sensordisplay[sensorTGT]['title']		
					
					smallBOX = true
					telemetryBox(posX,posY+boxH/2+(theme.colSpacing/2),boxW/2-(theme.colSpacing/2),boxH/2-theme.colSpacing/2,sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)

					sensorTGT = "temp_mcu"
					sensorVALUE = sensordisplay[sensorTGT]['value']
					sensorUNIT = sensordisplay[sensorTGT]['unit']
					sensorMIN = sensordisplay[sensorTGT]['min']
					sensorMAX = sensordisplay[sensorTGT]['max']
					sensorWARN = sensordisplay[sensorTGT]['warn']
					sensorTITLE = sensordisplay[sensorTGT]['title']		
					
					smallBOX = true
					telemetryBox(posX+boxW/2+(theme.colSpacing/2),posY+boxH/2+(theme.colSpacing/2),boxW/2-(theme.colSpacing/2),boxH/2-(theme.colSpacing/2),sensorTITLE,sensorVALUE,sensorUNIT,smallBOX,sensorWARN,sensorMIN,sensorMAX)	
	
			end	

		end	

	
	c = c+1
	end



	if linkUP == 0 then
		rf2status.noTelem()
	end
	
	if showLOGS then
		rf2status.logsBOX()
	end
			

	end
		
	-- TIME
 	if linkUP ~= 0 then
		if armswitchParam ~= nil then
			if armswitchParam:state() == false then
				stopTimer = true
				stopTIME = os.clock()
				timerNearlyActive = 1
				theTIME = 0
			end
		end	

		if idleupswitchParam ~= nil then
			if idleupswitchParam:state()  then
				if timerNearlyActive == 1 then
					timerNearlyActive = 0
					startTIME = os.clock()
				end
				if startTIME ~= nil then
					theTIME = os.clock() - startTIME
				end	
			end
		end
		
	end

	-- LOW FUEL ALERTS
    -- big conditional to announcement lfTimer if needed
    if linkUP ~= 0 then
		if idleupswitchParam ~= nil then
				if idleupswitchParam:state() then
				if (sensors.fuel <= lowfuelParam and alertonParam == 1 ) then
					lfTimer = true
				elseif (sensors.fuel <= lowfuelParam and alertonParam == 2 )then
					lfTimer = true
				else
					lfTimer = false
				end
			else
				lfTimer = false
			end
		else
			lfTimer = false
		end
    else
        lfTimer = false
    end


    if lfTimer == true then
        --start timer
        if lfTimerStart == nil then
            lfTimerStart = os.time()
        end
    else
        lfTimerStart = nil
    end

    if lfTimerStart ~= nil then
            -- only announcement if we have been on for 5 seconds or more
            if (tonumber(os.clock()) - tonumber(lfAudioAlertCounter)) >= alertintParam then
                lfAudioAlertCounter = os.clock()
				
				system.playFile("/scripts/rf2status/sounds/alerts/lowfuel.wav")

				--system.playNumber(sensors.voltage / 100, 2, 2)
				if alrthptParam == true then
					system.playHaptic("- . -")
				end

            end
    else
        -- stop timer
        lfTimerStart = nil
    end

	-- LOW VOLTAGE ALERTS
    -- big conditional to announcement lvTimer if needed
    if linkUP ~= 0 then
		if idleupswitchParam ~= nil then
			if idleupswitchParam:state() then
				if (voltageIsLow and alertonParam == 0) then
					lvTimer = true
				elseif 	(voltageIsLow and alertonParam == 2) then
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
            -- only announcement if we have been on for 5 seconds or more
            if (tonumber(os.clock()) - tonumber(lvAudioAlertCounter)) >= alertintParam then
                lvAudioAlertCounter = os.clock()
				
				if lvStickannouncement == false then -- do not play if sticks at high end points
					system.playFile("/scripts/rf2status/sounds/alerts/lowvoltage.wav")
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

	lcd.resetFocusTimeout()	

    if environment.simulation == true then
	
	

		tv = math.random(2100, 2274)
		voltage = tv
		temp_esc = math.random(50, 225)*10
		temp_mcu = math.random(50, 185)*10
		mah = math.random(10000, 10100)
		fuel = 55
		fm = "DISABLED"
		rssi = math.random(90, 100)	
		adjsource = 0
		adjvalue = 0
		current = 0
		

		if idleupswitchParam ~= nil and armswitchParam ~= nil then
			if idleupswitchParam:state() == true and armswitchParam:state() == true then
					current = math.random(100, 120)
					rpm = math.random(90, 100)
			else
					current = 0
					rpm = 0			
			end
		end
		
    elseif linkUP ~= 0 then
	
        local telemetrySOURCE = system.getSource("Rx RSSI1")
		


        if telemetrySOURCE ~= nil then
	        -- we are running crsf
			--print("CRSF")
	
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
			--print("SPORT")

			voltageSOURCE = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x0210})
			rpmSOURCE = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x0500})
			currentSOURCE = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x0200})
			temp_escSOURCE = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x0B70})
			temp_mcuSOURCE = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x0401})
			fuelSOURCE = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x0600})
			
			govSOURCE = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x5450})
			if govSOURCE == nil then
				govSOURCE = model.createSensor()
				govSOURCE:name("Governor")
				govSOURCE:appId(0x5450)
				govSOURCE:physId(0)
			end
			
			adjSOURCE = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x5110})
			if adjSOURCE == nil then
				adjSOURCE = model.createSensor()
				adjSOURCE:name("ADJ Source")
				adjSOURCE:appId(0x5110)
				adjSOURCE:physId(0)
			end			
			
			adjVALUE = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x5111})
			if adjVALUE == nil then
				adjVALUE = model.createSensor()
				adjVALUE:name("ADJ Value")
				adjVALUE:appId(0x5111)
				adjVALUE:physId(0)
			end					

			mahSOURCE = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = 0x5250})
			if mahSOURCE == nil then
				mahSOURCE = model.createSensor()
				mahSOURCE:name("mAh")
				mahSOURCE:appId(0x5250)
				mahSOURCE:physId(0)
			end		

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
                    fuel = rf2status.round(fuel, 0)
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
                    govmode = "AUTOROT"
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
		--print("NO LINK")
		-- keep looking for new sensor
		rssiSensor = rf2status.getRssiSensor()
		
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
    end


	--calc fuel percentage if needed
    if calcfuelParam == true then
	
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
        avgCellVoltage = (voltage/100) / cellsParam
        batteryPercentage = 100 * (avgCellVoltage - minCellVoltage) / ((maxCellVoltage + (0.1*cellsParam)) - minCellVoltage)
        fuel = batteryPercentage
		fuel = rf2status.round(fuel, 0)
		
        if fuel > 100 then
            fuel = 100
        end
	
    end
	
	-- convert from C to F
	-- Divide by 5, then multiply by 9, then add 32
	if tempconvertParamMCU == 2 then
		temp_mcu = ((temp_mcu/5) * 9) + 32
		temp_mcu = rf2status.round(temp_mcu,0)
	end
	-- convert from F to C
	-- Deduct 32, then multiply by 5, then divide by 9
	if tempconvertParamMCU == 3 then
		temp_mcu = ((temp_mcu - 32) * 5)/9
		temp_mcu = rf2status.round(temp_mcu,0)			
	end		


	-- convert from C to F
	-- Divide by 5, then multiply by 9, then add 32
	if tempconvertParamESC == 2 then
		temp_esc = ((temp_esc/5) * 9) + 32
		temp_esc = rf2status.round(temp_esc,0)
	end
	-- convert from F to C
	-- Deduct 32, then multiply by 5, then divide by 9
	if tempconvertParamESC == 3 then
		temp_esc = ((temp_esc - 32) * 5)/9
		temp_esc = rf2status.round(temp_esc,0)	
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
			lvStickannouncement = false
			for i, v in ipairs(lvStickOrder[lowvoltagStickParam]) do
				if lvStickannouncement == false then  -- we skip more if any stick has resulted in announcement
					if math.abs(getChannelValue(v)) >= lowvoltagStickCutoffParam then 
							lvStickannouncement = true
					end
				end
			end
	end		

	-- intercept governor for non rf governor helis
	if armswitchParam ~= nil or idleupswitchParam ~= nil then
		if govmodeParam == 1 then
			if armswitchParam:state() == true then
					 govmode = "ARMED"
					 fm = "ARMED"			
			else
					 govmode = "DISARMED"
					 fm = "DISARMED"			
			end
			
			if armswitchParam:state() == true then
				if idleupswitchParam:state() == true then
						 govmode = "ACTIVE"
						 fm = "ACTIVE"	
				else
						 govmode = "THR-OFF"
						 fm = "THR-OFF"				
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


local function sensorsMAXMIN(sensors)


    if linkUP ~= 0 and theTIME ~= nil and idleupdelayParam ~=nil then


		

		-- hold back - to early to get a reading
		if  theTIME <= idleupdelayParam then
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
			sensorTempESCMin = 0
			sensorTempMCUMax = 0
		end

		-- prob put in a screen/audio alert for initialising
		if theTIME >= 1 and theTIME < idleupdelayParam then
			
		end

	
        if theTIME >= idleupdelayParam  then
			
			local idleupdelayOFFSET = 2

			-- record initial parameters for max/min
			if theTIME >= idleupdelayParam and theTIME <= (idleupdelayParam + idleupdelayOFFSET ) then
				sensorVoltageMin = sensors.voltage
				sensorVoltageMax = sensors.voltage
				sensorFuelMin = sensors.fuel
				sensorFuelMax = sensors.fuel
				sensorRPMMin = sensors.rpm
				sensorRPMMax = sensors.rpm
				if sensors.current == 0 then
					sensorCurrentMin = 1
				else
					sensorCurrentMin = sensors.current
				end
				sensorCurrentMax = sensors.current

				sensorRSSIMin = sensors.rssi
				sensorRSSIMax = sensors.rssi
				sensorTempESCMin = sensors.temp_esc
				sensorTempESCMax = sensors.temp_esc
				sensorTempMCUMin = sensors.temp_mcu
				sensorTempMCUMax = sensors.temp_mcu
				motorNearlyActive = 0
			end
			

			if theTIME >= (idleupdelayParam + idleupdelayOFFSET) and idleupswitchParam:state() == true then

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
					if sensorCurrentMin == 0 then
						sensorCurrentMin = 1
					end
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
				if sensors.temp_esc < sensorTempESCMin then
					sensorTempESCMin = sensors.temp_esc
				end
				if sensors.temp_esc > sensorTempESCMax then
					sensorTempESCMax = sensors.temp_esc
				end
				motorWasActive = true
			end	
				
				
        end
		

	
		
		-- store the last values
		if motorWasActive and idleupswitchParam:state() == false then
		
		
			motorWasActive = false	

			local maxminFinals = rf2status.readHistory()	

			if sensorCurrentMin == 0 then
				sensorCurrentMinAlt = 1
			else
				sensorCurrentMinAlt = sensorCurrentMin
			end
			if sensorCurrentMax == 0 then
				sensorCurrentMaxAlt = 1
			else
				sensorCurrentMaxAlt = sensorCurrentMax
			end			

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
		
			file = "/scripts/rf2status/logs/" .. name .. ".log"	
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
		govmodeParam = storage.read("mem1")
		btypeParam = storage.read("mem2")
		lowfuelParam = storage.read("mem3")
		alertintParam = storage.read("mem4")
		alrthptParam = storage.read("mem5")
		maxminParam = storage.read("mem6")
		titleParam = storage.read("mem7")
		cellsParam = storage.read("mem8")
		announcementVoltageSwitchParam = storage.read("mem9")
		govmodeParam = storage.read("mem10")
		rpmAlertsParam = storage.read("mem11")				
		rpmAlertsPercentageParam = storage.read("mem12")	
		adjFunctionParam = storage.read("mem13")	
		announcementRPMSwitchParam = storage.read("mem14")
		announcementCurrentSwitchParam = storage.read("mem15")
		announcementFuelSwitchParam = storage.read("mem16")		
		announcementLQSwitchParam = storage.read("mem17")
		announcementESCSwitchParam = storage.read("mem18")
		announcementMCUSwitchParam = storage.read("mem19")
		announcementTimerSwitchParam = storage.read("mem20")
		filteringParam = storage.read("mem21")		
		sagParam = storage.read("mem22")	
		lowvoltagsenseParam = storage.read("mem23")		
		announcementIntervalParam = storage.read("mem24")	
		lowVoltageGovernorParam = storage.read("mem25")
		lowvoltagStickParam = storage.read("mem26")
		quadBoxParam = storage.read("mem27")  -- spare  item removed
		lowvoltagStickCutoffParam = storage.read("mem28")
		governorUNKNOWNParam = storage.read("mem29")
		governorDISARMEDParam = storage.read("mem30")
		governorDISABLEDParam = storage.read("mem31")
		governorBAILOUTParam = storage.read("mem32")
		governorAUTOROTParam = storage.read("mem33")
		governorLOSTHSParam = storage.read("mem34")
		governorTHROFFParam = storage.read("mem35")
		governorACTIVEParam = storage.read("mem36")
		governorRECOVERYParam = storage.read("mem37")
		governorSPOOLUPParam = storage.read("mem38")
		governorIDLEParam = storage.read("mem39")
		governorOFFParam = storage.read("mem40")
		alertonParam = storage.read("mem41")
		calcfuelParam = storage.read("mem42")
		tempconvertParamESC = storage.read("mem43")
		tempconvertParamMCU = storage.read("mem44")
		idleupswitchParam = storage.read("mem45")
		armswitchParam = storage.read("mem46")
		idleupdelayParam = storage.read("mem47")
		switchIdlelowParam = storage.read("mem48")
		switchIdlemediumParam  = storage.read("mem49")
		switchIdlehighParam = storage.read("mem50")
		switchrateslowParam = storage.read("mem51")
		switchratesmediumParam = storage.read("mem52")
		switchrateshighParam = storage.read("mem53")
		switchrescueonParam = storage.read("mem54")
		switchrescueoffParam = storage.read("mem55")
		switchbblonParam = storage.read("mem56")
		switchbbloffParam = storage.read("mem57")
		layoutBox1Param =  storage.read("mem58")
		layoutBox2Param =  storage.read("mem59")
		layoutBox3Param =  storage.read("mem60")
		layoutBox4Param =  storage.read("mem61")
		layoutBox5Param =  storage.read("mem62")
		layoutBox6Param =  storage.read("mem63")		

		
		rf2status.resetALL()
		updateFILTERING()		
end

local function write()
		storage.write("mem1", govmodeParam)
		storage.write("mem2", btypeParam)
		storage.write("mem3", lowfuelParam)
		storage.write("mem4", alertintParam)
		storage.write("mem5", alrthptParam)
		storage.write("mem6", maxminParam)
		storage.write("mem7", titleParam)
		storage.write("mem8", cellsParam)
		storage.write("mem9", announcementVoltageSwitchParam)
		storage.write("mem10", govmodeParam)	
		storage.write("mem11",rpmAlertsParam)
		storage.write("mem12",rpmAlertsPercentageParam)
		storage.write("mem13",adjFunctionParam)	
		storage.write("mem14",announcementRPMSwitchParam)
		storage.write("mem15",announcementCurrentSwitchParam)
		storage.write("mem16",announcementFuelSwitchParam)		
		storage.write("mem17",announcementLQSwitchParam)		
		storage.write("mem18",announcementESCSwitchParam)	
		storage.write("mem19",announcementMCUSwitchParam)		
		storage.write("mem20",announcementTimerSwitchParam)
		storage.write("mem21",filteringParam)	
		storage.write("mem22",sagParam)
		storage.write("mem23",lowvoltagsenseParam)
		storage.write("mem24",announcementIntervalParam)
		storage.write("mem25",lowVoltageGovernorParam)
		storage.write("mem26",lowvoltagStickParam)
		storage.write("mem27",0)					-- spare  item removed
		storage.write("mem28",lowvoltagStickCutoffParam)
		storage.write("mem29",governorUNKNOWNParam)
		storage.write("mem30",governorDISARMEDParam)
		storage.write("mem31",governorDISABLEDParam)
		storage.write("mem32",governorBAILOUTParam)
		storage.write("mem33",governorAUTOROTParam)
		storage.write("mem34",governorLOSTHSParam)
		storage.write("mem35",governorTHROFFParam)
		storage.write("mem36",governorACTIVEParam)
		storage.write("mem37",governorRECOVERYParam)
		storage.write("mem38",governorSPOOLUPParam)
		storage.write("mem39",governorIDLEParam)
		storage.write("mem40",governorOFFParam)
		storage.write("mem41",alertonParam)
		storage.write("mem42",calcfuelParam)
		storage.write("mem43",tempconvertParamESC)
		storage.write("mem44",tempconvertParamMCU)
		storage.write("mem45",idleupswitchParam)
		storage.write("mem46",armswitchParam)
		storage.write("mem47",idleupdelayParam)
		storage.write("mem48",switchIdlelowParam)
		storage.write("mem49",switchIdlemediumParam)
		storage.write("mem50",switchIdlehighParam)
		storage.write("mem51",switchrateslowParam)
		storage.write("mem52",switchratesmediumParam)
		storage.write("mem53",switchrateshighParam)
		storage.write("mem54",switchrescueonParam)
		storage.write("mem55",switchrescueoffParam)
		storage.write("mem56",switchbblonParam)
		storage.write("mem57",switchbbloffParam)	
		storage.write("mem58",layoutBox1Param)
		storage.write("mem59",layoutBox2Param)
		storage.write("mem60",layoutBox3Param)
		storage.write("mem61",layoutBox4Param)
		storage.write("mem62",layoutBox5Param)
		storage.write("mem63",layoutBox6Param)
		

		updateFILTERING()		
end

function rf2status.playCurrent(widget)
    if announcementCurrentSwitchParam ~= nil then
        if announcementCurrentSwitchParam:state() then
            currenttime.currentannouncementTimer = true
            currentDoneFirst = false
        else
            currenttime.currentannouncementTimer = false
            currentDoneFirst = true
        end

        if isInConfiguration == false then
            if sensors.current ~= nil then
                if currenttime.currentannouncementTimer == true then
                    --start timer
                    if currenttime.currentannouncementTimerStart == nil and currentDoneFirst == false then
                        currenttime.currentannouncementTimerStart = os.time()
						currenttime.currentaudioannouncementCounter = os.clock()
						--print ("Play Current Alert (first)")
                        system.playNumber(sensors.current/10, UNIT_AMPERE, 2)
                        currentDoneFirst = true
                    end
                else
                    currenttime.currentannouncementTimerStart = nil
                end

                if currenttime.currentannouncementTimerStart ~= nil then
                    if currentDoneFirst == false then
                        if ((tonumber(os.clock()) - tonumber(currenttime.currentaudioannouncementCounter)) >= announcementIntervalParam) then
							--print ("Play Current Alert (repeat)")
                            currenttime.currentaudioannouncementCounter = os.clock()
                            system.playNumber(sensors.current/10, UNIT_AMPERE, 2)
                        end
                    end
                else
                    -- stop timer
                    currenttime.currentannouncementTimerStart = nil
                end
            end
        end
    end
end

function rf2status.playLQ(widget)
    if announcementLQSwitchParam ~= nil then
        if announcementLQSwitchParam:state() then
            lqtime.lqannouncementTimer = true
            lqDoneFirst = false
        else
            lqtime.lqannouncementTimer = false
            lqDoneFirst = true
        end

        if isInConfiguration == false then
            if sensors.rssi ~= nil then
                if lqtime.lqannouncementTimer == true then
                    --start timer
                    if lqtime.lqannouncementTimerStart == nil and lqDoneFirst == false then
                        lqtime.lqannouncementTimerStart = os.time()
						lqtime.lqaudioannouncementCounter = os.clock()
						--print ("Play LQ Alert (first)")
						system.playFile("/scripts/rf2status/sounds/alerts/lq.wav")						
                        system.playNumber(sensors.rssi, UNIT_PERCENT, 2)
                        lqDoneFirst = true
                    end
                else
                    lqtime.lqannouncementTimerStart = nil
                end

                if lqtime.lqannouncementTimerStart ~= nil then
                    if lqDoneFirst == false then
                        if ((tonumber(os.clock()) - tonumber(lqtime.lqaudioannouncementCounter)) >= announcementIntervalParam) then
                            lqtime.lqaudioannouncementCounter = os.clock()
							--print ("Play LQ Alert (repeat)")
							system.playFile("/scripts/rf2status/sounds/alerts/lq.wav")
                            system.playNumber(sensors.rssi, UNIT_PERCENT, 2)
                        end
                    end
                else
                    -- stop timer
                    lqtime.lqannouncementTimerStart = nil
                end
            end
        end
    end
end

function rf2status.playMCU(widget)
    if announcementMCUSwitchParam ~= nil then
        if announcementMCUSwitchParam:state() then
            mcutime.mcuannouncementTimer = true
            mcuDoneFirst = false
        else
            mcutime.mcuannouncementTimer = false
            mcuDoneFirst = true
        end

        if isInConfiguration == false then
            if sensors.temp_mcu ~= nil then
                if mcutime.mcuannouncementTimer == true then
                    --start timer
                    if mcutime.mcuannouncementTimerStart == nil and mcuDoneFirst == false then
                        mcutime.mcuannouncementTimerStart = os.time()
						mcutime.mcuaudioannouncementCounter = os.clock()
						--print ("Playing MCU (first)")
						system.playFile("/scripts/rf2status/sounds/alerts/mcu.wav")
                        system.playNumber(sensors.temp_mcu/100, UNIT_DEGREE, 2)
                        mcuDoneFirst = true
                    end
                else
                    mcutime.mcuannouncementTimerStart = nil
                end

                if mcutime.mcuannouncementTimerStart ~= nil then
                    if mcuDoneFirst == false then
                        if ((tonumber(os.clock()) - tonumber(mcutime.mcuaudioannouncementCounter)) >= announcementIntervalParam) then
                            mcutime.mcuaudioannouncementCounter = os.clock()
							--print ("Playing MCU (repeat)")
							system.playFile("/scripts/rf2status/sounds/alerts/mcu.wav")
                            system.playNumber(sensors.temp_mcu/100, UNIT_DEGREE, 2)
                        end
                    end
                else
                    -- stop timer
                    mcutime.mcuannouncementTimerStart = nil
                end
            end
        end
    end
end

function rf2status.playESC(widget)
    if announcementESCSwitchParam ~= nil then
        if announcementESCSwitchParam:state() then
            esctime.escannouncementTimer = true
            escDoneFirst = false
        else
            esctime.escannouncementTimer = false
            escDoneFirst = true
        end

        if isInConfiguration == false then
            if sensors.temp_esc ~= nil then
                if esctime.escannouncementTimer == true then
                    --start timer
                    if esctime.escannouncementTimerStart == nil and escDoneFirst == false then
                        esctime.escannouncementTimerStart = os.time()
						esctime.escaudioannouncementCounter = os.clock()
						--print ("Playing ESC (first)")
						system.playFile("/scripts/rf2status/sounds/alerts/esc.wav")
                        system.playNumber(sensors.temp_esc/100, UNIT_DEGREE, 2)
                        escDoneFirst = true
                    end
                else
                    esctime.escannouncementTimerStart = nil
                end

                if esctime.escannouncementTimerStart ~= nil then
                    if escDoneFirst == false then
                        if ((tonumber(os.clock()) - tonumber(esctime.escaudioannouncementCounter)) >= announcementIntervalParam) then
                            esctime.escaudioannouncementCounter = os.clock()
							--print ("Playing ESC (repeat)")
							system.playFile("/scripts/rf2status/sounds/alerts/esc.wav")
                            system.playNumber(sensors.temp_esc/100, UNIT_DEGREE, 2)
                        end
                    end
                else
                    -- stop timer
                    esctime.escannouncementTimerStart = nil
                end
            end
        end
    end
end

function rf2status.playTIMER(widget)
    if announcementTimerSwitchParam ~= nil then

        if announcementTimerSwitchParam:state() then
            timetime.timerannouncementTimer = true
            timerDoneFirst = false
        else
            timetime.timerannouncementTimer = false
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
			
                if timetime.timerannouncementTimer == true then
                    --start timer
                    if timetime.timerannouncementTimerStart == nil and timerDoneFirst == false then
                        timetime.timerannouncementTimerStart = os.time()
						timetime.timeraudioannouncementCounter = os.clock()
						--print ("Playing TIMER (first)" .. alertTIME)
	
						if mins ~= "00" then
							system.playNumber(mins, UNIT_MINUTE, 2)
						end
						system.playNumber(secs, UNIT_SECOND, 2)

                        timerDoneFirst = true
                    end
                else
                    timetime.timerannouncementTimerStart = nil
                end

                if timetime.timerannouncementTimerStart ~= nil then
                    if timerDoneFirst == false then
                        if ((tonumber(os.clock()) - tonumber(timetime.timeraudioannouncementCounter)) >= announcementIntervalParam) then
                            timetime.timeraudioannouncementCounter = os.clock()
							--print ("Playing TIMER (repeat)" .. alertTIME)
							if mins ~= "00" then
								system.playNumber(mins, UNIT_MINUTE, 2)
							end
							system.playNumber(secs, UNIT_SECOND, 2)
                        end
                    end
                else
                    -- stop timer
                    timetime.timerannouncementTimerStart = nil
                end
            end
        end
    end
end

function rf2status.playFuel(widget)
    if announcementFuelSwitchParam ~= nil then
        if announcementFuelSwitchParam:state() then
            fueltime.fuelannouncementTimer = true
            fuelDoneFirst = false
        else
            fueltime.fuelannouncementTimer = false
            fuelDoneFirst = true
        end

        if isInConfiguration == false then
            if sensors.fuel ~= nil then
                if fueltime.fuelannouncementTimer == true then
                    --start timer
                    if fueltime.fuelannouncementTimerStart == nil and fuelDoneFirst == false then
                        fueltime.fuelannouncementTimerStart = os.time()
						fueltime.fuelaudioannouncementCounter = os.clock()
						--print("Play fuel alert (first)")
						system.playFile("/scripts/rf2status/sounds/alerts/fuel.wav")	
                        system.playNumber(sensors.fuel, UNIT_PERCENT, 2)				
                        fuelDoneFirst = true
                    end
                else
                    fueltime.fuelannouncementTimerStart = nil
                end

                if fueltime.fuelannouncementTimerStart ~= nil then
                    if fuelDoneFirst == false then
                        if ((tonumber(os.clock()) - tonumber(fueltime.fuelaudioannouncementCounter)) >= announcementIntervalParam) then
                            fueltime.fuelaudioannouncementCounter = os.clock()
							--print("Play fuel alert (repeat)")
							system.playFile("/scripts/rf2status/sounds/alerts/fuel.wav")	
                            system.playNumber(sensors.fuel, UNIT_PERCENT, 2)
													
                        end
                    end
                else
                    -- stop timer
                    fueltime.fuelannouncementTimerStart = nil
                end
            end
        end
    end
end

function rf2status.playRPM(widget)
    if announcementRPMSwitchParam ~= nil then
        if announcementRPMSwitchParam:state() then
            rpmtime.announcementTimer = true
            rpmDoneFirst = false
        else
            rpmtime.announcementTimer = false
            rpmDoneFirst = true
        end

        if isInConfiguration == false then
            if sensors.rpm ~= nil then
                if rpmtime.announcementTimer == true then
                    --start timer
                    if rpmtime.announcementTimerStart == nil and rpmDoneFirst == false then
                        rpmtime.announcementTimerStart = os.time()
						rpmtime.audioannouncementCounter = os.clock()
						--print("Play rpm alert (first)")
                        system.playNumber(sensors.rpm, UNIT_RPM, 2)
                        rpmDoneFirst = true
                    end
                else
                    rpmtime.announcementTimerStart = nil
                end

                if rpmtime.announcementTimerStart ~= nil then
                    if rpmDoneFirst == false then
                        if ((tonumber(os.clock()) - tonumber(rpmtime.audioannouncementCounter)) >= announcementIntervalParam) then
							--print("Play rpm alert (repeat)")
                            rpmtime.audioannouncementCounter = os.clock()
                            system.playNumber(sensors.rpm, UNIT_RPM, 2)
                        end
                    end
                else
                    -- stop timer
                    rpmtime.announcementTimerStart = nil
                end
            end
        end
    end
end

function rf2status.playVoltage(widget)
    if announcementVoltageSwitchParam ~= nil then
        if announcementVoltageSwitchParam:state() then
            lvannouncementTimer = true
            voltageDoneFirst = false
        else
            lvannouncementTimer = false
            voltageDoneFirst = true
        end

        if isInConfiguration == false then
            if sensors.voltage ~= nil then
                if lvannouncementTimer == true then
                    --start timer
                    if lvannouncementTimerStart == nil and voltageDoneFirst == false then
                        lvannouncementTimerStart = os.time()
						lvaudioannouncementCounter = os.clock()
						--print("Play voltage alert (first)")
						--system.playFile("/scripts/rf2status/sounds/alerts/voltage.wav")						
                        system.playNumber(sensors.voltage / 100, 2, 2)
                        voltageDoneFirst = true
                    end
                else
                    lvannouncementTimerStart = nil
                end

                if lvannouncementTimerStart ~= nil then
                    if voltageDoneFirst == false then
						if lvaudioannouncementCounter ~= nil and announcementIntervalParam ~= nil then
							if ((tonumber(os.clock()) - tonumber(lvaudioannouncementCounter)) >= announcementIntervalParam) then
								lvaudioannouncementCounter = os.clock()
								--print("Play voltage alert (repeat)")
								--system.playFile("/scripts/rf2status/sounds/alerts/voltage.wav")								
								system.playNumber(sensors.voltage / 100, 2, 2)
							end
						end
                    end
                else
                    -- stop timer
                    lvannouncementTimerStart = nil
                end
            end
        end
    end
end

local function event(widget, category, value, x, y)

	--print("Event received:", category, value, x, y)


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
				
				if sensors.govmode == "UNKNOWN" and governorUNKNOWNParam == true then
					if govmodeParam == 0 then
						system.playFile("/scripts/rf2status/sounds/events/governor.wav")
					end
					system.playFile("/scripts/rf2status/sounds/events/unknown.wav")
				end
				if sensors.govmode == "DISARMED" and governorDISARMEDParam == true then
					if govmodeParam == 0 then
						system.playFile("/scripts/rf2status/sounds/events/governor.wav")
					end	
					system.playFile("/scripts/rf2status/sounds/events/disarmed.wav")
				end				
				if sensors.govmode == "DISABLED" and governorDISABLEDParam == true then
					if govmodeParam == 0 then
						system.playFile("/scripts/rf2status/sounds/events/governor.wav")
					end	
					system.playFile("/scripts/rf2status/sounds/events/disabled.wav")
				end					
				if sensors.govmode == "BAILOUT" and governorBAILOUTParam == true then
					if govmodeParam == 0 then
						system.playFile("/scripts/rf2status/sounds/events/governor.wav")
					end	
					system.playFile("/scripts/rf2status/sounds/events/bailout.wav")
				end						
				if sensors.govmode == "AUTOROT" and governorAUTOROTParam == true then
					if govmodeParam == 0 then
						system.playFile("/scripts/rf2status/sounds/events/governor.wav")
					end
					system.playFile("/scripts/rf2status/sounds/events/autorot.wav")
				end						
				if sensors.govmode == "LOST-HS" and governorLOSTHSParam == true then
					if govmodeParam == 0 then
						system.playFile("/scripts/rf2status/sounds/events/governor.wav")
					end	
					system.playFile("/scripts/rf2status/sounds/events/lost-hs.wav")
				end		
				if sensors.govmode == "THR-OFF" and governorTHROFFParam == true then
					if govmodeParam == 0 then
						system.playFile("/scripts/rf2status/sounds/events/governor.wav")
					end	
					system.playFile("/scripts/rf2status/sounds/events/thr-off.wav")
				end		
				if sensors.govmode == "ACTIVE" and governorACTIVEParam == true then
					if govmodeParam == 0 then
						system.playFile("/scripts/rf2status/sounds/events/governor.wav")
					end	
					system.playFile("/scripts/rf2status/sounds/events/active.wav")
				end		
				if sensors.govmode == "RECOVERY" and governorRECOVERYParam == true then
					if govmodeParam == 0 then
						system.playFile("/scripts/rf2status/sounds/events/governor.wav")
					end
					system.playFile("/scripts/rf2status/sounds/events/recovery.wav")
				end		
				if sensors.govmode == "SPOOLUP" and governorSPOOLUPParam == true then
					if govmodeParam == 0 then
						system.playFile("/scripts/rf2status/sounds/events/governor.wav")
					end	
					system.playFile("/scripts/rf2status/sounds/events/spoolup.wav")
				end	
				if sensors.govmode == "IDLE" and governorIDLEParam == true then
					if govmodeParam == 0 then
						system.playFile("/scripts/rf2status/sounds/events/governor.wav")
					end
					system.playFile("/scripts/rf2status/sounds/events/idle.wav")
				end	
				if sensors.govmode == "OFF" and governorOFFParam == true then
					if govmodeParam == 0 then
						system.playFile("/scripts/rf2status/sounds/events/governor.wav")
					end
					system.playFile("/scripts/rf2status/sounds/events/off.wav")
				end	
				
		end
	
	end
end



function rf2status.playRPMDiff()
	if rpmAlertsParam == true then
	
	    if sensors.govmode == "ACTIVE" or sensors.govmode == "LOST-HS" or sensors.govmode == "BAILOUT" or sensors.govmode == "RECOVERY" then
	
			if playrpmdiff.playRPMDiffLastState == nil then
				playrpmdiff.playRPMDiffLastState = sensors.rpm
			end
		
			-- we take a reading every 5 second
			if (tonumber(os.clock()) - tonumber(playrpmdiff.playRPMDiffCounter)) >= 5 then
				playrpmdiff.playRPMDiffCounter = os.clock()
				playrpmdiff.playRPMDiffLastState = sensors.rpm
			end
			
			-- check if current state withing % of last state
			local percentageDiff = 0
			if sensors.rpm > playrpmdiff.playRPMDiffLastState then
				percentageDiff = math.abs(100 - (sensors.rpm / playrpmdiff.playRPMDiffLastState * 100))
			elseif playrpmdiff.playRPMDiffLastState < sensors.rpm then
				percentage = math.abs(100 - (playrpmdiff.playRPMDiffLastState/sensors.rpm * 100))
			else
				percentageDiff = 0
			end		

			if percentageDiff > rpmAlertsPercentageParam/10 then
				playrpmdiff.playRPMDiffCount = 0
			end

			if playrpmdiff.playRPMDiffCount == 0 then
					--print("RPM Difference: " .. percentageDiff)
					playrpmdiff.playRPMDiffCount = 1
					system.playNumber(sensors.rpm ,  UNIT_RPM, 2)
			end		
		end
	end
end


local adjTimerStart = os.time()
local adjJUSTUPCounter = 0
local function playADJ()


	if adjFunctionParam  == true then

		if sensors.adjsource ~= nil then
			ADJSOURCE = math.floor(sensors.adjsource)
		end
		if sensors.adjvalue ~nil then
			ADJVALUE = math.floor(sensors.adjvalue)
		end	
		
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
						--print("ADJfunc announcemented for: " .. "id".. ADJSOURCE)
						for wavi, wavv in ipairs(adjfunction.wavs) do
							system.playFile("/scripts/rf2status/sounds/adjfunc/"..wavv..".wav")
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
			

			if ((tonumber(os.clock()) - tonumber(linkUPTime)) >= 10) then
			
				-- IDLE
				if switchIdlelowParam ~= nil and switchIdlelowParam:state() == true then
					if switchstatus.idlelow == nil or switchstatus.idlelow == false then
						system.playFile("/scripts/rf2status/sounds/switches/idle-l.wav")
						switchstatus.idlelow = true
						switchstatus.idlemedium = false
						switchstatus.idlehigh = false
					end	
				else
					switchstatus.idlelow = false
				end
				if switchIdlemediumParam ~= nil and switchIdlemediumParam:state() == true then
					if switchstatus.idlemedium == nil or switchstatus.idlemedium == false then
						system.playFile("/scripts/rf2status/sounds/switches/idle-m.wav")
						switchstatus.idlelow = false				
						switchstatus.idlemedium = true
						switchstatus.idlehigh = false				
					end	
				else
					switchstatus.idlemedium = false
				end
				if switchIdlehighParam ~= nil and switchIdlehighParam:state() == true then
					if switchstatus.idlehigh == nil or switchstatus.idlehigh == false then
						system.playFile("/scripts/rf2status/sounds/switches/idle-h.wav")
						switchstatus.idlelow = false				
						switchstatus.idlemedium = false
						switchstatus.idlehigh = true	
					end	
				else
					switchstatus.idlehigh = false
				end		
				
				-- RATES
				if switchrateslowParam ~= nil and switchrateslowParam:state() == true then
					if switchstatus.rateslow == nil or switchstatus.rateslow == false then
						system.playFile("/scripts/rf2status/sounds/switches/rates-l.wav")
						switchstatus.rateslow = true
						switchstatus.ratesmedium = false
						switchstatus.rateshigh = false
					end	
				else
					switchstatus.rateslow = false
				end
				if switchratesmediumParam ~= nil and switchratesmediumParam:state() == true then
					if switchstatus.ratesmedium == nil or switchstatus.ratesmedium == false then
						system.playFile("/scripts/rf2status/sounds/switches/rates-m.wav")
						switchstatus.rateslow = false				
						switchstatus.ratesmedium = true
						switchstatus.rateshigh = false				
					end	
				else
					switchstatus.ratesmedium = false
				end
				if switchrateshighParam ~= nil and switchrateshighParam:state() == true then
					if switchstatus.rateshigh == nil or switchstatus.rateshigh == false then
						system.playFile("/scripts/rf2status/sounds/switches/rates-h.wav")
						switchstatus.rateslow = false				
						switchstatus.ratesmedium = false
						switchstatus.rateshigh = true	
					end	
				else
					switchstatus.rateshigh = false
				end			

				-- RESCUE
				if switchrescueonParam ~= nil and switchrescueonParam:state() == true then
					if switchstatus.rescueon == nil or switchstatus.rescueon == false then
						system.playFile("/scripts/rf2status/sounds/switches/rescue-on.wav")
						switchstatus.rescueon = true
						switchstatus.rescueoff = false
					end	
				else
					switchstatus.rescueon = false
				end
				if switchrescueoffParam ~= nil and switchrescueoffParam:state() == true then
					if switchstatus.rescueoff == nil or switchstatus.rescueoff == false then
						system.playFile("/scripts/rf2status/sounds/switches/rescue-off.wav")
						switchstatus.rescueon = false				
						switchstatus.rescueoff = true			
					end	
				else
					switchstatus.rescueoff = false
				end			

				-- BBL
				if switchbblonParam ~= nil and switchbblonParam:state() == true then
					if switchstatus.bblon == nil or switchstatus.bblon == false then
						system.playFile("/scripts/rf2status/sounds/switches/bbl-on.wav")
						switchstatus.bblon = true
						switchstatus.bbloff = false
					end	
				else
					switchstatus.bblon = false
				end
				if switchbbloffParam ~= nil and switchbbloffParam:state() == true then
					if switchstatus.bbloff == nil or switchstatus.bbloff == false then
						system.playFile("/scripts/rf2status/sounds/switches/bbl-off.wav")
						switchstatus.bblon = false				
						switchstatus.bbloff = true			
					end	
				else
					switchstatus.bbloff = false
				end	
				
				
			end	
			
			
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
            key = "bkshss",
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
