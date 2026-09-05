#!/bin/bash
set -eo pipefail
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
cd "$DIR/../.."

API_BASE_URL="https://app.airfocus.com"
OPENAPI_URL="$API_BASE_URL/api/docs/openapi.json"
OPENAPI_VERSIONS_URL="$API_BASE_URL/api/docs/openapi/versions.json"
OPENAPI_DIR="docs/openapi"

# The published spec advertises every host the API is reachable on, not just the one we fetch from.
SERVERS='[{"url":"https://app.airfocus.app"},{"url":"https://app.airfocus.com"},{"url":"https://app.us.airfocus.com"}]'

mkdir -p "$OPENAPI_DIR"

VERSION_CONFIG=$(curl -fsSL "$OPENAPI_VERSIONS_URL")
SUPPORTED_API_VERSIONS=()
while IFS= read -r API_VERSION; do
    SUPPORTED_API_VERSIONS+=("$API_VERSION")
done < <(echo "$VERSION_CONFIG" | jq -r '.versions[]')

OPENAPI_JSON=$(curl -fsSL "$OPENAPI_URL" | jq -r ". | .servers = $SERVERS")
echo "$OPENAPI_JSON" > docs/openapi.json
OPENAPI_VERSION=$(echo "$OPENAPI_JSON" | jq -r '.info.version')

rm -f "$OPENAPI_DIR"/v[0-9]*.json
for API_VERSION in "${SUPPORTED_API_VERSIONS[@]}"; do
    curl -fsSL "$API_BASE_URL/api/v$API_VERSION/docs/openapi.json" |
        jq -r ". | .servers = $SERVERS" > "$OPENAPI_DIR/v$API_VERSION.json"
done

echo "$VERSION_CONFIG" | jq '.' > "$OPENAPI_DIR/versions.json"

git add docs/openapi.json "$OPENAPI_DIR"

git commit -m 'Update openapi.json' && GIT_COMMIT_EXIT_CODE=$? || GIT_COMMIT_EXIT_CODE=$?
if [ $GIT_COMMIT_EXIT_CODE == "0" ]; then
    echo "OpenAPI changed (version is $OPENAPI_VERSION)"
    git tag -f "$OPENAPI_VERSION"
    bash .github/actions/changelog.sh
    git add docs/changelog/ docs/changelog.md
    git diff --cached --quiet || git commit -m 'Update changelog'
    if [ "$1" == "--push" ]; then
        git push origin main "$OPENAPI_VERSION" -f
    fi
elif [ $GIT_COMMIT_EXIT_CODE == "1" ]; then
    echo "OpenAPI unchanged"
else
    echo "Git commit failed with exit code $GIT_COMMIT_EXIT_CODE"
    exit $GIT_COMMIT_EXIT_CODE
fi
