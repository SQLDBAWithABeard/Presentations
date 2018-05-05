    ."GIT:\Presentations\PSConfEU2017 - Green is Bad Red is Good\Test-SQLSDefaults.ps1"
    $Parms = @{
      Servers = 'SQL2016N1' ,'SQL2016N2','SQL2016N3';
      SQLAdmins = 'THEBEARD\Rob','THEBEARD\SQLAdmins';
      BackupDirectory = 'C:\MSSQL\Backup';
      DataDirectory = 'C:\MSSQL\Data\';
      LogDirectory = 'C:\MSSQL\Logs\';
      MaxMemMb = '4096';
      Collation = 'Latin1_General_CI_AS';
      TempFiles = 3 ;
      OlaSysFullFrequency = 'Daily';
      OlaSysFullStartTime = '00:00:00';
      OlaUserFullSchedule = 'Weekly';
      OlaUserFullFrequency = 1 ;## 1 for Sunday
      OlaUserFullStartTime = '00:00:00';
      OlaUserDiffSchedule = 'Daily';
      OlaUserDiffFrequency = 1; ## 126 for every day except Sunday
      OlaUserDiffStartTime = '00:00:00';
      OlaUserLogSubDayInterval = 4;
      OlaUserLoginterval = 'Hour';
      HasSPBlitz = $true;
      HasSPBlitzCache = $True; 
      HasSPBlitzIndex = $True;
      HasSPAskBrent = $true;
      HASSPBlitzTrace =  $true;
      HasSPWhoisActive = $true;
      LogWhoIsActiveToTable = $true;
      LogSPBlitzToTable = $true;
      LogSPBlitzToTableEnabled = $true;
      LogSPBlitzToTableScheduled = $true;
      LogSPBlitzToTableSchedule = 'Weekly'; 
      LogSPBlitzToTableFrequency = 2 ; # 2 means Monday 
      LogSPBlitzToTableStartTime  = '03:00:00'}
      
      Test-SQLDefault @Parms