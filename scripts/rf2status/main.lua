
local config = {}
config.widgetName = "Rotorflight Flight Status"
config.widgetKey = "bkshss"
config.widgetDir = "/scripts/rf2status/"
config.useCompiler = true

compile = assert(loadfile(config.widgetDir .. "compile.lua"))(config)

rf2status = assert(compile.loadScript(config.widgetDir .. "rf2status.lua"))(config,compile)

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

local function event(widget, category, value, x, y)
	return rf2status.event(widget, category, value, x, y)
end

local function create()
	return rf2status.create()
end

local function menu()
	return rf2status.menu()
end


local function init()
    system.registerWidget({
        key = config.widgetKey,
        name = config.widgetName,
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
