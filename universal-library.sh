# use xcode-select to change xcode version

# detect project
FRAMEWORK=$(basename *.xcworkspace .xcworkspace)
if [ "$FRAMEWORK" = "*" ]; then
    FRAMEWORK=$(basename *.xcodeproj .xcodeproj)
    if [ "$FRAMEWORK" = "*" ]; then
        echo "Framework not found. Exiting...";
        exit 1
    else
        FLAGS="-project $FRAMEWORK.xcodeproj"
    fi
else
    FLAGS="-workspace $FRAMEWORK.xcworkspace"
fi



# framework found!
echo "$FRAMEWORK project found."
echo "Starting in 3..."
sleep 1
echo "Starting in 2..."
sleep 1
echo "Starting in 1..."
sleep 1

# define some variables
BUILD_PATH="build"
CONFIGURATION="Release"

SDK_OS="iphoneos"
SDK_SIMULATOR="iphonesimulator"
SDK_UNIVERSAL="iphoneuniversal"

# remove previous build folder
echo "Cleaning build folder..."
rm -rf $BUILD_PATH

# define build flags
FLAGS="$FLAGS \
    -scheme $FRAMEWORK \
    -configuration $CONFIGURATION \
    ONLY_ACTIVE_ARCH=NO \
    -derivedDataPath $BUILD_PATH"

# if error occur, exit immediately
set -e

# build for physical devices
echo "Building for Generic iOS Devices..."
xcodebuild $FLAGS \
    -destination generic/platform=iOS \
    -sdk $SDK_OS \
    OTHER_CFLAGS="-fembed-bitcode"

# build for simulator
echo "Building for simulator..."
xcodebuild $FLAGS \
    -sdk $SDK_SIMULATOR

# enter build folder
cd $BUILD_PATH

# move all products to root
echo "Moving products..."
mv Build/Products/* ./

# clean cache
echo "Cleaning cache folder..."
shopt -s extglob
rm -rf !($CONFIGURATION*)
#rm -rf **/!($FRAMEWORK.framework)
shopt -s extglob

# create directory for universal framework
mkdir $CONFIGURATION-$SDK_UNIVERSAL

# copy framework mantaining structure
echo "Copying framework..."
cp -r $CONFIGURATION-$SDK_OS/* $CONFIGURATION-$SDK_UNIVERSAL

# check if swift modules exists, then copy
echo "Copying swiftmodules..."
SWIFTMODULE_PATH=$FRAMEWORK.swiftmodule
if [ -d $CONFIGURATION-$SDK_SIMULATOR/$SWIFTMODULE_PATH ]; then
    cp -r $CONFIGURATION-$SDK_SIMULATOR/$SWIFTMODULE_PATH/* \
        $CONFIGURATION-$SDK_UNIVERSAL/$SWIFTMODULE_PATH/
fi

# merge binaries
echo "Merging binaries..."
BINARY_PATH="lib$FRAMEWORK.a"
lipo -create -output \
    $CONFIGURATION-$SDK_UNIVERSAL/$BINARY_PATH \
    $CONFIGURATION-$SDK_OS/$BINARY_PATH \
    $CONFIGURATION-$SDK_SIMULATOR/$BINARY_PATH

# done
echo "$FRAMEWORK was built successfully."
open ./
