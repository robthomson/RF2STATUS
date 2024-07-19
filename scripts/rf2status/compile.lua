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

function compile.loadScript(script)

    if config.useCompiler == true then
        local cachefile
        cachefile = widgetDir .. "compiled/" .. script:gsub("/", "_") .. "c"
        if compile.file_exists(cachefile) ~= true then
            system.compile(script)
            os.rename(script .. 'c', cachefile)
        end
        return loadfile(cachefile)
    else
        -- print(script)
        if compile.file_exists(cachefile) == true then
            os.remove(cachefile)
        end			
        return loadfile(script)
    end

end

return compile
