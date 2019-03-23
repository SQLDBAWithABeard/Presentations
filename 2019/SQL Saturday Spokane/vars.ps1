$SQLInstances = 'sql0', 'sql1'
$containers = 'bearddockerhost,15789', 'bearddockerhost,15788', 'bearddockerhost,15787', 'bearddockerhost,15786'
$11containers = 'bearddockerhost,15581', 'bearddockerhost,15582', 'bearddockerhost,15583', 'bearddockerhost,15584', 'bearddockerhost,15585', 'bearddockerhost,15586', 'bearddockerhost,15587', 'bearddockerhost,15588', 'bearddockerhost,15589', 'bearddockerhost,15590', 'bearddockerhost,15591'
$SQL2017Container = 'bearddockerhost,15789'
$sql0 = 'sql0'
$sql1 = 'sql1'
$LinuxSQL = 'beardlinuxsql'
$mirrors = 'sql0\mirror','sql1\mirror'
$cred = Import-Clixml $HOME\Documents\sa.cred
$filenames = (Get-ChildItem C:\SQLBackups\Keep).Name
$Share = '\\jumpbox.TheBeard.Local\SQLBackups'
$NetworkShare = '\\bearddockerhost.TheBeard.Local\NetworkSQLBackups'
$location = 'Spokane'

. .\invoke-Parallel.ps1


function Prompt { 
   $EndDate = Get-Date -Year 2019 -Month 3 -Day 23 -Hour 20 -Minute 45 -Second 0
    $Date = Get-Date
    $Mins = ($EndDate - $Date).TotalMinutes
 Write-Host "dbatools its awesome in $location " -ForegroundColor DarkGreen -NoNewline
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
    Write-Host "> " -ForegroundColor Cyan
    
  }

$PSDefaultParameterValues += @{'*dba*:SqlCredential' = $cred}