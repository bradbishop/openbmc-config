#!/bin/sh
# Hook to add source component/revision info to commit message
# Parameter:
#   $1 patch-file
#   $2 revision
#   $3 reponame
# For OpenBMC, generate a new change ID by hashing the old one; this ensures
# a stable Change-Id and encourages Gerrit to create a new change for the
# openbmc repository instead of complaining about the old one being closed.

patchfile=$1
rev=$2
reponame=$3

sed -i -e "0,/^Signed-off-by:/s#\(^Signed-off-by:.*\)#\(From $reponame rev: $rev\)\n\n\1#" $patchfile

change_id=`awk -F: '/^Change-Id:\sI[a-f0-9]{40}$/ { print $NF } ' $patchfile`
if [ -z "$change_id" ]; then
     change_id=$rev
fi
change_id=`echo $change_id | git hash-object --stdin`
sed -i -e "/^Change-Id:\sI[a-f0-9]\{40\}$/d" $patchfile
sed -i -e "0,/^Signed-off-by:/s#\(^Signed-off-by:.*\)#\Change-Id: I$change_id\n\1#" $patchfile
