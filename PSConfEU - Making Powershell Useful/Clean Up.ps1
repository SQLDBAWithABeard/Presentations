## Clean up

Remove-PSDrive -Name OldScripts 
Remove-PSDrive -Name Presentations
Remove-PSDrive -Name ProfileFunctions

Set-Location PSFunctions:\
.\Show-DriveSizes.ps1