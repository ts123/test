#!/bin/bash
echo $0 "$@"
# find . -name .git -prune -o -type f

TAG_NAME=${TRAVIS_BRANCH}
echo TAG_NAME:$TAG_NAME
if [[ ! "$TAG_NAME" =~ '[0-9]+\.[0-9]+\.[0-9]+$' ]]; then
    echo $TAG_NAME is not a valid tag name
    exit
fi

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
    echo remove release:$RELEASE_ID
    # remove github release
    curl -H "Authorization: token ${TOKEN}" \
         -X DELETE \
         "https://api.github.com/repos/${TRAVIS_REPO_SLUG}/releases/${RELEASE_ID}"
fi

# create github release
echo create release
rm -f data.json
printf '{"tag_name":"%s", "target_commitish":"%s", "draft":"true"}' "${TAG_NAME}" "${TRAVIS_COMMIT}" > data.json
curl -H "Authorization: token ${TOKEN}" \
     -H "Accept: application/vnd.github.manifold-preview" \
     -X POST \
     -d @data.json \
     "https://api.github.com/repos/${TRAVIS_REPO_SLUG}/releases"

RELEASE_ID=$(getreleaseid ${TRAVIS_REPO_SLUG} ${TAG_NAME})
if [ "$RELEASE_ID" == "null" ]; then
    echo releaseid:$RELEASE_ID not found
    exit 1
fi

# upload package.zip
echo upload ${ASSET}
curl -H "Authorization: token ${TOKEN}" \
     -H "Accept: application/vnd.github.manifold-preview" \
     -H "Content-Type: application/zip" \
     --data-binary @${ASSET} \
     "https://uploads.github.com/repos/${TRAVIS_REPO_SLUG}/releases/${RELEASE_ID}/assets?name=${ASSET}"

