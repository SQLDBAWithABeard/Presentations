$NotebookDirectory = "C:\Users\mrrob\OneDrive\Documents\GitHub\Presentations\2020\SQL Saturday Edinburgh\Notebooks"
$targetfilename = "ADSNotebookIndex.ipynb" 
$outputLocation = 'C:\temp\Work'
$NotebookPath = "$($NotebookDirectory)\$targetfilename"

$IntroCellText = "# Notebook Index 
Click on the code below the workbook you require to generate your custom version to save results in"
$IntroCell = New-ADSWorkBookCell -Text $IntroCellText -Type Text

#check output path exists
If (!(Test-path $outputLocation)) {
    Write-Output "creating folder $($outputLocation)"
    New-Item -Path  $outputLocation  -ItemType Directory   
}

#check ths files available and build the index
$WorkBookCells = foreach ($file in (Get-ChildItem $NotebookDirectory -Recurse -Exclude $targetfilename)) {
    # In case there are subfolders which don't have notebooks in them
    $out = (Get-ChildItem $file -Include *ipynb) |Out-String
    If ($file.PSIsContainer -ieq $true -and ((Get-ChildItem $file.FullName -Recurse -Include *ipynb).Count -ne 0)) {                            
        New-ADSWorkBookCell -Type Text -Text "---
---
## <u>Notebook Section:  **$($file.basename) </u>**"   
    }
    Elseif ($file.Extension -eq '.ipynb') {
        New-ADSWorkBookCell -Type Text -Text "Notebook Name: **$($file.basename)**"        
        $CellText = "# To use this Notebook, click the run button.
`$user = `$env:USERNAME.Replace('.','')
`$time = get-date -Format 'yyyyMMddHHmmssms'
`$destination = '{3}\{0}_' + `$time + '_'+ `$user + '{1}'
copy-item -path '{2}' -destination `$destination
# In case there is media or script files as well. Copy Those also
Get-ChildItem '{4}' -Exclude *ipynb | Copy-Item -Destination '{3}' -Recurse -Force
azuredatastudio.cmd `$destination
" -f $file.BaseName, $file.Extension, $file.FullName, $outputLocation , $file.DirectoryName
        New-ADSWorkBookCell -Type code -Text $celltext -Collapse
    }
}

New-ADSWorkBook -path $NotebookPath -Cells $IntroCell, $WorkBookCells -Type PowerShell