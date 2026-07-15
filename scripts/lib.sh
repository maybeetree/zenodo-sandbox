#!/bin/sh

eecho() { echo "$@" >&2 ; }
die() { eecho "$@"; exit 1; }
edie() { die "Failed to: $*"; }
cd_ass() { cd "$1" || die "Failed to cd into ${2:-$1}" ; }
ass() { "$@" || die "Failed to run command: $*" ; }

