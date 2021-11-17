#!/usr/bin/env bash

# Go to script root
cd $(dirname $(realpath $0))

# Reset
rm -rf mapped
rm -rf docs/idx
rm -rf docs/class
rm -rf docs/document
rm -rf docs/field
rm -rf docs/file
rm -rf docs/person

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
  mkdir -p docs/$(dirname $EID)
  cp $FILENAME docs/${EID}
  echo "${EID}" >> docs/idx
  # Files
  [ -d "${FILEDIR}/files" ] && (cd $FILEDIR ; ls files/) | while read FNAME; do
    FSHA256=$(sha256sum "${FILEDIR}/files/${FNAME}" | awk '{print $1}')
    mkdir -p docs/file/${FSHA256}
    cp "${FILEDIR}/files/${FNAME}" "docs/file/${FSHA256}/data"
    echo "<https://kb.finwo.net/${EID}> <https://kb.finwo.net/class/DocumentDataDescriptor> <https://kb.finwo.net/file/${FSHA256}/meta> ." >> "docs/${EID}"
    echo "<https://kb.finwo.net/file/${FSHA256}/meta> <https://kb.finwo.net/field/document-data-type> \"$(file --mime-type -b "${FILEDIR}/files/${FNAME}")\" ." >> "docs/file/${FSHA256}/meta"
    echo "<https://kb.finwo.net/file/${FSHA256}/meta> <https://kb.finwo.net/field/document-data-type> \"https://kb.finwo.net/file/${FSHA256}/data\" ." >> "docs/file/${FSHA256}/meta"
    # TODO: add file hashes to meta
  done
done

# TODO:
# - Find foaf:maker, append foaf:publications to inverse (most likely foaf:Person)
