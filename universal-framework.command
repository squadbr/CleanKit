# use xcode-select to change xcode version

# move to directory where script was executed
cd $(dirname $0)

# define some variables
BUILD_PATH="build"
DEBUG="Debug"
RELEASE="Release"

# define log filename
SCRIPT=$(basename "$0")
SCRIPT=${SCRIPT%.*}
LOG="$SCRIPT.log"

RELEASE_ONLY=false
KEEP_ALL=false

# print usage
usage () {
    echo "usage: $SCRIPT [-a] [-r] [-h]"
}

# process arguments
while [ "$1" != "" ]; do
    case $1 in
        -r | --release )        shift
                                RELEASE_ONLY=true
                                ;;
        -a | --all )            shift
                                KEEP_ALL=true
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

print_exit () {
    echo -e "\nSomething wrong happened."
    echo -e "Try checking logs or build project with the same configuration.\n"
    exit
}

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
echo -e "\n$FRAMEWORK project found.\n\n"

sleep 1
echo "Starting in 3..."
sleep 1
echo "Starting in 2..."
sleep 1
echo "Starting in 1..."
sleep 1

SDK_OS="iphoneos"
SDK_SIMULATOR="iphonesimulator"
SDK_UNIVERSAL="iphoneuniversal"

# remove previous build folder
echo "Cleaning build folder..."
rm -rf $BUILD_PATH
mkdir $BUILD_PATH

# define build flags
FLAGS="$FLAGS \
    -scheme $FRAMEWORK \
    ONLY_ACTIVE_ARCH=NO \
    -derivedDataPath $BUILD_PATH"

# if error occur, exit immediately
trap 'print_exit' ERR

# build for physical devices
echo "Building for Generic iOS Devices with $RELEASE Configuration..."
xcodebuild $FLAGS \
    -destination generic/platform=iOS \
    -configuration $RELEASE \
    -sdk $SDK_OS >> $BUILD_PATH/$LOG

# build for simulator
echo "Building for iOS Simulator with $RELEASE Configuration..."
xcodebuild $FLAGS \
    -configuration $RELEASE \
    -sdk $SDK_SIMULATOR >> $BUILD_PATH/$LOG

# enter build folder
cd $BUILD_PATH

# move all products to root
echo "Moving products..."
mv Build/Products/* ./

# create directory for universal framework
mkdir $RELEASE-$SDK_UNIVERSAL

# copy framework mantaining structure
echo "Copying framework..."
cp -r $RELEASE-$SDK_OS/* $RELEASE-$SDK_UNIVERSAL

# check if swift modules exists, then copy
echo "Copying swiftmodules..."
SWIFTMODULE_PATH=$FRAMEWORK.framework/Modules/$FRAMEWORK.swiftmodule
if [ -d $RELEASE-$SDK_SIMULATOR/$SWIFTMODULE_PATH ]; then
    cp -r $RELEASE-$SDK_SIMULATOR/$SWIFTMODULE_PATH/* \
        $RELEASE-$SDK_UNIVERSAL/$SWIFTMODULE_PATH/
fi

BINARY_PATH=$FRAMEWORK.framework/$FRAMEWORK
# merge binaries
echo "Merging binaries..."
lipo -create -output \
    $RELEASE-$SDK_UNIVERSAL/$BINARY_PATH \
    $RELEASE-$SDK_OS/$BINARY_PATH \
    $RELEASE-$SDK_SIMULATOR/$BINARY_PATH


# clean cache
echo "Cleaning cache..."
shopt -s extglob
if $KEEP_ALL ; then
    rm -rf !($DEBUG*|$RELEASE*|*.log)
else
    rm -rf !($DEBUG-$SDK_UNIVERSAL|$RELEASE*|*.log)
fi
shopt -s extglob

# done
echo "$FRAMEWORK was built successfully."
open ./
