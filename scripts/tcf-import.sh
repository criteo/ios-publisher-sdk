#!/bin/bash -l

IAB_TCF_FOLDER=CriteoPublisherSdk/Sources/IabTCF

# Cleanup
rm -rf $IAB_TCF_FOLDER

# Shallow clone
git clone -b master --single-branch --depth 1 \
    git@github.com:Singlespot/IAB-TCF-V2-Objective-C.git \
    $IAB_TCF_FOLDER

# Remove git data
rm -rf $IAB_TCF_FOLDER/.git

# Prefix file names
for file in $IAB_TCF_FOLDER/*/SPTIab*.{h,m} $IAB_TCF_FOLDER/*/*/SPTIab*.{h,m}; do
  mv "$file" "${file/SPTIab/CR_SPTIab}"
done

# Prefix class names
sed -i '' "s/SPTIab/CR_SPTIab/g" $IAB_TCF_FOLDER/*/*.{h,m} $IAB_TCF_FOLDER/*/*/*.{h,m}