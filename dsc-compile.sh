#!/bin/sh

DATA='{"automationRG":"AutomationAccounts","automationAcct":"PoshPug"}'
URL=https://s1events.azure-automation.net/webhooks?token=f423P5jNHDo2mdDCKRCuUJcKy7srv8Z1q%2bJgfGOIggE%3d

curl -d $DATA $URL
