#!/bin/bash
# Fetch basic metadata for all PRs to organize by month
# Output: pr_number, date_opened, date_merged, author, title

PRS=(
32133 32072 32071 32044 32012 31989 31963 31911 31888 31871
31838 31808 31798 31745 31705 31682 31670 31651 31653 31654
31640 31627 31610 31612 31613 31605 31592 31593 31585 31569
31570 31535 31536 31515 31519 31509 31494 31497 31469 31470
31463 31460 31445 31433 31436 31431 31412 31413 31411 31401
31402 31403 31392 31384 31385 31377 31368 31355 31337 31333
31323 31315 31314 31299 31249 31248 31214 31216 31204 31205
31209 31197 31199 31194 31179 31164 31123 31100 31091 31082
31084 31077 31078 31062 31064 31066 31065 31063 31018 31021
30995 31001 30982 30983 30991 30970 30972 30980 30962 30958
30959 30964 30966 30945 30944 30931 30924 30925 30916 30917
30907 30889 30890 30856 30860 30858 30842 30836 30838 30841
30823 30796 30778 30758 30759 30760
)

echo "pr_number,date_opened,date_merged,author,title"

for PR in "${PRS[@]}"; do
  # Use GitHub API to fetch PR metadata
  DATA=$(curl -s "https://api.github.com/repos/hashicorp/terraform-provider-azurerm/pulls/${PR}" \
    -H "Accept: application/vnd.github.v3+json" 2>/dev/null)
  
  OPENED=$(echo "$DATA" | jq -r '.created_at // "unknown"' | cut -c1-10)
  MERGED=$(echo "$DATA" | jq -r '.merged_at // "null"' | cut -c1-10)
  AUTHOR=$(echo "$DATA" | jq -r '.user.login // "unknown"')
  TITLE=$(echo "$DATA" | jq -r '.title // "unknown"' | tr ',' ';')
  STATE=$(echo "$DATA" | jq -r '.state // "unknown"')
  
  echo "${PR},${OPENED},${MERGED},${AUTHOR},${TITLE}"
  
  # Small delay to avoid rate limiting
  sleep 0.3
done
