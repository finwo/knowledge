#!/usr/bin/env bash

# Go to script root
cd $(dirname $(realpath $0))

# Reset
rm -rf mapped

# Map by X
(cd documents ; ls) | while read UUID; do
  [ -f "documents/${UUID}/type" ] || continue
  TYPE="$(cat "documents/${UUID}/type")"
  find "documents/${UUID}/" -type f -maxdepth 1 | grep -v type | xargs -n 1 basename | while read KEY; do
    cat "documents/${UUID}/${KEY}" | while read VALUE; do
      mkdir -p "mapped/${TYPE}/by-${KEY}/${VALUE//\//-}"
      ln -s "../../../../documents/${UUID}" "mapped/${TYPE}/by-${KEY}/${VALUE//\//-}/${UUID}"
    done
  done
done
