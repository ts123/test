#!/bin/bash
echo $0 "$@"
# find . -name .git -prune -o -type f

TAG_NAME=${TRAVIS_BRANCH}
echo TAG_NAME:$TAG_NAME

ASSET=package-${TAG_NAME}.zip
zip -r9 ${ASSET} . -x '*.git*'

JQ_URL=http://stedolan.github.io/jq/download/linux64/jq
getreleaseid() {
    if [[ ! -f ./jq ]]; then 
        wget "$JQ_URL"
        chmod +x jq
    fi
    curl -s "https://api.github.com/repos/${1}/releases" | ./jq '. | map(select(.tag_name == "'${2}'")) | .[0].id'
}

RELEASE_ID=$(getreleaseid ${TRAVIS_REPO_SLUG} ${TAG_NAME})
if [ ! "$RELEASE_ID" == "null" ]; then
    echo releaseid:$RELEASE_ID exists
    # remove github release
    curl -H "Authorization: token ${TOKEN}" \
         -X DELETE \
         "https://api.github.com/repos/${TRAVIS_REPO_SLUG}/releases/${RELEASE_ID}"
fi

# create github release
curl -H "Authorization: token ${TOKEN}" \
     -H "Accept: application/vnd.github.manifold-preview" \
     -X POST \
     -d $(printf '{"tag_name":"%s", "draft":"true"}' "${TAG_NAME}") \
     "https://api.github.com/repos/${TRAVIS_REPO_SLUG}/releases"

RELEASE_ID=$(getreleaseid ${TRAVIS_REPO_SLUG} ${TAG_NAME})
if [ "$RELEASE_ID" == "null" ]; then
    echo releaseid:$RELEASE_ID not found
    exit 1
fi

# upload package.zip
curl -H "Authorization: token ${TOKEN}" \
     -H "Accept: application/vnd.github.manifold-preview" \
     -H "Content-Type: application/zip" \
     --data-binary @${ASSET}.zip \
     "https://uploads.github.com/repos/${TRAVIS_REPO_SLUG}/releases/${RELEASE_ID}/assets?name=${ASSET}.zip"

