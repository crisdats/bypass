#!/bin/bash

# Mount overlay filesystem jika belum di-mount
if ! mount | grep -q "/merged"; then
    echo "Mounting overlay filesystem..."
    mount -t overlay overlay -o lowerdir=/,upperdir=/overlay-upperdir,workdir=/overlay-workdir /merged
fi

# Pastikan fake systemctl tersedia
if [ ! -L /fake-systemd/systemctl ]; then
    echo "Creating fake systemctl..."
    ln -sf /bin/busybox /fake-systemd/systemctl
fi

# Pastikan Docker tersedia
if ! command -v docker &> /dev/null; then
    echo "Docker binary not found! Please check the installation."
else
    echo "Docker is available."
fi

# Jalankan ttyd dan masuk ke shell
echo "Starting TTYD on port $PORT..."
ttyd -p $PORT -c $USERNAME:$PASSWORD /bin/bash
