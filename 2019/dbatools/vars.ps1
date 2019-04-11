


$containers = "$ENV:ComputerName,15591", "$ENV:ComputerName,15592"
$SQLInstances = $containers
$sql0 = $containers[0]
$sql1 = $containers[1]
$cred = Import-Clixml 'dockercompose:\dbatools-2-instances-AG\sacred.xml'

. .\invoke-Parallel.ps1


function Prompt { 
    $Date = Get-Date
    $Mins = ($EndDate - $Date).TotalMinutes
    Write-Host "dbatools its awesome in $location " -ForegroundColor DarkGreen -NoNewline
    switch ($Mins) {
        {$_ -ge 30} { 
            $ToGo = [Math]::Round($mins, 1)
            $Time = $Date.ToShortTimeString()
            Write-Host "$Time $ToGo Mins" -ForegroundColor DarkGreen -NoNewline
        }
        {$_ -lt 30 -and $_ -gt 10} {
            $ToGo = [Math]::Round($mins, 1)
            $Time = $Date.ToShortTimeString()
            Write-Host "$Time " -ForegroundColor DarkGreen -NoNewline
            Write-Host "$ToGo Mins" -ForegroundColor Yellow -NoNewline
        }
        {$_ -le 10} {
            $ToGo = [Math]::Round($mins, 1)
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

$PSDefaultParameterValues += @{
    '*db*:SqlCredential' = $cred
    '*db*:DestinationSqlCredential' = $cred
    '*db*:SourceSqlCredential' = $cred
}