param(
[object]$WebhookData

)

if ($WebhookData -ne $null)
    {
    $params = $WebhookData.RequestBody | ConvertFrom-Json

    $vnetName = $params.vnetName
    $region = $params.region
    $vmPrefix = $params.vmPrefix
    $numberofInstances = $params.numberOfInstances
    $dscNodeName = $params.dscNodeName
    }

else { $ErrorMessage = "The Parameters block from the webhook is null"
        throw $ErrorMessage
        }

#Login as ServicePrincipal
$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

#Set some global Vars

$kvname = Get-AutomationVariable -Name "keyvaultname"
$dscregurl = Get-AutomationVariable -Name "registrationurl"
$dscregkey = (Get-AzureKeyVaultSecret -VaultName $kvname -Name "registrationkey").SecretValueText
$vmadminPass = (Get-AzureKeyVaultSecret -VaultName $kvname -Name "adminpass").SecretValue
$vnettemplate = Get-AutomationVariable -Name "vnettemplate"
$vmtemplate = Get-AutomationVariable -Name "vmtemplate"


#Build VNET in a Resource Group

try
{
    $vnetrg = Get-AzureRmResourceGroup -Name VNET -ea 0

    (if!($vnetrg))
    {
        New-AzureRmResourceGroup -Name VNET -Location $location
    }
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
    }

#Build a parameters Hash for the VNet Template
$vnetparams = @{
'vnetName' = $vnetname
}

#Call an ARM deployment using a template artifact
try 
{ 
    New-AzureRmResourceGroupDeployment -Name "VNET Deployment" -ResourceGroupName $vnetrg -Mode Incremental -TemplateUri $vnettemplate -TemplateParameterObject $vnetparams
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
    }

#Build parameters hash for VM deployment
$vmparams = @{
'adminUsername' = "azureuser";
'adminPassword' = $vmadminPass;
'numberOfInstances' = $numberOfInstances;
'vmNamePrefix' = $vmPrefix;
'registrationKey' = $dscregkey;
'registrationUrl' = $dscregurl;
'nodeConfigurationName' = $dscNodeName;
'virtualNetworkName' = $vnetName;
'virtualNetworkResourceGroup' = $vnetrg;
'subnetName' = "Subnet1"
}

try
{
    $vmrg = Get-AzureRmResourceGroup -Name VMs -ea 0

    (if!($vmrg))
    {
        New-AzureRmResourceGroup -Name VNET -Location $location
    }
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
    }

#Call ARM deployment for the VM resource using a template artifact
try
{
    New-AzureRmResourceGroupDeployment -Name "VM Deployment" -Mode Incremental -ResourceGroupName $vmrg -TemplateUri $vmtemplate -TemplateParameterObject $vmparams
    }
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
    }