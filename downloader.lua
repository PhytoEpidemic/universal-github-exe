
local function cls()
	os.execute("cls")
end
local function pause()
	os.execute("pause")
end
local function title(st)
	os.execute("title "..st)
end
local appdataf = io.popen("echo %AppData%")
local roaming = appdataf:read("*all"):gsub("\n","")
appdataf:close()
local parentfolder = "parent_install_folder"
local repolink = "repository_link"
local packagename = "package_name"
local taskkillcom = "add_taskkill_command"
local applocation = roaming.."/"..parentfolder
title(packagename.." updater")
os.execute([[curl -o "versioncheck.txt" -L "version_file_link"]])
local thisversion = io.open(applocation.."/version.txt","r")
local nvtext = ""
local vtext = ""
local update = false
local newversion = io.open("versioncheck.txt","r")
if thisversion then
	vtext = thisversion:read("*all")
	thisversion:close()
end
local noconnection = false
if newversion then
	nvtext = newversion:read("*all")
	newversion:close()
else
	noconnection = true
end

if thisversion then
	if vtext ~= nvtext or vtext == "" then
		update = true
	end
else
	update = true
end

if update then
	os.execute([[powershell -window normal -command ""]])
	cls()
	if noconnection then
		print("You have no internet connection. Unable to update")
		if vtext == "" then
			print("No version currently installed. Pleases restore connection before trying again.")
			pause()
			os.exit()
		else
			print("Version "..vtext.." currently installed.")
		end
		pause()
	else
		print("Out of date version: "..vtext)
		print("Would you like to update to version: "..nvtext.."?")
		if vtext == "" or io.read() == "y" then
			cls()
			print("Updating to version: "..nvtext)
			os.execute([[curl -o "]]..packagename..[[.tmp" -L "]]..repolink..[[/releases/download/]]..nvtext..[[/]]..packagename..[["]])
			os.execute([[mkdir "]]..applocation..[["]])
			if taskkillcom ~= "" then
				if taskkillcom == "y" then
					os.execute([[taskkill /IM "]]..packagename..[["]])
					os.execute([[taskkill /IM /F "]]..packagename..[["]])
				else
					os.execute(taskkillcom)
				end
			end
			os.execute([[copy "]]..packagename..[[.tmp" "]]..applocation..[[/]]..packagename..[["]])
			os.remove(applocation.."/version.txt")
			
			os.rename("versioncheck.txt",applocation.."/version.txt")
		end
	end
	
	
end

os.execute([[start %AppData%"\]]..parentfolder.."\\"..packagename..[["]])
