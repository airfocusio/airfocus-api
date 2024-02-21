#!/bin/bash
set -eo pipefail
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
cd "$DIR/../.."

OPENAPI_URL="https://app.airfocus.com/api/docs/openapi.json"
OPENAPI_JSON=$(curl -fsSL "$OPENAPI_URL" | jq --sort-keys -r)
OPENAPI_VERSION=$(echo "$OPENAPI_JSON" | jq -r '.info.version')
echo "$OPENAPI_JSON" > openapi.json
git add openapi.json

git commit -m 'Update openapi.json' && GIT_COMMIT_EXIT_CODE=$? || GIT_COMMIT_EXIT_CODE=$?
if [ $GIT_COMMIT_EXIT_CODE == "0" ]; then
    echo "OpenAPI changed (version is $OPENAPI_VERSION)"
    git tag -f "$OPENAPI_VERSION"
    if [ "$1" == "--push" ]; then
        git push origin main "$OPENAPI_VERSION"
    fi
elif [ $GIT_COMMIT_EXIT_CODE == "1" ]; then
    echo "OpenAPI unchanged"
else
    echo "Git commit failed with exit code $GIT_COMMIT_EXIT_CODE"
    exit $GIT_COMMIT_EXIT_CODE
fi
