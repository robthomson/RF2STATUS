rf2status = {}

local arg = {...}

local widgetDir = arg[1].widgetDir
local compile = arg[2]

local environment = system.getVersion()

rf2status.oldsensors = {"rf2status.refresh", "voltage", "rpm", "current", "temp_esc", "temp_mcu", "fuel", "mah", "rssi", "fm", "govmode"}
rf2status.isVisible = nil
rf2status.isDARKMODE = nil
rf2status.loopCounter = 0
rf2status.sensors = nil
rf2status.gfx_model = nil
rf2status.theTIME = 0
rf2status.sensors = {}
rf2status.sensordisplay = {}
rf2status.theme = {}
rf2status.lvTimer = false
rf2status.lvTimerStart = nil
rf2status.lvannouncementTimer = false
rf2status.lvannouncementTimerStart = nil
rf2status.lvaudioannouncementCounter = 0
rf2status.lvAudioAlertCounter = 0
rf2status.motorWasActive = false
rf2status.lfTimer = false
rf2status.lfTimerStart = nil
rf2status.lfannouncementTimer = false
rf2status.lfannouncementTimerStart = nil
rf2status.lfaudioannouncementCounter = 0
rf2status.lfAudioAlertCounter = 0
rf2status.timeralarmVibrateParam = true
rf2status.timeralarmParam = 210
rf2status.timerAlarmPlay = true
rf2status.statusColorParam = true
rf2status.rpmtime = {}
rf2status.rpmtime.rpmTimer = false
rf2status.rpmtime.rpmTimerStart = nil
rf2status.rpmtime.announcementTimer = false
rf2status.rpmtime.announcementTimerStart = nil
rf2status.rpmtime.audioannouncementCounter = 0
rf2status.currenttime = {}
rf2status.currenttime.currentTimer = false
rf2status.currenttime.currentTimerStart = nil
rf2status.currenttime.currentannouncementTimer = false
rf2status.currenttime.currentannouncementTimerStart = nil
rf2status.currenttime.currentaudioannouncementCounter = 0
rf2status.lqtime = {}
rf2status.lqtime.lqTimer = false
rf2status.lqtime.lqTimerStart = nil
rf2status.lqtime.lqannouncementTimer = false
rf2status.lqtime.lqannouncementTimerStart = nil
rf2status.lqtime.lqaudioannouncementCounter = 0
rf2status.fueltime = {}
rf2status.fueltime.fuelTimer = false
rf2status.fueltime.fuelTimerStart = nil
rf2status.fueltime.fuelannouncementTimer = false
rf2status.fueltime.fuelannouncementTimerStart = nil
rf2status.fueltime.fuelaudioannouncementCounter = 0
rf2status.esctime = {}
rf2status.esctime.escTimer = false
rf2status.esctime.escTimerStart = nil
rf2status.esctime.escannouncementTimer = false
rf2status.esctime.escannouncementTimerStart = nil
rf2status.esctime.escaudioannouncementCounter = 0
rf2status.mcutime = {}
rf2status.mcutime.mcuTimer = false
rf2status.mcutime.mcuTimerStart = nil
rf2status.mcutime.mcuannouncementTimer = false
rf2status.mcutime.mcuannouncementTimerStart = nil
rf2status.mcutime.mcuaudioannouncementCounter = 0
rf2status.timetime = {}
rf2status.timetime.timerTimer = false
rf2status.timetime.timerTimerStart = nil
rf2status.timetime.timerannouncementTimer = false
rf2status.timetime.timerannouncementTimerStart = nil
rf2status.timetime.timeraudioannouncementCounter = 0
rf2status.linkUP = 0
rf2status.linkUPTime = 0
rf2status.refresh = true
rf2status.isInConfiguration = false
rf2status.stopTimer = true
rf2status.startTimer = false
rf2status.voltageIsLow = false
rf2status.voltageIsGettingLow = false
rf2status.fuelIsLow = false
rf2status.fuelIsGettingLow = false
rf2status.showLOGS = false
rf2status.readLOGS = false
rf2status.readLOGSlast = {}
rf2status.playGovernorCount = 0
rf2status.playGovernorLastState = nil
rf2status.playrpmdiff = {}
rf2status.playrpmdiff.playRPMDiffCount = 1
rf2status.playrpmdiff.playRPMDiffLastState = nil
rf2status.playrpmdiff.playRPMDiffCounter = 0
rf2status.lvStickOrder = {}
rf2status.lvStickOrder[1] = {1, 2, 3, 4}
rf2status.lvStickOrder[2] = {1, 2, 4, 5}
rf2status.lvStickOrder[3] = {1, 2, 4, 6}
rf2status.lvStickOrder[4] = {2, 3, 4, 6}
rf2status.switchstatus = {}
rf2status.quadBoxParam = 0
rf2status.lowvoltagStickParam = 0
rf2status.lowvoltagStickCutoffParam = 70
rf2status.govmodeParam = 0
rf2status.btypeParam = 0
rf2status.lowvoltagStickParam = nil
rf2status.lowvoltagStickCutoffParam = nil
rf2status.lowvoltagStickCutoffParam = 80
rf2status.govmodeParam = 0
rf2status.lowfuelParam = 20
rf2status.alertintParam = 5
rf2status.alrthptcParam = 1
rf2status.maxminParam = true
rf2status.titleParam = true
rf2status.modelImageParam = true
rf2status.cellsParam = 6
rf2status.lowVoltageGovernorParam = true
rf2status.sagParam = 5
rf2status.rpmAlertsParam = false
rf2status.rpmAlertsPercentageParam = 100
rf2status.governorAlertsParam = true
rf2status.announcementVoltageSwitchParam = nil
rf2status.announcementRPMSwitchParam = nil
rf2status.announcementCurrentSwitchParam = nil
rf2status.announcementFuelSwitchParam = nil
rf2status.announcementLQSwitchParam = nil
rf2status.announcementESCSwitchParam = nil
rf2status.announcementMCUSwitchParam = nil
rf2status.announcementTimerSwitchParam = nil
rf2status.filteringParam = 1
rf2status.lowvoltagsenseParam = 2
rf2status.announcementIntervalParam = 30
rf2status.lowVoltageGovernorParam = nil
rf2status.governorUNKNOWNParam = true
rf2status.governorDISARMEDParam = true
rf2status.governorDISABLEDParam = true
rf2status.governorAUTOROTParam = true
rf2status.governorLOSTHSParam = true
rf2status.governorTHROFFParam = true
rf2status.governorACTIVEParam = true
rf2status.governorRECOVERYParam = true
rf2status.governorSPOOLUPParam = true
rf2status.governorIDLEParam = true
rf2status.governorOFFParam = true
rf2status.alertonParam = 0
rf2status.calcfuelParam = false
rf2status.tempconvertParamESC = 1
rf2status.tempconvertParamMCU = 1
rf2status.idleupdelayParam = 20
rf2status.switchIdlelowParam = nil
rf2status.switchIdlemediumParam = nil
rf2status.switchIdlehighParam = nil
rf2status.switchrateslowParam = nil
rf2status.switchratesmediumParam = nil
rf2status.switchrateshighParam = nil
rf2status.switchrescueonParam = nil
rf2status.switchrescueoffParam = nil
rf2status.switchbblonParam = nil
rf2status.switchbbloffParam = nil
rf2status.idleupswitchParam = nil
rf2status.timerWASActive = false
rf2status.govWasActive = false
rf2status.maxMinSaved = false
rf2status.simPreSPOOLUP = false
rf2status.simDoSPOOLUP = false
rf2status.simDODISARM = false
rf2status.simDoSPOOLUPCount = 0
rf2status.actTime = nil
rf2status.lvStickannouncement = false
rf2status.maxminFinals1 = nil
rf2status.maxminFinals2 = nil
rf2status.maxminFinals3 = nil
rf2status.maxminFinals4 = nil
rf2status.maxminFinals5 = nil
rf2status.maxminFinals6 = nil
rf2status.maxminFinals7 = nil
rf2status.maxminFinals8 = nil
rf2status.oldADJSOURCE = 0
rf2status.oldADJVALUE = 0
rf2status.adjfuncIdChanged = false
rf2status.adjfuncValueChanged = false
rf2status.adjJUSTUP = false
rf2status.ADJSOURCE = nil
rf2status.ADJVALUE = nil
rf2status.noTelemTimer = 0
rf2status.closeButtonX = 0
rf2status.closeButtonY = 0
rf2status.closeButtonW = 0
rf2status.closeButtonH = 0
rf2status.adjTimerStart = os.time()
rf2status.adjJUSTUPCounter = 0
rf2status.sensorVoltageMax = 0
rf2status.sensorVoltageMin = 0
rf2status.sensorFuelMin = 0
rf2status.sensorFuelMax = 0
rf2status.sensorRPMMin = 0
rf2status.sensorRPMMax = 0
rf2status.sensorCurrentMin = 0
rf2status.sensorCurrentMax = 0
rf2status.sensorTempMCUMin = 0
rf2status.sensorTempMCUMax = 0
rf2status.sensorTempESCMin = 0
rf2status.sensorTempESCMax = 0
rf2status.sensorRSSIMin = 0
rf2status.sensorRSSIMax = 0
rf2status.lastMaxMin = 0
rf2status.wakeupSchedulerUI = os.clock()
rf2status.voltageNoiseQ = 100
rf2status.fuelNoiseQ = 100
rf2status.rpmNoiseQ = 100
rf2status.temp_mcuNoiseQ = 100
rf2status.temp_escNoiseQ = 100
rf2status.rssiNoiseQ = 100
rf2status.currentNoiseQ = 100
rf2status.i8n = assert(compile.loadScript(widgetDir .. "i8n/" .. system.getLocale() .. ".lua"))()
rf2status.layoutOptions = {
    {rf2status.i8n.TIMER, 1}, {rf2status.i8n.VOLTAGE, 2}, {rf2status.i8n.FUEL, 3}, {rf2status.i8n.CURRENT, 4}, {rf2status.i8n.MAH, 17}, {rf2status.i8n.RPM, 5}, {rf2status.i8n.LQ, 6},
    {rf2status.i8n.TESC, 7}, {rf2status.i8n.TMCU, 8}, {rf2status.i8n.IMAGE, 9}, {rf2status.i8n.GOVERNOR, 10}, {rf2status.i8n.IMAGEGOVERNOR, 11}, {rf2status.i8n.LQTIMER, 12},
    {rf2status.i8n.TESCTMCU, 13}, {rf2status.i8n.VOLTAGEFUEL, 14}, {rf2status.i8n.VOLTAGECURRENT, 15}, {rf2status.i8n.VOLTAGEMAH, 16}, {rf2status.i8n.LQTIMERTESCTMCU, 20},
    {rf2status.i8n.MAXCURRENT, 21}, {rf2status.i8n.LQGOVERNOR, 22}
}
rf2status.layoutBox1Param = 11 -- IMAGE, GOV
rf2status.layoutBox2Param = 2 -- VOLTAGE
rf2status.layoutBox3Param = 3 -- FUEL
rf2status.layoutBox4Param = 12 -- LQ,TIMER
rf2status.layoutBox5Param = 4 -- CURRENT
rf2status.layoutBox6Param = 5 -- RPM
rf2status.adjfunctions = {
    -- rates
    id5 = {name = "Pitch Rate", wavs = {"pitch", "rate"}},
    id6 = {name = "Roll Rate", wavs = {"roll", "rate"}},
    id7 = {name = "Yaw Rate", wavs = {"yaw", "rate"}},
    id8 = {name = "Pitch RC Rate", wavs = {"pitch", "rc", "rate"}},
    id9 = {name = "Roll RC Rate", wavs = {"roll", "rc", "rate"}},
    id10 = {name = "Yaw RC Rate", wavs = {"yaw", "rc", "rate"}},
    id11 = {name = "Pitch RC Expo", wavs = {"pitch", "rc", "expo"}},
    id12 = {name = "Roll RC Expo", wavs = {"roll", "rc", "expo"}},
    id13 = {name = "Yaw RC Expo", wavs = {"yaw", "rc", "expo"}},

    -- pids
    id14 = {name = "Pitch P Gain", wavs = {"pitch", "p", "gain"}},
    id15 = {name = "Pitch I Gain", wavs = {"pitch", "i", "gain"}},
    id16 = {name = "Pitch D Gain", wavs = {"pitch", "d", "gain"}},
    id17 = {name = "Pitch F Gain", wavs = {"pitch", "f", "gain"}},
    id18 = {name = "Roll P Gain", wavs = {"roll", "p", "gain"}},
    id19 = {name = "Roll I Gain", wavs = {"roll", "i", "gain"}},
    id20 = {name = "Roll D Gain", wavs = {"roll", "d", "gain"}},
    id21 = {name = "Roll F Gain", wavs = {"roll", "f", "gain"}},
    id22 = {name = "Yaw P Gain", wavs = {"yaw", "p", "gain"}},
    id23 = {name = "Yaw I Gain", wavs = {"yaw", "i", "gain"}},
    id24 = {name = "Yaw D Gain", wavs = {"yaw", "d", "gain"}},
    id25 = {name = "Yaw F Gain", wavs = {"yaw", "f", "gain"}},

    id26 = {name = "Yaw CW Gain", wavs = {"yaw", "cw", "gain"}},
    id27 = {name = "Yaw CCW Gain", wavs = {"yaw", "ccw", "gain"}},
    id28 = {name = "Yaw Cyclic FF", wavs = {"yaw", "cyclic", "ff"}},
    id29 = {name = "Yaw Coll FF", wavs = {"yaw", "collective", "ff"}},
    id30 = {name = "Yaw Coll Dyn", wavs = {"yaw", "collective", "dyn"}},
    id31 = {name = "Yaw Coll Decay", wavs = {"yaw", "collective", "decay"}},
    id32 = {name = "Pitch Coll FF", wavs = {"pitch", "collective", "ff"}},

    -- gyro cutoffs
    id33 = {name = "Pitch Gyro Cutoff", wavs = {"pitch", "gyro", "cutoff"}},
    id34 = {name = "Roll Gyro Cutoff", wavs = {"roll", "gyro", "cutoff"}},
    id35 = {name = "Yaw Gyro Cutoff", wavs = {"yaw", "gyro", "cutoff"}},

    -- dterm cutoffs
    id36 = {name = "Pitch D-term Cutoff", wavs = {"pitch", "dterm", "cutoff"}},
    id37 = {name = "Roll D-term Cutoff", wavs = {"roll", "dterm", "cutoff"}},
    id38 = {name = "Yaw D-term Cutoff", wavs = {"yaw", "dterm", "cutoff"}},

    -- rescue
    id39 = {name = "Rescue Climb Coll", wavs = {"rescue", "climb", "collective"}},
    id40 = {name = "Rescue Hover Coll", wavs = {"rescue", "hover", "collective"}},
    id41 = {name = "Rescue Hover Alt", wavs = {"rescue", "hover", "alt"}},
    id42 = {name = "Rescue Alt P Gain", wavs = {"rescue", "alt", "p", "gain"}},
    id43 = {name = "Rescue Alt I Gain", wavs = {"rescue", "alt", "i", "gain"}},
    id44 = {name = "Rescue Alt D Gain", wavs = {"rescue", "alt", "d", "gain"}},

    -- leveling
    id45 = {name = "Angle Level Gain", wavs = {"angle", "level", "gain"}},
    id46 = {name = "Horizon Level Gain", wavs = {"horizon", "level", "gain"}},
    id47 = {name = "Acro Trainer Gain", wavs = {"acro", "gain"}},

    -- governor
    id48 = {name = "Governor Gain", wavs = {"gov", "gain"}},
    id49 = {name = "Governor P Gain", wavs = {"gov", "p", "gain"}},
    id50 = {name = "Governor I Gain", wavs = {"gov", "i", "gain"}},
    id51 = {name = "Governor D Gain", wavs = {"gov", "d", "gain"}},
    id52 = {name = "Governor F Gain", wavs = {"gov", "f", "gain"}},
    id53 = {name = "Governor TTA Gain", wavs = {"gov", "tta", "gain"}},
    id54 = {name = "Governor Cyclic FF", wavs = {"gov", "cyclic", "ff"}},
    id55 = {name = "Governor Coll FF", wavs = {"gov", "collective", "ff"}},

    -- boost gains
    id56 = {name = "Pitch B Gain", wavs = {"pitch", "b", "gain"}},
    id57 = {name = "Roll B Gain", wavs = {"roll", "b", "gain"}},
    id58 = {name = "Yaw B Gain", wavs = {"yaw", "b", "gain"}},

    -- offset gains
    id59 = {name = "Pitch O Gain", wavs = {"pitch", "o", "gain"}},
    id60 = {name = "Roll O Gain", wavs = {"roll", "o", "gain"}},

    -- cross-coupling
    id61 = {name = "Cross Coup Gain", wavs = {"crossc", "gain"}},
    id62 = {name = "Cross Coup Ratio", wavs = {"crossc", "ratio"}},
    id63 = {name = "Cross Coup Cutoff", wavs = {"crossc", "cutoff"}}
}

function rf2status.create(widget)
    rf2status.gfx_model = lcd.loadBitmap(model.bitmap())
    rf2status.gfx_heli = lcd.loadBitmap(widgetDir .. "gfx/heli.png")
    rf2status.gfx_close = lcd.loadBitmap(widgetDir .. "gfx/close.png")
    rf2status.rssiSensor = rf2status.getRssiSensor()

    if tonumber(rf2status.sensorMakeNumber(environment.version)) < 159 then
        rf2status.screenError("ETHOS < V1.5.9")
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
        governorOFF = true,
        alerton = 0,
        tempconvertesc = 1
    }
end

