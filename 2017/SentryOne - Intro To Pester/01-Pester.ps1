$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
$CommandName = $sut.Replace(".ps1", '')
Describe "Tests for the $CommandName Command" {
    It "Command $CommandName exists" {
        Get-Command $CommandName -ErrorAction SilentlyContinue | Should Not BE NullOrEmpty
    }
} 