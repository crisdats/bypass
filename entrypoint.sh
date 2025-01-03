#!/bin/bash

# Aktifkan overlay filesystem
if ! mount | grep -q "/merged"; then
  /overlay-setup.sh || echo "Failed to setup overlay filesystem"
fi

# Jalankan ttyd sebagai user tanpa root
su - $USERNAME -c "/bin/ttyd -p $PORT -c $USERNAME:$PASSWORD /bin/bash"
