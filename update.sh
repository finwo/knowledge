#!/usr/bin/env bash

# Go to script root
cd $(dirname $(realpath $0))

# Reset
rm -rf mapped
rm -rf htdocs/idx
rm -rf htdocs/class
rm -rf htdocs/document
rm -rf htdocs/field
rm -rf htdocs/file
rm -rf htdocs/person

# Deprecated
# Designed for humans, not cross-referencing
(cd documents ; ls) | while read UUID; do
  [ -f "documents/${UUID}/type" ] || continue
  TYPE="$(cat "documents/${UUID}/type")"
  find "documents/${UUID}/" -type f -maxdepth 1 | grep -v type | grep -v data.nt | xargs -n 1 basename | while read KEY; do
    cat "documents/${UUID}/${KEY}" | while read VALUE; do
      mkdir -p "mapped/${TYPE}/by-${KEY}/${VALUE//\//-}"
      ln -s "../../../../documents/${UUID}" "mapped/${TYPE}/by-${KEY}/${VALUE//\//-}/${UUID}"
    done
  done
done

# "n-triples" storage style
(find data -type f -name data.nt) | while read FILENAME; do
  # Metadata
  FILEDIR=$(dirname $FILENAME)
  EID="${FILEDIR#*/}"
  mkdir -p htdocs/$(dirname $EID)
  cp $FILENAME htdocs/${EID}
  echo "${EID}" >> htdocs/idx
  # Files
  [ -d "${FILEDIR}/files" ] && (cd $FILEDIR ; ls files/) | while read FNAME; do
    FSHA256=$(sha256sum "${FILEDIR}/files/${FNAME}" | awk '{print $1}')
    mkdir -p htdocs/file/${FSHA256}
    cp "${FILEDIR}/files/${FNAME}" "htdocs/file/${FSHA256}/data"
    echo "<https://kb.finwo.net/${EID}> <https://kb.finwo.net/class/DocumentDataDescriptor> <https://kb.finwo.net/file/${FSHA256}/meta> ." >> "htdocs/${EID}"
    echo "<https://kb.finwo.net/file/${FSHA256}/meta> <https://kb.finwo.net/field/document-data-type> \"$(file --mime-type -b "${FILEDIR}/files/${FNAME}")\" ." >> "htdocs/file/${FSHA256}/meta"
    echo "<https://kb.finwo.net/file/${FSHA256}/meta> <https://kb.finwo.net/field/document-data-type> \"https://kb.finwo.net/file/${FSHA256}/data\" ." >> "htdocs/file/${FSHA256}/meta"
    # TODO: add file hashes to meta
  done
done

# TODO:
# - Find foaf:maker, append foaf:publications to inverse (most likely foaf:Person)
