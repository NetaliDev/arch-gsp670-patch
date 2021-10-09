#!/bin/bash

# check if files exist
ls -qd linux* 2>/dev/null > /dev/null
RESULT=$?

if [[ $RESULT -ne 0 ]]
then
    echo "Nothing to do."
    exit 0
fi

echo "The following files and directories will be deleted: "
echo

for file in $(ls -d linux*)
do
    echo $file
done

echo
read -p "Are you sure? " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Deleting..."
    rm -rf linux*
    echo "Done."
else
    echo "Aborted."
fi
