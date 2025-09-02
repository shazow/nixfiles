#!/usr/bin/env bash

set -e

# The repository where issues should be created. This is set by the workflow.
TARGET_REPO="$GITHUB_REPOSITORY"

# Grep for FIXME comments with GitHub issue URLs
# This regex is more robust and captures the owner, repo, issue number, and comment fragments.
grep -r -P "FIXME.*(https://github.com/([^/]+)/([^/]+)/(issues|pull)/(\d+)(#issuecomment-\d+)?)" . --exclude-dir={.git,node_modules,dist,build} --exclude="*.lock" --exclude="*.log" | while read -r line; do
  # Extract the URL and its components from the line
  full_url=$(echo "$line" | grep -o -P 'https://github.com/([^/]+)/([^/]+)/(issues|pull)/(\d+)(#issuecomment-\d+)?' | head -n 1)

  if [ -z "$full_url" ]; then
    continue
  fi

  base_url=$(echo "$full_url" | sed 's/#.*//')

  owner=$(echo "$base_url" | cut -d'/' -f4)
  repo=$(echo "$base_url" | cut -d'/' -f5)
  issue_number=$(echo "$base_url" | cut -d'/' -f7)

  # Check if the issue is closed
  # Note: This could be optimized to reduce API calls on large repositories
  issue_status=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$owner/$repo/issues/$issue_number" | jq -r '.state')

  if [ "$issue_status" != "closed" ]; then
    continue
  fi

  file_path=$(echo "$line" | cut -d':' -f1)

  # Construct the title for the new issue
  issue_title="$file_path: $owner/$repo#$issue_number"

  # Check if an issue with this title already exists in the target repo
  existing_issue=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/search/issues?q=repo:$TARGET_REPO+is:issue+in:title+\"$issue_title\"" | jq '.items | length')

  if [ "$existing_issue" -gt 0 ]; then
    continue
  fi

  # Create the new issue
  line_number=$(echo "$line" | cut -d':' -f2)
  code_line=$(echo "$line" | cut -d':' -f3-)
  commit_sha=$(git rev-parse HEAD)

  redirect_url=$(echo "$full_url" | sed 's|github.com|redirect.github.com|')

  # Construct the link to the FIXME using the GITHUB_SERVER_URL passed from the workflow
  issue_body=$(cat <<EOF
The issue [$owner/$repo#$issue_number]($redirect_url) has been closed. This FIXME may be ready to be addressed.

From \`$file_path:$line_number\`:
\`\`\`
$code_line
\`\`\`

$GITHUB_SERVER_URL/$TARGET_REPO/blob/$commit_sha/$file_path#L$line_number
EOF
)

  json_payload=$(jq -n \
    --arg title "$issue_title" \
    --arg body "$issue_body" \
    '{title: $title, body: $body}')

  curl -s -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$json_payload" \
    "https://api.github.com/repos/$TARGET_REPO/issues"
done
