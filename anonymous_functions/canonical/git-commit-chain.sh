#!/bin/bash

git logbase --graph "${1-develop}".."${2-HEAD}";
