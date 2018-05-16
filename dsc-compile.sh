#!/bin/sh

DATA='{"automationRG":"AutomationAccounts","automationAcct":"PoshPug"}'
URL=https://s1events.azure-automation.net/webhooks?token=QYtoRTGQp8z0Fwm5pwGyMnSW56LQ%2b0uXm5CAqsfkjK0%3d

curl -d $DATA $URL
