<#
Instead of Import-Module -FullyQualifiedName @{...} we use Import-Module -Name ... -Version ...;
Instead of Get-FileHash, we’re going to need to use .NET directly and write a function;
Instead of Split-Path -LeafBase, we can use [System.IO.Path]::GetFileNameWithoutExtension();
Instead of Compress-Archive we’ll need to use more .NET methods in a function, and;
Instead of Out-File -NoNewline we can use New-Item -Value
#>











#

Get-CimClass -Class win32_OperatingSystem
Get-Service -ComputerName Beard | ForEach-Object {$_}