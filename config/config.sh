#!/bin/bash

git config --file ./.gitconfig core.editor 'code --wait'
git config --file ./.gitconfig core.safecrlf 'warn'
git config --file ./.gitconfig branch.develop.mergeoptions '--no-ff'
git config --file ./.gitconfig branch.master.mergeoptions '--ff-only'
git config --file ./.gitconfig fetch.prune 'true'
git config --file ./.gitconfig pull.rebase 'preserve'
git config --file ./.gitconfig push.default 'simple'
git config --file ./.gitconfig push.followTags 'true'
git config --file ./.gitconfig rerere.enabled 'true'
git config --file ./.gitconfig workflow.featureaffix 'feature'
git config --file ./.gitconfig workflow.hotfixaffix 'hotfix'
git config --file ./.gitconfig workflow.releaseaffix 'release'
git config --file ./.gitconfig workflow.dorebase 'false'