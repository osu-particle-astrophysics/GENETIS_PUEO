#!/bin/bash
# This script is used to build the GA

NUKE=${1:-0}

if [ $NUKE -eq 1 ]; then
    echo "Nuking Shared-Code"
    rm -rf Shared-Code
fi

# Download the GA
git clone git@github.com:osu-particle-astrophysics/Shared-Code.git

echo "Done Building GA!"
