


local function reslash(st)
	local v1 = st:gsub("\\","/")
	return v1
end

--print("main download link")

--local mainlink = io.read():gsub('"',"")
print("Repository link")
local repolink = io.read():gsub('"',"")
print("version file link")
local versionlink = io.read():gsub('"',"")
print("package name (MyProgram.exe)")
local packagename = io.read():gsub('"',"")
print("install folder (inside roaming folder)")
local parentfolder = reslash(io.read():gsub('"',""))

print("output folder (where your package will be created)")
local outputfolder = reslash(io.read():gsub('"',""))

outputfolder = outputfolder.."/"..packagename.."_universal"
os.execute([[mkdir "]]..outputfolder..[["]])
function savefile(file,text)
	print(outputfolder.."/"..file)
	local thefile = io.open(outputfolder.."/"..file,"w")
	thefile:write(text.."\n")
	thefile:close()
end

local gitHub = [[https://github.com/]]
PhytoEpidemic/universal-github-exe
"https://github.com/PhytoEpidemic/universal-github-exe/releases/download/Official/universal-github-exe.exe"



local installcode = [[

mkdir "%AppData%\]]..parentfolder..[["
cd %~dp0
lua.exe downloader.lua

]]
local makepackage = [[
pushd "%~dp0"
iexpress /N iexpressinfo.sed
]]

local updatecode = [[
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
local parentfolder = "]]..parentfolder..[["
local packagename = "]]..packagename..[["
local applocation = roaming.."/"..parentfolder
title("]]..packagename..[[ updater")
os.execute(]].."[["..[[curl -o "versioncheck.txt" -L "]]..versionlink..[["]].."]]"..[[)
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
	os.execute(]].."[["..[[powershell -window normal -command ""]].."]]"..[[)
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
			os.execute(]].."[["..[[curl -o "]]..packagename..[[" -L "]]..repolink..[[/releases/download/]].."]]..vtext..[["..[[/]]..packagename..[["]].."]]"..[[)
			os.execute(]].."[["..[[copy "]]..packagename..[[" "]].."]]"..[[..applocation..]].."[["..[[/]]..packagename..[["]].."]]"..[[)
			os.remove(applocation.."/version.txt")
			
			os.rename("versioncheck.txt",applocation.."/version.txt")
		end
	end
	
	
end

os.execute(]].."[["..[[start %AppData%"\]]..parentfolder.."\\"..packagename..[["]].."]]"..[[)

]]
local sedfile = [[[Version]
Class=IEXPRESS
SEDVersion=3
[Options]
PackagePurpose=InstallApp
ShowInstallProgramWindow=1
HideExtractAnimation=1
UseLongFileName=1
InsideCompressed=0
CAB_FixedSize=0
CAB_ResvCodeSigning=0
RebootMode=N
InstallPrompt=%InstallPrompt%
DisplayLicense=%DisplayLicense%
FinishMessage=%FinishMessage%
TargetName=%TargetName%
FriendlyName=%FriendlyName%
AppLaunched=%AppLaunched%
PostInstallCmd=%PostInstallCmd%
AdminQuietInstCmd=%AdminQuietInstCmd%
UserQuietInstCmd=%UserQuietInstCmd%
SourceFiles=SourceFiles
[Strings]
InstallPrompt=
DisplayLicense=
FinishMessage=
TargetName=]]..outputfolder..[[\]]..packagename..[[

FriendlyName=dp
AppLaunched=cmd /c installer.bat
PostInstallCmd=<None>
AdminQuietInstCmd=
UserQuietInstCmd=
FILE0="installer.bat"
FILE1="downloader.lua"
FILE2="lua.exe"
[SourceFiles]
SourceFiles0=]]..outputfolder..[[\
[SourceFiles0]
%FILE0%=
%FILE1%=
%FILE2%=
]]

savefile("downloader.lua",updatecode)
savefile("installer.bat",installcode)
savefile("makepackage.bat",makepackage)
os.execute([[copy "lua.exe" "]]..outputfolder..[[\lua.exe"]])
os.execute([[copy "run_exe.bat" "]]..outputfolder..[[\run_exe.bat"]])
savefile("iexpressinfo.sed",sedfile)
os.execute([[call "]]..outputfolder.."/makepackage.bat"..[["]])

