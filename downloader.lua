lfs = require("lfs")

local function exe(com)
	os.execute(com)
end

local function showwindow()
	exe([[powershell -window normal -command ""]])
end

local function hidewindow()
	exe([[powershell -window hidden -command ""]])
end

local function cls()
	exe("cls")
end

local function execls(com)
	cls()
	exe(com)
end

local function execls2(com)
	execls(com)
	cls()
end

local function pause()
	exe("pause")
end

local function title(st)
	exe("title "..st)
end

local function slashback(st)
	return st:gsub("/","\\")
end

local function delete_file(filepath)
	if (lfs.attributes(filepath) ~= nil) then
		return (os.remove(filepath))
	else
		return true
	end
end

local function is_executable_running(executable_path)
	local handle = io.popen("ps -W")
	local result = handle:read("*a")
	handle:close()
	local processes = {}
	for process in string.gmatch(result, "[^\n]+") do
		processes[(process:sub(65,#process):gsub("/","\\"))] = true
	end
	return processes[(executable_path:gsub("/","\\"))] == true
end

local function copy_file(src, dest)
	local ok, src_file = pcall(io.open, src, 'rb')
	
	if not ok then
		return false, src_file
	end
	
	local ok, dest_file = pcall(io.open, dest, 'wb')
	
	if not ok then
		src_file:close()
		
		return false, dest_file
	end
	
	while true do
		local chunk = src_file:read(1024)
		
		if chunk == nil then break end
		
		dest_file:write(chunk)
	end
	
	src_file:close()
	dest_file:close()
	
	return true
end

local roaming = os.getenv("appdata")
local parentfolder = [[parent_install_folder]]
local UseGitHub = [[is_github_release]]
local nonGitHubLink = [[file_download_link]]
local repolink = [[repository_link]]
local packagename = [[package_name]]
local taskkillcom = [[add_taskkill_command]]
local alwaysforceupdate = [[always_force_update]]
local applocation = (roaming..[[/]]..parentfolder):gsub("\\","/")
local appdestination = applocation..[[/]]..packagename

title(packagename.." updater")

local function download_new_version_file()
	exe([[curl -o "versioncheck.txt" -L "version_file_link"]])
end

local function checkVersion(no_cache)
	local thisversion = io.open(applocation..[[/version.txt]],"r")
	local nvtext = ""
	local vtext = ""
	local needsupdate = false
	
	if thisversion then
		vtext = thisversion:read("*all")
		
		thisversion:close()
	end
	
	local noconnection = false
	local newversion = false
	
	if not no_cache then
		newversion = io.open([[versioncheck.txt]],"r")
	end
	
	local function read_new_version_file()
		nvtext = newversion:read("*all")
		
		newversion:close()
		
		noconnection = false
	end
	
	if newversion then
		read_new_version_file()
	else
		for download_attempt=1,5 do
			download_new_version_file()
			
			newversion = io.open([[versioncheck.txt]],"r")
			
			if newversion then
				read_new_version_file()
				
				break
			else
				noconnection = true
			end
			
			exe([[timeout 1]])
		end
	end
	
	if thisversion then
		if vtext ~= nvtext or vtext == "" then
			needsupdate = true
		end
	else
		needsupdate = true
	end
	
	return (not noconnection), needsupdate, vtext, nvtext
end

local function askBox(title,text,buttons,typ)
	title = title or "title"
	text = text or "text"
	buttons = buttons or "YesNo" --"OK"
	typ = typ or "Information" --"Warning"
	local bfile = io.open("askBox.bat","w")
	
	bfile:write([[
@echo off

powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show(']]..text..[[', ']]..title..[[', ']]..buttons..[[', [System.Windows.Forms.MessageBoxIcon]::]]..typ..[[);}" > %TEMP%\out.tmp
set /p OUT=<%TEMP%\out.tmp
echo %OUT%
]])--batch code from https://gist.github.com/shalithasuranga/aa5fc661dda192015cfeb26d02807cf6/
	bfile:close()
	
	local tf = io.popen([[askBox.bat]])
	local answer = tf:read("*l")
	
	if answer then
		answer = answer
	else
		answer = false
	end
	
	tf:close()
	delete_file([[askBox.bat]])
	
	return answer
end

local function runprogram()
	return ((os.execute(appdestination) == 0) or (lfs.attributes(applocation..[[/updating_app.tmp]]) ~= nil))
end

local function updateVersionFile()
	os.rename(applocation..[[/version.txt]],[[version.txt]])
	os.rename([[versioncheck.txt]],applocation..[[/version.txt]])
end

local function regressVersionFile()
	delete_file(applocation..[[/version.txt]])
	os.rename([[version.txt]],applocation..[[/version.txt]])
end

local function updateprogram(forceupdate, first_run)
	local hasconnection, needsupdate, vtext, nvtext = checkVersion(not first_run)
	local first_update_ever = vtext == ""
	
	if not hasconnection then
		askBox(packagename.." updater","You have no internet connection. Unable to update","OK","Warning")
		
		if first_update_ever then
			askBox(packagename.." updater","No version currently installed. Restore connection before trying again.","OK","Warning")
			os.exit()
		else
			if askBox(packagename.." updater","Version "..vtext.." currently installed. Would you like to run this version?","YesNo","Information") ~= "Yes" then
				os.exit()
			end
		end
	else
		local askbefore = io.open(applocation..[[/dontask.txt]],"r")
		local dontask = false
		
		if askbefore then
			dontask = askbefore:read("*all")
			
			askbefore:close()
			
			dontask = dontask == "Yes"
		end
		
		if forceupdate or (first_update_ever) or (dontask or (askBox(packagename.." updater","Out of date version: "..vtext.." Would you like to update to version: "..nvtext.."?","YesNo","Information") == "Yes")) then
			if (not dontask) and (not forceupdate) and (askBox(packagename.." updater","Always ask before updating?","YesNo","Information") ~= "Yes") then
				local askbefore = io.open(applocation..[[/dontask.txt]],"w")
				
				askbefore:write("Yes")
				askbefore:close()
			end
			local update_indicator = io.open(applocation..[[/updating_app.tmp]],"w")
			if update_indicator then
				update_indicator:close()
			end
			cls()
			showwindow()
			cls()
			
			print("Updating to version: "..nvtext)
			
			if UseGitHub == "y" then
				exe([[curl -o "]]..packagename..[[.tmp" -L "]]..repolink..[[/releases/download/]]..nvtext..[[/]]..packagename..[["]])
			else
				exe([[curl -o "]]..packagename..[[.tmp" -L "]]..nonGitHubLink..[["]])
			end
			
			execls2([[mkdir "]]..slashback(applocation)..[["]])
			
			if taskkillcom ~= "" then
				if taskkillcom == "y" and is_executable_running(appdestination) then
					execls([[taskkill /IM "]]..packagename..[["]])
					execls2([[taskkill /F /IM "]]..packagename..[["]])
				else
					execls2(taskkillcom)
				end
			end
			
			if (not delete_file(appdestination)) and (not first_update_ever) then
				hidewindow()
				
				return false, "remove", vtext
			end
			
			cls()
			print("Copying executable...")
			
			local copysucess = copy_file(packagename..[[.tmp]], appdestination)
			
			hidewindow()
			delete_file(applocation..[[/updating_app.tmp]])
			if not copysucess then
				return false, "copy", nvtext
			else
				return true
			end 
		end
	end
end

local function updateloop(forceupdate)
	local first_run = true
	
	while true do
		local update_sucess, error_type, error_info = updateprogram(forceupdate, first_run)
		
		if update_sucess then
			updateVersionFile()
			if not runprogram() then
				regressVersionFile()
				if askBox(packagename.." updater",packagename.." was unable to open. Would you like to try updating again?","YesNo","Warning") == "Yes" then
					forceupdate = true
				else
					return false
				end
			else
				return true
			end
		elseif error_type == "remove" then 
			if askBox(packagename.." updater",packagename.." version "..error_info.." was unable to be removed, you may need to run as administrator. Would you like to try updating again?","YesNo","Warning") == "Yes" then
				forceupdate = true
			else
				return false
			end
		elseif error_type == "copy" then 
			if askBox(packagename.." updater",packagename.." version "..error_info.." was unable to be installed, you may need to run as administrator. Would you like to try updating again?","YesNo","Warning") == "Yes" then
				forceupdate = true
			else
				return false
			end
		end
		
		first_run = false
	end
end

local _, needsupdate = checkVersion()

if needsupdate then
	updateloop(alwaysforceupdate == "y")
else
	if not runprogram() then
		if askBox(packagename.." updater","Program was unable to open properly. Would you like to try updating to repair it?","YesNo","Warning") == "Yes" then
			updateloop(true)
		end
	end
end



