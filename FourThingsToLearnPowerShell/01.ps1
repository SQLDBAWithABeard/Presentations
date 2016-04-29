$CurrentPath = Get-Location ## This is to make the last command work
# 
# You will need to have SQL Server installed to make all the commands work
# You can find the video at 
#
############################################################
#
# Four things you need to know to effectively use PowerShell
#
############################################################
#
#
# When you start you don't know the name of the command
#
# So Use Get-Command
# Get-Command ## This takes too long to be able to fit in a 5 minute lightning talk - delete the first # and run to see all the commands
#
# The * is a wild card
#
Get-Command *backup*
# Get returns
#
Get-Command Get-E*
# Set defines 
#
Get-command Set-C*
# New creates 
#
Get-Command New-V*
# There are a lot of Verbs 
#
Get-Verb
# So think of the thing you want to do
#
Get-Command *Backup*Database
# So now you need to know how to use the command that you have found
#
Get-Help
# Lets get the help for Backup-SQLDatabase
#
Get-Help Backup-SqlDatabase 
# Good but long, confusing at first - Don't forget about it, you will need it later
# But there is some help for you on the screen to make it easier to begin
#
Get-Help Backup-SqlDatabase -Examples 
# The Backup-SqlDatabase cmdlet performs backup operations on a SQL Server database.
#    
#    -------------------------- EXAMPLE 1 --------------------------
#    
#    C:\PS>Backup-SqlDatabase -ServerInstance Computer\Instance -Database MyDB
#    
#    
#    Description
#    
#    -----------
#    
#    This command creates a complete database backup of the database 'MyDB' to the 
#    default backup location of the server instance Computer\Instance'. The backup file 
#    will be named 'MyDB.bak'.
########################################################################################
#
# 
Backup-SqlDatabase -ServerInstance . -Database DBADatabase
# I will show the Default Backup Directory. Look at the LastWriteTime
#
ls C:\MSSQL\Backup
cd C:\MSSQL\Backup
# sneakily I showed you that you can use cmd or bash commands
#
# Everything is an object and you can assign and investigate objects. 
#
# This is how
#
# Use the pipe symbol | bottom left between the z and the SHIFT on my keyboard
#
# Pipe the results of your command to Get-Member if you want to do something different use Get-Help Get-Member
#
Get-ChildItem | Get-Member
# Now you can see the events, properties and methods for the object
# It is Better to do it like this though. Store the results in a variable using the $ to define the variable
#
$Service = Get-Service SQLSERVERAGENT
$Service | Get-Member -MemberType Method
# When you want to take it further Go back to Get-Help. Don't always relay on the examples. Read more of it
# But you can also find help about concepts and the langauge
#
Get-Help About_C*
# You can also get the help online
#
Get-Help about_Comparison_Operators -Online
# Also Don't forget CTR + J in the ISE
#
cd $CurrentPath
powershell_ise.exe '02.ps1' -noprofile
####
##             Hopefully You Will Remember
#
#              Get-Command                Use the wildcard it's *
#              Get-Help                   With the command afterwards. Also for concepts
#              Get-Member                 You need to pipe the object to it use a $ 
#              CTRL + J                   Will show snippets they will help with syntax
#              
#              Now you can work out how to do it with Powershell
#              Hopefully enabling you to ease frustrations and learn more
#
#              Don't be afraid to ask for help pn social media and Technology specific forums
#              Or any of the Powershell focused web-sites too many to list here             
#
#              Thank you 
#              @SQLDBAWithABeard
## 
####
Read-Host
#                                                          
#                    @@,                   ,                     
#                     @@8                ,@@,                    
#                       @@@.           f@@C                      
#                        .@@@       t@@@   0G                    
#                    C@@f   8@@   ;@8.   @@@@@8                  
#                  :@@i,@@@.      L0   t@@   ;@@@C               
#                G@@C     @@@@      i@@@;       :@@@:            
#             8@@0.          8@@  .@@:             @@            
#            @@@8          :@@,    @@@:          @@@f            
#              f@@@       @@@        18@@@     @@8               
#                 0@@0.C@@@.    8@t      @@0@@@@                 
#                   .@@0,      @80        C0,                    
#                             @@,                                
#                           8@@                                  
#                          @@i                                   
#                         @@@@@@@@@Gi                            
#                                  ti.                           
#                      tC.  8 @ t@G                              
#                    t;0i.@1@.   @. i@@@;,,,,,,,,,               
#                  @,8.@0@  .    f0@8..  C@C..;@@@               
#              ,@ @@i@@@f          @.   f@@.    :8@t             
#          .@G1@i @    8  C           @@,.    1@;                
#      @@t;@f 1@       @ 0@ @@  @@@ GC @        1@iGC            
#    88               ,G.88 @,. @@t@ 8 8                         
#                     G :@, @ . @8 @  88                         
#                     @ 1@, 8 . @  @@ @                          
#                     @G.@,@@ : @  @@.f                          
#                     G1 0,@@ @ @ t@8..                          
#                    t:  ,@@@ @ @ @C8..1                         
#                   @,:  @@@@ @ @ @0 ii8                         
#                    G  C 0@1.@ 8 @@ @88                         
#                    @  @ ,@, @ 8 @@ 18@                         
#                   .:  tL.0, @ 8 @@  @G                         
#                   G  G 8,0  @ G @@  @ G                        
#                   8  8 @8@  @   @8, @ @                        
#                  L. 8  t@0  L   @ @ @:@                        
#                  f i, 1tf. L    L @ @8.t                       
#                 G  @  @8@  8   0  @8@G @                       
#               .f  @   @G. :.      , @ 8 @                      
#              8.  i;  ti:  @       @@,f1. 1,                    
#             @    C  18   C.   :   ;;   @                       
#                    L.@        @    8@   @                      
#                      @       G.    @     G                     
#                      @      .i      @                          
#                            8        1,                                   
#              Thank you  @SQLDBAWithABeard
## 
####                           
Read-Host