-          New-Item F:Folder –Type Directory

-          Get-Acl F:Folder | Format-List

 

-          $acl = Get-Acl F:Folder

-          $acl.SetAccessRuleProtection($True, $False)

-          $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")

-          $acl.AddAccessRule($rule)

-          $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Users","Read", "ContainerInherit, ObjectInherit", "None", "Allow")

-          $acl.AddAccessRule($rule)

-          Set-Acl F:Folder $acl

 

-          Get-Acl F:Folder  | Format-List