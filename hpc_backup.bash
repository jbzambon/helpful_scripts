#!/bin/bash
# hpc_backup.sh

#   Backup cron script
#   Program will backup specified directories to specified backup drive and has an option for incremental backups.
#   Usage:
#     1.  Set local drive (backup_drive)
#     2.  Set remote backup directories (backup_dirs)
#     3.  Run initial backup with type=0
#     4.  After initial backup is complete, set type=1 and run as cronjob as often as you like

# Joseph B. Zambon, jbzambon@ncsu.edu
# 22 November 2016
#  Modified: 24 October 2017

# Define local backup destination directory
backup_drive=/raid0/backups/jbzambon

# Define directories from HPC to be backed up
backup_dirs=(
             '/gpfs_backup/he_data/he/jbzambon'
             '/gpfs_share/jbzambon'
             '/home/jbzambon'
            )

#Define backup type, 0 = initial, 1 = subsequent
type=0

# Do nothing below this line
#________________________________________________________________________________________________

date=`date "+%Y-%m-%d"`

for i in "${backup_dirs[@]}"
do
  echo $i
  if [ $type -eq 0 ]; then
    backup_dest=$backup_drive/hpc/backups/$i/backup_$date
    mkdir -p $backup_dest
    rsync -av -e "ssh -c arcfour" jbzambon@login01.hpc.ncsu.edu:$i/ $backup_dest
    rm -rf $backup_drive/hpc$i
    mkdir -p $backup_drive/hpc$i  # Must create entire path to new symlink dir
    rm -rf $backup_drive/hpc$i    # Must delete the symlink dir before writing new symlink dir
    ln -s $backup_dest $backup_drive/hpc$i
 elif [ $type -eq 1 ]; then
    backup_dest=$backup_drive/hpc/backups/$i/backup_$date
    mkdir -p $backup_dest
    rsync -av -e "ssh -c arcfour" --link-dest=$backup_drive/hpc$i jbzambon@login01.hpc.ncsu.edu:$i/ $backup_dest
    rm -rf $backup_drive/hpc$i
    mkdir -p $backup_drive/hpc$i  # Must create entire path to new symlink dir
    rm -rf $backup_drive/hpc$i    # Must delete the symlink dir before writing new symlink dir
    ln -s $backup_dest $backup_drive/hpc$i
  fi
done

