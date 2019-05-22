Lets start by creating a Kubernetes cluster

First a resource group

az group create --name beardkubes --location westeurope

Then, this will create us a kubernetes cluster (There are a lot more options)

az aks create --resource-group beardkubes --name beardk8scluster --generate-ssh-keys

Right now lets get to some slides about ACR while that runs

Then back to Chrome – We need to get our connection crecdntials for our cluster

az aks get-credentials --resource-group beardkubes --name beardk8scluster --overwrite-existing

Cat /home/rob/.kube/config

Place in the Azure DevOps Service Connection in Create Cluster Build Step

Run Create Clusters to add namespaces

Now we need some dns entries to make life easy (then we don’t have to worry about new IP Addresses – Look at the tags)


az network public-ip create --resource-group MC_beardkubes_beardk8scluster_westeurope --name beardk8sExternalIPDev --dns-name beardaksdev --allocation-method Static --tags 'Environment=Dev' 

az network public-ip create --resource-group MC_beardkubes_beardk8scluster_westeurope --name beardk8sExternalIPTest --dns-name beardakstest --allocation-method Static --tags 'Environment=Test' 

az network public-ip create --resource-group MC_beardkubes_beardk8scluster_westeurope --name beardk8sExternalIPProd --dns-name beardaksprod --allocation-method Static --tags 'Environment=Production' 

Run Build Environment Release

Then explain the fulll pipeline steps from Build to Release, triggers, approval gate for prod

Then show will actually be running cut down version of pipeline due to time

Show cluster in VS Code

If you get error run kubectl create -f kube-dashboard-access.yaml

Run the build release to build the envs and show in ADS and explain as it runs


Here is ACR (in VS Code)

Create a container 

docker run -d -p 15789:1433 --name bearddev -e SA_PASSWORD=Password0! -e ACCEPT_EULA=Y bearddevimage

Connect to it in ADS

Make change in Visual Studio 

Publish to container

Save Changes and Commit


-- A Header explaining what it does
CREATE VIEW Website.SpecialCustomers
AS
SELECT s.CustomerID,
       s.CustomerName,
       sc.CustomerCategoryName,
       pp.FullName AS PrimaryContact,
       ap.FullName AS AlternateContact,
       s.PhoneNumber,
       s.FaxNumber,
       bg.BuyingGroupName,
       s.WebsiteURL,
       dm.DeliveryMethodName AS DeliveryMethod,
       c.CityName AS CityName,
       s.DeliveryLocation AS DeliveryLocation,
       s.DeliveryRun,
       s.RunPosition
FROM Sales.Customers AS s
LEFT OUTER JOIN Sales.CustomerCategories AS sc
ON s.CustomerCategoryID = sc.CustomerCategoryID
LEFT OUTER JOIN [Application].People AS pp
ON s.PrimaryContactPersonID = pp.PersonID
LEFT OUTER JOIN [Application].People AS ap
ON s.AlternateContactPersonID = ap.PersonID
LEFT OUTER JOIN Sales.BuyingGroups AS bg
ON s.BuyingGroupID = bg.BuyingGroupID
LEFT OUTER JOIN [Application].DeliveryMethods AS dm
ON s.DeliveryMethodID = dm.DeliveryMethodID
LEFT OUTER JOIN [Application].Cities AS c
ON s.DeliveryCityID = c.CityID
WHERE sc.CustomerCategoryName = 'Special'




az group delete -n  beardkubes –yes
