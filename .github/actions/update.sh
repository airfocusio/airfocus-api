#!/bin/bash
set -eo pipefail
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
cd "$DIR/../.."

OPENAPI_URL="https://app.airfocus.com/api/docs/openapi.json"
OPENAPI_VERSIONS_URL="https://app.airfocus.com/api/docs/openapi/versions.json"
OPENAPI_DIR="docs/openapi"

mkdir -p "$OPENAPI_DIR"

VERSION_CONFIG=$(curl -fsSL "$OPENAPI_VERSIONS_URL")
STABLE_API_VERSION=$(echo "$VERSION_CONFIG" | jq -r '.stable')
SUPPORTED_API_VERSIONS=()
while IFS= read -r API_VERSION; do
    SUPPORTED_API_VERSIONS+=("$API_VERSION")
done < <(echo "$VERSION_CONFIG" | jq -r '.versions[]')

for API_VERSION in "${SUPPORTED_API_VERSIONS[@]}"; do
    OPENAPI_JSON=$(curl -fsSL "$OPENAPI_URL?version=$API_VERSION" |
        jq -r '. | .servers = [{"url":"https://app.airfocus.app"},{"url":"https://app.airfocus.com"},{"url":"https://app.us.airfocus.com"}]')
    echo "$OPENAPI_JSON" > "$OPENAPI_DIR/v$API_VERSION.json"

    if [ "$API_VERSION" == "$STABLE_API_VERSION" ]; then
        OPENAPI_VERSION=$(echo "$OPENAPI_JSON" | jq -r '.info.version')
        echo "$OPENAPI_JSON" > docs/openapi.json
    fi
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
