# Automatic Updating Executable Generator

![alt text](https://github.com/PhytoEpidemic/universal-github-exe/blob/main/logo2.png)

This allows you to create an executable that can automatically check for updates and install them for you. The updates can be hosted as GitHub releases or on a cloud service of your choice.

## Usage

To use this, you simply need to fill in the input parameters. The script will generate an executable based on the following input parameters.

- **Is this for a release on a GitHub repository? [y/n]** - Specify whether the update will be hosted on a GitHub release (y) or on a cloud service (n).
- **Repository link** - The link to the repository where the update will be hosted. This parameter is only required if the update will be hosted on a GitHub release.
- **File download link.** - The link to the file that will be downloaded and installed as the update. This parameter is only required if the update will not be hosted on a GitHub release.
- **version file link** - The link to the file that contains the current version number of the update. This file should contain only the version number, with no additional text.
- **package name on github (MyProgram.exe)** - The exact name of the update file as it is hosted on GitHub. This needs to match the name of the hosted file. This parameter is only required if the update will be hosted on a GitHub release.
- **package name (MyProgram.exe)** - The name of the update file as it will be saved locally on the user's computer. This does not need to match the name of the hosted file. This parameter is only required if the update will not be hosted on a GitHub release.
- **install folder (inside roaming folder)** - The folder where the update will be installed on the user's computer. This folder will be put inside the roaming folder.
- **Add taskkill command during update ('y' for your package name, or type a custom command)(leave blank to skip)** - Recommended = 'y'.
- **Would you like to make this executable force update when launched? [y/n](The user can turn this on if they want but they cannot turn it off if this is enabled)** - Specify whether the executable should always check for updates and install them if necessary when it is launched. If this is enabled, the user will not be able to disable the automatic updating feature.
- **Output folder (where your new package will be created)** - This is where the package will be created locally.
After filling in the input parameters, a folder will be generated with everything to re-make the automatic updating executable.

## Notes

- The 'downloader.lua' file is called by the generated executable to check for and install updates. It should not be modified unless you know what you are doing.
- The generated executable will check for updates every time it is launched. The user will be asked to update unless the 'Always ask before updating' has been disabled by the user or force update was enabled by whoever made the package.
- The generated executable will only work on Windows systems.
- The 'curl' command is used to download updates.
- If you are hosting the updates as GitHub releases, it's recommended to include a version file in the root of your repository. This file should contain the current version number of the update, with no additional text. Use the raw link for the 'version file link'.
- If you are hosting the updates on a cloud service, make sure to create a version file and upload it to the cloud. This file should contain the current version number of the update, with no additional text. The 'version file link' input parameter should point to the link to this file on the cloud.
- Officially tested and working on Dropbox and GitHub.
- Does not work for Google Drive.

