#!/bin/sh

DATA='{"vnetName":"vnet1","region":"westus2","vmPrefix":"demovm0","numberOfInstances":"2","dscNodeName":"HybridWorkerNode.Localhost"}'
URL=https://s1events.azure-automation.net/webhooks?token=f423P5jNHDo2mdDCKRCuUJcKy7srv8Z1q%2bJgfGOIggE%3d

curl -d $DATA $URL