function rf2status.configure(widget)
    rf2status.isInConfiguration = true

    triggerpanel = form.addExpansionPanel(rf2status.i8n.Triggers)
    triggerpanel:open(false)

    line = triggerpanel:addLine(rf2status.i8n.Armswitch)
    armswitch = form.addSwitchField(line, form.getFieldSlots(line)[0], function()
        return armswitchParam
    end, function(value)
        armswitchParam = value
    end)

    line = triggerpanel:addLine(rf2status.i8n.Idleupswitch)
    idleupswitch = form.addSwitchField(line, form.getFieldSlots(line)[0], function()
        return rf2status.idleupswitchParam
    end, function(value)
        rf2status.idleupswitchParam = value
    end)

    line = triggerpanel:addLine("    " .. rf2status.i8n.Delaybeforeactive)
    field = form.addNumberField(line, nil, 5, 60, function()
        return rf2status.idleupdelayParam
    end, function(value)
        rf2status.idleupdelayParam = value
    end)
    field:default(5)
    field:suffix("s")

    timerpanel = form.addExpansionPanel(rf2status.i8n.Timerconfiguration)
    timerpanel:open(false)

    timeTable = {
        {rf2status.i8n.Disabled, 0}, {"00:30", 30}, {"01:00", 60}, {"01:30", 90}, {"02:00", 120}, {"02:30", 150}, {"03:00", 180}, {"03:30", 210}, {"04:00", 240}, {"04:30", 270}, {"05:00", 300},
        {"05:30", 330}, {"06:00", 360}, {"06:30", 390}, {"07:00", 420}, {"07:30", 450}, {"08:00", 480}, {"08:30", 510}, {"09:00", 540}, {"09:30", 570}, {"10:00", 600}, {"10:30", 630}, {"11:00", 660},
        {"11:30", 690}, {"12:00", 720}, {"12:30", 750}, {"13:00", 780}, {"13:30", 810}, {"14:00", 840}, {"14:30", 870}, {"15:00", 900}, {"15:30", 930}, {"16:00", 960}, {"16:30", 990}, {"17:00", 1020},
        {"17:30", 1050}, {"18:00", 1080}, {"18:30", 1110}, {"19:00", 1140}, {"19:30", 1170}, {"20:00", 1200}
    }

    line = timerpanel:addLine(rf2status.i8n.Playalarmat)
    form.addChoiceField(line, nil, timeTable, function()
        return rf2status.timeralarmParam
    end, function(newValue)
        rf2status.timeralarmParam = newValue
    end)

    line = timerpanel:addLine(rf2status.i8n.Vibrate)
    form.addBooleanField(line, nil, function()
        return rf2status.timeralarmVibrateParam
    end, function(newValue)
        rf2status.timeralarmVibrateParam = newValue
    end)

    batterypanel = form.addExpansionPanel(rf2status.i8n.Batteryconfiguration)
    batterypanel:open(false)

    -- CELLS

    line = batterypanel:addLine(rf2status.i8n.Type)
    form.addChoiceField(line, nil, {{rf2status.i8n.LiPo, 0}, {rf2status.i8n.LiHv, 1}, {rf2status.i8n.Lion, 2}, {rf2status.i8n.LiFe, 3}, {rf2status.i8n.NiMh, 4}}, function()
        return rf2status.btypeParam
    end, function(newValue)
        rf2status.btypeParam = newValue
    end)

    -- BATTERY CELLS
    line = batterypanel:addLine(rf2status.i8n.Cells)
    field = form.addNumberField(line, nil, 0, 14, function()
        return rf2status.cellsParam
    end, function(value)
        rf2status.cellsParam = value
    end)
    field:default(6)

    -- LOW FUEL announcement
    line = batterypanel:addLine(rf2status.i8n.Lowfuelpercentage)
    field = form.addNumberField(line, nil, 0, 50, function()
        return rf2status.lowfuelParam
    end, function(value)
        rf2status.lowfuelParam = value
    end)
    field:default(20)
    field:suffix("%")

    -- ALERT ON
    line = batterypanel:addLine(rf2status.i8n.Playalerton)
    form.addChoiceField(line, nil, {{rf2status.i8n.Lowvoltage, 0}, {rf2status.i8n.Lowfuel, 1}, {rf2status.i8n.LowfuelLowvoltage, 2}, {rf2status.i8n.Disabled, 3}}, function()
        return rf2status.alertonParam
    end, function(newValue)
        if newValue == 3 then
            plalrtint:enable(false)
            plalrthap:enable(false)
        else
            plalrtint:enable(true)
            plalrthap:enable(true)
        end
        rf2status.alertonParam = newValue
    end)

    -- ALERT INTERVAL
    line = batterypanel:addLine("     " .. rf2status.i8n.Interval)
    plalrtint = form.addChoiceField(line, nil, {{"5S", 5}, {"10S", 10}, {"15S", 15}, {"20S", 20}, {"30S", 30}}, function()
        return rf2status.alertintParam
    end, function(newValue)
        rf2status.alertintParam = newValue
    end)
    if rf2status.alertonParam == 3 then
        plalrtint:enable(false)
    else
        plalrtint:enable(true)
    end

    -- HAPTIC
    line = batterypanel:addLine("     " .. rf2status.i8n.Vibrate)
    plalrthap = form.addBooleanField(line, nil, function()
        return alrthptParam
    end, function(newValue)
        alrthptParam = newValue
    end)
    if rf2status.alertonParam == 3 then
        plalrthap:enable(false)
    else
        plalrthap:enable(true)
    end

    switchpanel = form.addExpansionPanel(rf2status.i8n.Switchannouncements)
    switchpanel:open(false)

    line = switchpanel:addLine(rf2status.i8n.Idlespeedlow)
    form.addSwitchField(line, nil, function()
        return rf2status.switchIdlelowParam
    end, function(value)
        rf2status.switchIdlelowParam = value
    end)

    line = switchpanel:addLine(rf2status.i8n.Idlespeedmedium)
    form.addSwitchField(line, nil, function()
        return rf2status.switchIdlemediumParam
    end, function(value)
        rf2status.switchIdlemediumParam = value
    end)

    line = switchpanel:addLine(rf2status.i8n.Idlespeedhigh)
    form.addSwitchField(line, nil, function()
        return rf2status.switchIdlehighParam
    end, function(value)
        rf2status.switchIdlehighParam = value
    end)

    line = switchpanel:addLine(rf2status.i8n.Rateslow)
    form.addSwitchField(line, nil, function()
        return rf2status.switchrateslowParam
    end, function(value)
        rf2status.switchrateslowParam = value
    end)

    line = switchpanel:addLine(rf2status.i8n.Ratesmedium)
    form.addSwitchField(line, nil, function()
        return rf2status.switchratesmediumParam
    end, function(value)
        rf2status.switchratesmediumParam = value
    end)

    line = switchpanel:addLine(rf2status.i8n.Rateshigh)
    form.addSwitchField(line, nil, function()
        return rf2status.switchrateshighParam
    end, function(value)
        rf2status.switchrateshighParam = value
    end)

    line = switchpanel:addLine(rf2status.i8n.Rescueon)
    form.addSwitchField(line, nil, function()
        return rf2status.switchrescueonParam
    end, function(value)
        rf2status.switchrescueonParam = value
    end)

    line = switchpanel:addLine(rf2status.i8n.Rescueoff)
    form.addSwitchField(line, nil, function()
        return rf2status.switchrescueoffParam
    end, function(value)
        rf2status.switchrescueoffParam = value
    end)

    line = switchpanel:addLine(rf2status.i8n.BBLenabled)
    form.addSwitchField(line, nil, function()
        return rf2status.switchbblonParam
    end, function(value)
        rf2status.switchbblonParam = value
    end)

    line = switchpanel:addLine(rf2status.i8n.BBLdisabled)
    form.addSwitchField(line, nil, function()
        return rf2status.switchbbloffParam
    end, function(value)
        rf2status.switchbbloffParam = value
    end)

    announcementpanel = form.addExpansionPanel(rf2status.i8n.Telemetryannouncements)
    announcementpanel:open(false)

    -- announcement VOLTAGE READING
    line = announcementpanel:addLine(rf2status.i8n.Voltage)
    form.addSwitchField(line, form.getFieldSlots(line)[0], function()
        return rf2status.announcementVoltageSwitchParam
    end, function(value)
        rf2status.announcementVoltageSwitchParam = value
    end)

    -- announcement RPM READING
    line = announcementpanel:addLine(rf2status.i8n.Rpm)
    form.addSwitchField(line, nil, function()
        return rf2status.announcementRPMSwitchParam
    end, function(value)
        rf2status.announcementRPMSwitchParam = value
    end)

    -- announcement CURRENT READING
    line = announcementpanel:addLine(rf2status.i8n.Current)
    form.addSwitchField(line, nil, function()
        return rf2status.announcementCurrentSwitchParam
    end, function(value)
        rf2status.announcementCurrentSwitchParam = value
    end)

    -- announcement FUEL READING
    line = announcementpanel:addLine(rf2status.i8n.Fuel)
    form.addSwitchField(line, form.getFieldSlots(line)[0], function()
        return rf2status.announcementFuelSwitchParam
    end, function(value)
        rf2status.announcementFuelSwitchParam = value
    end)

    -- announcement LQ READING
    line = announcementpanel:addLine(rf2status.i8n.LQ)
    form.addSwitchField(line, form.getFieldSlots(line)[0], function()
        return rf2status.announcementLQSwitchParam
    end, function(value)
        rf2status.announcementLQSwitchParam = value
    end)

    -- announcement LQ READING
    line = announcementpanel:addLine(rf2status.i8n.Esctemperature)
    form.addSwitchField(line, form.getFieldSlots(line)[0], function()
        return rf2status.announcementESCSwitchParam
    end, function(value)
        rf2status.announcementESCSwitchParam = value
    end)

    -- announcement MCU READING
    line = announcementpanel:addLine(rf2status.i8n.Mcutemperature)
    form.addSwitchField(line, form.getFieldSlots(line)[0], function()
        return rf2status.announcementMCUSwitchParam
    end, function(value)
        rf2status.announcementMCUSwitchParam = value
    end)

    -- announcement TIMER READING
    line = announcementpanel:addLine(rf2status.i8n.Timer)
    form.addSwitchField(line, form.getFieldSlots(line)[0], function()
        return rf2status.announcementTimerSwitchParam
    end, function(value)
        rf2status.announcementTimerSwitchParam = value
    end)

    govalertpanel = form.addExpansionPanel(rf2status.i8n.Governorannouncements)
    govalertpanel:open(false)

    -- TITLE DISPLAY
    line = govalertpanel:addLine("  " .. rf2status.i8n.OFF)
    form.addBooleanField(line, nil, function()
        return rf2status.governorOFFParam
    end, function(newValue)
        rf2status.governorOFFParam = newValue
    end)

    -- TITLE DISPLAY
    line = govalertpanel:addLine("  " .. rf2status.i8n.IDLE)
    form.addBooleanField(line, nil, function()
        return rf2status.governorIDLEParam
    end, function(newValue)
        rf2status.governorIDLEParam = newValue
    end)

    -- TITLE DISPLAY
    line = govalertpanel:addLine("  " .. rf2status.i8n.SPOOLUP)
    form.addBooleanField(line, nil, function()
        return rf2status.governorSPOOLUPParam
    end, function(newValue)
        rf2status.governorSPOOLUPParam = newValue
    end)

    line = govalertpanel:addLine("  " .. rf2status.i8n.RECOVERY)
    form.addBooleanField(line, nil, function()
        return rf2status.governorRECOVERYParam
    end, function(newValue)
        rf2status.governorRECOVERYParam = newValue
    end)

    line = govalertpanel:addLine("  " .. rf2status.i8n.ACTIVE)
    form.addBooleanField(line, nil, function()
        return rf2status.governorACTIVEParam
    end, function(newValue)
        rf2status.governorACTIVEParam = newValue
    end)

    line = govalertpanel:addLine("  " .. rf2status.i8n.THROFF)
    form.addBooleanField(line, nil, function()
        return rf2status.governorTHROFFParam
    end, function(newValue)
        rf2status.governorTHROFFParam = newValue
    end)

    line = govalertpanel:addLine("  " .. rf2status.i8n.LOSTHS)
    form.addBooleanField(line, nil, function()
        return rf2status.governorLOSTHSParam
    end, function(newValue)
        rf2status.governorLOSTHSParam = newValue
    end)

    line = govalertpanel:addLine("  " .. rf2status.i8n.AUTOROT)
    form.addBooleanField(line, nil, function()
        return rf2status.governorAUTOROTParam
    end, function(newValue)
        rf2status.governorAUTOROTParam = newValue
    end)

    line = govalertpanel:addLine("  " .. rf2status.i8n.BAILOUT)
    form.addBooleanField(line, nil, function()
        return rf2status.governorBAILOUTParam
    end, function(newValue)
        rf2status.governorBAILOUTParam = newValue
    end)

    line = govalertpanel:addLine("  " .. rf2status.i8n.DISABLED)
    form.addBooleanField(line, nil, function()
        return rf2status.governorDISABLEDParam
    end, function(newValue)
        rf2status.governorDISABLEDParam = newValue
    end)

    line = govalertpanel:addLine("  " .. rf2status.i8n.DISARMED)
    form.addBooleanField(line, nil, function()
        return rf2status.governorDISARMEDParam
    end, function(newValue)
        rf2status.governorDISARMEDParam = newValue
    end)

    line = govalertpanel:addLine("   " .. rf2status.i8n.UNKNOWN)
    form.addBooleanField(line, nil, function()
        return rf2status.governorUNKNOWNParam
    end, function(newValue)
        rf2status.governorUNKNOWNParam = newValue
    end)

    displaypanel = form.addExpansionPanel(rf2status.i8n.Customisedisplay)
    displaypanel:open(false)

    line = displaypanel:addLine(rf2status.i8n.Box1)
    form.addChoiceField(line, nil, rf2status.layoutOptions, function()
        return rf2status.layoutBox1Param
    end, function(newValue)
        rf2status.layoutBox1Param = newValue
    end)

    line = displaypanel:addLine(rf2status.i8n.Box2)
    form.addChoiceField(line, nil, rf2status.layoutOptions, function()
        return rf2status.layoutBox2Param
    end, function(newValue)
        rf2status.layoutBox2Param = newValue
    end)

    line = displaypanel:addLine(rf2status.i8n.Box3)
    form.addChoiceField(line, nil, rf2status.layoutOptions, function()
        return rf2status.layoutBox3Param
    end, function(newValue)
        rf2status.layoutBox3Param = newValue
    end)

    line = displaypanel:addLine(rf2status.i8n.Box4)
    form.addChoiceField(line, nil, rf2status.layoutOptions, function()
        return rf2status.layoutBox4Param
    end, function(newValue)
        rf2status.layoutBox4Param = newValue
    end)

    line = displaypanel:addLine(rf2status.i8n.Box5)
    form.addChoiceField(line, nil, rf2status.layoutOptions, function()
        return rf2status.layoutBox5Param
    end, function(newValue)
        rf2status.layoutBox5Param = newValue
    end)

    line = displaypanel:addLine(rf2status.i8n.Box6)
    form.addChoiceField(line, nil, rf2status.layoutOptions, function()
        return rf2status.layoutBox6Param
    end, function(newValue)
        rf2status.layoutBox6Param = newValue
    end)

    -- TITLE DISPLAY
    line = displaypanel:addLine(rf2status.i8n.Displaytitle)
    form.addBooleanField(line, nil, function()
        return rf2status.titleParam
    end, function(newValue)
        rf2status.titleParam = newValue
    end)

    -- MAX MIN DISPLAY
    line = displaypanel:addLine(rf2status.i8n.Displaymaxmin)
    form.addBooleanField(line, nil, function()
        return rf2status.maxminParam
    end, function(newValue)
        rf2status.maxminParam = newValue
    end)

    -- color mode
    line = displaypanel:addLine(rf2status.i8n.statusColor)
    form.addBooleanField(line, nil, function()
        return rf2status.statusColorParam
    end, function(newValue)
        rf2status.statusColorParam = newValue
    end)    


    advpanel = form.addExpansionPanel(rf2status.i8n.Advanced)
    advpanel:open(false)

    line = advpanel:addLine(rf2status.i8n.Governor)
    extgov = form.addChoiceField(line, nil, {{rf2status.i8n.RFGovernor, 0}, {rf2status.i8n.ExternalGovernor, 1}}, function()
        return rf2status.govmodeParam
    end, function(newValue)
        rf2status.govmodeParam = newValue
    end)

    line = form.addLine(rf2status.i8n.Temperatureconversion, advpanel)

    line = advpanel:addLine("    " .. rf2status.i8n.ESC)
    form.addChoiceField(line, nil, {{rf2status.i8n.Disable, 1}, {"°C -> °F", 2}, {"°F -> °C", 3}}, function()
        return rf2status.tempconvertParamESC
    end, function(newValue)
        rf2status.tempconvertParamESC = newValue
    end)

    line = advpanel:addLine("   " .. rf2status.i8n.MCU)
    form.addChoiceField(line, nil, {{rf2status.i8n.Disable, 1}, {"°C -> °F", 2}, {"°F -> °C", 3}}, function()
        return rf2status.tempconvertParamMCU
    end, function(newValue)
        rf2status.tempconvertParamMCU = newValue
    end)

    line = form.addLine(rf2status.i8n.Voltage, advpanel)

    -- LVannouncement DISPLAY
    line = advpanel:addLine("    " .. rf2status.i8n.Sensitivity)
    form.addChoiceField(line, nil, {{rf2status.i8n.HIGH, 1}, {rf2status.i8n.MEDIUM, 2}, {rf2status.i8n.LOW, 3}}, function()
        return rf2status.lowvoltagsenseParam
    end, function(newValue)
        rf2status.lowvoltagsenseParam = newValue
    end)

    line = advpanel:addLine("    " .. rf2status.i8n.Sagcompensation)
    field = form.addNumberField(line, nil, 0, 10, function()
        return rf2status.sagParam
    end, function(value)
        rf2status.sagParam = value
    end)
    field:default(5)
    field:suffix("s")
    -- field:decimals(1)

    -- LVSTICK MONITORING
    line = advpanel:addLine("    " .. rf2status.i8n.Gimbalmonitoring)
    form.addChoiceField(line, nil, {
        {rf2status.i8n.DISABLED, 0}, -- recomended
        {"AECR1T23 (ELRS)", 1}, -- recomended
        {"AETRC123 (FRSKY)", 2}, -- frsky
        {"AETR1C23 (FUTABA)", 3}, -- fut/hitec
        {"TAER1C23 (SPEKTRUM)", 4} -- spec
    }, function()
        return rf2status.lowvoltagStickParam
    end, function(newValue)
        if newValue == 0 then
            fieldstckcutoff:enable(false)
        else
            fieldstckcutoff:enable(true)
        end
        rf2status.lowvoltagStickParam = newValue
    end)

    line = advpanel:addLine("       " .. rf2status.i8n.Stickcutoff)
    fieldstckcutoff = form.addNumberField(line, nil, 65, 95, function()
        return rf2status.lowvoltagStickCutoffParam
    end, function(value)
        rf2status.lowvoltagStickCutoffParam = value
    end)
    fieldstckcutoff:default(80)
    fieldstckcutoff:suffix("%")
    if rf2status.lowvoltagStickParam == 0 then
        fieldstckcutoff:enable(false)
    else
        fieldstckcutoff:enable(true)
    end

    line = form.addLine(rf2status.i8n.Headspeed, advpanel)

    -- TITLE DISPLAY
    line = advpanel:addLine("   " .. rf2status.i8n.AlertonRPMdifference)
    form.addBooleanField(line, nil, function()
        return rf2status.rpmAlertsParam
    end, function(newValue)
        if newValue == false then
            rpmperfield:enable(false)
        else
            rpmperfield:enable(true)
        end

        rf2status.rpmAlertsParam = newValue
    end)

    -- TITLE DISPLAY
    line = advpanel:addLine("   " .. rf2status.i8n.Alertifdifferencegtthan)
    rpmperfield = form.addNumberField(line, nil, 0, 200, function()
        return rf2status.rpmAlertsPercentageParam
    end, function(value)
        rf2status.rpmAlertsPercentageParam = value
    end)
    if rf2status.rpmAlertsParam == false then
        rpmperfield:enable(false)
    else
        rpmperfield:enable(true)
    end
    rpmperfield:default(100)
    rpmperfield:decimals(1)
    rpmperfield:suffix("%")

    -- FILTER
    -- MAX MIN DISPLAY
    line = advpanel:addLine(rf2status.i8n.Telemetryfiltering)
    form.addChoiceField(line, nil, {{rf2status.i8n.LOW, 1}, {rf2status.i8n.MEDIUM, 2}, {rf2status.i8n.HIGH, 3}}, function()
        return rf2status.filteringParam
    end, function(newValue)
        rf2status.filteringParam = newValue
    end)

    -- LVannouncement DISPLAY
    line = advpanel:addLine(rf2status.i8n.Announcementinterval)
    form.addChoiceField(line, nil, {
        {"5s", 5}, {"10s", 10}, {"15s", 15}, {"20s", 20}, {"25s", 25}, {"30s", 30}, {"35s", 35}, {"40s", 40}, {"45s", 45}, {"50s", 50}, {"55s", 55}, {"60s", 60}, {rf2status.i8n.Norepeat, 50000}
    }, function()
        return rf2status.announcementIntervalParam
    end, function(newValue)
        rf2status.announcementIntervalParam = newValue
    end)


    -- calcfuel
    line = advpanel:addLine(rf2status.i8n.Calcfuellocally)
    form.addBooleanField(line, nil, function()
        return rf2status.calcfuelParam
    end, function(newValue)
        rf2status.calcfuelParam = newValue
    end)
    
    rf2status.resetALL()

    return widget
end

function rf2status.getRssiSensor()
    if environment.simulation then return 100 end

    local rssiNames = {"RSSI", "RSSI 2.4G", "RSSI 900M", "Rx RSSI1", "Rx RSSI2", "RSSI Int", "RSSI Ext"}
    for i, name in ipairs(rssiNames) do
        rf2status.rssiSensor = system.getSource(name)
        if rf2status.rssiSensor then return rf2status.rssiSensor end
    end
end

function rf2status.getRSSI()
    if environment.simulation == true then return 100 end
    if rf2status.rssiSensor ~= nil and rf2status.rssiSensor:state() then return rf2status.rssiSensor:value() end
    return 0
end

function rf2status.screenError(msg)
    local w, h = lcd.getWindowSize()
    rf2status.isDARKMODE = lcd.darkMode()
    lcd.font(FONT_STD)
    str = msg
    tsizeW, tsizeH = lcd.getTextSize(str)

    if rf2status.isDARKMODE then
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
    rf2status.showLOGS = false
    rf2status.sensorVoltageMax = 0
    rf2status.sensorVoltageMin = 0
    rf2status.sensorFuelMin = 0
    rf2status.sensorFuelMax = 0
    rf2status.sensorRPMMin = 0
    rf2status.sensorRPMMax = 0
    rf2status.sensorCurrentMin = 0
    rf2status.sensorCurrentMax = 0
    rf2status.sensorTempMCUMin = 0
    rf2status.sensorTempMCUMax = 0
    rf2status.sensorTempESCMin = 0
    rf2status.sensorTempESCMax = 0
end

