#!/bin/bash
set -xe

image_name="cedar14"
release_ver=${$1:-latest}

trap 'clean_tmp; exit' QUIT TERM EXIT

function clean_tmp() {
  echo "clean temporary file..."
  [ -f Dockerfile.template ] && rm -rf Dockerfile.template
}


function release(){

  branch_name="master"

  
  git checkout master

  # get git describe info
  release_desc=master-`git rev-parse --short master`
  sed  "s/__RELEASE_DESC__/$release_desc/" Dockerfile > Dockerfile.template
  
  docker build -t rainbond/${image_name}:${release_ver} -f Dockerfile.template .
  docker push rainbond/${image_name}:${release_ver}
}

#=== main ===
release
