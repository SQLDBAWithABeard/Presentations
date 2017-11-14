###########################################################################
# Original Version: 1.1
# Updated to Version 2.0B, Maximo Trinidad, 02/12/2012
#--------------------------------------------------------------------------
# Comments:
# 1. Customized the foreground color to Cyan and backgroundColor to Black.
# 2. Created a Dump color to default to White.
# 3. Added to put back the default foreground and background colors.
# 4. Commented out the '(!) Suspense' option because Studio Shell can't
#    handle "$host.NestedPrompt".
# 5. Modify the Help menu to acomodate changes.
# 6. Commented out all "$Host.UI.RawUI.WindowTitle".
# 7. Replaced all "[System.Console]::ReadLine()" with "Read-Host".
# 8. Added an end of results 'write-host"-- Press Enter to continue --"'
#    follow with a read-host similate a pause.
#
# Modifications:
# 02/10/2012 - Add section identify oneliners with continuation tick "`".
# 02/10/2012 - Cleanup all unused V1 lines.
# 02/10/2012 - Make code to properly display continuation lines.
# 02/12/2012 - Fix info on Start time and duration.
# 02/12/2012 - Adjust execution message spacing.
# 29/08/2016 - Added support for multi-line code - ChocolateMonkey (Luke Duddridge)
#
###########################################################################
 
