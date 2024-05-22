
	print("Compiling scripts")

    local script = assert(loadfile("/scripts/RF2STATUS/compile/scripts.lua"))(i)

	for i,v in ipairs(script) do

		print("Compile: " .. v)
		system.compile(v)
		
	end	

	local file = io.open("/scripts/RF2STATUS/compile/scripts_compiled.lua", 'w')
    io.write(file, "return true")
    io.close(file)

return 
