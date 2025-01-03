FROM kalilinux/kali-rolling

# Update dan instal paket yang diperlukan
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y wget sudo busybox systemd bash

# Install ttyd (web terminal)
RUN wget -qO /bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 && \
    chmod +x /bin/ttyd

# Set environment variables untuk kredensial
ENV USERNAME=666
ENV PASSWORD=666
ENV PORT=7681

# Membuat user dengan hak akses sudo
RUN useradd -m -s /bin/bash $USERNAME && \
    echo "$USERNAME:$PASSWORD" | chpasswd && \
    usermod -aG sudo $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USERNAME

# Install Docker binary
RUN wget -qO- https://download.docker.com/linux/static/stable/x86_64/docker-20.10.24.tgz | \
    tar xz -C /usr/local/bin --strip-components=1 && \
    chmod +x /usr/local/bin/docker

# Konfigurasi overlay filesystem
RUN mkdir -p /overlay-workdir /overlay-upperdir /merged

# Membuat fake systemctl
RUN mkdir -p /fake-systemd && \
    ln -s /bin/busybox /fake-systemd/systemctl && \
    echo "#!/bin/bash" > /fake-systemd/init.sh && \
    echo "exec /bin/bash" >> /fake-systemd/init.sh && \
    chmod +x /fake-systemd/init.sh

# Membuat entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose port untuk TTYD
EXPOSE $PORT

# Jalankan container dengan entrypoint
ENTRYPOINT ["/entrypoint.sh"]
