function Get-SpeakerBeard {
    param(
    $Speaker,
   $Faces = (Get-SpeakerFace),
   [switch]$Detailed)
if(!$Faces){
$faces = (Get-SpeakerFace -webpage $Webpage)
}
if(($Faces.Name -match $Speaker).count -eq 0) {
    Return "No Speaker with a name like that - You entered $($Speaker)"
}
else {
   if(!($detailed)){
   $Faces.Where{$_.Name -like "*$Speaker*"}.FaceAttributes.facialHair.Beard
   }
   else {
   $Faces.Where{$_.Name -like "*$Speaker*"}|Select-Object Name, @{ 
   Name       = 'Beard' 
   Expression = { 
       [decimal]$_.faceattributes.facialhair.beard 
           } 
       }, ImageURL
   }
}
}