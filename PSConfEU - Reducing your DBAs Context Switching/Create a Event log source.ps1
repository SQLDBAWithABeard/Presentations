<# THIS NEEDS TO BE RUN AS ADMIN as it needs to search all logs for sources  #>

$Source = 'SQLAUTOSCRIPT' 
$log = 'Application'
[System.Diagnostics.EventLog]::CreateEventSource($source, $log)