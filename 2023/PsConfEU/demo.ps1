# 1. Hello World in PowerShell

# Automation is THE BEST

# Let's automate our demos also

# For Example lets take a look at dougfinke's ai module in action

Import-Module dbatools

Connect-DbaInstance -SqlInstance localhost -ConnectTimeout 1

# OK I know, thats dbatools v2 showing the new trust cert feature

# but now, we have an error lets see what we can get from it with ai

Set-OpenAIKey -Key (Get-Secret -Name powershellaikey)

Invoke-AIErrorHelper

# lets ask ai to explain itself

Invoke-AIExplain

# come on, beardy, do something useful

Invoke-AIFunctionBuilder -Prompt "Write a function to get the powershell conference schedule from the sessionize api using dkxcjtm2"