
local function pause()
	os.execute("pause")
end
local function title(st)
	os.execute("title "..st)
end
title("universal-github-exe.exe package maker")
function runcode()
	


	local function reslash(st)
		local v1 = st:gsub("\\","/")
		return v1
	end
	
	local inputparams = {
		[1] = {
			name = "Repository link",
			varname = "repository_link",
		},
		[2] = {
			name = "package name on github (MyProgram.exe)",
			varname = "package_name",
		},
		[3] = {
			name = "install folder (inside roaming folder)",
			varname = "parent_install_folder",
		},
		[4] = {
			name = "version file link",
			varname = "version_file_link",
		},
		[5] = {
			name = "Add taskkill command during update ('y' for your package name, or type a custom command)(leave blank to skip)",
			varname = "add_taskkill_command",
		},
	
	}
	
	local function getinputp(varname)
		for _,p in pairs(inputparams) do
			if p.varname == varname then
				return p.input
			end
		end
	end
	
	
	
	for i,p in ipairs(inputparams) do
		print(p.name)
		inputparams[i].input = io.read():gsub('"',"")
	end
	
	--print("main download link")
	
	--local mainlink = io.read():gsub('"',"")
	print("output folder (where your new package will be created)")
	local outputfolder = reslash(io.read():gsub('"',""))
	
	outputfolder = outputfolder.."/"..getinputp("package_name").."_universal"
	os.execute([[mkdir "]]..outputfolder..[["]])
	function savefile(file,text)
		print(outputfolder.."/"..file)
		print(text)
		local thefile = io.open(outputfolder.."/"..file,"w")
		thefile:write(text.."\n")
		thefile:close()
	end
	
	
	
	
	local makepackage = [[
	pushd "%~dp0"
	iexpress /N express.SED
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
	TargetName="]]..outputfolder..[[\package_name"
	FriendlyName=dp
	AppLaunched=universal-github-exe.exe downloader.lua
	PostInstallCmd=<None>
	AdminQuietInstCmd=
	UserQuietInstCmd=
	FILE0="universal-github-exe.exe"
	FILE1="downloader.lua"
	[SourceFiles]
	SourceFiles0=]]..outputfolder..[[\
	[SourceFiles0]
	%FILE0%=
	%FILE1%=
	]]
	
	local function loadtext(str)
		local temp = io.open(str,"r")
		local temp2 = temp:read("*all")
		temp:close()
		return temp2
	end
	local updatecode = loadtext("downloader.lua")
	for i,p in ipairs(inputparams) do
		updatecode = updatecode:gsub(p.varname,p.input)
	end
	for i,p in ipairs(inputparams) do
		sedfile = sedfile:gsub(p.varname,p.input)
	end
	savefile("downloader.lua",updatecode)
	savefile("makepackage.bat",makepackage)
	os.execute([[copy "universal-github-exe.exe" "]]..outputfolder..[[\universal-github-exe.exe"]])
	savefile("express.SED",sedfile)
	os.execute([[call "]]..outputfolder.."/makepackage.bat"..[["]])

end

OK, err = pcall(runcode)
if not OK then
	print("\n")
	print(err)
	pause()
end

