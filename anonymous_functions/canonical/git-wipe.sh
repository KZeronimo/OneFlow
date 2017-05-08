#!/bin/sh

git add -A && git commit -qm 'WIPE SAVEPOINT' && git reset --hard HEAD~1;
