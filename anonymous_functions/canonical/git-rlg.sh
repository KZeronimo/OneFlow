#!/bin/sh

git reflog "$(git rev-parse --abbrev-ref HEAD)";
