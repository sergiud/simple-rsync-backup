#!/bin/bash

# By default, assume ~/.srbrc. Use the SRBRC environment variable to override
# the path.
readonly conf=${SRBRC:-$HOME/.srbrc}

[[ -f $conf ]] || \
  { echo error: missing \"$conf\" >&2; exit 1; }

source "$conf"

# Backup folder name is constructed from the current data. Use the SRB_DATE_FMT
# environment variable to override it.
readonly date_fmt=${SRB_DATE_FMT:-+%Y-%m-%d %H_%M_%S}

# The folder name of the current backup
readonly FOLDER=$(date "$date_fmt")
# The path to the current backup
TARGET=$dst/$FOLDER
readonly LOG_FILE="$dst/$FOLDER.log"

# The symbolic link to the last backup
readonly LAST_TARGET=$dst/.last-backup
readonly LAST_ABORTED_TARGET=$dst/.aborted-backup

# TODO check backup-exclude.txt

# TODO use absolute paths
RSYNCCONFIG=(
  -a
  --info=progress2
  --delete-delay
  --delete-excluded
  #--chmod=u=rwX
  #--no-g
  #--no-p
  --stats
  --log-file="$LOG_FILE"
)

# TODO check exclude if provided
if [[ -s $exclude ]]
then
  RSYNCCONFIG+=(--exclude-from="$exclude")
fi

if [[ -L "$LAST_ABORTED_TARGET" ]]
then
  LAST_TARGET_RESOLVED=$(readlink -f "$LAST_TARGET")
  LAST_TARGET_REAL=$(readlink -f "$LAST_ABORTED_TARGET")

  [[ -d $LAST_TARGET_REAL ]] || \
      { echo error: previous backup in progress \"$LAST_TARGET_REAL\" does not \
          exist >&2; \
          echo note: either remove .aborted-backup or restore the symlink; exit 1; }

  # rsync failed: create a symlink to the last target
  echo "detected an earlier started backup"
  echo "resuming to backup from $LAST_TARGET_RESOLVED to $LAST_TARGET_REAL"

  TARGET=$LAST_TARGET_REAL
  RSYNCCONFIG+=(--link-dest="$LAST_TARGET_RESOLVED")
elif [ -d "$LAST_TARGET" ]
then
  RSYNCCONFIG+=(--link-dest="$LAST_TARGET")
fi

# TODO unlink only if the TARGET exists (no dry-run)
rsync "${RSYNCCONFIG[@]}" "${src[@]}" "$TARGET"

if [[ $? -ne 0 ]]
then
  if [[ -L "$LAST_ABORTED_TARGET" ]]
  then
    unlink "$LAST_ABORTED_TARGET"
  fi

  # Do not remove .last-backup if exists
  ln -s "$TARGET" "$LAST_ABORTED_TARGET"

  if [[ $? -eq 0 ]]
  then
    echo "backup aborted: you can resume the backup later"
  else
    echo "backup aborted: failed to create a check point. \
                          backup cannot be resumed."
  fi
else
  # In case rsync succeeded, create a symbolic link to the last target that will
  # be used as argument for --link-dest
  if [[ -d "$TARGET" ]]
  then
  ( unlink "$LAST_TARGET" 2>/dev/null; exit 0 ) && \
    ln -s "$TARGET" "$LAST_TARGET"
  fi

  # Since rsync finished successfully, remove the symlink to the last aborted
  # target.
  if [[ -L "$LAST_ABORTED_TARGET" ]]
  then
    unlink "$LAST_ABORTED_TARGET"
  fi
fi
