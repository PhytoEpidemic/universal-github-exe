

print("main download link")



local mainlink = io.read():gsub('"',"")
print("version file link")
local versionlink = io.read():gsub('"',"")
print("package name (MyProgram.exe)")
local packagename = io.read():gsub('"',"")
print("install folder (inside roaming folder)")
local parentfolder = io.read():gsub('"',"")

print("output folder (where your package will be created)")
local outputfolder = io.read():gsub('"',"")

outputfolder = outputfolder.."/"..packagename.."_universal"
os.execute([[mkdir "]]..outputfolder..[["]])
function savefile(file,text)
	print(outputfolder.."/"..file)
	local thefile = io.open(outputfolder.."/"..file,"w")
	thefile:write(text.."\n")
	thefile:close()
end






local installcode = [[
mkdir "%AppData%\]]..parentfolder..[["
robocopy /E %~dp0 "%AppData%\]]..parentfolder..[["
"%AppData%\]]..parentfolder..[[\run_exe.bat"

]]
local makepackage = [[
cd %~dp0
iexpress /N iexpressinfo.sed
]]

local updatecode = [[
local function cls()
	os.execute("cls")
end
local function title(st)
	os.execute("title "..st)
end
title("]]..packagename..[[ updater")
os.execute(]].."[["..[[curl -o "versioncheck.txt" -L "]]..versionlink..[["]].."]]"..[[)
local thisversion = io.open("version.txt","r")
local nvtext = ""
local vtext = ""
local update = false
if thisversion then
	local newversion = io.open("versioncheck.txt","r")
	vtext = thisversion:read("*all")
	nvtext = newversion:read("*all")
	if vtext ~= nvtext then
		update = true
		os.remove("version.txt")
		os.rename("versioncheck.txt","version.txt")
	end
	thisversion:close()
	newversion:close()
	os.remove("versioncheck.txt")
else
	os.rename("versioncheck.txt","version.txt")
	update = true
end

if update then
	os.execute(]].."[["..[[powershell -window normal -command ""]].."]]"..[[)
	cls()
	print("Out of date version: "..vtext)
	print("Would you like to update to version: "..nvtext.."?")
	if vtext == "" or io.read() == "y" then
		cls()
		print("Updating to version: "..nvtext)
		os.execute(]].."[["..[[curl -o "]]..packagename..[[" -L "]]..mainlink..[["]].."]]"..[[)
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
FILE3="run_exe.bat"
[SourceFiles]
SourceFiles0=]]..outputfolder..[[\
[SourceFiles0]
%FILE0%=
%FILE1%=
%FILE2%=
%FILE3%=
]]

savefile("downloader.lua",updatecode)
savefile("installer.bat",installcode)
savefile("makepackage.bat",makepackage)
os.execute([[copy "lua.exe" "]]..outputfolder..[[\lua.exe"]])
os.execute([[copy "run_exe.bat" "]]..outputfolder..[[\run_exe.bat"]])
savefile("iexpressinfo.sed",sedfile)
os.execute([["]]..outputfolder.."\\makepackage.bat"..[["]])

