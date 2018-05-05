## When I started using Powershell I would google for a script
## and then copy and paste it into ISE

Start-Process microsoft-edge:'https://www.google.co.uk/search?q=powershell+start+microsoft+edge&ie=&oe=#q=powershell+list+files+and+folders'

## list files and folders in a directory

dir Presentations:\ -r  | % { if ($_.PsIsContainer) { $_.FullName + "\" } else { $_.Name } }

## and when I needed to change something I would open the file and alter it

dir PSFunctions:\ -r  | % { if ($_.PsIsContainer) { $_.FullName + "\" } else { $_.Name } }

## Here is one of those original files !!!!!