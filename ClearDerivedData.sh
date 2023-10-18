#!/bin/bash

echo $(pwd)
if ! bundle exec fastlane run clear_derived_data > /dev/null 2>&1; then
    echo "Using Global Fastlane"
    fastlane run clear_derived_data > /dev/null 2>&1
fi
