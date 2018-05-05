## Welcome to PowerShell :-)
Return "This is a demo Beardy!"
## NOTE - Get in the habit of using the correct verbs in your commands
# Find them here
Get-Verb

## CTRL J advanced function

function Get-Somejunk
{
    [OutputType([String])]
    [Alias("gsj")]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("server")] 
        [string]$ComputerName
    )
    Get-Service -ComputerName $ComputerName | Where-object {$_.Status -eq 'Stopped'}
  
}

## Because we have set a mandatory parameter
Get-Somejunk 
#
Get-Somejunk -ComputerName $env:COMPUTERNAME
# because we have value from pipeline
$env:COMPUTERNAME | Get-Somejunk
# because we have aliased our computername parameter
Get-Somejunk -server $env:COMPUTERNAME
# because we have aliased our command and set our parameter position to 0
gsj $env:COMPUTERNAME

function Get-Somejunk
{
    [OutputType([String])]
    [Alias("gsj")]
    Param
    (
        # Computername
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("server")] 
        [string]$ComputerName,
        # How many shall we have
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [int]$Count

    )
    if($count)
    {
    Get-Service -ComputerName $ComputerName | Where-object {$_.Status -eq 'Stopped'} | Select-Object -First $Count
    }
    else
    {
    Get-Service -ComputerName $ComputerName | Where-object {$_.Status -eq 'Stopped'}
    }
  
}
# It tells us we need an int
Get-Somejunk $env:COMPUTERNAME -Count one
#
Get-Somejunk $env:COMPUTERNAME -Count 4

## Why is Help useful
function Get-Somejunk
{
<#
.Synopsis
   Short description for a silly function
.DESCRIPTION
   A much longer and detailed Long description for a silly function
.EXAMPLE
   $env:COMPUTERNAME | Get-Somejunk

   A full description of what happens when you run the above command - of course you need many exampels to make life easy

   YOU DONT WANT TO BE THE SUPPORT FUNCTION FOR THIS COMMAND

.NOTES
   General notes about a silly function
   AUTHOR A Silly Person
   DATE In the past
.LINK
https://sqldbawithabeard.com/presentations/

#>

    [OutputType([String])]
    [Alias("gsj")]
    Param
    (
        # Computername
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("server")] 
        [string]$ComputerName,
        # How many shall we have
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [int]$Count

    )
    if($count)
    {
    Get-Service -ComputerName $ComputerName | Where-object {$_.Status -eq 'Stopped'} | Select-Object -First $Count
    }
    else
    {
    Get-Service -ComputerName $ComputerName | Where-object {$_.Status -eq 'Stopped'}
    }
  
}

Get-Help Get-Somejunk
# Examples
Get-Help Get-Somejunk -Examples
#all of it
Get-Help Get-Somejunk -Full
# in a seperate window
Get-Help Get-Somejunk -ShowWindow
# Even online
Get-Help Get-Somejunk -Online

## Adding WhatIf Confirm to your functiosn is SO EASY
function Stop-Somejunk
{
    ## JUST ADD THIS HERE
   [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType([String])]
    [Alias("ssj")]
    Param
    (
        # Computername
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("server")] 
        [string]$ComputerName

    )
    $ServicestoStop =  Get-Service -ComputerName $ComputerName | Where-object {$_.Status -ne 'Stopped'} | Out-GridView -PassThru
    ## and this for any changing operation (Some will be there by default which is why I didnt use stop-service here)
    ## if ($pscmdlet.ShouldProcess("Target", "Operation"))
    ##     {
    ##     }
    foreach($Service in $ServicestoStop)
    {
         if ($pscmdlet.ShouldProcess("$ComputerName", "Stopping Service $($Service.ServiceName)"))
          {
             $Service.Stop()
          }
    }
}
# What if
Stop-Somejunk -ComputerName $env:COMPUTERNAME -WhatIf

# Confirm
Stop-Somejunk -ComputerName $env:COMPUTERNAME -Confirm
