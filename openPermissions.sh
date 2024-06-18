#!/bin/bash
### OPEN PERMISSIONS IN THE RUN DIRECTORY ###
RunName=$1

# Check if the RunName is empty
if [ -z "$RunName" ]; then
    echo "Please enter RunName as an argument."
    echo "Example: ./openPermissions.sh RunName"
    echo "Exiting..."
    exit 1
fi

# Open permissions in the Run directory
chmod 777 Run_Outputs/$RunName

# Loop through child directories (for echo purposes)
for dir in Run_Outputs/$RunName/*; do
    echo "Opening permissions in $dir"
    chmod -R 777 $dir
done
