Import-Module AWSPowerShell -force
##################################################
#Set up SAML 
##################################################
$endpoint = "https://fstest.nuveen.com/adfs/ls/IdpInitiatedSignOn.aspx?loginToRp=urn:amazon:webservices"
$epName = Set-AWSSamlEndpoint -Endpoint $endpoint -StoreAs ADFS-Credentials -AuthenticationType NTLM
Set-AWSSamlRoleProfile -StoreAs Role_lewish -EndpointName $epName | Out-Null
#Get-EC2Instance -Region us-east-1 -ProfileName lewish

##################################################
#tag will be application based (app, role, lane)
##################################################
$TagBase = "N1"
$TagApp  = "AP1"
$TagRole = "WS"
$TagLane = "D"
##################################################

 #Use the Firewalled subnet/Cidrblock for poc VPC
$cidrBlock = '10.75.2.0/24'
#$region = 'us-east-1'


$instancefilter = New-Object Amazon.EC2.Model.Filter 
$instancefilter.Name  ="tag:Name" 
$instancefilter.Value = $TagBase + $TagApp + $TagRole + $TagLane

$FirstInstance = (get-ec2instance -Filter $instanceFilter).Instances[0]
$stoppedInstance = Stop-EC2Instance -Instance $FirstInstance -Terminate -Force 
$stoppedInstance.CurrentState

