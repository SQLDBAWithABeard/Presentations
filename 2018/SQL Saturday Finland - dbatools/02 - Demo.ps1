$containers = 'bearddockerhost,15789', 'bearddockerhost,15788', 'bearddockerhost,15787', 'bearddockerhost,15786'
$filenames = (Get-ChildItem C:\SQLBackups\Keep).Name
$cred = Import-Clixml $HOME\Documents\sa.cred

$containers.ForEach{
    $Container = $Psitem
    $NameLevel = (Get-DbaSqlBuildReference -SqlInstance $Container -SqlCredential $cred).NameLevel
    $NameLevel
    switch ($NameLevel) {
        2017 { 
            Restore-DbaDatabase -SqlInstance $PSItem -SqlCredential $cred -Path C:\sqlbackups\ -useDestinationDefaultDirectories -WithReplace            
        }
        2016 {
            $Files = $Filenames.Where{$PSitem -notlike '*2017*'}.ForEach{'C:\sqlbackups\' + $Psitem}
            Restore-DbaDatabase -SqlInstance $Container -SqlCredential $cred -Path $Files -useDestinationDefaultDirectories -WithReplace            
        }
        2014 {
            $Files = $Filenames.Where{$PSitem -notlike '*2017*' -and $Psitem -notlike '*2016*'}.ForEach{'C:\sqlbackups\' + $Psitem}
            Restore-DbaDatabase -SqlInstance $Container -SqlCredential $cred -Path $Files -useDestinationDefaultDirectories -WithReplace            
        }
        2014 {
            $Files = $Filenames.Where{$PSitem -like '*2012*'}.ForEach{'C:\sqlbackups\' + $Psitem}
            Restore-DbaDatabase -SqlInstance $Container -SqlCredential $cred -Path $Files -useDestinationDefaultDirectories -WithReplace            
        }
        Default {}
    }
}

