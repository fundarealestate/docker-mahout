usage() {
cat << EOF
Usage: builddockerimage.sh
Builds a docker image with Pig, Hive, Mahout and Hadoop.

Copyright (c) 2018: Funda Real Estate B.V. All rights reserved.
EOF
exit 0
}
# Image Name
IMAGE_NAME="pig-hive-mahout-hadoop"

# ################## #
# BUILDING THE IMAGE #
# ################## #
echo "Building image '$IMAGE_NAME'"

# BUILD THE IMAGE (replace all environment variables)
BUILD_START=$(date '+%s')
docker build --force-rm=true --no-cache=true -t $IMAGE_NAME -f dockerfile ./ || {
	echo "There was an error building the image."
	read -p "Press any key to continue... " -n1 -s
	exit 1
}
BUILD_END=$(date '+%s')
BUILD_ELAPSED=`expr $BUILD_END - $BUILD_START`

echo ""
if [ $? -eq 0 ]; then
cat << EOF
  Docker image with Pig, Hive, Mahout and Hadoop is ready to be used.
    --> $IMAGE_NAME
  Build completed in $BUILD_ELAPSED seconds.
EOF
else
  echo "Docker image was NOT successfully created. Check the output and correct any reported problems with the docker build operation."
fi
read -p "Press any key to continue." -n1 -s