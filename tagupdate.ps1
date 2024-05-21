# First create a csv with the following headers ResourceGroupName, TagValue

# Import the CSV file

$csv = Import-Csv -Path "C:\Users\user\Documents\tagupdate.csv"



# Then run the following command to update the tags for all resource groups in the subscription.

# if the -approve paramter is passed and if the resource group exists, then create or update the TagName to the TagValue otherwise write out the resource group name and hte change to the tagname and tagvalue that would have been made.