# We could install the module beforehand in the dev container creation by adding it to a Post Create Script
Install-Module Pester

# Run some tests to make sure ewverything matches prod
Invoke-Pester src/ -Tag Before -Show All

# Have a look at the tests
code ./src/pre-check.Tests.ps1

# run some tests to ensure everything is as we expect it to be
# It's ok Chrissy - These ones are supposed to fail here ;-)
Invoke-Pester src/  -Tag After -Show All

# Take a look at and run the script we are testing
code ./src/thetestingscript.ps1

$PesterConfiguration = New-PesterConfiguration
$PesterConfiguration.Run.Path = 'src/'
$PesterConfiguration.Run.PassThru = $true
$PesterConfiguration.Filter.Tag = 'After'
$PesterConfiguration.Output.Verbosity = 'Detailed' # Diagnostic, Detailed, None, Normal

# run some tests to ensure everything is as we expect it to be
Invoke-Pester -Configuration $PesterConfiguration
