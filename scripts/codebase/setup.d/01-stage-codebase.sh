#!/bin/bash
set -e

# Stage the codebase
# This script is used to checkout the codebase to the commit that corresponds to the lesson label from the commit message.

# Note this file is meant to generalize the staging of the codebase via a provided LESSON_LABEL environment variable.
# there are no explicit parameters for this script to maximize the decoupling of the lesson content from the staging script.

# Env vars:
# LESSON_LABEL: Label to search for in commits. Must be surrounded by <> in the commit message to match
# LESSON_REPO_DIR: Location of the codebase repo, if not in ~/exercises

get_sha_for_lesson_label() {
  git log --format=format:%H --grep "<$LESSON_LABEL>"
}

checkout_to_label() {
  lesson_sha=$(get_sha_for_lesson_label)
  if [[ -z "$lesson_sha" ]]; then
    echo "LESSON_LABEL '$LESSON_LABEL' has no matching commit for this workshop."
  else
    echo "Checking out from git. Label (Git commit containing text): <$LESSON_LABEL>, SHA: $lesson_sha"
    git checkout $lesson_sha
  fi
}

# Make sure we are in the root of the repo
LESSON_REPO_DIR="${LESSON_REPO_DIR:-$HOME/exercises}"

if [[ ! -d "$LESSON_REPO_DIR" ]]; then
  echo "No codebase at $LESSON_REPO_DIR. Exiting without error."
  exit 0
fi

if [[ -z "$LESSON_LABEL" ]]; then
  echo "No lesson label provided. Exiting without error."
  exit 0
fi

cd "$LESSON_REPO_DIR"
checkout_to_label