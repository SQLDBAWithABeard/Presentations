New-ADGroup -Name SockFactoryAdmins -SamAccountName SockFactoryAdmins -GroupCategory Security -GroupScope Global -DisplayName "Administrators of the SockFactory" -Description "These are the sock factory administrators" -Verbose
New-ADGroup -Name ServiceDesk -SamAccountName ServiceDesk -GroupCategory Security -GroupScope Global -DisplayName "ServiceDesk" -Description "ServiceDesk" -Verbose

$members = @{
    Name = 'gsatori'
    FullName = 'Gianluca Sartori'
},@{
    Name = 'jpomfret'
    FullName = 'Jess Pomfret'
},@{
    Name = 'kkravtsov'
    FullName = 'Kirill Kravtsov'
},@{
    Name = 'sbizzotto'
    FullName = 'Simone Bizzotto'
},@{
    Name = 'wsmelton'
    FullName = 'Shawn Melton'
},@{
    Name = 'ncain'
    FullName = 'Nicholas Cain'
},@{
    Name = 'fweinmann'
    FullName = 'Friedrich Weinmann'
},@{
    Name = 'pflynn'
    FullName = 'Patrick Flynn'
},@{
    Name = 'alevy'
    FullName = 'Andrew Levy'
}

$group = Get-ADGroup -Identity SockFactoryAdmins

foreach($add in $members){
$user = New-ADUser -Name $add.Name -SamAccountName $add.Name -DisplayName $add.FullName -PassThru -Verbose
Add-ADGroupMember $group -Members $user.name -Verbose
}
$group = Get-ADGroup -Identity ServiceDesk

$user = New-ADUser -Name bmiller -SamAccountName bmiller -DisplayName "Brett Miller" -PassThru -Verbose
Add-ADGroupMember $group -Members $user.name -Verbose