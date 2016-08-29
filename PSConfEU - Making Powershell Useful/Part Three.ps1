## So I ended up using two different methods to enable others to use the scripts
Set-Location onedriveps:\
## First I created little menus that called the scripts

.\DBASewellBox.ps1

##  1, 4 ,7

## and I also created a little GUI :-)

.\BoxOfTricks.ps1  ## which doesnt work at 4K resolution!
invoke-item Presentations:\PowershellBoxOftricks.png

## These both worked well but as others began to want to develop scripts we turned to TFS

## We started making use of the profile and TFS

notepad $profile