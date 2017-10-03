
function Get-SpeakerBeard {
    param(
    $Speaker,
   $Faces = (Get-SpeakerFace)
)
if(($Faces.Name -match $Speaker).count -eq 0) {
    Return "No Speaker with a name like that - You entered $($Speaker)"
}
else {
   $Faces.Where{$_.Name -like "*$Speaker*"}.FaceAttributes.facialHair.Beard
}
}