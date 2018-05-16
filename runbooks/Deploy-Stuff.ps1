param(
$vnetName,
$region,
$vmPrefix,
$numberOfInstances,
$dscNodeName

)

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
$dscregurl = get-AutomationVariable -Name "registrationurl"
$vmadminPass = (Get-AzureKeyVaultSecret -VaultName $kvname -Name "adminpass").SecretValue
$templaterepo = Get-AutomationVariable -Name "templaterepo"

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


}

try 
{ 
    New-AzureRmResourceGroupDeployment -Name "VNET Deployment" -ResourceGroupName $vnetrg -Mode Incremental -TemplateUri $templaterepo -TemplateParameterObject $vnetparams
}
