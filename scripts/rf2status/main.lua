
local config = {}
config.WIDGET_NAME = "Rotorflight Flight Status"
config.WIDGET_KEY = "bkshss"
config.WIDGET_DIR = "/scripts/rf2status/"

compile = assert(loadfile(config.WIDGET_DIR .. "compile.lua"))(config)

rf2status = assert(compile.loadScript(config.WIDGET_DIR .. "rf2status.lua"))(config,compile)

local function paint()
	return rf2status.paint()
end

local function configure()
	return rf2status.configure()
end

local function wakeup()
	return rf2status.wakeup()
end

local function read()
	return rf2status.read()
end

local function write()
	return rf2status.write()
end

local function event()
	return rf2status.event()
end

local function create()
	return rf2status.create()
end


local function init()
    system.registerWidget({
        key = config.WIDGET_KEY,
        name = config.WIDGET_NAME,
        create = create,
        configure = configure,
        paint = paint,
        wakeup = wakeup,
        read = read,
        write = write,
        event = event,
        menu = menu,
        persistent = false
    })

end

return {init = init}
