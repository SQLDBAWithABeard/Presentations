#Check for Subnmenus
    $psTab = $PSISE.CurrentPowerShellTab.addonsmenu
    if($psTab.Submenus)
    {
      #count them
      $I = $psTab.Submenus.Count - 1
      # loop through them and Remove the beard
      while($I -gt -1)
      {
        if($psTab.Submenus[$I].displayname.Contains('TheBeard'))
        {
          $null = $psTab.Submenus.remove($psTab.Submenus[$I])  
          $I --
        }    
      }
    }
    ## Add in shortcut for new file with pester
    $TheBeard = $psTab.Submenus.Add('TheBeard',$null,$null)
    $null = $TheBeard.Submenus.Add('New Git File',{
        New-GitPester
    },'Ctrl+Alt+Shift+N')
    $null = $TheBeard.Submenus.Add('Start Zoomit',{
        Run-Zoomit
    },'Ctrl+Alt+Shift+Z')
  