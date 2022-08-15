#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=yandex-browser
PRODUCTCUR=yandex-browser-stable
PRODUCTDIR=/opt/yandex/browser

. $(dirname $0)/common-chromium-browser.sh

subst '1iConflicts:yandex-browser-beta' $SPEC

subst '5iProvides: yandex-browser = %{version}' $SPEC

set_alt_alternatives 65

copy_icons_to_share

cleanup

add_bin_commands

use_system_xdg

install_deps

