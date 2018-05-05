# Just a simple function to get the face attributes from the
# Microsoft Cognitive Services
Function Get-SpeakerFace
{
    ## Grab the webpage
$Webpage = Invoke-WebRequest http://tugait.pt/2017/speakers/
## Process the images witht eh api
$webpage.Images.Where{$_.class -eq 'speaker-image lazyOwl wp-post-image'}.src | ForEach-Object {
    $jsonBody = @{url = $_} | ConvertTo-Json
    $apiUrl = "https://westus.api.cognitive.microsoft.com/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=false&returnFaceAttributes=age,gender,headPose,smile,facialHair,glasses,emotion,hair,makeup,occlusion,accessories,blur"
    $apiKey = $Env:MS_Faces_Key
    $headers = @{ "Ocp-Apim-Subscription-Key" = $apiKey }
    $analyticsResults = Invoke-RestMethod -Method Post -Uri $apiUrl -Headers $headers -Body $jsonBody -ContentType "application/json"  -ErrorAction Stop
    [pscustomobject]@{
        Name           = $_ -replace '.*\/(.*)\..*$','$1' -replace '-|(\d{3}x\d{3})'
        FaceAttributes = $analyticsResults.FaceAttributes
        ImageUrl       = $_
    }
    Start-Sleep -Seconds 4 ## need the sleep to keep inside the free api rate  limits
} 
}
