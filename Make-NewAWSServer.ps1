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

#Get this VPC
$subnetfilter = New-Object Amazon.EC2.Model.Filter 
$subnetfilter.Name  ="cidrBlock" 
$subnetfilter.Value = $cidrBlock
#$pocVPC = get-ec2vpc -Filter $vpcfilter
##create the this app's subnet
#$NewSubnet = New-EC2Subnet -VpcId $VPC.VpcId -CidrBlock $cidrBlock
#Tag it
#$snTag = New-Object Amazon.EC2.Model.Tag
#$snTag.Key = "Name"
#$snTag.Value = "aw1poc-1d-private-1"
#New-EC2Tag -Resource $NewSubnet.SubnetId -Tag $snTag

#Get our subnet
$pocSubnet = Get-EC2Subnet -Filter $subnetfilter


#Use standard SecGroup
$VPCFilter = New-Object Amazon.EC2.Model.Filter
$VPCFilter.Name = 'vpc-id'
$VPCFilter.Value = $pocSubnet.VpcId
$NameFilter = New-Object Amazon.EC2.Model.Filter
$NameFilter.Name = 'group-name'
$NameFilter.Value = 'aw1poc-1'
$pocSG = Get-EC2SecurityGroup -Filter $VPCFilter, $NameFilter


#New-EC2Instance -ImageId "ami-6dcbdd07" -MinCount 1 -MaxCount 1 -InstanceType t2.micro -securitygroup  $pocSG.GroupId  -SubnetId $NewSubnet.SubnetId  
$NewEC2Instance = New-EC2Instance -ImageId "ami-6dcbdd07" -MinCount 1 -MaxCount 1 -InstanceType t2.micro  -SecurityGroupId $pocSG.GroupId -SubnetId $pocSubnet.SubnetId
#Tag it
$instanceTag = New-Object Amazon.EC2.Model.Tag
$instanceTag.Key = "Name"
$instanceTag.Value = $TagBase + $TagApp + $TagRole + $TagLane
new-ec2tag -Resource $NewEC2Instance.Instances[0].InstanceId  -tag $instanceTag

Write-Host ("Created new EC2 Instance: " + $instanceTag.Value )



#New-EC2Instance -ImageId "ami-6dcbdd07" -MinCount 1 -MaxCount 1 -InstanceType t2.micro -securitygroup sg-e37c189b -SubnetId  