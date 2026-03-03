#!/bin/sh
################################################################################
# sa-dl_learn.sh
# Simple wrapper tool for sa-learn to more easily automate Spam Assassin        
# learning.
#
# Copyright 2004: dleonard@dleonard.net
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.  The author
# would appreciate it if any useful modifications performed were emailed
# to the maintainer as a unified dif in order to make the tool more useful
# to others.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
################################################################################
sa_learn="/usr/bin/sa-learn"
sa_params="--no-sync --spam --mbox "
ham_params="--no-sync --ham --mbox "

maildir=`cd ~/mail ; pwd`
caughtdir="$maildir/probablespam"
notcaughtdir="$maildir/spam"
notspamdir="$maildir/notspam"

all=1
backup=''

################################################################################
help() {
 echo "sa-dl_learn.sh [--caught] [--notcaught] [--notspam] [--all] [--backup]"
 echo "  --caught       # Learn from MAILDIR/probablespam"
 echo "  --notcaught    # Learn from MAILDIR/spam"
 echo "  --notspam      # Learn from MAILDIR/notspam"
 echo "  --all          # Equivalent of --caught --notcaught --notspam"
 echo "  --backup       # Append message to <mailfolder>.bak before deleting"
 echo "                   <mailfolder>"
 echo

 exit 0
}

for i in $*; do
 if [ "$i" = "--caught" ]; then
  caught=1
  all=''
 elif [ "$i" = "--notcaught" ]; then
  notcaught=1
  all=''
 elif [ "$i" = "--ham" -o "$i" = "--notspam" ]; then
  notspam=1
  all=''
 elif [ "$i" = "--all" ]; then
  all=1
 elif [ "$i" = "--backup" ]; then
  backup=1
 else
  help
 fi
done

if [ "$all" ]; then
 caught=1
 notcaught=1
 notspam=1
fi

# Learn from previous spam
if [ "$caught" ]; then
 if [ -f $caughtdir ]; then
  $sa_learn $sa_params $caughtdir
  if [ "$backup" ]; then
   cat $caughtdir >>$caughtdir.bak
  fi
  rm $caughtdir
 fi
fi

if [ "notcaught" ]; then
 if [ -f $notcaughtdir ]; then
  $sa_learn $sa_params $notcaughtdir
  if [ "$backup" ]; then
   cat $notcaughtdir >>$notcaughtdir.bak
  fi
  rm $notcaughtdir
 fi
fi

# Learn to not catch messages as spam
if [ "$notspam" ]; then
 if [ -f $notspamdir ]; then
  $sa_learn $ham_params $notspamdir
  if [ "$backup" ]; then
   cat $notspamdir >>$notspamdir.bak
  fi
  rm $notspamdir
 fi
fi

$sa_learn --sync
