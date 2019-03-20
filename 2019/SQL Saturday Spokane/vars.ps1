[datetime]$EndDate = '2019-03-02 14:33'
if ($ENV:COMPUTERNAME -eq 'JumpBox') {
    $cred = Import-Clixml $HOME\Documents\sa.cred
    $SQLInstances = 'sql0', 'sql1'
    $containers = 'bearddockerhost,15789', 'bearddockerhost,15788', 'bearddockerhost,15787', 'bearddockerhost,15786'
    $SQL2017Container = 'bearddockerhost,15789'
    $sql0 = 'sql0'
    $sql1 = 'sql1'
    $filenames = (Get-ChildItem C:\SQLBackups\Keep).Name
    $LinuxSQL = 'beardlinuxsql'
    $Share = '\\jumpbox.TheBeard.Local\SQLBackups'
    $NetworkShare = '\\bearddockerhost.TheBeard.Local\NetworkSQLBackups'

}
elseif ($ENV:COMPUTERNAME -eq 'ROB-XPS') {
    $cred = Import-Clixml C:\MSSQL\BACKUP\sqladmin.cred     
    $containers = 'localhost,15591', 'localhost,15592', 'localhost,15593', 'localhost,15594'
    $sql0 = 'localhost,15591'
    $sql1 = 'localhost,15592'
    $sql2 = 'localhost,15593'
    $sql3 = 'localhost,15594'
}
if (-not ($PSDefaultParameterValues.'*-Dba*:SqlCredential')) {
    $PSDefaultParameterValues += @{
        '*-Dba*:SqlCredential' = $cred
    }
    $PSDefaultParameterValues += @{
        '*-Dbc*:SqlCredential' = $cred
    }
}
$location = 'Manchester'

function Prompt { 
    $Date = Get-Date
    $Mins = ($EndDate - $Date).TotalMinutes

    switch ($Mins) {
        {$_ -ge 30} { 
            $ToGo = [Math]::Round($mins,1)
            $Time = $Date.ToShortTimeString()
            Write-Host "$Time $ToGo Mins" -ForegroundColor DarkGreen -NoNewline
         }
         {$_ -lt 30 -and $_ -gt 10}{
            $ToGo = [Math]::Round($mins,1)
            $Time = $Date.ToShortTimeString()
            Write-Host "$Time " -ForegroundColor DarkGreen -NoNewline
            Write-Host "$ToGo Mins" -ForegroundColor Yellow -NoNewline
         }
         {$_ -le 10}{
            $ToGo = [Math]::Round($mins,1)
            $Time = $Date.ToShortTimeString()
            Write-Host "$Time " -ForegroundColor DarkGreen -NoNewline
            Write-Host "$ToGo Mins" -ForegroundColor Red -NoNewline
         }
        Default {}
    }
    
    try {
        $history = Get-History -ErrorAction Ignore -Count 1
        if ($history) {
            $ts = New-TimeSpan $history.StartExecutionTime  $history.EndExecutionTime
            switch ($ts) {
                {$_.totalminutes -gt 1 -and $_.totalminutes -lt 30  } {
                    Write-Host " [" -ForegroundColor Red -NoNewline
                    [decimal]$d = $_.TotalMinutes
                    '{0:f3}m' -f ($d) | Write-Host  -ForegroundColor Red -NoNewline
                    Write-Host "]" -ForegroundColor Red -NoNewline
                }
                {$_.totalminutes -le 1 -and $_.TotalSeconds -gt 1} {
                    Write-Host " [" -ForegroundColor Yellow -NoNewline
                    [decimal]$d = $_.TotalSeconds
                    '{0:f3}s' -f ($d) | Write-Host  -ForegroundColor Yellow -NoNewline
                    Write-Host "]" -ForegroundColor Yellow -NoNewline
                }
                {$_.TotalSeconds -le 1} {
                    [decimal]$d = $_.TotalMilliseconds
                    Write-Host " [" -ForegroundColor Green -NoNewline
                    '{0:f3}ms' -f ($d) | Write-Host  -ForegroundColor Green -NoNewline
                    Write-Host "]" -ForegroundColor Green -NoNewline
                }
                Default {
                    $_.Milliseconds | Write-Host  -ForegroundColor Gray -NoNewline
                }
            }
        }
    }
    catch { }
    "> "
  }