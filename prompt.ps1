function prompt {
    Write-Host "$(Split-Path -leaf -path (Get-Location)) $(Get-Date -Format HH:mm:ss) >" -ForegroundColor Green -nonewline 
    return " "
}
