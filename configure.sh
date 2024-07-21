#!/bin/sh

function cleanup() {
    echo "Cleaning up if needed"
    if [[ -d "tmp" ]]; then
        rm -rf "tmp"
    fi
}

if [[ -d "python-stdlib" && -d "Vance/Python.xcframework" ]]; then
    echo "Python interpreter is downloaded and ready"
    cleanup
    exit 0
fi

cleanup

mkdir tmp
cd tmp

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

cd ..

echo "Placing files in project"

if [[ -d "python-stdlib" ]]; then
    echo "Standard Python library directory already exists. Replacing it with the new one."
    rm -rf "python-stdlib"
fi
mv "tmp/python-stdlib" "python-stdlib"

if [[ -d "Vance/Python.xcframework" ]]; then
    echo "Python xcframework already exists. Replacing it with the new one."
    rm -rf "Vance/Python.xcframework"
fi
mv "tmp/Python.xcframework" "Vance/Python.xcframework"

cleanup
