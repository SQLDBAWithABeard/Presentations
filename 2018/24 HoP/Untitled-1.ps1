$Instance = 'ROB-XPS'
#region comparing foreach
$a = 0..10000
0..10 | ForEach-Object {

    $withcmdlet = Measure-Command {
        $a | ForEach-Object {
            $psitem
        }
    }
Write-Output "With Cmdlet = $($withstatement.TotalMilliseconds) "

    $withstatement = Measure-Command {
        foreach ($Beard in $a) {
            $Beard
        }
    }
Write-Output "With Statement = $($withstatement.TotalMilliseconds) "
    $WithMethod = Measure-Command {
        $A.ForEach{
            $psitem
        }
    }
    Write-Output "With Method= $($withMethod.TotalMilliseconds) "
}

#endregion

#region foreach database
$a = Get-DbaDatabase -SqlInstance ROB-XPS

$TotalCmdlet = @()
$TotalStatement= @()
$TotalMethod = @()

0..10 | ForEach-Object {

    $withcmdlet = Measure-Command {
        $a | ForEach-Object {
            $psitem
        }
    }
    $TotalCmdlet += $withcmdlet 

    $withstatement = Measure-Command {
        foreach ($Beard in $a) {
            $Beard
        }
    }
    $TotalStatement += $withstatement

    $WithMethod = Measure-Command {
        $A.ForEach{
            $psitem
        }
    }


$TotalMethod += $WithMethod
}

$CmdletAverage = ($TotalCmdlet | Measure-Object TotalMilliseconds -Average).Average
$StatementAverage = ($TotalStatement | Measure-Object TotalMilliseconds -Average).Average
$MethodAverage = ($TotalMethod | Measure-Object  TotalMilliseconds -Average).Average

Write-Output "Average using ForEach Cmdlet = $CmdletAverage Milliseconds"
Write-Output "Average using ForEach Statement = $StatementAverage Milliseconds"
Write-Output "Average using With ForEach Method = $MethodAverage Milliseconds"

#endregion

#region foreach database property
$a = Get-DbaDatabase -SqlInstance ROB-XPS
$TotalCmdlet = @()
$TotalStatement= @()
$TotalMethod = @()
0..10 | ForEach-Object {

    $withcmdlet = Measure-Command {
        $a | ForEach-Object {
            $psitem.AutoClose
        }
    }
    $TotalCmdlet += $withcmdlet 

    $withstatement = Measure-Command {
        foreach ($Beard in $a) {
            $Beard.AutoClose
        }
    }
    $TotalStatement += $withstatement

    $WithMethod = Measure-Command {
        $A.ForEach{
            $psitem.AutoClose
        }
    }


$TotalMethod += $WithMethod
}

$MCCmdletAverage = ($TotalCmdlet | Measure-Object TotalMilliseconds -Average).Average
$MCStatementAverage = ($TotalStatement | Measure-Object TotalMilliseconds -Average).Average
$MCMethodAverage = ($TotalMethod | Measure-Object  TotalMilliseconds -Average).Average
cls
Write-Output "Average using ForEach Cmdlet = $MCCmdletAverage Milliseconds"
Write-Output "Average using ForEach Statement = $MCStatementAverage Milliseconds"
Write-Output "Average using With ForEach Method = $MCMethodAverage Milliseconds"

#endregion

#region how to list one property quickest
$onelisttime = @()
0..10 | ForEach-Object {
    $onelist = Measure-Command{
        $a.AutoClose
    }
    $onelisttime += $onelist
}
$MCJustOneProperty = ($onelisttime | Measure-Object TotalMilliseconds -Average).Average

cls
Write-Output "Average using ForEach Cmdlet = $MCCmdletAverage Milliseconds"
Write-Output "Average using ForEach Statement = $MCStatementAverage Milliseconds"
Write-Output "Average using With ForEach Method = $MCMethodAverage Milliseconds"
Write-Output "Average listing just one property = $MCJustOneProperty  Milliseconds"

#endregion 

$sw = [diagnostics.stopwatch]::StartNew()
$sw.Stop()
$sw

#region using stopwatch
$TotalCmdlet = @()
$TotalStatement= @()
$TotalMethod = @()
$onelisttime = @()

$a = Get-DbaDatabase -SqlInstance ROB-XPS

