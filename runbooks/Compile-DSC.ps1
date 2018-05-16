param(
$automationRG = "AutomationAccounts",
$automationAcct = "PoshPug"
)

    
<#RunAs Account Permissions are not sufficient by default to compile DSC jobs    


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
}#>          $ConfigurationData = @{
        AllNodes = @(
            @{
                NodeName = 'Localhost'
                PSDscAllowPlainTextPassword = $true
            }
        )
    }

    $CompileParams = @{
        ResourceGroupName     = $automationRG
        AutomationAccountName = $automationAcct
        ConfigurationName     = "HybridWorkerNode"
        ConfigurationData     = $ConfigurationData
    }

    Start-AzureRmAutomationDscCompilationJob @CompileParams