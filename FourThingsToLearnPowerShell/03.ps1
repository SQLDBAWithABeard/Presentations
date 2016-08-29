# Path to Temp
$path = "C:\temp\"

# Find Text files with the word hello in them
$items = Get-ChildItem $path\*.txt `
-Recurse | Select-String -Pattern "Hello" | group path | select name

#basic return
$items

#As this invokes as a command on a single line, dont forget the SemiColons
foreach($item in $items)
{
    $file = Get-Item $item.Name;
    $file.FullName;
}

#Without you get problems
foreach($item in $items)
{
    $file = Get-Item $item.Name
    $file.FullName
}

#Valid format
foreach($item in $items){
	$item
}
#Valid format with nested loops
if($items.Length -ne 0)
{
    foreach($item in $items)
    {
        $item
    }
}

#Valid format as on one line
foreach($item in $items){$item}

#This wont work if you dont have more than 1 item returned in the initial search.
$items.ForEach({$_})

#This wont work because I havent put in anything to handle this pattern yet :)
$items.ForEach({
$_
})


#So what wont? unexpected spaces

#This works because it is on one line
foreach($item in $items) {$item}

#This wont
foreach($item in $items) {
    #This breaks the lines
    $item
#And again
}

# basically pattern matching and predictive / expected behaviour is how this works
foreach($item in $items)
{
    $item
}

