Write-Output "Starting Collection"
Write-Output "    pods"
# get all of the containers in the cluster ready for the Pester Test
$pods = kubectl get pods --all-namespaces -o json
$podsjson = $pods | ConvertFrom-Json -Depth 15
$Containers = foreach ($pod in $podsjson.items) {
    $podname = $pod.metadata.name
    $nodename = $pod.spec.nodename
    foreach ($container in $pod.status.ContainerStatuses) {
        @{
            nodename       = $nodename
            podname        = $podname
            containername  = $container.name
            containerready = $container.ready
        }
    }
} 



Write-Output "    connection"
$benscreds = New-Object System.Management.Automation.PSCredential ((Get-Secret -Name beardmi-benadmin-user -AsPlainText), (Get-Secret -Name beardmi-benadmin-pwd))
$SQLInstance = '192.168.2.63,30666'
$ConnectionTest = Test-DbaConnection -SqlInstance $SQLInstance -SqlCredential $benscreds
Write-Output "Finished Collection"
