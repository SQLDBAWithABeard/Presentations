# Installation

# Chocolatey (in an Admin PowerShell window)

# check if running as admin

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
Write-Output "Process is running as Admin"
}
else {
    Write-Warning "Process is not running as Admin - It's better to install choco as admin"
}

[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Visual Studio Code and Azure CLI

choco install vscode -y
choco install azure-cli -y

# PowerShell Az Modules Accounts & Resources

Install-Module Az.Accounts
Install-Module Az.Resources

# Bicep

choco install bicep -y
# choco upgrade bicep -y
bicep --version

# In Visual Studio Code install required extensions

# to open CTRL + SHIFT + X

# Search for Bicep and install the extension
# Search for PowerShell and install the extension
# Search for CodeTour and install the extension

