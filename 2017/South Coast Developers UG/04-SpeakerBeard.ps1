
 function Get-SpeakerBeard {
    param(
        $Speaker,
        $faces = (Get-SpeakerFace),
        [switch]$Detailed,
        [switch]$ShowImage
       )
   # If no faces grab some    
   if(!$Faces){
    $faces = (Get-SpeakerFace)
   }
   # if no speaker tell them
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
       if($ShowImage){
           Start-Process $Faces.Where{$_.Name -like "*$Speaker*"}.ImageURL
       }
   }
}