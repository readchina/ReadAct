#!/bin/sh
# https://www.vinaygopinath.me/blog/tech/commit-to-master-branch-on-github-using-travis-ci/

setup_git() {
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
}

commit_files() {
  git checkout master
  git add ./csv/views/ *.csv
  git add ./xml/ *.xml
  git commit --message "[skip ci] Travis build: $TRAVIS_BUILD_NUMBER"
}

upload_files() {
  git remote add new-origin https://duncdrum:${GH_TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git > /dev/null 2>&1
  git push new-origin master --quiet > /dev/null 2>&1
}

setup_git
commit_files
upload_files
