#!/bin/sh -e

SCRIPT_DIR=$(cd $(dirname $0) && pwd)
cd $SCRIPT_DIR

echo '演習用にSSH鍵を作成します。'
echo 'これは演習時にDockerコンテナ間でのSSH接続に使用します。'
ssh-keygen -t rsa -b 4096 -C '[DO NOT USE PRODUCTION] Using ansible_workshop' -f ./.keys/ansible_workshop -q -N ""

