
local function showwindow()
	os.execute([[powershell -window normal -command ""]])
end
local function hidewindow()
	os.execute([[powershell -window hidden -command ""]])
end

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
local function checkVersion()
	os.execute([[curl -o "versioncheck.txt" -L "version_file_link"]])
	local thisversion = io.open(applocation.."/version.txt","r")
	local nvtext = ""
	local vtext = ""
	local needsupdate = false
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
			needsupdate = true
		end
	else
		needsupdate = true
	end
	return (not noconnection), needsupdate, vtext, nvtext
end




function askBox(title,text,buttons,typ)
	name = name or "title"
	text = text or "text"
	buttons = buttons or "YesNo" --"OK"
	typ = typ or "Information" --"Warning"
	local bfile = io.open("askBox.bat","w")
	bfile:write([[
@echo off

powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show(']]..text..[[', ']]..title..[[', ']]..buttons..[[', [System.Windows.Forms.MessageBoxIcon]::]]..typ..[[);}" > %TEMP%\out.tmp
set /p OUT=<%TEMP%\out.tmp
echo %OUT%
]])
	bfile:close()
	local tf = io.popen([[askBox.bat]])
	local answer = tf:read("*l")
	if answer then
		answer = answer
	else
		answer = false
	end
	tf:close()
	os.remove([[askBox.bat]])
	return answer
end

local function runprogram()
	local check = io.popen([[start %AppData%\"]]..parentfolder.."\\"..packagename..[[" 2>&1]])
	local info = check:read("*all")
	check:close()
	return not (#info > 3)
end



local function updateprogram(forceupdate)
	local hasconnection, needsupdate, vtext, nvtext = checkVersion()
	if not hasconnection then
		askBox(packagename.." updater","You have no internet connection. Unable to update","OK","Warning")
		
		
		if vtext == "" then
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
		if forceupdate or (vtext == "") or (dontask or (askBox(packagename.." updater","Out of date version: "..vtext.." Would you like to update to version: "..nvtext.."?","YesNo","Information") == "Yes")) then
			if (not dontask) and (not forceupdate) and (askBox(packagename.." updater","Always ask before updating?","YesNo","Information") ~= "Yes") then
				local askbefore = io.open(applocation..[[/dontask.txt]],"w")
				askbefore:write("Yes")
				askbefore:close()
			end
			showwindow()
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
			hidewindow()
		end
	end
	
end

local function updateloop(forceupdate)
	while true do
		updateprogram(forceupdate)
		if runprogram() then
			return true
		else
			if askBox(packagename.." updater","Program was unable to open. Would you like to try updating again?","YesNo","Warning") == "Yes" then
				forceupdate = true
			else
				return false
			end
		end
	end
end
local _, needsupdate = checkVersion()
if needsupdate then
	updateloop()
elseif not runprogram() then
	if askBox(packagename.." updater","Program was unable to open properly. Would you like to try updating to repair it?","YesNo","Warning") == "Yes" then
		updateloop(true)
	end
end



