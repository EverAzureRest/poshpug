param(
$subscriptionName,
[bool]$start,
[bool]$stop
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

Set-AzureRmContext -SubscriptionName $subscriptionName

$resourcegroups = get-AzureRmResourceGroup

if ($stop -eq $true){
$resourcegroups.resourcegroupname | foreach $_ { 
Get-AzureRmResource -ResourceGroupName $_ -ResourceType Microsoft.Compute/virtualMachines | Stop-AzureRmVM $_ -Force}
}
elseif ($start -eq $true){
$resourcegroups.resourcegroupname | foreach $_ { 
Get-AzureRmResource -ResourceGroupName $_ -ResourceType Microsoft.Compute/virtualMachines | Start-AzureRmVM $_ }
} 