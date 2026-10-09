#!/usr/bin/env bash
#
# gcp-tree.sh
#
# Purpose:
#   Print the GCP resource hierarchy (organization -> folders -> projects)
#   as an indented tree, recursing through all nested folders. Projects
#   that are Shared VPC host projects are tagged "[shared VPC host]".
#   This is a terminal alternative to the console's resource hierarchy
#   view, which is cramped and hard to screenshot.
#
# Usage:
#   ./gcp-tree.sh ORG_ID QUERY_PROJECT
#
# Requirements:
#   - gcloud CLI, authenticated (gcloud auth login)
#   - Folder Viewer (or Browser) at the organization level
#   - compute.organizations.listSharedVpcHosts (e.g. Compute Shared VPC
#     Admin or Compute Network Viewer at the org) to tag host projects
#   - Don't use the bootstrap project as the QUERY_PROJECT as it won't have Compute enabled.
#
# Notes:
#   - Each gcloud call inside the loops reads from /dev/null so it can't
#     consume the while-loop's stdin.
#   - The script makes one API call per folder level. On a large org,
#     Cloud Asset Inventory (gcloud asset search-all-resources) is faster.
#
# Change History:
#   Date        Author       Description
#   ----------  -----------  ------------------------------------------------
#   2026-10-09  Steve Hager   Initial version: recursive org/folder/project tree
#                               with Shared VPC host tagging.
#
ORG_ID="$1"
QUERY_PROJECT="${2:-$(gcloud config get-value project 2>/dev/null)}"

if [[ -z "$QUERY_PROJECT" ]]; then
  echo "WARNING: no project given or configured; skipping Shared VPC host lookup" >&2
  HOSTS=""
elif ! HOSTS=$(gcloud compute shared-vpc organizations list-host-projects "$ORG_ID" \
                 --project="$QUERY_PROJECT" --format="value(name)" </dev/null); then
  echo "WARNING: couldn't list Shared VPC hosts; tags will be missing" >&2
  HOSTS=""
elif [[ -z "$HOSTS" ]]; then
  echo "NOTE: no Shared VPC host projects found in org ${ORG_ID}" >&2
fi

walk() {
  local ptype="$1" pid="$2" indent="$3"

  # Projects directly under this parent
  gcloud projects list --filter="parent.type=${ptype} AND parent.id=${pid}" \
      --format="value(projectId)" </dev/null |
  while read -r proj; do
    tag=""; grep -qx "$proj" <<<"$HOSTS" && tag="   [shared VPC host]"
    echo "${indent}- ${proj}${tag}"
  done

  # Subfolders, then recurse
  gcloud resource-manager folders list --"${ptype}"="${pid}" \
      --format="value(name.basename(),displayName)" </dev/null |
  while IFS=$'\t' read -r fid fname; do
    echo "${indent}+ ${fname}/  (${fid})"
    walk folder "$fid" "${indent}    "
  done
}

echo "Organization ${ORG_ID}"
walk organization "$ORG_ID" "  "
