# PSScriptAnalyzerSettings.psd1
# Settings for PSScriptAnalyzer invocation.
@{
    Rules = @{
        PSUseCompatibleCommands = @{
            # Turns the rule on
            Enable = $false

            # Lists the PowerShell platforms we want to check compatibility with
            TargetProfiles = @(
                'win-8_x64_10.0.17763.0_6.1.3_x64_4.0.30319.42000_core',
                'ubuntu_x64_18.04_6.1.3_x64_4.0.30319.42000_core'
               ,'win-8_x64_10.0.17763.0_5.1.17763.316_x64_4.0.30319.42000_framework'
                ,'win-8_x64_6.2.9200.0_3.0_x64_4.0.30319.42000_framework'
            )
        }
        PSUseCompatibleSyntax = @{
            # This turns the rule on (setting it to false will turn it off)
            Enable = $false

            # Simply list the targeted versions of PowerShell here
            TargetVersions = @(
                '6.1',
                '6.2'
               #  ,'5.1'
               # , '3.0'
            )
        }
    }
}