function rf2status.noTelem()

    lcd.font(FONT_STD)
    str = rf2status.i8n.NODATA

    rf2status.theme = rf2status.getThemeInfo()
    local w, h = lcd.getWindowSize()
    boxW = math.floor(w / 2)
    boxH = 45
    tsizeW, tsizeH = lcd.getTextSize(str)

    -- draw the backgrf2status.round
    if rf2status.isDARKMODE then
        lcd.color(lcd.RGB(40, 40, 40))
    else
        lcd.color(lcd.RGB(240, 240, 240))
    end
    lcd.drawFilledRectangle(w / 2 - boxW / 2, h / 2 - boxH / 2, boxW, boxH)

    -- draw the border
    if rf2status.isDARKMODE then
        -- dark theme
        lcd.color(lcd.RGB(255, 255, 255, 1))
    else
        -- light theme
        lcd.color(lcd.RGB(90, 90, 90))
    end
    lcd.drawRectangle(w / 2 - boxW / 2, h / 2 - boxH / 2, boxW, boxH)

    if rf2status.isDARKMODE then
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
    h = (math.floor((h / 4)) * 4)
    w = (math.floor((w / 6)) * 6)

    -- first one is unsporrted

    if environment.board == "XES" or environment.board == "XE" or environment.board == "X20" or environment.board == "X20S" or environment.board == "X20PRO" or environment.board == "X20PROAW" or
        environment.board == "X20R" or environment.board == "X20RS" then
        ret = {
            supportedRADIO = true,
            colSpacing = 4,
            fullBoxW = 262,
            fullBoxH = h / 2,
            smallBoxSensortextOFFSET = -5,
            title_voltage = rf2status.i8n.VOLTAGE,
            title_fuel = rf2status.i8n.FUEL,
            title_mah = rf2status.i8n.MAH,
            title_rpm = rf2status.i8n.RPM,
            title_current = rf2status.i8n.CURRENT,
            title_tempMCU = rf2status.i8n.MCU,
            title_tempESC = rf2status.i8n.ESC,
            title_time = rf2status.i8n.TIMER,
            title_governor = rf2status.i8n.GOVERNOR,
            title_fm = rf2status.i8n.FLIGHTMODE,
            title_rssi = rf2status.i8n.LQ,
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
            title_voltage = rf2status.i8n.VOLTAGE,
            title_fuel = rf2status.i8n.FUEL,
            title_mah = rf2status.i8n.MAH,
            title_rpm = rf2status.i8n.RPM,
            title_current = rf2status.i8n.CURRENT,
            title_tempMCU = rf2status.i8n.MCU,
            title_tempESC = rf2status.i8n.ESC,
            title_time = rf2status.i8n.TIMER,
            title_governor = rf2status.i8n.GOVERNOR,
            title_fm = rf2status.i8n.FLIGHTMODE,
            title_rssi = rf2status.i8n.LQ,
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
            title_voltage = rf2status.i8n.VOLTAGE,
            title_fuel = rf2status.i8n.FUEL,
            title_mah = rf2status.i8n.MAH,
            title_rpm = rf2status.i8n.RPM,
            title_current = rf2status.i8n.CURRENT,
            title_tempMCU = rf2status.i8n.MCU,
            title_tempESC = rf2status.i8n.ESC,
            title_time = rf2status.i8n.TIMER,
            title_governor = rf2status.i8n.GOVERNOR,
            title_fm = rf2status.i8n.FLIGHTMODE,
            title_rssi = rf2status.i8n.LQ,
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
            title_voltage = rf2status.i8n.VOLTAGE,
            title_fuel = rf2status.i8n.FUEL,
            title_mah = rf2status.i8n.MAH,
            title_rpm = rf2status.i8n.RPM,
            title_current = rf2status.i8n.CURRENT,
            title_tempMCU = rf2status.i8n.MCU,
            title_tempESC = rf2status.i8n.ESC,
            title_time = rf2status.i8n.TIMER,
            title_governor = rf2status.i8n.GOVERNOR,
            title_fm = rf2status.i8n.FLIGHTMODE,
            title_rssi = rf2status.i8n.LQ,
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

    if environment.board == "X10EXPRESS" or environment.board == "X10" or environment.board == "X10S" or environment.board == "X12" or environment.board == "X12S" then
        ret = {
            supportedRADIO = true,
            colSpacing = 2,
            fullBoxW = 158,
            fullBoxH = 79,
            smallBoxSensortextOFFSET = -10,
            title_voltage = rf2status.i8n.VOLTAGE,
            title_fuel = rf2status.i8n.FUEL,
            title_mah = rf2status.i8n.MAH,
            title_rpm = rf2status.i8n.RPM,
            title_current = rf2status.i8n.CURRENT,
            title_tempMCU = rf2status.i8n.MCU,
            title_tempESC = rf2status.i8n.ESC,
            title_time = rf2status.i8n.TIMER,
            title_governor = rf2status.i8n.GOVERNOR,
            title_fm = rf2status.i8n.FLIGHTMODE,
            title_rssi = rf2status.i8n.LQ,
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

function rf2status.govColorFlag(flag)

    -- 0 = default colour
    -- 1 = red (alarm)
    -- 2 = orange (warning)
    -- 3 = green (ok)  
    
    if flag == "UNKNOWN" then
        return 1
    elseif flag == "DISARMED" then
        return 0
    elseif flag == "DISABLED" then
        return 0
    elseif flag == "BAILOUT" then
        return 2
    elseif flag == "AUTOROT" then
        return 2
    elseif flag == "LOST-HS" then
        return 2
    elseif flag == "THR-OFF" then
        return 2
    elseif flag == "ACTIVE" then
        return 3
    elseif flag == "RECOVERY" then
        return 2
    elseif flag == "SPOOLUP" then
        return 2
    elseif flag == "IDLE" then
        return 0
    elseif flag == "OFF" then
        return 0
    end

    return 0
end

function rf2status.telemetryBox(x, y, w, h, title, value, unit, smallbox, alarm, minimum, maximum)

    rf2status.isVisible = lcd.isVisible()
    rf2status.isDARKMODE = lcd.darkMode()
    local theme = rf2status.getThemeInfo()

    if rf2status.isDARKMODE then
        lcd.color(lcd.RGB(40, 40, 40))
    else
        lcd.color(lcd.RGB(240, 240, 240))
    end

    -- draw box backgrf2status.round	
    lcd.drawFilledRectangle(x, y, w, h)

    -- color	
    if rf2status.isDARKMODE then
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

        sx = (x + w / 2) - (tsizeW / 2)
        if smallbox == nil or smallbox == false then
            sy = (y + h / 2) - (tsizeH / 2)
        else
            if rf2status.maxminParam == false and rf2status.titleParam == false then
                sy = (y + h / 2) - (tsizeH / 2)
            else
                sy = (y + h / 2) - (tsizeH / 2) + theme.smallBoxSensortextOFFSET
            end
        end

        -- change text colour to suit alarm flag
        -- 0 = default colour
        -- 1 = red (alarm)
        -- 2 = orange (warning)
        -- 3 = green (ok)  
        if rf2status.statusColorParam == true then
            if alarm == 1 then 
                lcd.color(lcd.RGB(255, 0, 0, 1))   -- red
            elseif alarm == 2 then 
                lcd.color(lcd.RGB(255, 204, 0, 1)) -- orange
            elseif alarm == 3 then 
                lcd.color(lcd.RGB(0, 188, 4, 1))  -- green
            end
        else
            -- we only do red
            if alarm == 1 then 
                lcd.color(lcd.RGB(255, 0, 0, 1))   -- red
            end
        end

        lcd.drawText(sx, sy, str)
 
        -- reset text back from red to ensure max/min stay right color 
        if alarm ~= 0 then
            if rf2status.isDARKMODE then
                lcd.color(lcd.RGB(255, 255, 255, 1))
            else
                lcd.color(lcd.RGB(90, 90, 90))
            end
        end

    end

    if title ~= nil and rf2status.titleParam == true then
        lcd.font(theme.fontTITLE)
        str = title
        tsizeW, tsizeH = lcd.getTextSize(str)

        sx = (x + w / 2) - (tsizeW / 2)
        sy = (y + h) - (tsizeH) - theme.colSpacing

        lcd.drawText(sx, sy, str)
    end

    if rf2status.maxminParam == true then

        if minimum ~= nil then

            lcd.font(theme.fontTITLE)

            if tostring(minimum) ~= "-" then lastMin = minimum end

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
            sy = (y + h) - (tsizeH) - theme.colSpacing

            lcd.drawText(sx, sy, str)
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
            sy = (y + h) - (tsizeH) - theme.colSpacing

            lcd.drawText(sx, sy, str)
        end

    end

end

function rf2status.telemetryBoxMAX(x, y, w, h, title, value, unit, smallbox)

    rf2status.isVisible = lcd.isVisible()
    rf2status.isDARKMODE = lcd.darkMode()
    local theme = rf2status.getThemeInfo()

    if rf2status.isDARKMODE then
        lcd.color(lcd.RGB(40, 40, 40))
    else
        lcd.color(lcd.RGB(240, 240, 240))
    end

    -- draw box backgrf2status.round	
    lcd.drawFilledRectangle(x, y, w, h)

    -- color	
    if rf2status.isDARKMODE then
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

        sx = (x + w / 2) - (tsizeW / 2)
        if smallbox == nil or smallbox == false then
            sy = (y + h / 2) - (tsizeH / 2)
        else
            if rf2status.maxminParam == false and rf2status.titleParam == false then
                sy = (y + h / 2) - (tsizeH / 2)
            else
                sy = (y + h / 2) - (tsizeH / 2) + theme.smallBoxSensortextOFFSET
            end
        end

        lcd.drawText(sx, sy, str)

    end

    if title ~= nil and rf2status.titleParam == true then
        lcd.font(theme.fontTITLE)
        str = title
        tsizeW, tsizeH = lcd.getTextSize(str)

        sx = (x + w / 2) - (tsizeW / 2)
        sy = (y + h) - (tsizeH) - theme.colSpacing

        lcd.drawText(sx, sy, str)
    end

end

function rf2status.logsBOX()

    if rf2status.readLOGS == false then
        local history = rf2status.readHistory()
        rf2status.readLOGSlast = history
        rf2status.readLOGS = true
    else
        history = rf2status.readLOGSlast
    end

    local theme = rf2status.getThemeInfo()
    local w, h = lcd.getWindowSize()
    if w < 500 then
        boxW = w
    else
        boxW = w - math.floor((w * 2) / 100)
    end
    if h < 200 then
        boxH = h - 2
    else
        boxH = h - math.floor((h * 4) / 100)
    end

    -- draw the backgrf2status.round
    if rf2status.isDARKMODE then
        lcd.color(lcd.RGB(40, 40, 40, 50))
    else
        lcd.color(lcd.RGB(240, 240, 240, 50))
    end
    lcd.drawFilledRectangle(w / 2 - boxW / 2, h / 2 - boxH / 2, boxW, boxH)

    -- draw the border
    lcd.color(lcd.RGB(248, 176, 56))
    lcd.drawRectangle(w / 2 - boxW / 2, h / 2 - boxH / 2, boxW, boxH)

    -- draw the title
    lcd.color(lcd.RGB(248, 176, 56))
    lcd.drawFilledRectangle(w / 2 - boxW / 2, h / 2 - boxH / 2, boxW, boxH / 9)

    if rf2status.isDARKMODE then
        -- dark theme
        lcd.color(lcd.RGB(0, 0, 0, 1))
    else
        -- light theme
        lcd.color(lcd.RGB(255, 255, 255))
    end
    str = rf2status.i8n.LogHistory
    lcd.font(theme.fontPopupTitle)
    tsizeW, tsizeH = lcd.getTextSize(str)

    boxTh = boxH / 9
    boxTy = h / 2 - boxH / 2
    boxTx = w / 2 - boxW / 2
    lcd.drawText((w / 2) - tsizeW / 2, boxTy + (boxTh / 2) - tsizeH / 2, str)

    -- close button
    lcd.drawBitmap(boxTx + boxW - boxTh, boxTy, rf2status.gfx_close, boxTh, boxTh)
    rf2status.closeButtonX = math.floor(boxTx + boxW - boxTh)
    rf2status.closeButtonY = math.floor(boxTy) + theme.widgetTitleOffset
    rf2status.closeButtonW = math.floor(boxTh)
    rf2status.closeButtonH = math.floor(boxTh)

    lcd.color(lcd.RGB(255, 255, 255))

    --[[ header column format 
		TIME VOLTAGE AMPS RPM LQ MCU ESC
	]] --
    colW = boxW / 7

    col1x = boxTx
    col2x = boxTx + theme.logsCOL1w
    col3x = boxTx + theme.logsCOL1w + theme.logsCOL2w
    col4x = boxTx + theme.logsCOL1w + theme.logsCOL2w + theme.logsCOL3w
    col5x = boxTx + theme.logsCOL1w + theme.logsCOL2w + theme.logsCOL3w + theme.logsCOL4w
    col6x = boxTx + theme.logsCOL1w + theme.logsCOL2w + theme.logsCOL3w + theme.logsCOL4w + theme.logsCOL5w
    col7x = boxTx + theme.logsCOL1w + theme.logsCOL2w + theme.logsCOL3w + theme.logsCOL4w + theme.logsCOL5w + theme.logsCOL6w

    lcd.color(lcd.RGB(90, 90, 90))

    -- LINES
    lcd.drawLine(boxTx + boxTh / 2, boxTy + (boxTh * 2), boxTx + boxW - (boxTh / 2), boxTy + (boxTh * 2))

    lcd.drawLine(col2x, boxTy + boxTh + boxTh / 2, col2x, boxTy + boxH - (boxTh / 2))
    lcd.drawLine(col3x, boxTy + boxTh + boxTh / 2, col3x, boxTy + boxH - (boxTh / 2))
    lcd.drawLine(col4x, boxTy + boxTh + boxTh / 2, col4x, boxTy + boxH - (boxTh / 2))
    lcd.drawLine(col5x, boxTy + boxTh + boxTh / 2, col5x, boxTy + boxH - (boxTh / 2))
    lcd.drawLine(col6x, boxTy + boxTh + boxTh / 2, col6x, boxTy + boxH - (boxTh / 2))
    lcd.drawLine(col7x, boxTy + boxTh + boxTh / 2, col7x, boxTy + boxH - (boxTh / 2))

    -- HEADER text
    if rf2status.isDARKMODE then
        -- dark theme
        lcd.color(lcd.RGB(255, 255, 255, 1))
    else
        -- light theme
        lcd.color(lcd.RGB(0, 0, 0))
    end
    lcd.font(theme.fontPopupTitle)

    if theme.logsCOL1w ~= 0 then
        str = rf2status.i8n.TIME
        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText(col1x + (theme.logsCOL1w / 2) - (tsizeW / 2), theme.logsHeaderOffset + (boxTy + boxTh) + ((boxTh / 2) - (tsizeH / 2)), str)
    end

    if theme.logsCOL2w ~= 0 then
        str = rf2status.i8n.VOLTAGE
        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText((col2x) + (theme.logsCOL2w / 2) - (tsizeW / 2), theme.logsHeaderOffset + (boxTy + boxTh) + (boxTh / 2) - (tsizeH / 2), str)
    end

    if theme.logsCOL3w ~= 0 then
        str = rf2status.i8n.AMPS
        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText((col3x) + (theme.logsCOL3w / 2) - (tsizeW / 2), theme.logsHeaderOffset + (boxTy + boxTh) + (boxTh / 2) - (tsizeH / 2), str)
    end

    if theme.logsCOL4w ~= 0 then
        str = rf2status.i8n.RPM
        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText((col4x) + (theme.logsCOL4w / 2) - (tsizeW / 2), theme.logsHeaderOffset + (boxTy + boxTh) + (boxTh / 2) - (tsizeH / 2), str)
    end

    if theme.logsCOL5w ~= 0 then
        str = rf2status.i8n.LQ
        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText((col5x) + (theme.logsCOL5w / 2) - (tsizeW / 2), theme.logsHeaderOffset + (boxTy + boxTh) + (boxTh / 2) - (tsizeH / 2), str)
    end

    if theme.logsCOL6w ~= 0 then
        str = rf2status.i8n.MCU
        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText((col6x) + (theme.logsCOL6w / 2) - (tsizeW / 2), theme.logsHeaderOffset + (boxTy + boxTh) + (boxTh / 2) - (tsizeH / 2), str)
    end

    if theme.logsCOL7w ~= 0 then
        str = rf2status.i8n.ESC
        tsizeW, tsizeH = lcd.getTextSize(str)
        lcd.drawText((col7x) + (theme.logsCOL7w / 2) - (tsizeW / 2), theme.logsHeaderOffset + (boxTy + boxTh) + (boxTh / 2) - (tsizeH / 2), str)
    end

    c = 0

    if history ~= nil then
        for index, value in ipairs(history) do
            if value ~= nil then
                if value ~= "" and value ~= nil then
                    rowH = c * boxTh

                    local rowData = rf2status.explode(value, ",")

                    --[[ rowData is a csv string as follows
				
						rf2status.theTIME,rf2status.sensorVoltageMin,rf2status.sensorVoltageMax,rf2status.sensorFuelMin,rf2status.sensorFuelMax,
						rf2status.sensorRPMMin,rf2status.sensorRPMMax,rf2status.sensorCurrentMin,rf2status.sensorCurrentMax,rf2status.sensorRSSIMin,
						rf2status.sensorRSSIMax,rf2status.sensorTempMCUMin,rf2status.sensorTempMCUMax,rf2status.sensorTempESCMin,rf2status.sensorTempESCMax	
				]] --
                    -- loop of rowData and extract each value bases on idx
                    if rowData ~= nil then

                        for idx, snsr in pairs(rowData) do

                            snsr = snsr:gsub("%s+", "")

                            if snsr ~= nil and snsr ~= "" then
                                -- time
                                if idx == 1 and theme.logsCOL1w ~= 0 then
                                    str = rf2status.SecondsToClockAlt(snsr)
                                    tsizeW, tsizeH = lcd.getTextSize(str)
                                    lcd.drawText(col1x + (theme.logsCOL1w / 2) - (tsizeW / 2), boxTy + tsizeH / 2 + (boxTh * 2) + rowH, str)
                                end
                                -- voltagemin
                                if idx == 2 then vstr = snsr end
                                -- voltagemax
                                if idx == 3 and theme.logsCOL2w ~= 0 then
                                    str = rf2status.round(vstr / 100, 1) .. 'v / ' .. rf2status.round(snsr / 100, 1) .. 'v'
                                    tsizeW, tsizeH = lcd.getTextSize(str)
                                    lcd.drawText(col2x + (theme.logsCOL2w / 2) - (tsizeW / 2), boxTy + tsizeH / 2 + (boxTh * 2) + rowH, str)
                                end
                                -- fuelmin
                                if idx == 4 then local logFUELmin = snsr end
                                -- fuelmax
                                if idx == 5 then local logFUELmax = snsr end
                                -- rpmmin
                                if idx == 6 then rstr = snsr end
                                -- rpmmax
                                if idx == 7 and theme.logsCOL4w ~= 0 then
                                    str = rstr .. 'rpm / ' .. snsr .. 'rpm'
                                    tsizeW, tsizeH = lcd.getTextSize(str)
                                    lcd.drawText(col4x + (theme.logsCOL4w / 2) - (tsizeW / 2), boxTy + tsizeH / 2 + (boxTh * 2) + rowH, str)
                                end
                                -- currentmin
                                if idx == 8 then cstr = snsr end
                                -- currentmax
                                if idx == 9 and theme.logsCOL3w ~= 0 then
                                    str = math.floor(cstr / 10) .. 'A / ' .. math.floor(snsr / 10) .. 'A'
                                    tsizeW, tsizeH = lcd.getTextSize(str)
                                    lcd.drawText(col3x + (theme.logsCOL3w / 2) - (tsizeW / 2), boxTy + tsizeH / 2 + (boxTh * 2) + rowH, str)
                                end
                                -- rssimin
                                if idx == 10 then lqstr = snsr end
                                -- rssimax
                                if idx == 11 and theme.logsCOL5w ~= 0 then
                                    str = lqstr .. '% / ' .. snsr .. '%'
                                    tsizeW, tsizeH = lcd.getTextSize(str)
                                    lcd.drawText(col5x + (theme.logsCOL5w / 2) - (tsizeW / 2), boxTy + tsizeH / 2 + (boxTh * 2) + rowH, str)
                                end
                                -- mcumin
                                if idx == 12 then mcustr = snsr end
                                -- mcumax
                                if idx == 13 and theme.logsCOL6w ~= 0 then
                                    str = rf2status.round(mcustr / 100, 0) .. '° / ' .. rf2status.round(snsr / 100, 0) .. '°'
                                    strf = rf2status.round(mcustr / 100, 0) .. '. / ' .. rf2status.round(snsr / 100, 0) .. '.'
                                    tsizeW, tsizeH = lcd.getTextSize(strf)
                                    lcd.drawText(col6x + (theme.logsCOL6w / 2) - (tsizeW / 2), boxTy + tsizeH / 2 + (boxTh * 2) + rowH, str)
                                end
                                -- escmin
                                if idx == 14 then escstr = snsr end
                                -- escmax
                                if idx == 15 and theme.logsCOL7w ~= 0 then
                                    str = rf2status.round(escstr / 100, 0) .. '° / ' .. rf2status.round(snsr / 100, 0) .. '°'
                                    strf = rf2status.round(escstr / 100, 0) .. '. / ' .. rf2status.round(snsr / 100, 0) .. '.'
                                    tsizeW, tsizeH = lcd.getTextSize(strf)
                                    lcd.drawText(col7x + (theme.logsCOL7w / 2) - (tsizeW / 2), boxTy + tsizeH / 2 + (boxTh * 2) + rowH, str)
                                end
                            end
                            -- end loop of each storage line		
                        end
                        c = c + 1

                        if h < 200 then
                            if c > 5 then break end
                        else
                            if c > 7 then break end
                        end
                        -- end of each log storage slot
                    end
                end
            end
        end
    end

    -- lcd.drawText((w / 2) - tsizeW / 2, (h / 2) - tsizeH / 2, str)
    return
end

function rf2status.telemetryBoxImage(x, y, w, h, gfx)

    rf2status.isVisible = lcd.isVisible()
    rf2status.isDARKMODE = lcd.darkMode()
    local theme = rf2status.getThemeInfo()

    if rf2status.isDARKMODE then
        lcd.color(lcd.RGB(40, 40, 40))
    else
        lcd.color(lcd.RGB(240, 240, 240))
    end

    -- draw box backgrf2status.round	
    lcd.drawFilledRectangle(x, y, w, h)

    lcd.drawBitmap(x, y, gfx, w - theme.colSpacing, h - theme.colSpacing)

end

function rf2status.paint(widget)

    rf2status.isVisible = lcd.isVisible()
    rf2status.isDARKMODE = lcd.darkMode()

    rf2status.isInConfiguration = false

    local cellVoltage
    -- voltage detection
    if rf2status.btypeParam ~= nil then
        if rf2status.btypeParam == 0 then
            -- LiPo
            cellVoltage = 3.6
        elseif rf2status.btypeParam == 1 then
            -- LiHv
            cellVoltage = 3.6
        elseif rf2status.btypeParam == 2 then
            -- Lion
            cellVoltage = 3
        elseif rf2status.btypeParam == 3 then
            -- LiFe
            cellVoltage = 2.9
        elseif rf2status.btypeParam == 4 then
            -- NiMh
            cellVoltage = 1.1
        else
            -- LiPo (default)
            cellVoltage = 3.6
        end

        if rf2status.sensors.voltage ~= nil then
            -- we use rf2status.lowvoltagsenseParam is use to raise or lower sensitivity
            if rf2status.lowvoltagsenseParam == 1 then
                zippo = 0.2
            elseif rf2status.lowvoltagsenseParam == 2 then
                zippo = 0.1
            else
                zippo = 0
            end
            --low
            if rf2status.sensors.voltage / 100 < ((cellVoltage * rf2status.cellsParam) + zippo) then
                rf2status.voltageIsLow = true
            else
                rf2status.voltageIsLow = false
            end
            --getting low
            if rf2status.sensors.voltage / 100 < (((cellVoltage + 0.2) * rf2status.cellsParam) + zippo) then
                rf2status.voltageIsGettingLow = true
            else
                rf2status.voltageIsGettingLow = false
            end
        else
            rf2status.voltageIsLow = false
            rf2status.voltageIsGettingLow = false
        end
    end

    -- fuel detection
    if rf2status.sensors.voltage ~= nil then
        if rf2status.sensors.fuel < rf2status.lowfuelParam then
            rf2status.fuelIsLow = true
        else
            rf2status.fuelIsLow = false
        end
    else
        rf2status.fuelIsLow = false
    end

    -- fuel detection
    if rf2status.sensors.voltage ~= nil then

        if rf2status.sensors.fuel < (rf2status.lowfuelParam + (rf2status.lowfuelParam * 20)/100) then
            rf2status.fuelIsGettingLow = true
        else
            rf2status.fuelIsGettingLow = false
        end
    else
        rf2status.fuelIsGettingLow = false
    end

    -- -----------------------------------------------------------------------------------------------
    -- write values to boxes
    -- -----------------------------------------------------------------------------------------------

    local theme = rf2status.getThemeInfo()
    local w, h = lcd.getWindowSize()

    if rf2status.isVisible then
        -- blank out display
        if rf2status.isDARKMODE then
            -- dark theme
            lcd.color(lcd.RGB(16, 16, 16))
        else
            -- light theme
            lcd.color(lcd.RGB(209, 208, 208))
        end
        lcd.drawFilledRectangle(0, 0, w, h)

        -- hard error
        if theme.supportedRADIO ~= true then
            rf2status.screenError(rf2status.i8n.UNKNOWN .. " " .. environment.board)
            return
        end

        -- widget size
        if environment.board == "V20" or environment.board == "XES" or environment.board == "X20" or environment.board == "X20S" or environment.board == "X20PRO" or environment.board == "X20PROAW" then
            if w ~= 784 and h ~= 294 then
                rf2status.screenError(rf2status.i8n.DISPLAYSIZEINVALID)
                return
            end
        end
        if environment.board == "X18" or environment.board == "X18S" then
            smallTEXT = true
            if w ~= 472 and h ~= 191 then
                rf2status.screenError(rf2status.i8n.DISPLAYSIZEINVALID)
                return
            end
        end
        if environment.board == "X14" or environment.board == "X14S" then
            if w ~= 630 and h ~= 236 then
                rf2status.screenError(rf2status.i8n.DISPLAYSIZEINVALID)
                return
            end
        end
        if environment.board == "TWXLITE" or environment.board == "TWXLITES" then
            if w ~= 472 and h ~= 191 then
                rf2status.screenError(rf2status.i8n.DISPLAYSIZEINVALID)
                return
            end
        end
        if environment.board == "X10EXPRESS" or environment.board == "X10" or environment.board == "X10S" or environment.board == "X12" or environment.board == "X12S" then
            if w ~= 472 and h ~= 158 then
                rf2status.screenError(rf2status.i8n.DISPLAYSIZEINVALID)
                return
            end
        end

        boxW = theme.fullBoxW - theme.colSpacing
        boxH = theme.fullBoxH - theme.colSpacing

        boxHs = theme.fullBoxH / 2 - theme.colSpacing
        boxWs = theme.fullBoxW / 2 - theme.colSpacing

        -- FUEL
        if rf2status.sensors.fuel ~= nil then

            sensorWARN = 3
            if rf2status.fuelIsGettingLow then sensorWARN = 2 end
            if rf2status.fuelIsLow then sensorWARN = 1 end
            

            sensorVALUE = rf2status.sensors.fuel

            if rf2status.sensors.fuel < 5 then sensorVALUE = "0" end

            if rf2status.titleParam == true then
                sensorTITLE = "FUEL"
            else
                sensorTITLE = ""
            end

            if rf2status.sensorFuelMin == 0 or rf2status.sensorFuelMin == nil or rf2status.theTIME == 0 then
                sensorMIN = "-"
            else
                sensorMIN = rf2status.sensorFuelMin
            end

            if rf2status.sensorFuelMax == 0 or rf2status.sensorFuelMax == nil or rf2status.theTIME == 0 then
                sensorMAX = "-"
            else
                sensorMAX = rf2status.sensorFuelMax
            end

            sensorUNIT = "%"

            local sensorTGT = 'fuel'
            rf2status.sensordisplay[sensorTGT] = {}
            rf2status.sensordisplay[sensorTGT]['title'] = sensorTITLE
            rf2status.sensordisplay[sensorTGT]['value'] = sensorVALUE
            rf2status.sensordisplay[sensorTGT]['warn'] = sensorWARN
            rf2status.sensordisplay[sensorTGT]['min'] = sensorMIN
            rf2status.sensordisplay[sensorTGT]['max'] = sensorMAX
            rf2status.sensordisplay[sensorTGT]['unit'] = sensorUNIT

        end

        -- RPM
        if rf2status.sensors.rpm ~= nil then

            sensorVALUE = rf2status.sensors.rpm

            if rf2status.sensors.rpm < 5 then sensorVALUE = 0 end

            if rf2status.titleParam == true then
                sensorTITLE = theme.title_rpm
            else
                sensorTITLE = ""
            end

            if rf2status.sensorRPMMin == 0 or rf2status.sensorRPMMin == nil or rf2status.theTIME == 0 then
                sensorMIN = "-"
            else
                sensorMIN = rf2status.sensorRPMMin
            end

            if rf2status.sensorRPMMax == 0 or rf2status.sensorRPMMax == nil or rf2status.theTIME == 0 then
                sensorMAX = "-"
            else
                sensorMAX = rf2status.sensorRPMMax
            end

            sensorUNIT = "rpm"
            sensorWARN = 0

            local sensorTGT = 'rpm'
            rf2status.sensordisplay[sensorTGT] = {}
            rf2status.sensordisplay[sensorTGT]['title'] = sensorTITLE
            rf2status.sensordisplay[sensorTGT]['value'] = sensorVALUE
            rf2status.sensordisplay[sensorTGT]['warn'] = sensorWARN
            rf2status.sensordisplay[sensorTGT]['min'] = sensorMIN
            rf2status.sensordisplay[sensorTGT]['max'] = sensorMAX
            rf2status.sensordisplay[sensorTGT]['unit'] = sensorUNIT

        end

        -- VOLTAGE
        if rf2status.sensors.voltage ~= nil then

            sensorWARN = 3
            if rf2status.voltageIsGettingLow then sensorWARN = 2 end
            if rf2status.voltageIsLow then sensorWARN = 1 end

            sensorVALUE = rf2status.sensors.voltage / 100

            if sensorVALUE < 1 then sensorVALUE = 0 end

            if rf2status.titleParam == true then
                sensorTITLE = theme.title_voltage
            else
                sensorTITLE = ""
            end

            if rf2status.sensorVoltageMin == 0 or rf2status.sensorVoltageMin == nil or rf2status.theTIME == 0 then
                sensorMIN = "-"
            else
                sensorMIN = rf2status.sensorVoltageMin / 100
            end

            if rf2status.sensorVoltageMax == 0 or rf2status.sensorVoltageMax == nil or rf2status.theTIME == 0 then
                sensorMAX = "-"
            else
                sensorMAX = rf2status.sensorVoltageMax / 100
            end

            sensorUNIT = "v"

            local sensorTGT = 'voltage'
            rf2status.sensordisplay[sensorTGT] = {}
            rf2status.sensordisplay[sensorTGT]['title'] = sensorTITLE
            rf2status.sensordisplay[sensorTGT]['value'] = sensorVALUE
            rf2status.sensordisplay[sensorTGT]['warn'] = sensorWARN
            rf2status.sensordisplay[sensorTGT]['min'] = sensorMIN
            rf2status.sensordisplay[sensorTGT]['max'] = sensorMAX
            rf2status.sensordisplay[sensorTGT]['unit'] = sensorUNIT

        end

        -- CURRENT
        if rf2status.sensors.current ~= nil then

            sensorVALUE = rf2status.sensors.current / 10
            if rf2status.linkUP == 0 then
                sensorVALUE = 0
            else
                if sensorVALUE == 0 then
                    local fakeC
                    if rf2status.sensors.rpm > 5 then
                        fakeC = 1
                    elseif rf2status.sensors.rpm > 50 then
                        fakeC = 2
                    elseif rf2status.sensors.rpm > 100 then
                        fakeC = 3
                    elseif rf2status.sensors.rpm > 200 then
                        fakeC = 4
                    elseif rf2status.sensors.rpm > 500 then
                        fakeC = 5
                    elseif rf2status.sensors.rpm > 1000 then
                        fakeC = 6
                    else
                        if rf2status.sensors.voltage > 0 then
                            fakeC = math.random(1, 3) / 10
                        else
                            fakeC = 0
                        end
                    end
                    sensorVALUE = fakeC
                end
            end

            if rf2status.titleParam == true then
                sensorTITLE = theme.title_current
            else
                sensorTITLE = ""
            end

            if rf2status.sensorCurrentMin == 0 or rf2status.sensorCurrentMin == nil or rf2status.theTIME == 0 then
                sensorMIN = "-"
            else
                sensorMIN = rf2status.sensorCurrentMin / 10
            end

            if rf2status.sensorCurrentMax == 0 or rf2status.sensorCurrentMax == nil or rf2status.theTIME == 0 then
                sensorMAX = "-"
            else
                sensorMAX = rf2status.sensorCurrentMax / 10
            end

            sensorUNIT = "A"
            sensorWARN = 0

            local sensorTGT = 'current'
            rf2status.sensordisplay[sensorTGT] = {}
            rf2status.sensordisplay[sensorTGT]['title'] = sensorTITLE
            rf2status.sensordisplay[sensorTGT]['value'] = sensorVALUE
            rf2status.sensordisplay[sensorTGT]['warn'] = sensorWARN
            rf2status.sensordisplay[sensorTGT]['min'] = sensorMIN
            rf2status.sensordisplay[sensorTGT]['max'] = sensorMAX
            rf2status.sensordisplay[sensorTGT]['unit'] = sensorUNIT

        end

        -- TEMP ESC
        if rf2status.sensors.temp_esc ~= nil then

            sensorVALUE = rf2status.round(rf2status.sensors.temp_esc / 100, 0)

            if sensorVALUE < 1 then sensorVALUE = 0 end

            if rf2status.titleParam == true then
                sensorTITLE = theme.title_tempESC
            else
                sensorTITLE = ""
            end

            if rf2status.sensorTempESCMin == 0 or rf2status.sensorTempESCMin == nil or rf2status.theTIME == 0 then
                sensorMIN = "-"
            else
                sensorMIN = rf2status.round(rf2status.sensorTempESCMin / 100, 0)
            end

            if rf2status.sensorTempESCMax == 0 or rf2status.sensorTempESCMax == nil or rf2status.theTIME == 0 then
                sensorMAX = "-"
            else
                sensorMAX = rf2status.round(rf2status.sensorTempESCMax / 100, 0)
            end

            sensorUNIT = "°"
            sensorWARN = 0

            local sensorTGT = 'temp_esc'
            rf2status.sensordisplay[sensorTGT] = {}
            rf2status.sensordisplay[sensorTGT]['title'] = sensorTITLE
            rf2status.sensordisplay[sensorTGT]['value'] = sensorVALUE
            rf2status.sensordisplay[sensorTGT]['warn'] = sensorWARN
            rf2status.sensordisplay[sensorTGT]['min'] = sensorMIN
            rf2status.sensordisplay[sensorTGT]['max'] = sensorMAX
            rf2status.sensordisplay[sensorTGT]['unit'] = sensorUNIT

        end

        -- TEMP MCU
        if rf2status.sensors.temp_mcu ~= nil then

            sensorVALUE = rf2status.round(rf2status.sensors.temp_mcu / 100, 0)

            if sensorVALUE < 1 then sensorVALUE = 0 end

            if rf2status.titleParam == true then
                sensorTITLE = theme.title_tempMCU
            else
                sensorTITLE = ""
            end

            if rf2status.sensorTempMCUMin == 0 or rf2status.sensorTempMCUMin == nil or rf2status.theTIME == 0 then
                sensorMIN = "-"
            else
                sensorMIN = rf2status.round(rf2status.sensorTempMCUMin / 100, 0)
            end

            if rf2status.sensorTempMCUMax == 0 or rf2status.sensorTempMCUMax == nil or rf2status.theTIME == 0 then
                sensorMAX = "-"
            else
                sensorMAX = rf2status.round(rf2status.sensorTempMCUMax / 100, 0)
            end

            sensorUNIT = "°"
            sensorWARN = 0

            local sensorTGT = 'temp_mcu'
            rf2status.sensordisplay[sensorTGT] = {}
            rf2status.sensordisplay[sensorTGT]['title'] = sensorTITLE
            rf2status.sensordisplay[sensorTGT]['value'] = sensorVALUE
            rf2status.sensordisplay[sensorTGT]['warn'] = sensorWARN
            rf2status.sensordisplay[sensorTGT]['min'] = sensorMIN
            rf2status.sensordisplay[sensorTGT]['max'] = sensorMAX
            rf2status.sensordisplay[sensorTGT]['unit'] = sensorUNIT

        end

        -- RSSI
        if rf2status.sensors.rssi ~= nil and (rf2status.quadBoxParam == 0 or rf2status.quadBoxParam == 1) then

            sensorVALUE = rf2status.sensors.rssi

            if sensorVALUE < 1 then sensorVALUE = 0 end

            if rf2status.titleParam == true then
                sensorTITLE = theme.title_rssi
            else
                sensorTITLE = ""
            end

            if rf2status.sensorRSSIMin == 0 or rf2status.sensorRSSIMin == nil then
                sensorMIN = "-"
            else
                sensorMIN = rf2status.sensorRSSIMin
            end

            if rf2status.sensorRSSIMax == 0 or rf2status.sensorRSSIMax == nil then
                sensorMAX = "-"
            else
                sensorMAX = rf2status.sensorRSSIMax
            end

            sensorUNIT = "%"
            sensorWARN = 0

            local sensorTGT = 'rssi'
            rf2status.sensordisplay[sensorTGT] = {}
            rf2status.sensordisplay[sensorTGT]['title'] = sensorTITLE
            rf2status.sensordisplay[sensorTGT]['value'] = sensorVALUE
            rf2status.sensordisplay[sensorTGT]['warn'] = sensorWARN
            rf2status.sensordisplay[sensorTGT]['min'] = sensorMIN
            rf2status.sensordisplay[sensorTGT]['max'] = sensorMAX
            rf2status.sensordisplay[sensorTGT]['unit'] = sensorUNIT

        end

        -- mah
        if rf2status.sensors.mah ~= nil then

            sensorVALUE = rf2status.sensors.mah

            if sensorVALUE < 1 then sensorVALUE = 0 end

            if rf2status.titleParam == true then
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
            sensorWARN = 0

            local sensorTGT = 'mah'
            rf2status.sensordisplay[sensorTGT] = {}
            rf2status.sensordisplay[sensorTGT]['title'] = sensorTITLE
            rf2status.sensordisplay[sensorTGT]['value'] = sensorVALUE
            rf2status.sensordisplay[sensorTGT]['warn'] = sensorWARN
            rf2status.sensordisplay[sensorTGT]['min'] = sensorMIN
            rf2status.sensordisplay[sensorTGT]['max'] = sensorMAX
            rf2status.sensordisplay[sensorTGT]['unit'] = sensorUNIT
        end

        -- TIMER
        sensorMIN = nil
        sensorMAX = nil

        if rf2status.theTIME ~= nil or rf2status.theTIME == 0 then
            str = rf2status.SecondsToClock(rf2status.theTIME)
        else
            str = "00:00:00"
        end

        if rf2status.titleParam == true then
            sensorTITLE = theme.title_time
        else
            sensorTITLE = ""
        end

        sensorVALUE = str

        sensorUNIT = ""
        sensorWARN = 0

        local sensorTGT = 'timer'
        rf2status.sensordisplay[sensorTGT] = {}
        rf2status.sensordisplay[sensorTGT]['title'] = sensorTITLE
        rf2status.sensordisplay[sensorTGT]['value'] = sensorVALUE
        rf2status.sensordisplay[sensorTGT]['warn'] = sensorWARN
        rf2status.sensordisplay[sensorTGT]['min'] = sensorMIN
        rf2status.sensordisplay[sensorTGT]['max'] = sensorMAX
        rf2status.sensordisplay[sensorTGT]['unit'] = sensorUNIT

        -- GOV MODE
        if rf2status.govmodeParam == 0 then
            if rf2status.sensors.govmode == nil then rf2status.sensors.govmode = "INIT" end
            str = rf2status.sensors.govmode
            sensorTITLE = theme.title_governor
        else
            str = rf2status.sensors.fm
            sensorTITLE = theme.title_fm
        end
        sensorVALUE = str

        if rf2status.titleParam ~= true then sensorTITLE = "" end

        sensorUNIT = ""
        sensorWARN = 0
        sensorMIN = nil
        sensorMAX = nil

        local sensorTGT = 'governor'
        rf2status.sensordisplay[sensorTGT] = {}
        rf2status.sensordisplay[sensorTGT]['title'] = sensorTITLE
        rf2status.sensordisplay[sensorTGT]['value'] = sensorVALUE
        rf2status.sensordisplay[sensorTGT]['warn'] = rf2status.govColorFlag(sensorVALUE)
        rf2status.sensordisplay[sensorTGT]['min'] = sensorMIN
        rf2status.sensordisplay[sensorTGT]['max'] = sensorMAX
        rf2status.sensordisplay[sensorTGT]['unit'] = sensorUNIT

        -- loop throught 6 box and link into rf2status.sensordisplay to choose where to put things
        local c = 1
        while c <= 6 do

            -- reset all values
            sensorVALUE = nil
            sensorUNIT = nil
            sensorMIN = nil
            sensorMAX = nil
            sensorWARN = 0
            sensorTITLE = nil
            sensorTGT = nil
            smallBOX = false

            -- column positions and tgt
            if c == 1 then
                posX = 0
                posY = theme.colSpacing
                sensorTGT = rf2status.layoutBox1Param
            end
            if c == 2 then
                posX = 0 + theme.colSpacing + boxW
                posY = theme.colSpacing
                sensorTGT = rf2status.layoutBox2Param
            end
            if c == 3 then
                posX = 0 + theme.colSpacing + boxW + theme.colSpacing + boxW
                posY = theme.colSpacing
                sensorTGT = rf2status.layoutBox3Param
            end
            if c == 4 then
                posX = 0
                posY = theme.colSpacing + boxH + theme.colSpacing
                sensorTGT = rf2status.layoutBox4Param
            end
            if c == 5 then
                posX = 0 + theme.colSpacing + boxW
                posY = theme.colSpacing + boxH + theme.colSpacing
                sensorTGT = rf2status.layoutBox5Param
            end
            if c == 6 then
                posX = 0 + theme.colSpacing + boxW + theme.colSpacing + boxW
                posY = theme.colSpacing + boxH + theme.colSpacing
                sensorTGT = rf2status.layoutBox6Param
            end

            -- remap sensorTGT
            if sensorTGT == 1 then sensorTGT = 'timer' end
            if sensorTGT == 2 then sensorTGT = 'voltage' end
            if sensorTGT == 3 then sensorTGT = 'fuel' end
            if sensorTGT == 4 then sensorTGT = 'current' end
            if sensorTGT == 17 then sensorTGT = 'mah' end
            if sensorTGT == 5 then sensorTGT = 'rpm' end
            if sensorTGT == 6 then sensorTGT = 'rssi' end
            if sensorTGT == 7 then sensorTGT = 'temp_esc' end
            if sensorTGT == 8 then sensorTGT = 'temp_mcu' end
            if sensorTGT == 9 then sensorTGT = 'image' end
            if sensorTGT == 10 then sensorTGT = 'governor' end
            if sensorTGT == 11 then sensorTGT = 'image__gov' end
            if sensorTGT == 12 then sensorTGT = 'rssi__timer' end
            if sensorTGT == 13 then sensorTGT = 'temp_esc__temp_mcu' end
            if sensorTGT == 14 then sensorTGT = 'voltage__fuel' end
            if sensorTGT == 15 then sensorTGT = 'voltage__current' end
            if sensorTGT == 16 then sensorTGT = 'voltage__mah' end
            if sensorTGT == 20 then sensorTGT = 'rssi_timer_temp_esc_temp_mcu' end
            if sensorTGT == 21 then sensorTGT = 'max_current' end
            if sensorTGT == 22 then sensorTGT = 'lq__gov' end

            -- set sensor values based on sensorTGT
            if rf2status.sensordisplay[sensorTGT] ~= nil then
                -- all std values.  =
                sensorVALUE = rf2status.sensordisplay[sensorTGT]['value']
                sensorUNIT = rf2status.sensordisplay[sensorTGT]['unit']
                sensorMIN = rf2status.sensordisplay[sensorTGT]['min']
                sensorMAX = rf2status.sensordisplay[sensorTGT]['max']
                sensorWARN = rf2status.sensordisplay[sensorTGT]['warn']
                sensorTITLE = rf2status.sensordisplay[sensorTGT]['title']
                rf2status.telemetryBox(posX, posY, boxW, boxH, sensorTITLE, sensorVALUE, sensorUNIT, smallBOX, sensorWARN, sensorMIN, sensorMAX)
            else

                if sensorTGT == 'image' then
                    -- IMAGE
                    if rf2status.gfx_model ~= nil then
                        rf2status.telemetryBoxImage(posX, posY, boxW, boxH, rf2status.gfx_model)
                    else
                        rf2status.telemetryBoxImage(posX, posY, boxW, boxH, rf2status.gfx_heli)
                    end
                end

                if sensorTGT == 'image__gov' then
                    -- IMAGE + GOVERNOR
                    if rf2status.gfx_model ~= nil then
                        rf2status.telemetryBoxImage(posX, posY, boxW, boxH / 2 - (theme.colSpacing / 2), rf2status.gfx_model)
                    else
                        rf2status.telemetryBoxImage(posX, posY, boxW, boxH / 2 - (theme.colSpacing / 2), rf2status.gfx_heli)
                    end

                    sensorTGT = "governor"
                    sensorVALUE = rf2status.sensordisplay[sensorTGT]['value']
                    sensorUNIT = rf2status.sensordisplay[sensorTGT]['unit']
                    sensorMIN = rf2status.sensordisplay[sensorTGT]['min']
                    sensorMAX = rf2status.sensordisplay[sensorTGT]['max']
                    sensorWARN = rf2status.sensordisplay[sensorTGT]['warn']
                    sensorTITLE = rf2status.sensordisplay[sensorTGT]['title']

                    smallBOX = true
                    rf2status.telemetryBox(posX, posY + boxH / 2 + (theme.colSpacing / 2), boxW, boxH / 2 - theme.colSpacing / 2, sensorTITLE, sensorVALUE, sensorUNIT, smallBOX, sensorWARN, sensorMIN,
                                           sensorMAX)

                end

                if sensorTGT == 'lq__gov' then
                    -- LQ + GOV
                    sensorTGT = "rssi"
                    sensorVALUE = rf2status.sensordisplay[sensorTGT]['value']
                    sensorUNIT = rf2status.sensordisplay[sensorTGT]['unit']
                    sensorMIN = rf2status.sensordisplay[sensorTGT]['min']
                    sensorMAX = rf2status.sensordisplay[sensorTGT]['max']
                    sensorWARN = rf2status.sensordisplay[sensorTGT]['warn']
                    sensorTITLE = rf2status.sensordisplay[sensorTGT]['title']

                    smallBOX = true
                    rf2status.telemetryBox(posX, posY, boxW, boxH / 2 - (theme.colSpacing / 2), sensorTITLE, sensorVALUE, sensorUNIT, smallBOX, sensorWARN, sensorMIN, sensorMAX)

                    sensorTGT = "governor"
                    sensorVALUE = rf2status.sensordisplay[sensorTGT]['value']
                    sensorUNIT = rf2status.sensordisplay[sensorTGT]['unit']
                    sensorMIN = rf2status.sensordisplay[sensorTGT]['min']
                    sensorMAX = rf2status.sensordisplay[sensorTGT]['max']
                    sensorWARN = rf2status.sensordisplay[sensorTGT]['warn']
                    sensorTITLE = rf2status.sensordisplay[sensorTGT]['title']

                    smallBOX = true
                    rf2status.telemetryBox(posX, posY + boxH / 2 + (theme.colSpacing / 2), boxW, boxH / 2 - theme.colSpacing / 2, sensorTITLE, sensorVALUE, sensorUNIT, smallBOX, sensorWARN, sensorMIN,
                                           sensorMAX)

                end

                if sensorTGT == 'rssi__timer' then

                    sensorTGT = "rssi"
                    if rf2status.sensordisplay[sensorTGT] ~= nil then
                        sensorVALUE = rf2status.sensordisplay[sensorTGT]['value']
                        sensorUNIT = rf2status.sensordisplay[sensorTGT]['unit']
                        sensorMIN = rf2status.sensordisplay[sensorTGT]['min']
                        sensorMAX = rf2status.sensordisplay[sensorTGT]['max']
                        sensorWARN = rf2status.sensordisplay[sensorTGT]['warn']
                        sensorTITLE = rf2status.sensordisplay[sensorTGT]['title']

                        smallBOX = true
                        rf2status.telemetryBox(posX, posY, boxW, boxH / 2 - (theme.colSpacing / 2), sensorTITLE, sensorVALUE, sensorUNIT, smallBOX, sensorWARN, sensorMIN, sensorMAX)
                    end

                    sensorTGT = "timer"
                    sensorVALUE = rf2status.sensordisplay[sensorTGT]['value']
                    sensorUNIT = rf2status.sensordisplay[sensorTGT]['unit']
                    sensorMIN = rf2status.sensordisplay[sensorTGT]['min']
                    sensorMAX = rf2status.sensordisplay[sensorTGT]['max']
                    sensorWARN = rf2status.sensordisplay[sensorTGT]['warn']
                    sensorTITLE = rf2status.sensordisplay[sensorTGT]['title']

                    smallBOX = true
                    rf2status.telemetryBox(posX, posY + boxH / 2 + (theme.colSpacing / 2), boxW, boxH / 2 - theme.colSpacing / 2, sensorTITLE, sensorVALUE, sensorUNIT, smallBOX, sensorWARN, sensorMIN,
                                           sensorMAX)

                end

                if sensorTGT == 'temp_esc__temp_mcu' then

                    sensorTGT = "temp_esc"
                    sensorVALUE = rf2status.sensordisplay[sensorTGT]['value']
                    sensorUNIT = rf2status.sensordisplay[sensorTGT]['unit']
                    sensorMIN = rf2status.sensordisplay[sensorTGT]['min']
                    sensorMAX = rf2status.sensordisplay[sensorTGT]['max']
                    sensorWARN = rf2status.sensordisplay[sensorTGT]['warn']
                    sensorTITLE = rf2status.sensordisplay[sensorTGT]['title']

                    smallBOX = true
                    rf2status.telemetryBox(posX, posY, boxW, boxH / 2 - (theme.colSpacing / 2), sensorTITLE, sensorVALUE, sensorUNIT, smallBOX, sensorWARN, sensorMIN, sensorMAX)

                    sensorTGT = "temp_mcu"
                    sensorVALUE = rf2status.sensordisplay[sensorTGT]['value']
                    sensorUNIT = rf2status.sensordisplay[sensorTGT]['unit']
                    sensorMIN = rf2status.sensordisplay[sensorTGT]['min']
                    sensorMAX = rf2status.sensordisplay[sensorTGT]['max']
                    sensorWARN = rf2status.sensordisplay[sensorTGT]['warn']
                    sensorTITLE = rf2status.sensordisplay[sensorTGT]['title']

                    smallBOX = true
                    rf2status.telemetryBox(posX, posY + boxH / 2 + (theme.colSpacing / 2), boxW, boxH / 2 - theme.colSpacing / 2, sensorTITLE, sensorVALUE, sensorUNIT, smallBOX, sensorWARN, sensorMIN,
                                           sensorMAX)

                end

                if sensorTGT == 'voltage__fuel' then

                    sensorTGT = "voltage"
                    sensorVALUE = rf2status.sensordisplay[sensorTGT]['value']
                    sensorUNIT = rf2status.sensordisplay[sensorTGT]['unit']
                    sensorMIN = rf2status.sensordisplay[sensorTGT]['min']
                    sensorMAX = rf2status.sensordisplay[sensorTGT]['max']
                    sensorWARN = rf2status.sensordisplay[sensorTGT]['warn']
                    sensorTITLE = rf2status.sensordisplay[sensorTGT]['title']

                    smallBOX = true
                    rf2status.telemetryBox(posX, posY, boxW, boxH / 2 - (theme.colSpacing / 2), sensorTITLE, sensorVALUE, sensorUNIT, smallBOX, sensorWARN, sensorMIN, sensorMAX)

                    sensorTGT = "fuel"
                    sensorVALUE = rf2status.sensordisplay[sensorTGT]['value']
                    sensorUNIT = rf2status.sensordisplay[sensorTGT]['unit']
                    sensorMIN = rf2status.sensordisplay[sensorTGT]['min']
                    sensorMAX = rf2status.sensordisplay[sensorTGT]['max']
                    sensorWARN = rf2status.sensordisplay[sensorTGT]['warn']
                    sensorTITLE = rf2status.sensordisplay[sensorTGT]['title']

                    smallBOX = true
                    rf2status.telemetryBox(posX, posY + boxH / 2 + (theme.colSpacing / 2), boxW, boxH / 2 - theme.colSpacing / 2, sensorTITLE, sensorVALUE, sensorUNIT, smallBOX, sensorWARN, sensorMIN,
                                           sensorMAX)

                end

                if sensorTGT == 'voltage__current' then

                    sensorTGT = "voltage"
                    sensorVALUE = rf2status.sensordisplay[sensorTGT]['value']
                    sensorUNIT = rf2status.sensordisplay[sensorTGT]['unit']
                    sensorMIN = rf2status.sensordisplay[sensorTGT]['min']
                    sensorMAX = rf2status.sensordisplay[sensorTGT]['max']
                    sensorWARN = rf2status.sensordisplay[sensorTGT]['warn']
                    sensorTITLE = rf2status.sensordisplay[sensorTGT]['title']

                    smallBOX = true
                    rf2status.telemetryBox(posX, posY, boxW, boxH / 2 - (theme.colSpacing / 2), sensorTITLE, sensorVALUE, sensorUNIT, smallBOX, sensorWARN, sensorMIN, sensorMAX)

                    sensorTGT = "current"
                    sensorVALUE = rf2status.sensordisplay[sensorTGT]['value']
                    sensorUNIT = rf2status.sensordisplay[sensorTGT]['unit']
                    sensorMIN = rf2status.sensordisplay[sensorTGT]['min']
                    sensorMAX = rf2status.sensordisplay[sensorTGT]['max']
                    sensorWARN = rf2status.sensordisplay[sensorTGT]['warn']
                    sensorTITLE = rf2status.sensordisplay[sensorTGT]['title']

                    smallBOX = true
                    rf2status.telemetryBox(posX, posY + boxH / 2 + (theme.colSpacing / 2), boxW, boxH / 2 - theme.colSpacing / 2, sensorTITLE, sensorVALUE, sensorUNIT, smallBOX, sensorWARN, sensorMIN,
                                           sensorMAX)

                end

                if sensorTGT == 'voltage__mah' then

                    sensorTGT = "voltage"
                    sensorVALUE = rf2status.sensordisplay[sensorTGT]['value']
                    sensorUNIT = rf2status.sensordisplay[sensorTGT]['unit']
                    sensorMIN = rf2status.sensordisplay[sensorTGT]['min']
                    sensorMAX = rf2status.sensordisplay[sensorTGT]['max']
                    sensorWARN = rf2status.sensordisplay[sensorTGT]['warn']
                    sensorTITLE = rf2status.sensordisplay[sensorTGT]['title']

                    smallBOX = true
                    rf2status.telemetryBox(posX, posY, boxW, boxH / 2 - (theme.colSpacing / 2), sensorTITLE, sensorVALUE, sensorUNIT, smallBOX, sensorWARN, sensorMIN, sensorMAX)

                    sensorTGT = "mah"
                    sensorVALUE = rf2status.sensordisplay[sensorTGT]['value']
                    sensorUNIT = rf2status.sensordisplay[sensorTGT]['unit']
                    sensorMIN = rf2status.sensordisplay[sensorTGT]['min']
                    sensorMAX = rf2status.sensordisplay[sensorTGT]['max']
                    sensorWARN = rf2status.sensordisplay[sensorTGT]['warn']
                    sensorTITLE = rf2status.sensordisplay[sensorTGT]['title']

                    smallBOX = true
                    rf2status.telemetryBox(posX, posY + boxH / 2 + (theme.colSpacing / 2), boxW, boxH / 2 - theme.colSpacing / 2, sensorTITLE, sensorVALUE, sensorUNIT, smallBOX, sensorWARN, sensorMIN,
                                           sensorMAX)

                end

                if sensorTGT == 'rssi_timer_temp_esc_temp_mcu' then

                    sensorTGT = "rssi"
                    sensorVALUE = rf2status.sensordisplay[sensorTGT]['value']
                    sensorUNIT = rf2status.sensordisplay[sensorTGT]['unit']
                    sensorMIN = rf2status.sensordisplay[sensorTGT]['min']
                    sensorMAX = rf2status.sensordisplay[sensorTGT]['max']
                    sensorWARN = rf2status.sensordisplay[sensorTGT]['warn']
                    sensorTITLE = rf2status.sensordisplay[sensorTGT]['title']

                    smallBOX = true
                    rf2status.telemetryBox(posX, posY, boxW / 2 - (theme.colSpacing / 2), boxH / 2 - (theme.colSpacing / 2), sensorTITLE, sensorVALUE, sensorUNIT, smallBOX, sensorWARN, sensorMIN,
                                           sensorMAX)

                    sensorTGT = "timer"
                    sensorVALUE = rf2status.sensordisplay[sensorTGT]['value']
                    sensorUNIT = rf2status.sensordisplay[sensorTGT]['unit']
                    sensorMIN = rf2status.sensordisplay[sensorTGT]['min']
                    sensorMAX = rf2status.sensordisplay[sensorTGT]['max']
                    sensorWARN = rf2status.sensordisplay[sensorTGT]['warn']
                    sensorTITLE = rf2status.sensordisplay[sensorTGT]['title']

                    smallBOX = true
                    rf2status.telemetryBox(posX + boxW / 2 + (theme.colSpacing / 2), posY, boxW / 2 - (theme.colSpacing / 2), boxH / 2 - (theme.colSpacing / 2), sensorTITLE, sensorVALUE, sensorUNIT,
                                           smallBOX, sensorWARN, sensorMIN, sensorMAX)

                    sensorTGT = "temp_esc"
                    sensorVALUE = rf2status.sensordisplay[sensorTGT]['value']
                    sensorUNIT = rf2status.sensordisplay[sensorTGT]['unit']
                    sensorMIN = rf2status.sensordisplay[sensorTGT]['min']
                    sensorMAX = rf2status.sensordisplay[sensorTGT]['max']
                    sensorWARN = rf2status.sensordisplay[sensorTGT]['warn']
                    sensorTITLE = rf2status.sensordisplay[sensorTGT]['title']

                    smallBOX = true
                    rf2status.telemetryBox(posX, posY + boxH / 2 + (theme.colSpacing / 2), boxW / 2 - (theme.colSpacing / 2), boxH / 2 - theme.colSpacing / 2, sensorTITLE, sensorVALUE, sensorUNIT,
                                           smallBOX, sensorWARN, sensorMIN, sensorMAX)

                    sensorTGT = "temp_mcu"
                    sensorVALUE = rf2status.sensordisplay[sensorTGT]['value']
                    sensorUNIT = rf2status.sensordisplay[sensorTGT]['unit']
                    sensorMIN = rf2status.sensordisplay[sensorTGT]['min']
                    sensorMAX = rf2status.sensordisplay[sensorTGT]['max']
                    sensorWARN = rf2status.sensordisplay[sensorTGT]['warn']
                    sensorTITLE = rf2status.sensordisplay[sensorTGT]['title']

                    smallBOX = true
                    rf2status.telemetryBox(posX + boxW / 2 + (theme.colSpacing / 2), posY + boxH / 2 + (theme.colSpacing / 2), boxW / 2 - (theme.colSpacing / 2), boxH / 2 - (theme.colSpacing / 2),
                                           sensorTITLE, sensorVALUE, sensorUNIT, smallBOX, sensorWARN, sensorMIN, sensorMAX)

                end

                if sensorTGT == 'max_current' then

                    sensorTGT = "current"
                    sensorVALUE = rf2status.sensordisplay[sensorTGT]['value']
                    sensorUNIT = rf2status.sensordisplay[sensorTGT]['unit']
                    sensorMIN = rf2status.sensordisplay[sensorTGT]['min']
                    sensorMAX = rf2status.sensordisplay[sensorTGT]['max']
                    sensorWARN = rf2status.sensordisplay[sensorTGT]['warn']
                    sensorTITLE = rf2status.sensordisplay[sensorTGT]['title']

                    if sensorMAX == "-" or sensorMAX == nil then sensorMAX = 0 end

                    smallBOX = false
                    rf2status.telemetryBox(posX, posY, boxW, boxH, "MAX " .. sensorTITLE, sensorMAX, sensorUNIT, smallBOX)

                end

            end

            c = c + 1
        end

        if rf2status.linkUP == 0 then rf2status.noTelem() end

        if rf2status.showLOGS ~= nil then if rf2status.showLOGS then rf2status.logsBOX() end end

    end


end

function rf2status.ReverseTable(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do reversedTable[itemCount + 1 - k] = v end
    return reversedTable
end

function rf2status.getChannelValue(ich)
    local src = system.getSource({category = CATEGORY_CHANNEL, member = (ich - 1), options = 0})
    return math.floor((src:value() / 10.24) + 0.5)
end

function rf2status.getSensors()
    if rf2status.isInConfiguration == true then return rf2status.sensors end

    local tv
    local voltage
    local temp_esc
    local temp_mcu
    local mah
    local mah
    local fuel
    local fm
    local rssi
    local adjSOURCE
    local adjvalue
    local current

    -- lcd.resetFocusTimeout()

    if environment.simulation == true then

        tv = math.random(2100, 2274)
        voltage = tv
        temp_esc = math.random(50, 225) * 10
        temp_mcu = math.random(50, 185) * 10
        mah = math.random(10000, 10100)
        fuel = 55
        fm = "DISABLED"
        rssi = math.random(90, 100)
        adjsource = 0
        adjvalue = 0
        current = 0

        if rf2status.idleupswitchParam ~= nil and armswitchParam ~= nil then
            if rf2status.idleupswitchParam:state() == true and armswitchParam:state() == true then
                current = math.random(100, 120)
                rpm = math.random(90, 100)
            else
                current = 0
                rpm = 0
            end
        end

    elseif rf2status.linkUP ~= 0 then

        local telemetrySOURCE = system.getSource("Rx RSSI1")

        if telemetrySOURCE ~= nil then
            -- we are running crsf
            -- print("CRSF")
            local crsfSOURCE = system.getSource("Vbat")

            if crsfSOURCE ~= nil then
                -- crsf passthru
                voltageSOURCE = system.getSource("Vbat")
                rpmSOURCE = system.getSource("Hspd")
                currentSOURCE = system.getSource("Curr")
                temp_escSOURCE = system.getSource("EscT")
                temp_mcuSOURCE = system.getSource("Tmcu")
                fuelSOURCE = system.getSource("Bat%")
                mahSOURCE = system.getSource("Capa")
                govSOURCE = system.getSource("Gov")
                rssiSOURCE = system.getSource("Rx Quality")
                adjfSOURCE = system.getSource("AdjF")
                adjvSOURCE = system.getSource("AdjV")

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
                    if rpmSOURCE:maximum() == 1000.0 then rpmSOURCE:maximum(65000) end

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
                    if currentSOURCE:maximum() == 50.0 then currentSOURCE:maximum(400.0) end

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
                    govId = govSOURCE:value()

                    -- print(govId)
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

                if adjfSOURCE ~= nil then
                    adjfunc = adjfSOURCE:value()
                    if adjfunc ~= nil then
                        adjfunc = adjfunc
                    else
                        adjfunc = 0
                    end
                else
                    adjfunc = 0
                end

                if adjvSOURCE ~= nil then
                    adjvalue = adjvSOURCE:value()
                    if adjvalue ~= nil then
                        adjvalue = adjvalue
                    else
                        adjvalue = 0
                    end
                else
                    adjvalue = 0
                end

            else
                -- LEGACY CRSF REUSE
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
                    if rpmSOURCE:maximum() == 1000.0 then rpmSOURCE:maximum(65000) end

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
                    if currentSOURCE:maximum() == 50.0 then currentSOURCE:maximum(400.0) end

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

                if govSOURCE ~= nil then govmode = govSOURCE:stringValue() end
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
            end

        else
            -- we are run sport	
            -- set sources for everthing below
            -- print("SPORT")

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

            -- voltageSOURCE = system.getSource("VFAS")
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

                -- print(govId)
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

            if adjSOURCE ~= nil then adjsource = adjSOURCE:value() end

            if adjVALUE ~= nil then adjvalue = adjVALUE:value() end

            rssi = rf2status.linkUP

        end
    else
        -- we have no link.  do something
        -- print("NO LINK")
        -- keep looking for new sensor
        rf2status.rssiSensor = rf2status.getRssiSensor()

        voltage = 0
        rpm = 0
        current = 0
        temp_esc = 0
        temp_mcu = 0
        fuel = 0
        mah = 0
        govmode = "-"
        fm = "-"
        rssi = rf2status.linkUP
        adjsource = 0
        adjvalue = 0
    end

    -- calc fuel percentage if needed
    if rf2status.calcfuelParam == true then

        if rf2status.btypeParam == 0 then
            -- LiPo
            maxCellVoltage = 4.2
            minCellVoltage = 3.2
        elseif rf2status.btypeParam == 1 then
            -- LiHv
            maxCellVoltage = 4.35
            minCellVoltage = 3.4
        elseif rf2status.btypeParam == 2 then
            -- Lion
            maxCellVoltage = 2.4
            minCellVoltage = 3
        elseif rf2status.btypeParam == 3 then
            -- LiFe
            maxCellVoltage = 3.65
            minCellVoltage = 2.5
        elseif rf2status.btypeParam == 4 then
            -- NiMh
            maxCellVoltage = 1.2
            minCellVoltage = 0.9
        else
            -- LiPo (default)
            maxCellVoltage = 4.196
            minCellVoltage = 3.2
        end

        -- maxCellVoltage = 4.196
        -- minCellVoltage = 3.2
        avgCellVoltage = (voltage / 100) / rf2status.cellsParam
        batteryPercentage = 100 * (avgCellVoltage - minCellVoltage) / ((maxCellVoltage + (0.00000001 * rf2status.cellsParam)) - minCellVoltage)
        fuel = batteryPercentage
        fuel = rf2status.round(fuel, 0)

        if fuel > 100 then fuel = 100 end

    end

    -- convert from C to F
    -- Divide by 5, then multiply by 9, then add 32
    if rf2status.tempconvertParamMCU == 2 then
        temp_mcu = ((temp_mcu / 5) * 9) + 32
        temp_mcu = rf2status.round(temp_mcu, 0)
    end
    -- convert from F to C
    -- Deduct 32, then multiply by 5, then divide by 9
    if rf2status.tempconvertParamMCU == 3 then
        temp_mcu = ((temp_mcu - 32) * 5) / 9
        temp_mcu = rf2status.round(temp_mcu, 0)
    end

    -- convert from C to F
    -- Divide by 5, then multiply by 9, then add 32
    if rf2status.tempconvertParamESC == 2 then
        temp_esc = ((temp_esc / 5) * 9) + 32
        temp_esc = rf2status.round(temp_esc, 0)
    end
    -- convert from F to C
    -- Deduct 32, then multiply by 5, then divide by 9
    if rf2status.tempconvertParamESC == 3 then
        temp_esc = ((temp_esc - 32) * 5) / 9
        temp_esc = rf2status.round(temp_esc, 0)
    end

    -- set flag to rf2status.refresh screen or not

    voltage = rf2status.kalmanVoltage(voltage, rf2status.sensors.voltage)
    voltage = rf2status.round(voltage, 0)

    rpm = rf2status.kalmanRPM(rpm, rf2status.sensors.rpm)
    rpm = rf2status.round(rpm, 0)

    temp_mcu = rf2status.kalmanTempMCU(temp_mcu, rf2status.sensors.temp_mcu)
    temp_mcu = rf2status.round(temp_mcu, 0)

    temp_esc = rf2status.kalmanTempESC(temp_esc, rf2status.sensors.temp_esc)
    temp_esc = rf2status.round(temp_esc, 0)

    current = rf2status.kalmanCurrent(current, rf2status.sensors.current)
    current = rf2status.round(current, 0)

    rssi = rf2status.kalmanRSSI(rssi, rf2status.sensors.rssi)
    rssi = rf2status.round(rssi, 0)

    -- do / dont do voltage based on stick position
    if rf2status.lowvoltagStickParam == nil then rf2status.lowvoltagStickParam = 0 end
    if rf2status.lowvoltagStickCutoffParam == nil then rf2status.lowvoltagStickCutoffParam = 80 end

    if (rf2status.lowvoltagStickParam ~= 0) then
        rf2status.lvStickannouncement = false
        for i, v in ipairs(rf2status.lvStickOrder[rf2status.lowvoltagStickParam]) do
            if rf2status.lvStickannouncement == false then -- we skip more if any stick has resulted in announcement
                if math.abs(rf2status.getChannelValue(v)) >= rf2status.lowvoltagStickCutoffParam then rf2status.lvStickannouncement = true end
            end
        end
    end

    -- intercept governor for non rf governor helis
    if armswitchParam ~= nil or rf2status.idleupswitchParam ~= nil then
        if rf2status.govmodeParam == 1 then
            if armswitchParam:state() == true then
                govmode = "ARMED"
                fm = "ARMED"
            else
                govmode = "DISARMED"
                fm = "DISARMED"
            end

            if armswitchParam:state() == true then
                if rf2status.idleupswitchParam:state() == true then
                    govmode = "ACTIVE"
                    fm = "ACTIVE"
                else
                    govmode = "THR-OFF"
                    fm = "THR-OFF"
                end

            end
        end

    end

    if rf2status.sensors.voltage ~= voltage then rf2status.refresh = true end
    if rf2status.sensors.rpm ~= rpm then rf2status.refresh = true end
    if rf2status.sensors.current ~= current then rf2status.refresh = true end
    if rf2status.sensors.temp_esc ~= temp_esc then rf2status.refresh = true end
    if rf2status.sensors.temp_mcu ~= temp_mcu then rf2status.refresh = true end
    if rf2status.sensors.govmode ~= govmode then rf2status.refresh = true end
    if rf2status.sensors.fuel ~= fuel then rf2status.refresh = true end
    if rf2status.sensors.mah ~= mah then rf2status.refresh = true end
    if rf2status.sensors.rssi ~= rssi then rf2status.refresh = true end
    if rf2status.sensors.fm ~= CURRENT_FLIGHT_MODE then rf2status.refresh = true end

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
    rf2status.sensors = ret

    return ret
end

function rf2status.sensorsMAXMIN(sensors)

    if rf2status.linkUP ~= 0 and rf2status.theTIME ~= nil and rf2status.idleupdelayParam ~= nil then

        -- hold back - to early to get a reading
        if rf2status.theTIME <= rf2status.idleupdelayParam then
            rf2status.sensorVoltageMin = 0
            rf2status.sensorVoltageMax = 0
            rf2status.sensorFuelMin = 0
            rf2status.sensorFuelMax = 0
            rf2status.sensorRPMMin = 0
            rf2status.sensorRPMMax = 0
            rf2status.sensorCurrentMin = 0
            rf2status.sensorCurrentMax = 0
            rf2status.sensorRSSIMin = 0
            rf2status.sensorRSSIMax = 0
            rf2status.sensorTempESCMin = 0
            rf2status.sensorTempMCUMax = 0
        end

        -- prob put in a screen/audio alert for initialising
        if rf2status.theTIME >= 1 and rf2status.theTIME < rf2status.idleupdelayParam then end

        if rf2status.theTIME >= rf2status.idleupdelayParam then

            local idleupdelayOFFSET = 2

            -- record initial parameters for max/min
            if rf2status.theTIME >= rf2status.idleupdelayParam and rf2status.theTIME <= (rf2status.idleupdelayParam + idleupdelayOFFSET) then
                rf2status.sensorVoltageMin = sensors.voltage
                rf2status.sensorVoltageMax = sensors.voltage
                rf2status.sensorFuelMin = sensors.fuel
                rf2status.sensorFuelMax = sensors.fuel
                rf2status.sensorRPMMin = sensors.rpm
                rf2status.sensorRPMMax = sensors.rpm
                if sensors.current == 0 then
                    rf2status.sensorCurrentMin = 1
                else
                    rf2status.sensorCurrentMin = sensors.current
                end
                rf2status.sensorCurrentMax = sensors.current

                rf2status.sensorRSSIMin = sensors.rssi
                rf2status.sensorRSSIMax = sensors.rssi
                rf2status.sensorTempESCMin = sensors.temp_esc
                rf2status.sensorTempESCMax = sensors.temp_esc
                rf2status.sensorTempMCUMin = sensors.temp_mcu
                rf2status.sensorTempMCUMax = sensors.temp_mcu
                motorNearlyActive = 0
            end

            if rf2status.theTIME >= (rf2status.idleupdelayParam + idleupdelayOFFSET) and rf2status.idleupswitchParam:state() == true then

                if sensors.voltage < rf2status.sensorVoltageMin then rf2status.sensorVoltageMin = sensors.voltage end
                if sensors.voltage > rf2status.sensorVoltageMax then rf2status.sensorVoltageMax = sensors.voltage end

                if sensors.fuel < rf2status.sensorFuelMin then rf2status.sensorFuelMin = sensors.fuel end
                if sensors.fuel > rf2status.sensorFuelMax then rf2status.sensorFuelMax = sensors.fuel end

                if sensors.rpm < rf2status.sensorRPMMin then rf2status.sensorRPMMin = sensors.rpm end
                if sensors.rpm > rf2status.sensorRPMMax then rf2status.sensorRPMMax = sensors.rpm end
                if sensors.current < rf2status.sensorCurrentMin then
                    rf2status.sensorCurrentMin = sensors.current
                    if rf2status.sensorCurrentMin == 0 then rf2status.sensorCurrentMin = 1 end
                end
                if sensors.current > rf2status.sensorCurrentMax then rf2status.sensorCurrentMax = sensors.current end
                if sensors.rssi < rf2status.sensorRSSIMin then rf2status.sensorRSSIMin = sensors.rssi end
                if sensors.rssi > rf2status.sensorRSSIMax then rf2status.sensorRSSIMax = sensors.rssi end
                if sensors.temp_esc < rf2status.sensorTempESCMin then rf2status.sensorTempESCMin = sensors.temp_esc end
                if sensors.temp_esc > rf2status.sensorTempESCMax then rf2status.sensorTempESCMax = sensors.temp_esc end
                rf2status.motorWasActive = true
            end

        end

        -- store the last values
        if rf2status.motorWasActive and rf2status.idleupswitchParam:state() == false then

            rf2status.motorWasActive = false

            local maxminFinals = rf2status.readHistory()

            if rf2status.sensorCurrentMin == 0 then
                rf2status.sensorCurrentMinAlt = 1
            else
                rf2status.sensorCurrentMinAlt = rf2status.sensorCurrentMin
            end
            if rf2status.sensorCurrentMax == 0 then
                rf2status.sensorCurrentMaxAlt = 1
            else
                rf2status.sensorCurrentMaxAlt = rf2status.sensorCurrentMax
            end

            local maxminRow = rf2status.theTIME .. "," .. rf2status.sensorVoltageMin .. "," .. rf2status.sensorVoltageMax .. "," .. rf2status.sensorFuelMin .. "," .. rf2status.sensorFuelMax .. "," ..
                                  rf2status.sensorRPMMin .. "," .. rf2status.sensorRPMMax .. "," .. rf2status.sensorCurrentMin .. "," .. rf2status.sensorCurrentMax .. "," .. rf2status.sensorRSSIMin ..
                                  "," .. rf2status.sensorRSSIMax .. "," .. rf2status.sensorTempMCUMin .. "," .. rf2status.sensorTempMCUMax .. "," .. rf2status.sensorTempESCMin .. "," ..
                                  rf2status.sensorTempESCMax

            -- print("Last data: ".. maxminRow )

            table.insert(maxminFinals, 1, maxminRow)
            if tablelength(maxminFinals) >= 9 then table.remove(maxminFinals, 9) end

            name = string.gsub(model.name(), "%s+", "_")
            name = string.gsub(name, "%W", "_")

            file = widgetDir .. "logs/" .. name .. ".log"
            f = io.open(file, 'w')
            f:write("")
            io.close(f)

            -- print("Writing history to: " .. file)

            f = io.open(file, 'a')
            for k, v in ipairs(maxminFinals) do
                if v ~= nil then
                    v = v:gsub("%s+", "")
                    -- if v ~= "" then
                    -- print(v)
                    f:write(v .. "\n")
                    -- end
                end
            end
            io.close(f)

            rf2status.readLOGS = false

        end

    else
        rf2status.sensorVoltageMax = 0
        rf2status.sensorVoltageMin = 0
        rf2status.sensorFuelMin = 0
        rf2status.sensorFuelMax = 0
        rf2status.sensorRPMMin = 0
        rf2status.sensorRPMMax = 0
        rf2status.sensorCurrentMin = 0
        rf2status.sensorCurrentMax = 0
        rf2status.sensorTempESCMin = 0
        rf2status.sensorTempESCMax = 0
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

    if (indentLevel == nil) then
        print(print_r(arr, 0))
        return
    end

    for i = 0, indentLevel do indentStr = indentStr .. "\t" end

    for index, value in ipairs(arr) do
        if type(value) == "table" then
            str = str .. indentStr .. index .. ": \n" .. print_r(value, (indentLevel + 1))
        else
            str = str .. indentStr .. index .. ": " .. value .. "\n"
        end
    end
    return str
end

function rf2status.updateFILTERING()
    if rf2status.filteringParam == 2 then
        -- print("Filtering: medium")
        rf2status.voltageNoiseQ = 150
        rf2status.fuelNoiseQ = 150
        rf2status.rpmNoiseQ = 150
        rf2status.temp_mcuNoiseQ = 150
        rf2status.temp_escNoiseQ = 150
        rf2status.rssiNoiseQ = 150
        rf2status.currentNoiseQ = 150
    elseif rf2status.filteringParam == 3 then
        -- print("Filtering: high")
        rf2status.voltageNoiseQ = 200
        rf2status.fuelNoiseQ = 200
        rf2status.rpmNoiseQ = 200
        rf2status.temp_mcuNoiseQ = 200
        rf2status.temp_escNoiseQ = 200
        rf2status.rssiNoiseQ = 200
        rf2status.currentNoiseQ = 200
    else
        -- print("Filtering: low")
        rf2status.voltageNoiseQ = 100
        rf2status.fuelNoiseQ = 100
        rf2status.rpmNoiseQ = 100
        rf2status.temp_mcuNoiseQ = 100
        rf2status.temp_escNoiseQ = 100
        rf2status.rssiNoiseQ = 100
        rf2status.currentNoiseQ = 100
    end
end

function rf2status.kalmanCurrent(new, old)
    if old == nil then old = 0 end
    if new == nil then new = 0 end
    x = old
    local p = 100
    local k = 0
    p = p + 0.05
    k = p / (p + rf2status.currentNoiseQ)
    x = x + k * (new - x)
    p = (1 - k) * p
    return x
end

function rf2status.kalmanRSSI(new, old)
    if old == nil then old = 0 end
    if new == nil then new = 0 end
    x = old
    local p = 100
    local k = 0
    p = p + 0.05
    k = p / (p + rf2status.rssiNoiseQ)
    x = x + k * (new - x)
    p = (1 - k) * p
    return x
end

function rf2status.kalmanTempMCU(new, old)
    if old == nil then old = 0 end
    if new == nil then new = 0 end
    x = old
    local p = 100
    local k = 0
    p = p + 0.05
    k = p / (p + rf2status.temp_mcuNoiseQ)
    x = x + k * (new - x)
    p = (1 - k) * p
    return x
end

function rf2status.kalmanTempESC(new, old)
    if old == nil then old = 0 end
    if new == nil then new = 0 end
    x = old
    local p = 100
    local k = 0
    p = p + 0.05
    k = p / (p + rf2status.temp_escNoiseQ)
    x = x + k * (new - x)
    p = (1 - k) * p
    return x
end

function rf2status.kalmanRPM(new, old)
    if old == nil then old = 0 end
    if new == nil then new = 0 end
    x = old
    local p = 100
    local k = 0
    p = p + 0.05
    k = p / (p + rf2status.rpmNoiseQ)
    x = x + k * (new - x)
    p = (1 - k) * p
    return x
end

function rf2status.kalmanVoltage(new, old)
    if old == nil then old = 0 end
    if new == nil then new = 0 end
    x = old
    local p = 100
    local k = 0
    p = p + 0.05
    k = p / (p + rf2status.voltageNoiseQ)
    x = x + k * (new - x)
    p = (1 - k) * p
    return x
end

function rf2status.sensorMakeNumber(x)
    if x == nil or x == "" then x = 0 end

    x = string.gsub(x, "%D+", "")
    x = tonumber(x)
    if x == nil or x == "" then x = 0 end

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
        return mins .. ":" .. secs
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
    for k in pairs(t) do keys[#keys + 1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a, b)
            return order(t, a, b)
        end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then return keys[i], t[keys[i]] end
    end
end

function rf2status.explode(inputstr, sep)
    if sep == nil then sep = "%s" end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do table.insert(t, str) end
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
    -- print("Reading history")

    name = string.gsub(model.name(), "%s+", "_")
    name = string.gsub(name, "%W", "_")

    file = widgetDir .. "logs/" .. name .. ".log"
    local f = io.open(file, "rb")

    if f ~= nil then
        -- file exists
        local rData
        c = 0
        tc = 1
        while c <= 10 do
            if c == 0 then
                rData = io.read(f, "l")
            else
                rData = io.read(f, "L")
            end
            if rData ~= "" or rData ~= nil then
                history[tc] = rData
                tc = tc + 1
            end
            c = c + 1
        end
        io.close(f)

    else
        return history
    end

    return history

end

function rf2status.read()
    rf2status.govmodeParam = storage.read("mem1")
    rf2status.btypeParam = storage.read("mem2")
    rf2status.lowfuelParam = storage.read("mem3")
    rf2status.alertintParam = storage.read("mem4")
    alrthptParam = storage.read("mem5")
    rf2status.maxminParam = storage.read("mem6")
    rf2status.titleParam = storage.read("mem7")
    rf2status.cellsParam = storage.read("mem8")
    rf2status.announcementVoltageSwitchParam = storage.read("mem9")
    rf2status.govmodeParam = storage.read("mem10")
    rf2status.rpmAlertsParam = storage.read("mem11")
    rf2status.rpmAlertsPercentageParam = storage.read("mem12")
    rf2status.adjFunctionParam = storage.read("mem13") -- spare
    rf2status.announcementRPMSwitchParam = storage.read("mem14")
    rf2status.announcementCurrentSwitchParam = storage.read("mem15")
    rf2status.announcementFuelSwitchParam = storage.read("mem16")
    rf2status.announcementLQSwitchParam = storage.read("mem17")
    rf2status.announcementESCSwitchParam = storage.read("mem18")
    rf2status.announcementMCUSwitchParam = storage.read("mem19")
    rf2status.announcementTimerSwitchParam = storage.read("mem20")
    rf2status.filteringParam = storage.read("mem21")
    rf2status.sagParam = storage.read("mem22")
    rf2status.lowvoltagsenseParam = storage.read("mem23")
    rf2status.announcementIntervalParam = storage.read("mem24")
    rf2status.lowVoltageGovernorParam = storage.read("mem25")
    rf2status.lowvoltagStickParam = storage.read("mem26")
    rf2status.quadBoxParam = storage.read("mem27") 
    rf2status.lowvoltagStickCutoffParam = storage.read("mem28")
    rf2status.governorUNKNOWNParam = storage.read("mem29")
    rf2status.governorDISARMEDParam = storage.read("mem30")
    rf2status.governorDISABLEDParam = storage.read("mem31")
    rf2status.governorBAILOUTParam = storage.read("mem32")
    rf2status.governorAUTOROTParam = storage.read("mem33")
    rf2status.governorLOSTHSParam = storage.read("mem34")
    rf2status.governorTHROFFParam = storage.read("mem35")
    rf2status.governorACTIVEParam = storage.read("mem36")
    rf2status.governorRECOVERYParam = storage.read("mem37")
    rf2status.governorSPOOLUPParam = storage.read("mem38")
    rf2status.governorIDLEParam = storage.read("mem39")
    rf2status.governorOFFParam = storage.read("mem40")
    rf2status.alertonParam = storage.read("mem41")
    rf2status.calcfuelParam = storage.read("mem42")
    rf2status.tempconvertParamESC = storage.read("mem43")
    rf2status.tempconvertParamMCU = storage.read("mem44")
    rf2status.idleupswitchParam = storage.read("mem45")
    armswitchParam = storage.read("mem46")
    rf2status.idleupdelayParam = storage.read("mem47")
    rf2status.switchIdlelowParam = storage.read("mem48")
    rf2status.switchIdlemediumParam = storage.read("mem49")
    rf2status.switchIdlehighParam = storage.read("mem50")
    rf2status.switchrateslowParam = storage.read("mem51")
    rf2status.switchratesmediumParam = storage.read("mem52")
    rf2status.switchrateshighParam = storage.read("mem53")
    rf2status.switchrescueonParam = storage.read("mem54")
    rf2status.switchrescueoffParam = storage.read("mem55")
    rf2status.switchbblonParam = storage.read("mem56")
    rf2status.switchbbloffParam = storage.read("mem57")
    rf2status.layoutBox1Param = storage.read("mem58")
    rf2status.layoutBox2Param = storage.read("mem59")
    rf2status.layoutBox3Param = storage.read("mem60")
    rf2status.layoutBox4Param = storage.read("mem61")
    rf2status.layoutBox5Param = storage.read("mem62")
    rf2status.layoutBox6Param = storage.read("mem63")
    rf2status.timeralarmVibrateParam = storage.read("mem64")
    rf2status.timeralarmParam = storage.read("mem65")
    rf2status.statusColorParam = storage.read("mem66")

    if rf2status.layoutBox1Param == nil then rf2status.layoutBox1Param = 11 end
    if rf2status.layoutBox2Param == nil then rf2status.layoutBox2Param = 2 end
    if rf2status.layoutBox3Param == nil then rf2status.layoutBox3Param = 3 end
    if rf2status.layoutBox4Param == nil then rf2status.layoutBox4Param = 12 end
    if rf2status.layoutBox5Param == nil then rf2status.layoutBox5Param = 4 end
    if rf2status.layoutBox6Param == nil then rf2status.layoutBox6Param = 5 end

    rf2status.resetALL()
    rf2status.updateFILTERING()
end

function rf2status.write()
    storage.write("mem1", rf2status.govmodeParam)
    storage.write("mem2", rf2status.btypeParam)
    storage.write("mem3", rf2status.lowfuelParam)
    storage.write("mem4", rf2status.alertintParam)
    storage.write("mem5", alrthptParam)
    storage.write("mem6", rf2status.maxminParam)
    storage.write("mem7", rf2status.titleParam)
    storage.write("mem8", rf2status.cellsParam)
    storage.write("mem9", rf2status.announcementVoltageSwitchParam)
    storage.write("mem10", rf2status.govmodeParam)
    storage.write("mem11", rf2status.rpmAlertsParam)
    storage.write("mem12", rf2status.rpmAlertsPercentageParam)
    storage.write("mem13", rf2status.adjFunctionParam)  -- spare
    storage.write("mem14", rf2status.announcementRPMSwitchParam)
    storage.write("mem15", rf2status.announcementCurrentSwitchParam)
    storage.write("mem16", rf2status.announcementFuelSwitchParam)
    storage.write("mem17", rf2status.announcementLQSwitchParam)
    storage.write("mem18", rf2status.announcementESCSwitchParam)
    storage.write("mem19", rf2status.announcementMCUSwitchParam)
    storage.write("mem20", rf2status.announcementTimerSwitchParam)
    storage.write("mem21", rf2status.filteringParam)
    storage.write("mem22", rf2status.sagParam)
    storage.write("mem23", rf2status.lowvoltagsenseParam)
    storage.write("mem24", rf2status.announcementIntervalParam)
    storage.write("mem25", rf2status.lowVoltageGovernorParam)
    storage.write("mem26", rf2status.lowvoltagStickParam)
    storage.write("mem27", rf2status.quadBoxParam) 
    storage.write("mem28", rf2status.lowvoltagStickCutoffParam)
    storage.write("mem29", rf2status.governorUNKNOWNParam)
    storage.write("mem30", rf2status.governorDISARMEDParam)
    storage.write("mem31", rf2status.governorDISABLEDParam)
    storage.write("mem32", rf2status.governorBAILOUTParam)
    storage.write("mem33", rf2status.governorAUTOROTParam)
    storage.write("mem34", rf2status.governorLOSTHSParam)
    storage.write("mem35", rf2status.governorTHROFFParam)
    storage.write("mem36", rf2status.governorACTIVEParam)
    storage.write("mem37", rf2status.governorRECOVERYParam)
    storage.write("mem38", rf2status.governorSPOOLUPParam)
    storage.write("mem39", rf2status.governorIDLEParam)
    storage.write("mem40", rf2status.governorOFFParam)
    storage.write("mem41", rf2status.alertonParam)
    storage.write("mem42", rf2status.calcfuelParam)
    storage.write("mem43", rf2status.tempconvertParamESC)
    storage.write("mem44", rf2status.tempconvertParamMCU)
    storage.write("mem45", rf2status.idleupswitchParam)
    storage.write("mem46", armswitchParam)
    storage.write("mem47", rf2status.idleupdelayParam)
    storage.write("mem48", rf2status.switchIdlelowParam)
    storage.write("mem49", rf2status.switchIdlemediumParam)
    storage.write("mem50", rf2status.switchIdlehighParam)
    storage.write("mem51", rf2status.switchrateslowParam)
    storage.write("mem52", rf2status.switchratesmediumParam)
    storage.write("mem53", rf2status.switchrateshighParam)
    storage.write("mem54", rf2status.switchrescueonParam)
    storage.write("mem55", rf2status.switchrescueoffParam)
    storage.write("mem56", rf2status.switchbblonParam)
    storage.write("mem57", rf2status.switchbbloffParam)
    storage.write("mem58", rf2status.layoutBox1Param)
    storage.write("mem59", rf2status.layoutBox2Param)
    storage.write("mem60", rf2status.layoutBox3Param)
    storage.write("mem61", rf2status.layoutBox4Param)
    storage.write("mem62", rf2status.layoutBox5Param)
    storage.write("mem63", rf2status.layoutBox6Param)
    storage.write("mem64", rf2status.timeralarmVibrateParam)
    storage.write("mem65", rf2status.timeralarmParam)
    storage.write("mem66", rf2status.statusColorParam)

    rf2status.updateFILTERING()
end

function rf2status.playCurrent(widget)
    if rf2status.announcementCurrentSwitchParam ~= nil then
        if rf2status.announcementCurrentSwitchParam:state() then
            rf2status.currenttime.currentannouncementTimer = true
            currentDoneFirst = false
        else
            rf2status.currenttime.currentannouncementTimer = false
            currentDoneFirst = true
        end

        if rf2status.isInConfiguration == false then
            if rf2status.sensors.current ~= nil then
                if rf2status.currenttime.currentannouncementTimer == true then
                    -- start timer
                    if rf2status.currenttime.currentannouncementTimerStart == nil and currentDoneFirst == false then
                        rf2status.currenttime.currentannouncementTimerStart = os.time()
                        rf2status.currenttime.currentaudioannouncementCounter = os.clock()
                        -- print ("Play Current Alert (first)")
                        system.playNumber(rf2status.sensors.current / 10, UNIT_AMPERE, 2)
                        currentDoneFirst = true
                    end
                else
                    rf2status.currenttime.currentannouncementTimerStart = nil
                end

                if rf2status.currenttime.currentannouncementTimerStart ~= nil then
                    if currentDoneFirst == false then
                        if ((tonumber(os.clock()) - tonumber(rf2status.currenttime.currentaudioannouncementCounter)) >= rf2status.announcementIntervalParam) then
                            -- print ("Play Current Alert (repeat)")
                            rf2status.currenttime.currentaudioannouncementCounter = os.clock()
                            system.playNumber(rf2status.sensors.current / 10, UNIT_AMPERE, 2)
                        end
                    end
                else
                    -- stop timer
                    rf2status.currenttime.currentannouncementTimerStart = nil
                end
            end
        end
    end
end

function rf2status.playLQ(widget)
    if rf2status.announcementLQSwitchParam ~= nil then
        if rf2status.announcementLQSwitchParam:state() then
            rf2status.lqtime.lqannouncementTimer = true
            lqDoneFirst = false
        else
            rf2status.lqtime.lqannouncementTimer = false
            lqDoneFirst = true
        end

        if rf2status.isInConfiguration == false then
            if rf2status.sensors.rssi ~= nil then
                if rf2status.lqtime.lqannouncementTimer == true then
                    -- start timer
                    if rf2status.lqtime.lqannouncementTimerStart == nil and lqDoneFirst == false then
                        rf2status.lqtime.lqannouncementTimerStart = os.time()
                        rf2status.lqtime.lqaudioannouncementCounter = os.clock()
                        -- print ("Play LQ Alert (first)")
                        system.playFile(widgetDir .. "sounds/alerts/lq.wav")
                        system.playNumber(rf2status.sensors.rssi, UNIT_PERCENT, 2)
                        lqDoneFirst = true
                    end
                else
                    rf2status.lqtime.lqannouncementTimerStart = nil
                end

                if rf2status.lqtime.lqannouncementTimerStart ~= nil then
                    if lqDoneFirst == false then
                        if ((tonumber(os.clock()) - tonumber(rf2status.lqtime.lqaudioannouncementCounter)) >= rf2status.announcementIntervalParam) then
                            rf2status.lqtime.lqaudioannouncementCounter = os.clock()
                            -- print ("Play LQ Alert (repeat)")
                            system.playFile(widgetDir .. "sounds/alerts/lq.wav")
                            system.playNumber(rf2status.sensors.rssi, UNIT_PERCENT, 2)
                        end
                    end
                else
                    -- stop timer
                    rf2status.lqtime.lqannouncementTimerStart = nil
                end
            end
        end
    end
end

function rf2status.playMCU(widget)
    if rf2status.announcementMCUSwitchParam ~= nil then
        if rf2status.announcementMCUSwitchParam:state() then
            rf2status.mcutime.mcuannouncementTimer = true
            mcuDoneFirst = false
        else
            rf2status.mcutime.mcuannouncementTimer = false
            mcuDoneFirst = true
        end

        if rf2status.isInConfiguration == false then
            if rf2status.sensors.temp_mcu ~= nil then
                if rf2status.mcutime.mcuannouncementTimer == true then
                    -- start timer
                    if rf2status.mcutime.mcuannouncementTimerStart == nil and mcuDoneFirst == false then
                        rf2status.mcutime.mcuannouncementTimerStart = os.time()
                        rf2status.mcutime.mcuaudioannouncementCounter = os.clock()
                        -- print ("Playing MCU (first)")
                        system.playFile(widgetDir .. "sounds/alerts/mcu.wav")
                        system.playNumber(rf2status.sensors.temp_mcu / 100, UNIT_DEGREE, 2)
                        mcuDoneFirst = true
                    end
                else
                    rf2status.mcutime.mcuannouncementTimerStart = nil
                end

                if rf2status.mcutime.mcuannouncementTimerStart ~= nil then
                    if mcuDoneFirst == false then
                        if ((tonumber(os.clock()) - tonumber(rf2status.mcutime.mcuaudioannouncementCounter)) >= rf2status.announcementIntervalParam) then
                            rf2status.mcutime.mcuaudioannouncementCounter = os.clock()
                            -- print ("Playing MCU (repeat)")
                            system.playFile(widgetDir .. "sounds/alerts/mcu.wav")
                            system.playNumber(rf2status.sensors.temp_mcu / 100, UNIT_DEGREE, 2)
                        end
                    end
                else
                    -- stop timer
                    rf2status.mcutime.mcuannouncementTimerStart = nil
                end
            end
        end
    end
end

function rf2status.playESC(widget)
    if rf2status.announcementESCSwitchParam ~= nil then
        if rf2status.announcementESCSwitchParam:state() then
            rf2status.esctime.escannouncementTimer = true
            escDoneFirst = false
        else
            rf2status.esctime.escannouncementTimer = false
            escDoneFirst = true
        end

        if rf2status.isInConfiguration == false then
            if rf2status.sensors.temp_esc ~= nil then
                if rf2status.esctime.escannouncementTimer == true then
                    -- start timer
                    if rf2status.esctime.escannouncementTimerStart == nil and escDoneFirst == false then
                        rf2status.esctime.escannouncementTimerStart = os.time()
                        rf2status.esctime.escaudioannouncementCounter = os.clock()
                        -- print ("Playing ESC (first)")
                        system.playFile(widgetDir .. "sounds/alerts/esc.wav")
                        system.playNumber(rf2status.sensors.temp_esc / 100, UNIT_DEGREE, 2)
                        escDoneFirst = true
                    end
                else
                    rf2status.esctime.escannouncementTimerStart = nil
                end

                if rf2status.esctime.escannouncementTimerStart ~= nil then
                    if escDoneFirst == false then
                        if ((tonumber(os.clock()) - tonumber(rf2status.esctime.escaudioannouncementCounter)) >= rf2status.announcementIntervalParam) then
                            rf2status.esctime.escaudioannouncementCounter = os.clock()
                            -- print ("Playing ESC (repeat)")
                            system.playFile(widgetDir .. "sounds/alerts/esc.wav")
                            system.playNumber(rf2status.sensors.temp_esc / 100, UNIT_DEGREE, 2)
                        end
                    end
                else
                    -- stop timer
                    rf2status.esctime.escannouncementTimerStart = nil
                end
            end
        end
    end
end

function rf2status.playTIMERALARM(widget)
    if rf2status.theTIME ~= nil and rf2status.timeralarmParam ~= nil and rf2status.timeralarmParam ~= 0 then

        -- reset timer Delay
        if rf2status.theTIME > rf2status.timeralarmParam + 2 then rf2status.timerAlarmPlay = true end
        -- trigger first timer
        if rf2status.timerAlarmPlay == true then
            if rf2status.theTIME >= rf2status.timeralarmParam and rf2status.theTIME <= rf2status.timeralarmParam + 1 then

                system.playFile(widgetDir .. "sounds/alerts/beep.wav")

                hours = string.format("%02.f", math.floor(rf2status.theTIME / 3600))
                mins = string.format("%02.f", math.floor(rf2status.theTIME / 60 - (hours * 60)))
                secs = string.format("%02.f", math.floor(rf2status.theTIME - hours * 3600 - mins * 60))

                system.playFile(widgetDir .. "sounds/alerts/timer.wav")
                if mins ~= "00" then system.playNumber(mins, UNIT_MINUTE, 2) end
                system.playNumber(secs, UNIT_SECOND, 2)

                if rf2status.timeralarmVibrateParam == true then system.playHaptic("- - -") end

                rf2status.timerAlarmPlay = false
            end
        end

    end
end

function rf2status.playTIMER(widget)
    if rf2status.announcementTimerSwitchParam ~= nil then

        if rf2status.announcementTimerSwitchParam:state() then
            rf2status.timetime.timerannouncementTimer = true
            timerDoneFirst = false
        else
            rf2status.timetime.timerannouncementTimer = false
            timerDoneFirst = true
        end

        if rf2status.isInConfiguration == false then

            if rf2status.theTIME == nil then
                alertTIME = 0
            else
                alertTIME = rf2status.theTIME
            end

            if alertTIME ~= nil then

                hours = string.format("%02.f", math.floor(alertTIME / 3600))
                mins = string.format("%02.f", math.floor(alertTIME / 60 - (hours * 60)))
                secs = string.format("%02.f", math.floor(alertTIME - hours * 3600 - mins * 60))

                if rf2status.timetime.timerannouncementTimer == true then
                    -- start timer
                    if rf2status.timetime.timerannouncementTimerStart == nil and timerDoneFirst == false then
                        rf2status.timetime.timerannouncementTimerStart = os.time()
                        rf2status.timetime.timeraudioannouncementCounter = os.clock()
                        -- print ("Playing TIMER (first)" .. alertTIME)

                        if mins ~= "00" then system.playNumber(mins, UNIT_MINUTE, 2) end
                        system.playNumber(secs, UNIT_SECOND, 2)

                        timerDoneFirst = true
                    end
                else
                    rf2status.timetime.timerannouncementTimerStart = nil
                end

                if rf2status.timetime.timerannouncementTimerStart ~= nil then
                    if timerDoneFirst == false then
                        if ((tonumber(os.clock()) - tonumber(rf2status.timetime.timeraudioannouncementCounter)) >= rf2status.announcementIntervalParam) then
                            rf2status.timetime.timeraudioannouncementCounter = os.clock()
                            -- print ("Playing TIMER (repeat)" .. alertTIME)
                            if mins ~= "00" then system.playNumber(mins, UNIT_MINUTE, 2) end
                            system.playNumber(secs, UNIT_SECOND, 2)
                        end
                    end
                else
                    -- stop timer
                    rf2status.timetime.timerannouncementTimerStart = nil
                end
            end
        end
    end
end

function rf2status.playFuel(widget)
    if rf2status.announcementFuelSwitchParam ~= nil then
        if rf2status.announcementFuelSwitchParam:state() then
            rf2status.fueltime.fuelannouncementTimer = true
            fuelDoneFirst = false
        else
            rf2status.fueltime.fuelannouncementTimer = false
            fuelDoneFirst = true
        end

        if rf2status.isInConfiguration == false then
            if rf2status.sensors.fuel ~= nil then
                if rf2status.fueltime.fuelannouncementTimer == true then
                    -- start timer
                    if rf2status.fueltime.fuelannouncementTimerStart == nil and fuelDoneFirst == false then
                        rf2status.fueltime.fuelannouncementTimerStart = os.time()
                        rf2status.fueltime.fuelaudioannouncementCounter = os.clock()
                        -- print("Play fuel alert (first)")
                        system.playFile(widgetDir .. "sounds/alerts/fuel.wav")
                        system.playNumber(rf2status.sensors.fuel, UNIT_PERCENT, 2)
                        fuelDoneFirst = true
                    end
                else
                    rf2status.fueltime.fuelannouncementTimerStart = nil
                end

                if rf2status.fueltime.fuelannouncementTimerStart ~= nil then
                    if fuelDoneFirst == false then
                        if ((tonumber(os.clock()) - tonumber(rf2status.fueltime.fuelaudioannouncementCounter)) >= rf2status.announcementIntervalParam) then
                            rf2status.fueltime.fuelaudioannouncementCounter = os.clock()
                            -- print("Play fuel alert (repeat)")
                            system.playFile(widgetDir .. "sounds/alerts/fuel.wav")
                            system.playNumber(rf2status.sensors.fuel, UNIT_PERCENT, 2)

                        end
                    end
                else
                    -- stop timer
                    rf2status.fueltime.fuelannouncementTimerStart = nil
                end
            end
        end
    end
end

function rf2status.playRPM(widget)
    if rf2status.announcementRPMSwitchParam ~= nil then
        if rf2status.announcementRPMSwitchParam:state() then
            rf2status.rpmtime.announcementTimer = true
            rpmDoneFirst = false
        else
            rf2status.rpmtime.announcementTimer = false
            rpmDoneFirst = true
        end

        if rf2status.isInConfiguration == false then
            if rf2status.sensors.rpm ~= nil then
                if rf2status.rpmtime.announcementTimer == true then
                    -- start timer
                    if rf2status.rpmtime.announcementTimerStart == nil and rpmDoneFirst == false then
                        rf2status.rpmtime.announcementTimerStart = os.time()
                        rf2status.rpmtime.audioannouncementCounter = os.clock()
                        -- print("Play rpm alert (first)")
                        system.playNumber(rf2status.sensors.rpm, UNIT_RPM, 2)
                        rpmDoneFirst = true
                    end
                else
                    rf2status.rpmtime.announcementTimerStart = nil
                end

                if rf2status.rpmtime.announcementTimerStart ~= nil then
                    if rpmDoneFirst == false then
                        if ((tonumber(os.clock()) - tonumber(rf2status.rpmtime.audioannouncementCounter)) >= rf2status.announcementIntervalParam) then
                            -- print("Play rpm alert (repeat)")
                            rf2status.rpmtime.audioannouncementCounter = os.clock()
                            system.playNumber(rf2status.sensors.rpm, UNIT_RPM, 2)
                        end
                    end
                else
                    -- stop timer
                    rf2status.rpmtime.announcementTimerStart = nil
                end
            end
        end
    end
end

function rf2status.playVoltage(widget)
    if rf2status.announcementVoltageSwitchParam ~= nil then
        if rf2status.announcementVoltageSwitchParam:state() then
            rf2status.lvannouncementTimer = true
            voltageDoneFirst = false
        else
            rf2status.lvannouncementTimer = false
            voltageDoneFirst = true
        end

        if rf2status.isInConfiguration == false then
            if rf2status.sensors.voltage ~= nil then
                if rf2status.lvannouncementTimer == true then
                    -- start timer
                    if rf2status.lvannouncementTimerStart == nil and voltageDoneFirst == false then
                        rf2status.lvannouncementTimerStart = os.time()
                        rf2status.lvaudioannouncementCounter = os.clock()
                        -- print("Play voltage alert (first)")
                        -- system.playFile(widgetDir .. "sounds/alerts/voltage.wav")						
                        system.playNumber(rf2status.sensors.voltage / 100, 2, 2)
                        voltageDoneFirst = true
                    end
                else
                    rf2status.lvannouncementTimerStart = nil
                end

                if rf2status.lvannouncementTimerStart ~= nil then
                    if voltageDoneFirst == false then
                        if rf2status.lvaudioannouncementCounter ~= nil and rf2status.announcementIntervalParam ~= nil then
                            if ((tonumber(os.clock()) - tonumber(rf2status.lvaudioannouncementCounter)) >= rf2status.announcementIntervalParam) then
                                rf2status.lvaudioannouncementCounter = os.clock()
                                -- print("Play voltage alert (repeat)")
                                -- system.playFile(widgetDir .. "sounds/alerts/voltage.wav")								
                                system.playNumber(rf2status.sensors.voltage / 100, 2, 2)
                            end
                        end
                    end
                else
                    -- stop timer
                    rf2status.lvannouncementTimerStart = nil
                end
            end
        end
    end
end

function rf2status.event(widget, category, value, x, y)

    -- print("Event received:", category, value, x, y)

    if closingLOGS then
        if category == EVT_TOUCH and (value == 16640 or value == 16641) then
            closingLOGS = false
            return true
        end

    end

    if rf2status.showLOGS then
        if value == 35 then rf2status.showLOGS = false end

        if category == EVT_TOUCH and (value == 16640 or value == 16641) then
            if (x >= (rf2status.closeButtonX) and (x <= (rf2status.closeButtonX + rf2status.closeButtonW))) and
                (y >= (rf2status.closeButtonY) and (y <= (rf2status.closeButtonY + rf2status.closeButtonH))) then
                rf2status.showLOGS = false
                closingLOGS = true
            end
            return true
        else
            if category == EVT_TOUCH then return true end
        end

    end

end

function rf2status.playGovernor()
    if rf2status.governorAlertsParam == true then
        if rf2status.playGovernorLastState == nil then rf2status.playGovernorLastState = rf2status.sensors.govmode end

        if rf2status.sensors.govmode ~= rf2status.playGovernorLastState then
            rf2status.playGovernorCount = 0
            rf2status.playGovernorLastState = rf2status.sensors.govmode
        end

        if rf2status.playGovernorCount == 0 then
            -- print("Governor: " .. rf2status.sensors.govmode)
            rf2status.playGovernorCount = 1

            if rf2status.sensors.govmode == "UNKNOWN" and rf2status.governorUNKNOWNParam == true then
                if rf2status.govmodeParam == 0 then system.playFile(widgetDir .. "sounds/events/governor.wav") end
                system.playFile(widgetDir .. "sounds/events/unknown.wav")
            end
            if rf2status.sensors.govmode == "DISARMED" and rf2status.governorDISARMEDParam == true then
                if rf2status.govmodeParam == 0 then system.playFile(widgetDir .. "sounds/events/governor.wav") end
                system.playFile(widgetDir .. "sounds/events/disarmed.wav")
            end
            if rf2status.sensors.govmode == "DISABLED" and rf2status.governorDISABLEDParam == true then
                if rf2status.govmodeParam == 0 then system.playFile(widgetDir .. "sounds/events/governor.wav") end
                system.playFile(widgetDir .. "sounds/events/disabled.wav")
            end
            if rf2status.sensors.govmode == "BAILOUT" and rf2status.governorBAILOUTParam == true then
                if rf2status.govmodeParam == 0 then system.playFile(widgetDir .. "sounds/events/governor.wav") end
                system.playFile(widgetDir .. "sounds/events/bailout.wav")
            end
            if rf2status.sensors.govmode == "AUTOROT" and rf2status.governorAUTOROTParam == true then
                if rf2status.govmodeParam == 0 then system.playFile(widgetDir .. "sounds/events/governor.wav") end
                system.playFile(widgetDir .. "sounds/events/autorot.wav")
            end
            if rf2status.sensors.govmode == "LOST-HS" and rf2status.governorLOSTHSParam == true then
                if rf2status.govmodeParam == 0 then system.playFile(widgetDir .. "sounds/events/governor.wav") end
                system.playFile(widgetDir .. "sounds/events/lost-hs.wav")
            end
            if rf2status.sensors.govmode == "THR-OFF" and rf2status.governorTHROFFParam == true then
                if rf2status.govmodeParam == 0 then system.playFile(widgetDir .. "sounds/events/governor.wav") end
                system.playFile(widgetDir .. "sounds/events/thr-off.wav")
            end
            if rf2status.sensors.govmode == "ACTIVE" and rf2status.governorACTIVEParam == true then
                if rf2status.govmodeParam == 0 then system.playFile(widgetDir .. "sounds/events/governor.wav") end
                system.playFile(widgetDir .. "sounds/events/active.wav")
            end
            if rf2status.sensors.govmode == "RECOVERY" and rf2status.governorRECOVERYParam == true then
                if rf2status.govmodeParam == 0 then system.playFile(widgetDir .. "sounds/events/governor.wav") end
                system.playFile(widgetDir .. "sounds/events/recovery.wav")
            end
            if rf2status.sensors.govmode == "SPOOLUP" and rf2status.governorSPOOLUPParam == true then
                if rf2status.govmodeParam == 0 then system.playFile(widgetDir .. "sounds/events/governor.wav") end
                system.playFile(widgetDir .. "sounds/events/spoolup.wav")
            end
            if rf2status.sensors.govmode == "IDLE" and rf2status.governorIDLEParam == true then
                if rf2status.govmodeParam == 0 then system.playFile(widgetDir .. "sounds/events/governor.wav") end
                system.playFile(widgetDir .. "sounds/events/idle.wav")
            end
            if rf2status.sensors.govmode == "OFF" and rf2status.governorOFFParam == true then
                if rf2status.govmodeParam == 0 then system.playFile(widgetDir .. "sounds/events/governor.wav") end
                system.playFile(widgetDir .. "sounds/events/off.wav")
            end

        end

    end
end

function rf2status.playRPMDiff()
    if rf2status.rpmAlertsParam == true then

        if rf2status.sensors.govmode == "ACTIVE" or rf2status.sensors.govmode == "LOST-HS" or rf2status.sensors.govmode == "BAILOUT" or rf2status.sensors.govmode == "RECOVERY" then

            if rf2status.playrpmdiff.playRPMDiffLastState == nil then rf2status.playrpmdiff.playRPMDiffLastState = rf2status.sensors.rpm end

            -- we take a reading every 5 second
            if (tonumber(os.clock()) - tonumber(rf2status.playrpmdiff.playRPMDiffCounter)) >= 5 then
                rf2status.playrpmdiff.playRPMDiffCounter = os.clock()
                rf2status.playrpmdiff.playRPMDiffLastState = rf2status.sensors.rpm
            end

            -- check if current state withing % of last state
            local percentageDiff = 0
            if rf2status.sensors.rpm > rf2status.playrpmdiff.playRPMDiffLastState then
                percentageDiff = math.abs(100 - (rf2status.sensors.rpm / rf2status.playrpmdiff.playRPMDiffLastState * 100))
            elseif rf2status.playrpmdiff.playRPMDiffLastState < rf2status.sensors.rpm then
                percentage = math.abs(100 - (rf2status.playrpmdiff.playRPMDiffLastState / rf2status.sensors.rpm * 100))
            else
                percentageDiff = 0
            end

            if percentageDiff > rf2status.rpmAlertsPercentageParam / 10 then rf2status.playrpmdiff.playRPMDiffCount = 0 end

            if rf2status.playrpmdiff.playRPMDiffCount == 0 then
                -- print("RPM Difference: " .. percentageDiff)
                rf2status.playrpmdiff.playRPMDiffCount = 1
                system.playNumber(rf2status.sensors.rpm, UNIT_RPM, 2)
            end
        end
    end
end


-- MAIN WAKEUP FUNCTION. THIS SIMPLY FARMS OUT AT DIFFERING SCHEDULES TO SUB FUNCTIONS
function rf2status.wakeup(widget)

    local schedulerUI
    if lcd.isVisible() then
        schedulerUI = 0.25
    else
        schedulerUI = 1
    end

    -- keep cpu load down by running UI at reduced interval
    local now = os.clock()
    if (now - rf2status.wakeupSchedulerUI) >= schedulerUI then
        rf2status.wakeupSchedulerUI = now
        rf2status.wakeupUI()
    end

end

function rf2status.wakeupUI(widget)
    rf2status.refresh = false

    rf2status.linkUP = rf2status.getRSSI()
    rf2status.sensors = rf2status.getSensors()

    if rf2status.refresh == true then
        rf2status.sensorsMAXMIN(rf2status.sensors)
        lcd.invalidate()
    end

    if rf2status.linkUP == 0 then rf2status.linkUPTime = os.clock() end

    if rf2status.linkUP ~= 0 then

        if ((tonumber(os.clock()) - tonumber(rf2status.linkUPTime)) >= 5) then
            -- voltage alerts
            rf2status.playVoltage(widget)
            -- governor callouts
            rf2status.playGovernor(widget)
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
            -- timer alarm
            rf2status.playTIMERALARM(widget)


            if ((tonumber(os.clock()) - tonumber(rf2status.linkUPTime)) >= 10) then

                -- IDLE
                if rf2status.switchIdlelowParam ~= nil and rf2status.switchIdlelowParam:state() == true then
                    if rf2status.switchstatus.idlelow == nil or rf2status.switchstatus.idlelow == false then
                        system.playFile(widgetDir .. "sounds/switches/idle-l.wav")
                        rf2status.switchstatus.idlelow = true
                        rf2status.switchstatus.idlemedium = false
                        rf2status.switchstatus.idlehigh = false
                    end
                else
                    rf2status.switchstatus.idlelow = false
                end
                if rf2status.switchIdlemediumParam ~= nil and rf2status.switchIdlemediumParam:state() == true then
                    if rf2status.switchstatus.idlemedium == nil or rf2status.switchstatus.idlemedium == false then
                        system.playFile(widgetDir .. "sounds/switches/idle-m.wav")
                        rf2status.switchstatus.idlelow = false
                        rf2status.switchstatus.idlemedium = true
                        rf2status.switchstatus.idlehigh = false
                    end
                else
                    rf2status.switchstatus.idlemedium = false
                end
                if rf2status.switchIdlehighParam ~= nil and rf2status.switchIdlehighParam:state() == true then
                    if rf2status.switchstatus.idlehigh == nil or rf2status.switchstatus.idlehigh == false then
                        system.playFile(widgetDir .. "sounds/switches/idle-h.wav")
                        rf2status.switchstatus.idlelow = false
                        rf2status.switchstatus.idlemedium = false
                        rf2status.switchstatus.idlehigh = true
                    end
                else
                    rf2status.switchstatus.idlehigh = false
                end

                -- RATES
                if rf2status.switchrateslowParam ~= nil and rf2status.switchrateslowParam:state() == true then
                    if rf2status.switchstatus.rateslow == nil or rf2status.switchstatus.rateslow == false then
                        system.playFile(widgetDir .. "sounds/switches/rates-l.wav")
                        rf2status.switchstatus.rateslow = true
                        rf2status.switchstatus.ratesmedium = false
                        rf2status.switchstatus.rateshigh = false
                    end
                else
                    rf2status.switchstatus.rateslow = false
                end
                if rf2status.switchratesmediumParam ~= nil and rf2status.switchratesmediumParam:state() == true then
                    if rf2status.switchstatus.ratesmedium == nil or rf2status.switchstatus.ratesmedium == false then
                        system.playFile(widgetDir .. "sounds/switches/rates-m.wav")
                        rf2status.switchstatus.rateslow = false
                        rf2status.switchstatus.ratesmedium = true
                        rf2status.switchstatus.rateshigh = false
                    end
                else
                    rf2status.switchstatus.ratesmedium = false
                end
                if rf2status.switchrateshighParam ~= nil and rf2status.switchrateshighParam:state() == true then
                    if rf2status.switchstatus.rateshigh == nil or rf2status.switchstatus.rateshigh == false then
                        system.playFile(widgetDir .. "sounds/switches/rates-h.wav")
                        rf2status.switchstatus.rateslow = false
                        rf2status.switchstatus.ratesmedium = false
                        rf2status.switchstatus.rateshigh = true
                    end
                else
                    rf2status.switchstatus.rateshigh = false
                end

                -- RESCUE
                if rf2status.switchrescueonParam ~= nil and rf2status.switchrescueonParam:state() == true then
                    if rf2status.switchstatus.rescueon == nil or rf2status.switchstatus.rescueon == false then
                        system.playFile(widgetDir .. "sounds/switches/rescue-on.wav")
                        rf2status.switchstatus.rescueon = true
                        rf2status.switchstatus.rescueoff = false
                    end
                else
                    rf2status.switchstatus.rescueon = false
                end
                if rf2status.switchrescueoffParam ~= nil and rf2status.switchrescueoffParam:state() == true then
                    if rf2status.switchstatus.rescueoff == nil or rf2status.switchstatus.rescueoff == false then
                        system.playFile(widgetDir .. "sounds/switches/rescue-off.wav")
                        rf2status.switchstatus.rescueon = false
                        rf2status.switchstatus.rescueoff = true
                    end
                else
                    rf2status.switchstatus.rescueoff = false
                end

                -- BBL
                if rf2status.switchbblonParam ~= nil and rf2status.switchbblonParam:state() == true then
                    if rf2status.switchstatus.bblon == nil or rf2status.switchstatus.bblon == false then
                        system.playFile(widgetDir .. "sounds/switches/bbl-on.wav")
                        rf2status.switchstatus.bblon = true
                        rf2status.switchstatus.bbloff = false
                    end
                else
                    rf2status.switchstatus.bblon = false
                end
                if rf2status.switchbbloffParam ~= nil and rf2status.switchbbloffParam:state() == true then
                    if rf2status.switchstatus.bbloff == nil or rf2status.switchstatus.bbloff == false then
                        system.playFile(widgetDir .. "sounds/switches/bbl-off.wav")
                        rf2status.switchstatus.bblon = false
                        rf2status.switchstatus.bbloff = true
                    end
                else
                    rf2status.switchstatus.bbloff = false
                end

            end
			
			
			---
			-- TIME
			if rf2status.linkUP ~= 0 then
				if armswitchParam ~= nil then
					if armswitchParam:state() == false then
						rf2status.stopTimer = true
						stopTIME = os.clock()
						timerNearlyActive = 1
						rf2status.theTIME = 0
					end
				end

				if rf2status.idleupswitchParam ~= nil then
					if rf2status.idleupswitchParam:state() then
						if timerNearlyActive == 1 then
							timerNearlyActive = 0
							startTIME = os.clock()
						end
						if startTIME ~= nil then rf2status.theTIME = os.clock() - startTIME end
					end
				end

			end

			-- LOW FUEL ALERTS
			-- big conditional to announcement rf2status.lfTimer if needed
			if rf2status.linkUP ~= 0 then
				if rf2status.idleupswitchParam ~= nil then
					if rf2status.idleupswitchParam:state() then
						if (rf2status.sensors.fuel <= rf2status.lowfuelParam and rf2status.alertonParam == 1) then
							rf2status.lfTimer = true
						elseif (rf2status.sensors.fuel <= rf2status.lowfuelParam and rf2status.alertonParam == 2) then
							rf2status.lfTimer = true
						else
							rf2status.lfTimer = false
						end
					else
						rf2status.lfTimer = false
					end
				else
					rf2status.lfTimer = false
				end
			else
				rf2status.lfTimer = false
			end

			if rf2status.lfTimer == true then
				-- start timer
				if rf2status.lfTimerStart == nil then rf2status.lfTimerStart = os.time() end
			else
				rf2status.lfTimerStart = nil
			end

			if rf2status.lfTimerStart ~= nil then
				-- only announcement if we have been on for 5 seconds or more
				if (tonumber(os.clock()) - tonumber(rf2status.lfAudioAlertCounter)) >= rf2status.alertintParam then
					rf2status.lfAudioAlertCounter = os.clock()

					system.playFile(widgetDir .. "sounds/alerts/lowfuel.wav")

					-- system.playNumber(rf2status.sensors.voltage / 100, 2, 2)
					if alrthptParam == true then system.playHaptic("- . -") end

				end
			else
				-- stop timer
				rf2status.lfTimerStart = nil
			end

			-- LOW VOLTAGE ALERTS
			-- big conditional to announcement rf2status.lvTimer if needed
			if rf2status.linkUP ~= 0 then

				if rf2status.idleupswitchParam ~= nil then
					if rf2status.idleupswitchParam:state() then
						if (rf2status.voltageIsLow and rf2status.alertonParam == 0) then
							rf2status.lvTimer = true
						elseif (rf2status.voltageIsLow and rf2status.alertonParam == 2) then
							rf2status.lvTimer = true
						else
							rf2status.lvTimer = false
						end
					else
						rf2status.lvTimer = false
					end
				else
					rf2status.lvTimer = false
				end
			else
				rf2status.lvTimer = false
			end

			if rf2status.lvTimer == true then
				-- start timer
				if rf2status.lvTimerStart == nil then rf2status.lvTimerStart = os.time() end
			else
				rf2status.lvTimerStart = nil
			end

			if rf2status.lvTimerStart ~= nil then
				if (os.time() - rf2status.lvTimerStart >= rf2status.sagParam) then
					-- only announcement if we have been on for 5 seconds or more
					if (tonumber(os.clock()) - tonumber(rf2status.lvAudioAlertCounter)) >= rf2status.alertintParam then
						rf2status.lvAudioAlertCounter = os.clock()

						if rf2status.lvStickannouncement == false then -- do not play if sticks at high end points
							system.playFile(widgetDir .. "sounds/alerts/lowvoltage.wav")
							-- system.playNumber(rf2status.sensors.voltage / 100, 2, 2)
							if alrthptParam == true then system.playHaptic("- . -") end
						else
							-- print("Alarm supressed due to stick positions")
						end

					end
				end
			else
				-- stop timer
				rf2status.lvTimerStart = nil
			end			
			---

        else
            rf2status.adjJUSTUP = true
        end
    end

    return
end

function rf2status.viewLogs()
    rf2status.showLOGS = true
end

function rf2status.menu(widget)

    return {
        {
            "View logs", function()
                rf2status.viewLogs()
            end
        }
    }

end

return rf2status
