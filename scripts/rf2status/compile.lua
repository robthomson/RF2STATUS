local compile = {}


local arg={...}
local WIDGET_DIR = arg[1].WIDGET_DIR

function compile.file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function compile.loadScript(script)

	local cachefile
	
	cachefile = WIDGET_DIR .. "compiled/" .. script:gsub( "/", "_") .. "c"


	if compile.file_exists(cachefile) ~= true then
		system.compile(script)
		os.rename(script .. 'c', cachefile)
	end	
	
	return loadfile(cachefile)
	
	
end



return compile