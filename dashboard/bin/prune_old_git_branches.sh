#!/usr/bin/env bash
set -Eeu

git fetch && git remote prune origin && git gc --prune=now