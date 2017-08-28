#!/bin/bash

git config --file "$1" core.editor 'vim'
git config --file "$1" core.autocrlf 'input'
git config --file "$1" core.safecrlf 'warn'
git config --file "$1" core.pager 'less -RFX'
git config --file "$1" branch.develop.mergeoptions '--no-ff'
git config --file "$1" branch.master.mergeoptions '--ff-only'
git config --file "$1" fetch.prune 'true'
git config --file "$1" pull.rebase 'preserve'
git config --file "$1" push.default 'simple'
git config --file "$1" push.followTags 'true'
git config --file "$1" rerere.enabled 'true'
git config --file "$1" workflow.featureaffix 'feature'
git config --file "$1" workflow.hotfixaffix 'hotfix'
git config --file "$1" workflow.releaseaffix 'release'
git config --file "$1" workflow.dorebase 'false'
