param(
[object]$WebhookData

)

if ($WebhookData -ne $null)
    {
    $params = $WebhookData.RequestBody | ConvertFrom-Json

    $vnetName = $params.vnetName
    $location = $params.region
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

    Set-AzureRmContext -SubscriptionId 6804f610-18f5-481e-9f8c-00cdf8da6836
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
$dscregkey = (Get-AzureKeyVaultSecret -VaultName $kvname -Name "registrationkey").SecretValue
$vmadminPass = (Get-AzureKeyVaultSecret -VaultName $kvname -Name "adminpass").SecretValue
$vnettemplate = Get-AutomationVariable -Name "vnettemplate"
$vmtemplate = Get-AutomationVariable -Name "vmtemplate"
$vnetrgname = "VNET"
$vmrgname = "VMs"
[string]$timestamp = (get-date -Format "MM/dd/yyyy H:mm:ss tt")

if ($vmadminPass -eq $null)
    {$ErrorMessage = "Access issue to Keyvault - Check Access Policies on KeyVault"
     throw $ErrorMessage
    }

#Build VNET in a Resource Group

try
{
    $vnetrg = Get-AzureRmResourceGroup -Name $vnetrgname -ea 0

    if (!$vnetrg)
    {
        New-AzureRmResourceGroup -Name $vnetrgname -Location $location
    }
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
    }

#Build a parameters Hash for the VNet Template
$vnetparams = @{
'vnetName' = $vnetName
}

#Call an ARM deployment using a template artifact
try 
{ 
    New-AzureRmResourceGroupDeployment -Name "VNETDeployment" -ResourceGroupName $vnetrgname -Mode Incremental -TemplateUri $vnettemplate -TemplateParameterObject $vnetparams
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
'nodeConfigurationName' = $dscNodeName;
'virtualNetworkName' = $vnetName;
'virtualNetworkResourceGroup' = $vnetrgname;
'subnetName' = "Subnet1";
'timestamp' = $timestamp
}

try
{
    $vmrg = Get-AzureRmResourceGroup -Name $vmrgname -ea 0

    if (!$vmrg)
    {
      New-AzureRmResourceGroup -Name $vmrgname -Location $location
    }
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
    }

#Call ARM deployment for the VM resource using a template artifact
try
{
    New-AzureRmResourceGroupDeployment -Name "VMDeployment" -Mode Incremental -ResourceGroupName $vmrgname -TemplateUri $vmtemplate -TemplateParameterObject $vmparams
    }
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
    }