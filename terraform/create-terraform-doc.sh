#!/bin/bash

#
# Use this script to update and create the terraform-doc.md files in the modules
# directories.
#

# Change directory to modules directory (relative path)
cd modules

# Loop through each directory inside modules
for dir in */; do
  # Enter the current directory
  cd "$dir"

  # Execute the docker run command
  docker run --rm --volume "$(pwd):/terraform-docs" -u $(id -u) quay.io/terraform-docs/terraform-docs:0.19.0 markdown /terraform-docs > terraform-doc.md

  # Exit from the current directory
  cd ..
done

# Print a message after processing all directories
echo "** Documentation generation completed! **"
