param(
$automationRG = "AutomationAccounts",
$automationAcct = "PoshPug"
)
        $ConfigurationData = @{
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