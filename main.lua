
local function pause()
	os.execute("pause")
end
local function title(st)
	os.execute("title "..st)
end
local function cls()
	os.execute("cls")
end


title("universal-github-exe.exe package maker")
function runcode()
	


	local function reslash(st)
		local v1 = st:gsub("\\","/")
		return v1
	end
	
	local inputparams = {}
	local function addparam(param)
		table.insert(inputparams, param)
	end
	
	
	
	
	addparam({
		name = "Is this for a release on a GitHub repository? [y/n]",
		varname = "is_github_release",
		valid = {"y","n"},
		hide = true,
	})
	addparam({
		name = "Repository link",
		varname = "repository_link",
		prereq = {"is_github_release","y"}
	})
	addparam({
		name = "File download link.",
		varname = "file_download_link",
		prereq = {"is_github_release","n"}
	})
	addparam({
		name = "version file link",
		varname = "version_file_link",
	})
	addparam({
		name = "package name on github (MyProgram.exe)",
		varname = "package_name",
		prereq = {"is_github_release","y"},
	})
	addparam({
		name = "package name (MyProgram.exe)",
		varname = "package_name",
		prereq = {"is_github_release","n"},
	})
	addparam({
		name = "install folder (inside roaming folder)",
		varname = "parent_install_folder",
		afterf = reslash,
	})
	
	addparam({
		name = "Add taskkill command during update ('y' for your package name, or type a custom command)(leave blank to skip)",
		varname = "add_taskkill_command",
	})
	addparam({
		name = "Would you like to make this executable force update when launched? [y/n](The user can turn this on if they want but they cannot turn it off if this is enabled)",
		varname = "always_force_update",
		valid = {"y","n"},
	})
	
	
	
	local function getinputp(varname)
		for _,p in pairs(inputparams) do
			if p.input and p.varname == varname then
				return p.input
			end
		end
	end
	
	local function printparams()
		for _,p in pairs(inputparams) do
			if p.input and not p.hide then
				print(p.varname.." = "..p.input)
				print("")
			end
		end
	end
	
	
	
	for i,p in ipairs(inputparams) do
		cls()
		printparams()
		while true do
			if p.prereq and getinputp(p.prereq[1]) ~= p.prereq[2] then
				break
			end
			print(p.name)
			local userinput = io.read():gsub('"',"")
			if p.afterf then
				userinput = p.afterf(userinput)
			end
			local validinput = false
			if p.valid then
				for _,vi in pairs(p.valid) do
					if vi == userinput then
						validinput = true
						break
					end
				end
			else
				validinput = true
			end
			if validinput then
				inputparams[i].input = userinput
				break
			else
				print("Invalid input")
				print("try:")
				for _,vi in pairs(p.valid) do
					print(vi)
				end
			end
			
		end
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
	FILE2="lua5.1.dll"
	FILE3="lfs.dll"
	[SourceFiles]
	SourceFiles0=]]..outputfolder..[[\
	[SourceFiles0]
	%FILE0%=
	%FILE1%=
	%FILE2%=
	%FILE3%=
	]]
	
	local function loadtext(str)
		local temp = io.open(str,"r")
		local temp2 = temp:read("*all")
		temp:close()
		return temp2
	end
	local updatecode = loadtext("downloader.lua")
	for i,p in ipairs(inputparams) do
		if p.input then
			updatecode = updatecode:gsub(p.varname,p.input)
		end
	end
	for i,p in ipairs(inputparams) do
		if p.input then
			sedfile = sedfile:gsub(p.varname,p.input)
		end
	end
	savefile("downloader.lua",updatecode)
	savefile("makepackage.bat",makepackage)
	local files_to_copy = {
		"universal-github-exe.exe",
		"lua5.1.dll",
		"lfs.dll"
	}
	
	for _, file in ipairs(files_to_copy) do
		os.execute([[copy "]]..file..[[" "]]..outputfolder..[[\]]..file..[["]])
	end
	
	savefile("express.SED",sedfile)
	os.execute([[call "]]..outputfolder.."/makepackage.bat"..[["]])

end

OK, err = pcall(runcode)
if not OK then
	print("\n")
	print(err)
	pause()
end

