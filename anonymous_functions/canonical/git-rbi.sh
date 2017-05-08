#!/bin/bash

git rebase -i "$(git merge-base "${1-develop}" "${2-HEAD}")";
