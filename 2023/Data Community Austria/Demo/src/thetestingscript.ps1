<# Script to be tested

This script will perform a number of tasks
#>

# Normally we would not put passwords here - we would use the secret management module or a Key Vault but demo time is short
$secStringPassword = ConvertTo-SecureString -String 'dbatools.IO' -AsPlainText -Force
[pscredential]$cred = New-Object System.Management.Automation.PSCredential ('sa', $secStringPassword)

# Create some databases

$Databases = 'Database1','BeardsAreAwesome'
$Databases | ForEach-Object {
    New-DbaDatabase -SqlInstance db -SqlCredential $cred -Name $PsItem
}

# Create some users

$Users = 'Beard','Jess', 'Chrissy','Claudio','William','Gianluca','BW1','BW2','BW3'

foreach ($User in $Users){
    New-DbaLogin  -SqlInstance db -SqlCredential $cred -Login $User -SecurePassword $cred.Password -DefaultDatabase tempdb 
}

# Create some logins

# Create some Agent Jobs

# Set some configuration