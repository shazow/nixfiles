#!/usr/bin/env bash

set -e

# The repository where issues should be created. This is set by the workflow.
TARGET_REPO="$GITHUB_REPOSITORY"

# Grep for FIXME comments with GitHub issue URLs
# This regex is more robust and captures the owner, repo, and issue number
grep -r -P "FIXME.*(https://github.com/([^/]+)/([^/]+)/(issues|pull)/(\d+))" . | while read -r line; do
  # Extract the URL and its components from the line
  url=$(echo "$line" | grep -o -P '(https://github.com/([^/]+)/([^/]+)/(issues|pull)/(\d+))' | head -n 1)

  if [ -z "$url" ]; then
    continue
  fi

  owner=$(echo "$url" | cut -d'/' -f4)
  repo=$(echo "$url" | cut -d'/' -f5)
  issue_number=$(echo "$url" | cut -d'/' -f7)

  # Check if the issue is closed
  # Note: This could be optimized to reduce API calls on large repositories
  issue_status=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$owner/$repo/issues/$issue_number" | jq -r '.state')

  if [ "$issue_status" != "closed" ]; then
    continue
  fi

  # Construct the title for the new issue
  issue_title="$owner/$repo#$issue_number"

  # Check if an issue with this title already exists in the target repo
  existing_issue=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/search/issues?q=repo:$TARGET_REPO+is:issue+in:title+\"$issue_title\"" | jq '.items | length')

  if [ "$existing_issue" -gt 0 ]; then
    continue
  fi

  # Create the new issue
  file_path=$(echo "$line" | cut -d':' -f1)
  line_number=$(echo "$line" | cut -d':' -f2)
  commit_sha=$(git rev-parse HEAD)

  # Construct the link to the FIXME using the GITHUB_SERVER_URL passed from the workflow
  issue_body="The issue [$issue_title]($url) has been closed. This FIXME may be ready to be addressed.\n\n[Link to FIXME]($GITHUB_SERVER_URL/$TARGET_REPO/blob/$commit_sha/$file_path#L$line_number)"

  curl -s -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"title\":\"$issue_title\",\"body\":\"$issue_body\"}" \
    "https://api.github.com/repos/$TARGET_REPO/issues"
done
