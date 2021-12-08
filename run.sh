#!/bin/bash

set -e

bundle exec rake yard:docs
git add docs/
git commit -m 'update docs'

git checkout gh-pages
git checkout development -- docs/
git commit -m 'update docs'
git push origin gh-pages

git checkout development
git reset --hard HEAD~1
