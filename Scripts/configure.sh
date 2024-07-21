#!/bin/sh

PROJROOT=".."

function cleanup() {
    echo "Cleaning up if needed"
    if [[ -d "$PROJROOT/tmp" ]]; then
        rm -rf "$PROJROOT/tmp"
    fi
}

function create_mmap() {
    if [[ -e "$PROJROOT/Vance/Python.xcframework/ios-arm64/Headers/module.modulemap" && -e "$PROJROOT/Vance/Python.xcframework/ios-arm64_x86_64-simulator/Headers/module.modulemap" ]]; then
        echo "Module map files are already created"
        return
    fi

    echo "Creating module map file"

    cp "module.modulemap" "$PROJROOT/Vance/Python.xcframework/ios-arm64/Headers/module.modulemap"
    cp "module.modulemap" "$PROJROOT/Vance/Python.xcframework/ios-arm64_x86_64-simulator/Headers/module.modulemap"
}

if [[ -d "$PROJROOT/python-stdlib" && -d "$PROJROOT/Vance/Python.xcframework" ]]; then
    echo "Python files already exist"
    create_mmap
    cleanup
    exit 0
fi

cleanup

mkdir "$PROJROOT/tmp"
cd "$PROJROOT/tmp"

echo "Downloading Python package"
curl -L -o "python_package.tar.gz" "https://github.com/beeware/Python-Apple-support/releases/download/3.9-b12/Python-3.9-iOS-support.b12.tar.gz"

if [[ $? -ne 0 ]]; then
    cleanup
    exit 1
fi

echo "Extracting Python package"
tar -xzf "python_package.tar.gz"

if [[ $? -ne 0 ]]; then
    cleanup
    exit 1
fi

cd -

echo "Placing files in project"

if [[ -d "$PROJROOT/python-stdlib" ]]; then
    echo "Standard Python library directory already exists. Replacing it with the new one."
    rm -rf "$PROJROOT/python-stdlib"
fi
mv "$PROJROOT/tmp/python-stdlib" "$PROJROOT/python-stdlib"

if [[ -d "$PROJROOT/Vance/Python.xcframework" ]]; then
    echo "Python xcframework already exists. Replacing it with the new one."
    rm -rf "$PROJROOT/Vance/Python.xcframework"
fi
mv "$PROJROOT/tmp/Python.xcframework" "$PROJROOT/Vance/Python.xcframework"

create_mmap
cleanup
