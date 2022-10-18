# Snap

This tool is used to save the location of desktop windows and move them back to that location on demand.

## Requirements
Powershell 7

Windows 10 or higher

## Usage
1. Download all files
2. Find the process name of all the windows you wish to manage
- This can be done by opening Task Manager (ctrl + shift + esc)
- Find the process name, right click, properties
- The name will be something like "spotify.exe" copy the text except for the extension ".exe"
- Paste this into `process.json` following the json array formatting in the example.  
(All example process names in `processes.json` can be removed as requried)

3. Manually organise your windows in the location you want them to be moved back to then run `save_instant.bat`
5. Whenever you want to move your windows back to this location run `snap_instant.bat`
