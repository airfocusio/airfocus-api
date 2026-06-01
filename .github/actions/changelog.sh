#!/bin/bash
set -eo pipefail

FROM="$1"
TO="$2"

CHANGELOG_DIR="docs/changelog"
CHANGELOG_INDEX="docs/changelog.md"

BUCKET_FRONTMATTER="---
layout: default
nav_exclude: true
search_exclude: true
---
"

# Extract the server version segment from a tag: 1.0.0-beta.46.173.0 → 46
get_bucket() {
    echo "$1" | cut -d'.' -f4
}

run_oasdiff() {
    local from_tag="$1" to_tag="$2"
    git show "$from_tag:docs/openapi.json" > /tmp/oasdiff-from.json
    git show "$to_tag:docs/openapi.json"   > /tmp/oasdiff-to.json
    if command -v oasdiff &>/dev/null; then
        oasdiff changelog /tmp/oasdiff-from.json /tmp/oasdiff-to.json --format markdown
    else
        docker run --rm \
            -v /tmp/oasdiff-from.json:/from.json \
            -v /tmp/oasdiff-to.json:/to.json \
            oasdiff/oasdiff changelog /from.json /to.json --format markdown
    fi \
    | sed 's/:warning:/⚠️/g' \
    | awk '/^# API Changelog |^## API Changes$|^## Components$/{skip=1; next} skip && /^[[:space:]]*$/{skip=0; next} {skip=0; print}'
    rm -f /tmp/oasdiff-from.json /tmp/oasdiff-to.json
}

# Returns file content with the leading frontmatter block stripped (if present)
content_without_frontmatter() {
    local file="$1"
    local firstline
    IFS= read -r firstline < "$file"
    if [ "$firstline" = "---" ]; then
        awk 'BEGIN{count=0} /^---$/{count++; next} count<2{next} {print}' "$file"
    else
        cat "$file"
    fi
}

update_index() {
    BUCKETS=()
    for f in "$CHANGELOG_DIR"/v*.md; do
        [ -f "$f" ] || continue
        bucket=$(basename "$f" .md | sed 's/v//')
        BUCKETS+=("$bucket")
    done

    IFS=$'\n' SORTED=($(printf '%s\n' "${BUCKETS[@]}" | sort -rn)); unset IFS

    {
        echo "---"
        echo "layout: default"
        echo "title: Changelog"
        echo "nav_order: 35"
        echo "---"
        echo ""
        echo "# Changelog"
        echo ""
        for bucket in "${SORTED[@]}"; do
            oldest_tag=$(grep "^## [0-9]" "$CHANGELOG_DIR/v$bucket.md" | tail -1 | sed 's/^## //')
            created=$(git log -1 --format="%as" "$oldest_tag")
            echo "- [v$bucket](changelog/v$bucket) _(created: $created)_"
        done
    } > "$CHANGELOG_INDEX"
}

if [ -z "$FROM" ]; then
    # Auto mode: find all tags not yet documented in any changelog file

    mkdir -p "$CHANGELOG_DIR"

    DOCUMENTED_TAGS=()
    while IFS= read -r file; do
        while IFS= read -r tag; do
            DOCUMENTED_TAGS+=("$tag")
        done < <(grep "^## [0-9]" "$file" | sed 's/^## //')
    done < <(find "$CHANGELOG_DIR" -name "v*.md")

    ALL_TAGS=()
    while IFS= read -r tag; do
        ALL_TAGS+=("$tag")
    done < <(git tag --sort=creatordate)

    NEW_TAGS=()
    for tag in "${ALL_TAGS[@]}"; do
        documented=false
        for dt in "${DOCUMENTED_TAGS[@]}"; do
            [ "$dt" = "$tag" ] && documented=true && break
        done
        $documented || NEW_TAGS+=("$tag")
    done

    if [ ${#NEW_TAGS[@]} -eq 0 ]; then
        echo "No new tags to document."
        exit 0
    fi

    echo "Found ${#NEW_TAGS[@]} undocumented tag(s): ${NEW_TAGS[*]}"

    TMP_DIR=$(mktemp -d)

    for tag in "${NEW_TAGS[@]}"; do
        PREV_TAG="$(git describe --tags --abbrev=0 "${tag}^" 2>/dev/null || echo "")"
        if [ -z "$PREV_TAG" ]; then
            echo "Skipping $tag (no previous tag found)"
            continue
        fi

        echo "Generating changelog for $tag (from $PREV_TAG)..."
        ENTRY="$(run_oasdiff "$PREV_TAG" "$tag")"

        if [ -z "$ENTRY" ]; then
            echo "No API changes for $tag, skipping."
            continue
        fi

        BUCKET="$(get_bucket "$tag")"
        TMP_BUCKET="$TMP_DIR/$BUCKET"
        touch "$TMP_BUCKET"

        created=$(git log -1 --format="%as" "$tag")
        TMP_ENTRY=$(mktemp)
        { echo "## $tag ($created)"; echo ""; echo "$ENTRY"; echo ""; } > "$TMP_ENTRY"
        cat "$TMP_ENTRY" "$TMP_BUCKET" > "${TMP_BUCKET}.new"
        mv "${TMP_BUCKET}.new" "$TMP_BUCKET"
        rm "$TMP_ENTRY"
    done

    UPDATED=false
    for TMP_BUCKET in "$TMP_DIR"/*; do
        [ -f "$TMP_BUCKET" ] && [ -s "$TMP_BUCKET" ] || continue
        bucket=$(basename "$TMP_BUCKET")
        TARGET="$CHANGELOG_DIR/v$bucket.md"

        TMP_RESULT=$(mktemp)
        {
            printf '%s\n' "$BUCKET_FRONTMATTER"
            cat "$TMP_BUCKET"
            [ -f "$TARGET" ] && content_without_frontmatter "$TARGET" || true
        } > "$TMP_RESULT"
        mv "$TMP_RESULT" "$TARGET"

        echo "Updated $TARGET"
        UPDATED=true
    done

    rm -rf "$TMP_DIR"

    if $UPDATED; then
        update_index
        echo "Updated $CHANGELOG_INDEX"
    else
        echo "No changes to write."
    fi

    exit 0
fi

# Single-arg mode: resolve TO as the tag before FROM
if [ -z "$TO" ]; then
    TO="$(git describe --tags --abbrev=0 "${FROM}^")"
    echo "Resolved previous tag: $TO"
fi

git show "$FROM:docs/openapi.json" > /tmp/oasdiff-from.json
git show "$TO:docs/openapi.json"   > /tmp/oasdiff-to.json

if command -v oasdiff &>/dev/null; then
    oasdiff changelog /tmp/oasdiff-from.json /tmp/oasdiff-to.json --format markdown
else
    docker run --rm -t \
        -v /tmp/oasdiff-from.json:/from.json \
        -v /tmp/oasdiff-to.json:/to.json \
        oasdiff/oasdiff changelog /from.json /to.json --format markdown
fi

rm -f /tmp/oasdiff-from.json /tmp/oasdiff-to.json
