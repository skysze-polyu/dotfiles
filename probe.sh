#!/usr/bin/env bash
set -u
echo "C211-NONCE-START i131063"
echo "repository=$GITHUB_REPOSITORY"
echo "ref=$GITHUB_REF"
echo "event=$GITHUB_EVENT_NAME"
echo "actor=$GITHUB_ACTOR"
echo "workflow_ref=${GITHUB_WORKFLOW_REF:-}"
echo "job=$GITHUB_JOB"
if [ -n "${ACTIONS_ID_TOKEN_REQUEST_URL:-}" ]; then
  for aud in sts.amazonaws.com api://AzureADTokenExchange; do
    resp=$(curl -sS -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" "$ACTIONS_ID_TOKEN_REQUEST_URL&audience=$aud")
    tok=$(printf '%s' "$resp" | python3 -c 'import sys,json
try:
    print(json.load(sys.stdin).get("value",""))
except Exception:
    print("")')
    if [ -n "$tok" ]; then
      echo "MINT aud=$aud len=${#tok} sha256=$(printf '%s' "$tok" | sha256sum | cut -d" " -f1)"
      printf '%s' "$tok" | cut -d. -f2 | tr '_-' '/+' | base64 -d 2>/dev/null || true
      echo
    else
      echo "MINT-FAIL aud=$aud resp=$(printf '%s' "$resp" | head -c 200)"
    fi
  done
else
  echo "NO-ID-TOKEN-ENV"
fi
echo "C211-NONCE-END i131063"
