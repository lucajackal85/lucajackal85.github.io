################################
#### Travis CI Auto Tagging ####
################################
################################
## Example of usage inside a travis build file
#
#jobs:
#  include:
#    - stage: deploy
#      php: 7.4
#      script:
#        - curl -s https://lucajackal85.github.io/.travis-auto-tag.sh | bash
###################################
echo "################## Travis automatic Tag ##################"
if [[ "$TRAVIS_REPO_SLUG" == "" ]]; then
  echo "ERROR!"
  echo "\`TRAVIS_REPO_SLUG\` not set. Are you sure you're running this script inside a Travis build?"
  exit 1
fi

if [[ "$GH_TOKEN" == "" ]]; then
  echo "ERROR!"
  echo "\`GH_TOKEN\` not set. Please add it to the environment variables in the build configuration"
  exit 1
fi

GIT_VERSION_FULL=`curl -s https://api.github.com/repos/$TRAVIS_REPO_SLUG/tags | grep -m 1 -oP '"name": "\K(.*)(?=")'`
if [[ "$GIT_VERSION_FULL" == "" ]]; then
  echo "No Tags found!"
  GIT_VERSION_FULL="<none>"
  GIT_TAG="v0.1.0"
else
  if [[ `echo "$GIT_VERSION_FULL" | grep -oP "^v([0-9]+)\.([0-9]+)\.([0-9]+)$"` == "" ]]; then
    echo "ERROR!"
    echo "Invalid versioning format. Current tag is '$GIT_VERSION_FULL'. Supported format is \`v[major].[minor].[patch]\` (example v1.23.456)"
    exit 1
  fi

  GIT_VERSION_MAJOR=`echo "$GIT_VERSION_FULL" | grep -oP "v([0-9]+)\.([0-9]+)"`
  GIT_VERSION_PATCH=`echo "$GIT_VERSION_FULL" | grep -oP "([0-9]+)$"`

  GIT_VERSION_NEXT_PATCH=`expr $GIT_VERSION_PATCH + 1`
  GIT_TAG=$GIT_VERSION_MAJOR.$GIT_VERSION_NEXT_PATCH
fi

echo "Current Tag Version:  $GIT_VERSION_FULL"
echo "Next Tag Version:     $GIT_TAG"
echo ""
echo "Creating Tag $GIT_TAG on GitHub..."

if [[ "$GIT_VERSION_FULL" != "" && "$GIT_VERSION_MAJOR" != "" && "$GIT_VERSION_PATCH" != "" ]]; then
  echo "ok"
  git config --global user.email "builds@travis-ci.com"
  git config --global user.name "Travis CI"
  git tag $GIT_TAG -a -m "Tag Generated from TravisCI for build $TRAVIS_BUILD_NUMBER"
  git push https://${GH_TOKEN}@github.com/${TRAVIS_REPO_SLUG} --tags
fi

echo "Done!"
echo "##########################################################"