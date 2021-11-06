$rgnames = 'PassBeard','PassBeards','PassBeard-Admin'

foreach ($rg in $rgnames) {
    $r = Get-AzResourceGroup -Name $rg -ErrorAction SilentlyContinue
    if($r){
        $message =  "We have a resource group called {0}" -f $rg
        Write-PSFMessage $message -Level Output
        try {
            $message =  "###   Removing resource group {0}" -f $rg
            Write-PSFMessage $message -Level Output
            Remove-AzResourceGroup -Name $rg -Confirm:$false -Force
            $message =  "###   Resource group {0} Removed" -f $rg
            Write-PSFMessage $message -Level Output
        }
        catch {
            $message =  "###   FAILED - REMOVING -Resource group {0}" -f $rg
            Write-PSFMessage $message -Level Significant
        }
    }else {
        $message =  "There is no resource group called {0}" -f $rg
        Write-PSFMessage $message -Level Output
    }
}