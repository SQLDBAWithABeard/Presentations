
function Get-SpeakerBeard {
    param(
        $Speaker,
        $Faces ,
        [switch]$Detailed,
        [switch]$ShowImage,
        [int]$Top,
        [int]$Bottom
    )
    # If no faces grab some    
    if (!$Faces) {
        $faces = (Get-SpeakerFace -webpage $Webpage)
    }
    # if no speaker tell them
    if (($Faces.Name -match $Speaker).count -eq 0) {
        Return "No Speaker with a name like that - You entered $($Speaker)"
    }
    else {
        if ($Top -or $Bottom) {
            if ($top) { 
                $Faces | Select-Object Name, @{
                    Name       = 'Beard'
                    Expression = {
                        [decimal]$_.faceattributes.facialhair.beard 
                    }
                } | Sort-Object Beard -Descending |Select-Object Name, Beard -First $top
            }
       
            if ($bottom) { 
                $Faces|Select-Object Name, @{
                    Name       = 'Beard'
                    Expression = {
                        [decimal]$_.faceattributes.facialhair.beard 
                    }
                } |Sort-Object Beard -Descending |Select-Object Name, Beard -Last $Bottom
            }
        }
        elseif (!($detailed)) {
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
        if ($ShowImage) {
            Start-Process $Faces.Where{$_.Name -like "*$Speaker*"}.ImageURL
        }
    }
}
