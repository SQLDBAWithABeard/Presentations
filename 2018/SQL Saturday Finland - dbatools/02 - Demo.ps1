#region Setup Variables
$containers = 'bearddockerhost,15789', 'bearddockerhost,15788', 'bearddockerhost,15787', 'bearddockerhost,15786'
$SQLInstances = 'sql0','sql1'
$filenames = (Get-ChildItem C:\SQLBackups\Keep).Name
$cred = Import-Clixml $HOME\Documents\sa.cred
#endregion

#region Look at Builds
$builds = @()
$SQLInstances.ForEach{
    $builds += Get-DbaSqlBuildReference -SqlInstance $PSitem 
}

$containers.ForEach{
    $Builds += Get-DbaSqlBuildReference -SqlInstance $PSitem -SqlCredential $cred
}

$Builds | Format-Table
#endregion