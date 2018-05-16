#!/bin/sh

DATA='{"vnetName":"vnet1","region":"westus2","vmPrefix":"demovm0","numberOfInstances":2,"dscNodeName":"HybridWorkerNode.Localhost"}'
URL=https://s1events.azure-automation.net/webhooks?token=OWmtfCZFcM3DjudeTupkd3j%2fYM85jmJip5gP7C6D%2flE%3d

curl -d $DATA $URL
