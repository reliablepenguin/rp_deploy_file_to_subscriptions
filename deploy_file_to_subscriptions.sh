#!/bin/bash

#!/bin/bash

# Check if two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <template_name> <target_name>"
    exit 1
fi

# Assign parameters to variables
TEMPLATE_NAME="$1"
TARGET_NAME="$2"

# Check if the template file exists
if [ ! -f "$TEMPLATE_NAME" ]; then
    echo "Error: Template file '$TEMPLATE_NAME' does not exist."
    exit 1
fi

# Fetch the list of domains managed by Plesk
sites=$(plesk bin domain --list)

# Check if the domain list was retrieved successfully
if [[ -z "$sites" ]]; then
  echo "No domains found or unable to fetch domain list."
  exit 1
fi

# Loop through each site
for site in $sites; do
  echo "Processing site: $site"

  # Determine the site's home directory
  ftp_user=$(plesk bin site --info $site | grep "FTP Login" | awk '{print $3}')
   
  echo "ftp user: $ftp_user"
  home_dir=$(getent passwd $ftp_user | cut -d: -f6)

  # Ensure home directory exists
  if [[ -d "$home_dir" ]]; then

    # Copy the template to the target
    cp $TEMPLATE_NAME $home_dir/$TARGET_NAME

    # Check if the copy operation was successful
    if [ $? -eq 0 ]; then
      echo "Template '$TEMPLATE_NAME' successfully copied to '$home_dir/$TARGET_NAME'."
    else
      echo "Error: Failed to copy template."
      #exit 1
    fi

    chown $ftp_user.psacln $home_dir/$TARGET_NAME

  else
    echo "Home directory for $site ($home_dir) not found. Skipping..."
  fi
done

echo "Script execution completed."

