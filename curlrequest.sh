#!/bin/sh

DATA='{"WorkspaceName":"jorsmith-oi","storageAccountName":"3c1702eastus2","subscriptionName":"jorsmith-scdemo"}'
URL=https://s1events.azure-automation.net/webhooks?token=f423P5jNHDo2mdDCKRCuUJcKy7srv8Z1q%2bJgfGOIggE%3d

curl -d $DATA $URL
