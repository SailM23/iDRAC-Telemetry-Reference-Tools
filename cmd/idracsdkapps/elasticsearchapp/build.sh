#!/bin/sh

set -x
set -e

script_dir=$( cd $(dirname $0); pwd )
repo_top=$( cd $script_dir/../../../; pwd )
SDKROOT=${SDKROOT:-~/sdkbuild}

# prepare an output directory as $SDKROOT/output

# build with host GO version for now instead of SDK provided one. it's fine! (make sure latest go installed in $PATH!)
cd $repo_top
GOARCH=arm GOARM=5 go build -o $SDKROOT/output/bin/containerapp -ldflags "-s -w" ./cmd/idracsdkapps/elasticsearchapp/elasticsearchplugin.go

# copy any other required files into the container:
#cp $script_dir/dcm-client.yaml        $SDKROOT/output/etc/

cd $SDKROOT

echo Sourcing environment
source ./environment-setup-armv7a-poky-linux-gnueabi
source ./build_common
export PLUGIN_CODE_DIR=./
export GOOS="linux"
export GOARCH="arm"
export GOARM=5

###############################################################################
# generated the following "stable" component id and uuid values for DCM Client
# DO NOT CHANGE

# manifest: productComponentID
COMPONENTID=158908

# manifest: productUUID
CONTAINERNAME=eaf91aae190f42c48e78746625c6192e-myfork

# END NOT CHANGE
###############################################################################

cat $script_dir/manifest-SPLUNK.json | jq ".productUUID=\"$CONTAINERNAME\" | .productComponentID=\"$COMPONENTID\"" > $SDKROOT/manifest.json

export CONTAINERNAME=$(cat $SDKROOT/manifest.json | jq -r .productUUID)
export COMPONENTID=$(cat $SDKROOT/manifest.json | jq -r .productComponentID )

finalize_container

ln -sf ${CONTAINERNAME}.d9 ElasticSearch-plugin.d9

if [ -d ~/webserver/ ]; then
  cp ${CONTAINERNAME}.d9 ~/webserver/ElasticSearch-plugin.d9
fi
