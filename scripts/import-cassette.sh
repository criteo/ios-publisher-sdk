#!/bin/bash -l

CASSETTE_FOLDER=CriteoPublisherSdk/Sources/Cassette

# Cleanup
rm -rf $CASSETTE_FOLDER

# Shallow clone
git clone -b master --single-branch --depth 1 \
    git@github.com:linkedin/cassette.git \
    $CASSETTE_FOLDER.tmp

# Only keep library source
mv $CASSETTE_FOLDER.tmp/Cassette $CASSETTE_FOLDER
rm -rf $CASSETTE_FOLDER.tmp $CASSETTE_FOLDER/Info.plist

# Prefix file names
for file in $CASSETTE_FOLDER/CAS*.{h,m}; do
  mv "$file" "${file/CAS/CR_CAS}"
done

# Prefix class names
sed -i '' "s/CAS/CR_CAS/g" $CASSETTE_FOLDER/*.{h,m}

# Fix imports
sed -i '' "s/#import <Cassette\/\(.*\)>/#import \"\1\"/g" $CASSETTE_FOLDER/*.{h,m}

# Exclude it from clang-format
cat <<EOF >> $CASSETTE_FOLDER/.clang-format
---
DisableFormat: true
SortIncludes: false
---
EOF