function Start-Demo
{
  param($file=".\demo.txt", [int]$command=0)
 
  ## - Saved previous default Host Colors:
  $defaultForegroundColor = $host.UI.RawUI.ForegroundColor;
  $defaultBackgroundColor = $host.UI.RawUI.BackgroundColor;
 
  ## - Customizing Host Colors:
  $host.UI.RawUI.ForegroundColor = "White";
  $host.UI.RawUI.BackgroundColor = "DarkBlue";
  $CommentColor = "Green"
  $MetaCommandColor = "Cyan"
  $DumpColor = "White"
  $otherColor = "Yellow"
  Clear-Host
 
  ## - setting demo variables:
  $_Random = New-Object System.Random
  $_lines = @(Get-Content $file)
  $Global:starttime = [DateTime]::now
  $_PretendTyping = $true
  $_InterkeyPause = 100
  $Global:Duration = $null
  $justKeepSwinging = 0
 
  Write-Host -for $otherColor @"
Start-Demo: $file - Start time: $starttime
Version 2.0B (02/12/2012)
NOTE: Start-Demo replaces the typing but runs the actual commands.
.
 
"@
  $continuation = $false;
 
  # We use a FOR and an INDEX ($_i) instead of a FOREACH because
  # it is possible to start at a different location and/or jump
  # around in the order.
  for ($_i = $Command; $_i -lt $_lines.count; $_i++)
  {
    if($_lines[$_i].Length -eq 0)
    {
        continue
    }

    if ($_lines[$_i].StartsWith("#"))
    {
        Write-Host -NoNewLine $("`n[$_i]PS> ")
        Write-Host -NoNewLine -Foreground $CommentColor $($($_Lines[$_i]) + "  ")
        continue
    }
    else
    {
        # Put the current command in the Window Title along with the demo duration
        $Global:Duration = [DateTime]::Now - $Global:StartTime
        Write-Host -NoNewLine $("`n[$_i]PS> ")
        $_SimulatedLine = $($_Lines[$_i]) + "  "
 
        for ($_j = 0; $_j -lt $_SimulatedLine.Length; $_j++)
        {
           Write-Host -NoNewLine $_SimulatedLine[$_j]
 
               if ($_PretendTyping)
               {
                   if ([System.Console]::KeyAvailable)
                   {
                       $_PretendTyping = $False
                   }
                   else
                   {
                       Start-Sleep -milliseconds 50
                   };
               };
 
        } # For $_j
        $_PretendTyping = $true
 
    } # else

    if(($_lines[$_i] -match '\)' -and $_lines[$_i+1] -match '\{') -or ($_lines[$_i] -match '\)\s?{'))
    {
        $justKeepSwinging++
    }

    if($justKeepSwinging -ne 0 -and $_lines[$_i] -match '\}')
    {
         $justKeepSwinging--
    }

    if($_lines[$_i] -notmatch '`' -and $justKeepSwinging -eq 0)
    {
         #Write-Host "Yes $($_Lines[$_i])" -BackgroundColor white -ForegroundColor red;
         $_input = Read-Host;
    }
	#else { $continuation = $true}  

    switch ($_input)
    {
################ HELP with DEMO
      "?"
        {
            Write-Host -ForeGroundColor Yellow @"
--------------------------------------------------------------------------------
Start-Demo - Updated to Version 2.0B (12/12/2012)
Help Running Demo: $file
.
(#x) Goto Command #x    (b) Backup     (?) Help
(fx) Find cmds using X  (q) Quit       (s) Skip
(t)  Timecheck          (d) Dump demo  (px) Typing Pause Interval
.
NOTE 1: Any key cancels "Pretend typing" for that line.  Use  unless you
        want to run a one of these meta-commands.
.
NOTE 2: After cmd output, enter  to move to the next line in the demo.
        This avoids the audience getting distracted by the next command
        as you explain what happened with this command.
.
NOTE 3: The line to be run is displayed in the Window Title BEFORE it is typed.
        This lets you know what to explain as it is typing.
.
NOTE 4: Although this script is functional try not to "Goto" a continuation 
        one-liner or it will go to a continues loop. I will correct this sympton
        soon. (02/12/2012)  
---------------------------------------------------------------------------------
"@;
            Write-Host "-- Press Enter to continue --" -BackgroundColor white `
                -ForegroundColor Magenta;
            Read-Host; cls;
            $_i -= 1
        }
 
      #################### PAUSE
      {$_.StartsWith("p")}
          {
               $_InterkeyPause = [int]$_.substring(1)
               $_i -= 1
          }
 
      ####################  Backup
      "b" 
        {
            if($_i -gt 0)
            {
                $_i --
 
                while (($_i -gt 0) -and ($_lines[$($_i)].StartsWith("#")))
                {   
                    $_i -= 1
                }
            }
 
            $_i --
            $_PretendTyping = $false
        }
 
      ####################  QUIT
      "q"
        {
            Write-Host -ForeGroundColor $OtherColor ""
            $host.UI.RawUI.ForegroundColor = $defaultForegroundColor;
            $host.UI.RawUI.BackgroundColor = $defaultBackgroundColor;
            cls;
            return
        }
 
        ####################  SKIP
        "s"
        {
            Write-Host -ForeGroundColor $OtherColor ""
        }
 
        ####################  DUMP the DEMO
        "d"
        {
            for ($_ni = 0; $_ni -lt $_lines.Count; $_ni++)
            {
                if ($_i -eq $_ni)
                {
                    Write-Host -ForeGroundColor Yellow "$("*" * 25) >Interrupted< $("*" * 25)"
                }
                Write-Host -ForeGroundColor $DumpColor ("[{0,2}] {1}" -f $_ni, $_lines[$_ni])
            }
            $_i -= 1
            Write-Host "-- Press Enter to continue --" -BackgroundColor white `
            -ForegroundColor Magenta;
            Read-Host; cls;
        }
 
        ####################  TIMECHECK       
        "t" 
        {              
            $Global:Duration = [DateTime]::Now - $Global:StartTime              
            Write-Host -ForeGroundColor $OtherColor $("Demo has run {0} Minutes and {1} Seconds`nYou are at line {2} of {3} " `
                -f [int]$Global:Duration.TotalMinutes,[int]$Global:Duration.Seconds,$_i,($_lines.Count - 1))
            $_i -= 1
        }
 
        ####################  FIND commands in Demo
        {$_.StartsWith("f")}
        {             
            for ($_ni = 0; $_ni -lt $_lines.Count; $_ni++)
            {
                if ($_lines[$_ni] -match $_.SubString(1))
                {
                  Write-Host -ForeGroundColor $OtherColor ("[{0,2}] {1}" -f $_ni, $_lines[$_ni])
                }
            }
            $_i -= 1
        };
             
#####################  SUSPEND  # --> not working in StudioShell: help (!)  Suspend (not working)
#
#      {$_.StartsWith("!")}
#          {
#             if ($_.Length -eq 1)
#             {
#                 Write-Host -ForeGroundColor $CommentColor ""
#                 function Prompt {"[Demo Suspended]`nPS>"}
#                 $host.EnterNestedPrompt()
#             }else
#             {
#                 trap [System.Exception] {Write-Error $_;continue;}
#                 Invoke-Expression $(".{" + $_.SubString(1) + "}| out-host")
#             }
#             $_i -= 1
#          }
# --------------------------------------------------------------------------------
 
      ####################  GO TO
      {$_.StartsWith("#")}
          {
             $_i = [int]($_.SubString(1)) - 1
             $Scriptline = $null;
             $continuation = $false;
             continue
          }
 
      ####################  EXECUTE
      default
          {
            trap [System.Exception] {Write-Error $_;continue;};
            ## - 02/10/2012-> Commented out original line below
            # Invoke-Expression $(".{" + $_lines[$_i] + "}| out-host")
 
            ## - add section identify oneliners with continuation tick:
            [string] $Addline = $null;
            if($_lines[$_i] -match '`')
            {
                #Write-Host " Found tick = $($_lines[$_i])" -ForegroundColor yellow;
                $Addline = $_lines[$_i].replace('`','').tostring()
                $Scriptline += $Addline;
                $continuation = $true;
            }
			elseif(($_lines[$_i] -match '\)' -and $_lines[$_i+1] -match '\{') -or ($_lines[$_i] -match '\){'))
            {
                #Write-Host " Found tick = $($_lines[$_i])" -ForegroundColor yellow;
                $Addline = $_lines[$_i].tostring()
                $Scriptline += $Addline;
                $continuation = $true;

                #just incase the full statement is on one line
                if($_lines[$_i] -match '\}')
                {
                    $continuation = $false;
                }
            }
			elseif($_lines[$_i] -match '\}')
            {
                #Write-Host " Found tick = $($_lines[$_i])" -ForegroundColor yellow;
                $Addline = $_lines[$_i].tostring()
                $Scriptline += $Addline;
                $continuation = $false;
            }
            else
            {
                $Scriptline += $_lines[$_i].ToString();
                $continuation = $false;
            }

            if($continuation -eq $false -and $justKeepSwinging -eq 0)
            {
                ## - Executive:
                Write-Host " `r`n`t Executing Script...`r`n" -ForegroundColor $otherColor;
                Invoke-Expression $(".{" +$Scriptline + "}| out-host")
            }
            
			## - --------------------------------------------------------------------
            if($continuation -eq $false -and $justKeepSwinging -eq 0)
            {
                # Write-Host "`r`n";
                Write-Host "-- Press Enter to continue --" 
                $Global:Duration = [DateTime]::Now - $Global:StartTime
                Read-Host;
                $Scriptline = $null;
            };
          }
    } # Switch
  } # for
  ## Next three list to put backl the console default colors and do a clear screen:
  $host.UI.RawUI.ForegroundColor = $defaultForegroundColor;
  $host.UI.RawUI.BackgroundColor = $defaultBackgroundColor;
  cls;
  $Global:Duration = [DateTime]::Now - $Global:StartTime; Write-Host "`r`n";
  Write-Host "Start-Demo of $file completed:" -ForegroundColor $otherColor;
  Write-Host -ForeGroundColor Yellow $("Total minutes/sec: {0}.{1}, Date: {2}" `
    -f [int]$Global:Duration.TotalMinutes, [int]$Global:Duration.Seconds, [DateTime]::now);
} # function
