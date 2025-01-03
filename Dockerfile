FROM kalilinux/kali-rolling

# Update dan instal paket yang diperlukan
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y wget sudo dbus fuse-overlayfs iproute2 util-linux busybox

# Install ttyd (web terminal)
RUN wget -qO /bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 && \
    chmod +x /bin/ttyd

# Set environment variables untuk kredensial
ENV USERNAME=666
ENV PASSWORD=666
ENV PORT=7681
EXPOSE $PORT

# Membuat user dengan hak akses sudo
RUN useradd -m -s /bin/bash $USERNAME && \
    echo "$USERNAME:$PASSWORD" | chpasswd && \
    usermod -aG sudo $USERNAME

# Memberikan hak sudo tanpa password
RUN echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USERNAME

# Menambahkan "fake" systemd
RUN mkdir -p /fake-systemd && \
    ln -s /bin/busybox /fake-systemd/systemctl && \
    echo "#!/bin/sh" > /fake-systemd/init.sh && \
    echo "exec /bin/bash" >> /fake-systemd/init.sh && \
    chmod +x /fake-systemd/init.sh

# Emulasi overlay filesystem
RUN mkdir -p /overlay-workdir && \
    mkdir -p /overlay-upperdir && \
    mkdir -p /merged && \
    echo "mount -t overlay overlay -o lowerdir=/,upperdir=/overlay-upperdir,workdir=/overlay-workdir /merged && chroot /merged /bin/bash" > /overlay-setup.sh && \
    chmod +x /overlay-setup.sh

# Install docker binary untuk bypass docker di dalam container
RUN wget -qO /bin/docker https://download.docker.com/linux/static/stable/x86_64/docker-20.10.24.tgz && \
    tar -xz -C /bin/ docker && \
    chmod +x /bin/docker

# Memodifikasi entrypoint untuk mengaktifkan semua trik
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
