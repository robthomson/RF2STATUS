local compile = {}

local arg = {...}
local config = arg[1]
local widgetDir = config.widgetDir

function compile.file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

function compile.baseName()
    local baseName
    baseName = config.widgetDir:gsub("/scripts/", "")
    baseName = baseName:gsub("/", "")
    return baseName
end

function compile.loadScript(script)

    local cachefile
    cachefile = widgetDir .. "compiled/" .. script:gsub("/", "_") .. "c"

    if compile.file_exists("/scripts/" .. compile.baseName() .. ".nocompile") == true then config.useCompiler = false end

    if compile.file_exists("/scripts/nocompile") == true then config.useCompiler = false end

    if config.useCompiler == true then

        if compile.file_exists(cachefile) ~= true then
            system.compile(script)
            os.rename(script .. 'c', cachefile)
        end
        collectgarbage()        
        return loadfile(cachefile)
    else
        -- print(script)
        if compile.file_exists(cachefile) == true then os.remove(cachefile) end
        collectgarbage()
        return loadfile(script)
    end

end

return compile
