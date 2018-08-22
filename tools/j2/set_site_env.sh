#!/bin/bash

export GENESIS_HOST={{yaml.genesis.host}}
echo GENESIS_HOST=$GENESIS_HOST
export PXE_INTERFACE={{yaml.networks.pxe.interface}}
echo PXE_INTERFACE=$PXE_INTERFACE
export HOST_INTERFACE={{yaml.networks.host.interface}}
echo HOST_INTERFACE=$HOST_INTERFACE
