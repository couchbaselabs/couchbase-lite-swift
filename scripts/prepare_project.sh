#!/bin/bash

# Link couchbase-lite-core-EE if not exists
CORE_EE_PATH="couchbase-lite-swift/vendor/couchbase-lite-C"
BASEDIR="$(pwd)/$(dirname "$0")"
if [ ! -L $CORE_EE_PATH ] || [ ! -e $CORE_EE_PATH ] ; then
  echo "Create symlink, no file/link exists at couchbase-lite-swift/vendor/couchbase-lite-C/vendor/couchbase-lite-core-EE"
  # 'ln' command requires the full path to create the symlink
  ln -s "$BASEDIR/../couchbase-lite-core-EE" "$BASEDIR/../couchbase-lite-swift/vendor/couchbase-lite-C/vendor"
else
  echo "Skip symlink, file/link exists at couchbase-lite-swift/vendor/couchbase-lite-C/vendor/couchbase-lite-core-EE"
fi
