#region  Create a clone image

Connect-SqlClone -ServerUrl 'http://jumpbox:14145'
$sqlServerInstance = Get-SqlCloneSqlServerInstance -MachineName SQL0 -InstanceName Mirror
$imageDestination = Get-SqlCloneImageLocation -Path '\\sql0\sqlbackups'

$imageOperation = New-SqlCloneImage -Name "WWI-DW-$(Get-Date -Format yyyyMMddHHmmss)" `
  -SqlServerInstance $sqlServerInstance `
  -BackupFileName @('\\sql0\sqlbackups\WideWorldImportersDW-Full.bak') `
  -Destination $imageDestination

$imageOperation | Wait-SqlCloneOperation

#endregion

#region  Create a clone image

Connect-SqlClone -ServerUrl 'http://jumpbox:14145'
$sqlServerInstance = Get-SqlCloneSqlServerInstance -MachineName SQL0 -InstanceName Mirror
$imageDestination = Get-SqlCloneImageLocation -Path '\\sql0\sqlbackups'

$imageOperation = New-SqlCloneImage -Name "WWI-DW-Bigger"  -SqlServerInstance $sqlServerInstance   -BackupFileName @('\\sql0\c$\backups\WideWorldImportersDW-forclone_201905091042-1-of-4.bak','\\sql0\c$\backups\WideWorldImportersDW-forclone_201905091042-2-of-4.bak','\\sql0\c$\backups\WideWorldImportersDW-forclone_201905091042-3-of-4.bak','\\sql0\c$\backups\WideWorldImportersDW-forclone_201905091042-4-of-4.bak')   -Destination $imageDestination

$imageOperation | Wait-SqlCloneOperation

#endregion

#region Create a New Clone

Connect-SqlClone -ServerUrl 'http://jumpbox:14145'
$imageWWI = Get-SqlCloneImage -Name 'WWI'
$imageWWIDW = Get-SqlCloneImage -Name 'WWI-DW'
$imageWWIDWDated = Get-SqlCloneImage -Name 'WWI-DW-20190509090540'
$imageWWIDWBigger = Get-SqlCloneImage -Name 'WWI-DW-Bigger'

$sqlServerInstance = Get-SqlCloneSqlServerInstance -MachineName SQL0 -InstanceName Mirror

$imageWWI | New-SqlClone -Name 'GiveItAName' -Location $sqlServerInstance | Wait-SqlCloneOperation
$imageWWIDW | New-SqlClone -Name 'GiveItANewName' -Location $sqlServerInstance | Wait-SqlCloneOperation
$imageWWIDWDated | New-SqlClone -Name 'DatedClone1' -Location $sqlServerInstance | Wait-SqlCloneOperation
$imageWWIDWDated | New-SqlClone -Name 'DatedClone2' -Location $sqlServerInstance | Wait-SqlCloneOperation
$imageWWIDWBigger | New-SqlClone -Name 'Ber11' -Location $sqlServerInstance | Wait-SqlCloneOperation
$imageWWIDWBigger| New-SqlClone -Name 'Bger21' -Location $sqlServerInstance | Wait-SqlCloneOperation

#endregion

#region "Do some testing"

$query = "CREATE TABLE [dbo].[RobsDataTable](
	[RobsID] [int] NOT NULL,
	[RobsData1] [nchar](10) NULL,
	[RobsData2] [nchar](10) NULL,
 CONSTRAINT [PK_RobsDataTable] PRIMARY KEY CLUSTERED 
(
	[RobsID] ASC
) ON [PRIMARY]
) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [RobsDescendingIndex] ON [dbo].[RobsDataTable]
(
	[RobsID] ASC,
	[RobsData1] DESC,
	[RobsData2] ASC
)ON [PRIMARY];"

Invoke-DbaQuery -SqlInstance sql0\Mirror -Database Ber11 -Query $Query

#endregion

#region Reset clone

Get-SqlClone -Name 'Ber11' | Reset-SqlClone | Wait-SqlCloneOperation
#endregion

Get-SqlClone | Remove-SqlClone






ipmo 'C:\Program Files (x86)\Red Gate\SQL Clone PowerShell Client\RedGate.SqlClone.PowerShell\RedGate.SqlClone.PowerShell.psd1'