0..10 | ForEach-Object {

    $sw = [diagnostics.stopwatch]::StartNew()
        $a | ForEach-Object {
            $psitem.AutoClose
        }
        $sw.Stop()
    
    $TotalCmdlet += $sw

    $sw = [diagnostics.stopwatch]::StartNew()
        foreach ($Beard in $a) {
            $Beard.AutoClose
        }
        $sw.Stop()
    $TotalStatement += $sw

    $sw = [diagnostics.stopwatch]::StartNew()
        $A.ForEach{
            $psitem.AutoClose
        }
        $sw.Stop()


$TotalMethod += $sw



$sw = [diagnostics.stopwatch]::StartNew()
        $a.AutoClose
    $sw.Stop()
    Start-Sleep -Milliseconds 500
    $onelisttime += $sw


}

$JustOneProperty = ($onelisttime | Measure-Object ElapsedMilliseconds -Average).Average
$CmdletAverage = ($TotalCmdlet | Measure-Object ElapsedMilliseconds -Average).Average
$StatementAverage = ($TotalStatement | Measure-Object ElapsedMilliseconds -Average).Average
$MethodAverage = ($TotalMethod | Measure-Object  ElapsedMilliseconds -Average).Average
cls
Write-Output "Average using ForEach Cmdlet Measure = $MCCmdletAverage Milliseconds"
Write-Output "Average using ForEach Statement Measure = $MCStatementAverage Milliseconds"
Write-Output "Average using With ForEach Method Measure = $MCMethodAverage Milliseconds"
Write-Output "Average listing just one property Measure = $MCJustOneProperty  Milliseconds"

Write-Output "Average using ForEach Cmdlet stopwatch = $CmdletAverage Milliseconds"
Write-Output "Average using ForEach Statement stopwatch = $StatementAverage Milliseconds"
Write-Output "Average using With ForEach Method stopwatch = $MethodAverage Milliseconds"
Write-Output "Average listing just one property stopwatch = $JustOneProperty  Milliseconds"
#endregion

#region Don't loop When you dont need to
$a = Get-DbaDatabase -SqlInstance ROB-XPS



    $sw = [diagnostics.stopwatch]::StartNew()
        $a | ForEach-Object {
            Get-DbaLastBackup -SqlInstance $psitem.Sqlinstance -Database $psitem.Name| Write-DbaDataTable -SqlInstance ROB-XPS -Database tempdb -Table ObjectLastBackup -AutoCreateTable
        }
        $sw.Stop()
    
        $Cmdlet = $sw

    $sw = [diagnostics.stopwatch]::StartNew()
        foreach ($Beard in $a) {
            Get-DbaLastBackup -SqlInstance $Beard.Sqlinstance -Database $Beard.Name| Write-DbaDataTable -SqlInstance ROB-XPS -Database tempdb -Table StatementLastBackup -AutoCreateTable
        }
        $sw.Stop()
    $Statement = $sw

    $sw = [diagnostics.stopwatch]::StartNew()
        $A.ForEach{
            Get-DbaLastBackup -SqlInstance $psitem.Sqlinstance -Database $psitem.Name| Write-DbaDataTable -SqlInstance ROB-XPS -Database tempdb -Table MethodLastBackup -AutoCreateTable
        } 
        $sw.Stop()


$Method = $sw


cls
Write-Output "Using ForEach Cmdlet = $($Cmdlet.ElapsedMilliseconds) Milliseconds"
Write-Output "Using ForEach Statement = $($Statement.ElapsedMilliseconds) Milliseconds"
Write-Output "Using With ForEach Method = $($Method.ElapsedMilliseconds) Milliseconds"

$sw = [diagnostics.stopwatch]::StartNew()

Get-DbaLastBackup -SqlInstance Rob-XPS | Write-DbaDataTable -SqlInstance ROB-XPS -Database tempdb -Table LastBackup -AutoCreateTable

$sw.Stop()

$sw

(0..200)| ForEach-Object {
    Invoke-DbaSqlQuery -SqlInstance $Instance  -Database master -Query "CREATE DATABASE [Test_$Psitem]"
}

#endregion

#region Where is it

0..10 | ForEach-Object {
$sw = [diagnostics.stopwatch]::StartNew()
Get-DbaDatabase -SqlInstance ROB-XPS| Where-Object {$PSItem.Name -like 'Wide*'}
$sw.Stop()

$TotalCmdlet += $sw


$sw = [diagnostics.stopwatch]::StartNew()
(Get-DbaDatabase -SqlInstance ROB-XPS).Where{$PSItem.Name -like 'Wide*'}

$sw.Stop()


$TotalMethod += $sw

}

$CmdletAverage = ($TotalCmdlet | Measure-Object ElapsedMilliseconds -Average).Average
$MethodAverage = ($TotalMethod | Measure-Object  ElapsedMilliseconds -Average).Average
cls

Write-Output "Average using Cmdlet stopwatch = $CmdletAverage Milliseconds"
Write-Output "Average using  Method stopwatch = $MethodAverage Milliseconds"


#endregion