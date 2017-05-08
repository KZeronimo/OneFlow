#!/bin/bash

git log --decorate --stat "${1--1}" HEAD;
