#!/bin/bash
# Fetch detailed review data for PRs via GitHub API
# Arguments: PR number(s)
# Outputs: structured review data per PR

REPO="hashicorp/terraform-provider-azurerm"

for PR in "$@"; do
  echo "=== PR #${PR} ==="
  
  # Get PR details
  PR_DATA=$(curl -s "https://api.github.com/repos/${REPO}/pulls/${PR}" \
    -H "Accept: application/vnd.github.v3+json" 2>/dev/null)
  
  TITLE=$(echo "$PR_DATA" | jq -r '.title')
  AUTHOR=$(echo "$PR_DATA" | jq -r '.user.login')
  STATE=$(echo "$PR_DATA" | jq -r '.state')
  MERGED=$(echo "$PR_DATA" | jq -r '.merged_at // "not merged"')
  CREATED=$(echo "$PR_DATA" | jq -r '.created_at')
  COMMITS=$(echo "$PR_DATA" | jq -r '.commits')
  CHANGED_FILES=$(echo "$PR_DATA" | jq -r '.changed_files')
  ADDITIONS=$(echo "$PR_DATA" | jq -r '.additions')
  DELETIONS=$(echo "$PR_DATA" | jq -r '.deletions')
  
  echo "Title: ${TITLE}"
  echo "Author: ${AUTHOR}"
  echo "State: ${STATE} | Merged: ${MERGED}"
  echo "Created: ${CREATED}"
  echo "Commits: ${COMMITS} | Files: ${CHANGED_FILES} | +${ADDITIONS}/-${DELETIONS}"
  echo ""
  
  # Get reviews (formal review submissions)
  echo "--- REVIEWS ---"
  curl -s "https://api.github.com/repos/${REPO}/pulls/${PR}/reviews?per_page=100" \
    -H "Accept: application/vnd.github.v3+json" 2>/dev/null | \
    jq -r '.[] | "[\(.submitted_at)] \(.user.login): \(.state) - \(.body // "no comment" | gsub("\n"; " ") | .[0:200])"'
  echo ""
  
  # Get review comments (inline code comments)
  echo "--- REVIEW COMMENTS ---"
  curl -s "https://api.github.com/repos/${REPO}/pulls/${PR}/comments?per_page=100" \
    -H "Accept: application/vnd.github.v3+json" 2>/dev/null | \
    jq -r '.[] | "[\(.created_at)] \(.user.login) on \(.path):\(.line // .original_line): \(.body | gsub("\n"; " ") | .[0:300])"'
  echo ""
  
  # Get issue comments (conversation comments)
  echo "--- ISSUE COMMENTS ---"
  curl -s "https://api.github.com/repos/${REPO}/issues/${PR}/comments?per_page=100" \
    -H "Accept: application/vnd.github.v3+json" 2>/dev/null | \
    jq -r '.[] | select(.user.login != "github-actions[bot]" and .user.login != "github-actions") | "[\(.created_at)] \(.user.login): \(.body | gsub("\n"; " ") | .[0:300])"'
  echo ""
  echo "========================="
  echo ""
  
  sleep 0.5
done
