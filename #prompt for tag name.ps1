#prompt for tag name
$TagName = Read-Host -Prompt "Enter the name of the tag to update"

$CSVPath = Read-Host -Prompt "Enter the path to create the csv file or press enter to use the default path C:\Temp\TagValues.csv"

if ($CSVPath -eq "") {
    $CSVPath = "C:\Temp\TagValues.csv"
}

if (-not (Test-Path $CSVPath)) {
    # First create a csv with the following headers ResourceGroupName, TagValue
    New-Item -Path $CSVPath -ItemType File
    Set-Content -Path $CSVPath -Value "ResourceGroupName,TagValue"

} else {
    $message = "The file at {0} already exists I will open it for you" -f $CSVPath
    Write-Output $message

}

$message = "Please add the ResourceGroup Names and the tag values to the CSV" -f $CSVPath
Write-Output $message

    #open the file
    Invoke-Item -Path "C:\Temp\TagValues.csv"

#import the csv
$TagValues = Import-Csv -Path "C:\Temp\TagValues.csv"

#prompt for subscription name
$SubscriptionName = Read-Host -Prompt "Enter the name of the subscription to update"

#prompt yes or no to confirm
$Confirm = Read-Host -Prompt "Are you sure you want to update the tag $TagName in subscription $SubscriptionName? (Y/N)"

# Get some input from users
$title = "Do You  want to make changes?"
$message = "Yes to make changes No to only view the what will happen (Y/N)"
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Will continue"
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Will exit"
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
$result = $host.ui.PromptForChoice($title, $message, $options, 0)

if ($result -eq 1) {
    $Confirm = "N"
    $message = "User - {0} wanted to see what would happen and not make any changes" -f $env:USERNAME
    Write-Output $message
} elseif ($result -eq 0) {
    $Confirm = "Y"
    $message = "User - {0} wanted to make changes" -f $env:USERNAME
    Write-Output $message
} else {
    $message = "User - {0} wanted to make the changes to the tags in subscription {1}" -f $env:USERNAME, $SubscriptionName
    Write-Output $message
}

#connect to the subscription
Connect-AzAccount -SubscriptionName $SubscriptionName

# get all of the resource groups in the subscription
$ResourceGroups = Get-AzResourceGroup

# loop through each resource group
foreach ($ResourceGroup in $ResourceGroups) {
    # if the resource group name is in the csv file
    if ($TagValues.ResourceGroupName -contains $ResourceGroup.ResourceGroupName) {
        #if the tag name exists on the resource group
        if ($ResourceGroup.Tags.ContainsKey("Tag1")) {
            # update the tag value on the resource group
            $ResourceGroup.Tags["Tag1"] = $TagValues.TagValue
            #if confirm is yes
            if ($Confirm -eq "Y") {
                # update the resource group
                $ResourceGroup | Set-AzResourceGroup
                $message = 'I have updated tag {0} in resource group {1} to value {2}' -f $TagName, $ResourceGroup.ResourceGroupName, $TagValues.TagValue
                Write-Output $message
            }
        } else {
            $message = 'I will update tag {0} in resource group {1} to value {2}' -f $TagName, $ResourceGroup.ResourceGroupName, $TagValues.TagValue
            Write-Output $message
        } else {
            #if confirm is yes
            if ($Confirm -eq "Y") {
                #create the tag on the resource group and set the value
                $ResourceGroup | Set-AzResourceGroup -Tag @{Tag1 = $TagValues.TagValue }
                $message = 'I have created tag {0} in resource group {1} with value {2}' -f $TagName, $ResourceGroup.ResourceGroupName, $TagValues.TagValue
                Write-Output $message
            } else {
                $message = 'I will create tag {0} in resource group {1} with value {2}' -f $TagName, $ResourceGroup.ResourceGroupName, $TagValues.TagValue
                Write-Output $message

            }
        }
    }
}