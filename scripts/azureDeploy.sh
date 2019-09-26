export AZURE_STORAGE_ACCOUNT=pubsdkuseprod
export AZURE_STORAGE_KEY=IBXkbamPEDzFFvLFgjL8bG5v7GOLy/2HY2xMVtgXICxSXG/AYYP57Xme9lxNgcoaznc2XGdye/zDT7fPUYrXbA==
release=$1
export container_name=publishersdk
export blob_name=ios/CriteoPublisherSdk_iOS_v${release}.Release.zip
export file_to_upload=./CriteoPublisherSdk_iOS_v${release}.Release.zip

echo "Uploading the file...${blob_name}"
az storage blob upload --container-name $container_name --file $file_to_upload --name $blob_name

echo "Listing the blobs..."
az storage blob list --container-name $container_name --output table


echo "Done"
