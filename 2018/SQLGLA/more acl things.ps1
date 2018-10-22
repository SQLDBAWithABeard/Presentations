## create a folder and add specific permissions to it

$folder = 'C:\temp\LockedDownBackUp'
New-Item $folder -ItemType Directory
(0..5) | ForEach-Object { New-Item -Path $folder -Name $PSItem -ItemType File }

Get-ChildItem $folder

$acl = Get-Acl $folder

# BE CAREFUL - This is locking your own user account out
$User = whoami
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("$User", "Read", "ContainerInherit, ObjectInherit", "None", "Deny")

$acl.AddAccessRule($rule)
Set-Acl -path $folder $acl

# Now open Powershell and run

Get-ChildItem C:\temp\LockedDownBackUp

# You need to know what the exception type is 

$error[0].Exception.Gettype().FullName

function CanIaccess {
    Param($folder)

    try {
        Get-ChildItem $folder -ErrorAction Stop
    }
    catch [System.UnauthorizedAccessException] {
        Write-PSFHostColor "I am not allowed in " 
    }
    catch [System.Management.Automation.ItemNotFoundException] {
        Write-PSFHostColor "It Isnt there " 
    }
    catch {
        Write-PSFHostColor "Failed for a different reason" 
    }
}

CanIaccess -folder C:\temp\LockedDownBackUp
CanIaccess -folder C:\temp\NotThere
