$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
$CommandName = $sut.Replace(".ps1", '')
Describe "Tests for the $CommandName Command" {
    It "Command $CommandName exists" {
        Get-Command $CommandName -ErrorAction SilentlyContinue | Should Not BE NullOrEmpty
    }
    Context "$CommandName Input" {
        ## For Checking parameters

    }
    Context "$CommandName Execution" {
        ## Ensuring the code follows the expected path

    }
    Context "$CommandName Output" {
        ## Probably most of tests here
    }
    
}