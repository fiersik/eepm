#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=rustdesk
# FIXME: move 1.2.0 to /opt
PRODUCTDIR=/usr/lib/$PRODUCT

. $(dirname $0)/common.sh

subst '1iAutoProv:no' $SPEC

# put service file to the normal place
mkdir -p $BUILDROOT/etc/systemd/system/
cp $BUILDROOT/usr/share/rustdesk/files/systemd/rustdesk.service $BUILDROOT/etc/systemd/system/$PRODUCT.service
remove_dir /usr/share/rustdesk/files/systemd
pack_file /etc/systemd/system/$PRODUCT.service

VERSION=$(grep "^Version:" $SPEC | sed -e "s|Version: ||")
if [ "$VERSION" = "1.1.9" ] ; then
echo "Note: use 1.1.9 compatibility script"
echo "Categories=GNOME;GTK;Network;RemoteAccess;" >> $BUILDROOT/usr/share/applications/$PRODUCT.desktop

# thread 'main' panicked at 'error: 'libsciter-gtk.so' was not found neither in PATH nor near the current executable.
#move_to_opt /usr/lib/rustdesk
#mv $BUILDROOT/usr/bin/$PRODUCT $BUILDROOT/$PRODUCTDIR
#pack_file $PRODUCTDIR/$PRODUCT
#add_bin_exec_command
#remove_dir /usr/lib

# Works without this
#epm assure patchelf || fatal
#for i in $BUILDROOT/usr/bin/$PRODUCT ; do
#    a= patchelf --set-rpath '$PRODUCTDIR' $i || continue
#done

epm install --skip-installed glib2 libappindicator-gtk3 libcairo libgdk-pixbuf libgtk+3 libpango libpulseaudio libuuid libX11 libXau libxcb libXdmcp libXfixes libXtst xdotool
epm install --skip-installed  python3-module-pynput || epm install 316570

exit
fi

#### 1.2.0 and above
subst "s|^Categories.*|Categories=GNOME;GTK;Network;RemoteAccess;|" $BUILDROOT/usr/share/applications/$PRODUCT.desktop
subst "s|/usr/share/rustdesk/files/rustdesk.png|$PRODUCT|" $BUILDROOT/usr/share/applications/$PRODUCT.desktop

ICONFILE=$PRODUCT.png
install_file /usr/share/rustdesk/files/rustdesk.png /usr/share/pixmaps/$ICONFILE

#move_to_opt /usr/lib/rustdesk
add_bin_link_command

epm assure patchelf || fatal
for i in $BUILDROOT/$PRODUCTDIR/lib/*.so ; do
    a= patchelf --set-rpath '$ORIGIN/' $i || continue
done

epm install --skip-installed glib2 libappindicator-gtk3 libcairo libgdk-pixbuf libgtk+3 libpango libpulseaudio libuuid libX11 libXau libxcb libXdmcp libXfixes libXtst xdotool
epm install --skip-installed  python3-module-pynput || epm install 316570
