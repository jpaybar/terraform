#!/usr/bin/env bash

clear
WORKSPACE_DIR="terraform.tfstate.d"
#shopt -s nullglob
#shopt -u nullglob


# Read command output line by line into array ${lines [@]}
# Bash 3.x: use the following instead (read command and Internal Field Separator):
#   IFS=$'\n' read -d '' -ra lines <<< `ls -d $WORKSPACE_DIR/* | awk -F/ '{print$2}'`
readarray -t lines <<< `ls -d $WORKSPACE_DIR/* | awk -F/ '{print$2}'`

# Prompt the user to select one of the lines.
# for i in ${lines[@]}; do echo $i; done
echo ""
echo "Please select a Workspace to destroy:"
echo ""
select choice in "${lines[@]}"; do
  [[ -n $choice ]] || { echo ""; echo "Invalid choice. Please try again." >&2; continue; }
  #break # If valid choice was made then exit prompt.
done


# Read a choosen workspace.
read <<<"$choice"

# Select and destroy workspace.
terraform workspace select $choice
TFVARS=$choice.tfvars
terraform destroy -var-file $TFVARS

if  !([ -d $WORKSPACE_DIR ]); then 
    echo ""
    echo "El directorio \"$WORKSPACE_DIR\" no existe en este proyecto" 
    echo "o no contiene ningun \"Workspace\" valido."
    echo ""
fi



