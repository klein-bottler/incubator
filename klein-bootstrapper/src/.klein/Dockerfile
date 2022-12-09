FROM alpine:3.16.2

RUN apk add --no-cache podman fuse-overlayfs shadow


RUN useradd podman; \
echo -e "podman:1:999\npodman:1001:64535" > /etc/subuid; \
echo -e "podman:1:999\npodman:1001:64535" > /etc/subgid;

COPY assets/config/containers.global.conf /etc/containers/containers.conf
COPY assets/config/containers.local.conf /home/podman/.config/containers/containers.conf


RUN mkdir -p /home/podman/.local/share/containers && \
    chown podman:podman -R /home/podman && \
    chmod 644 /etc/containers/containers.conf

RUN sed -e 's|^#mount_program|mount_program|g' \
           -e '/additionalimage.*/a "/var/lib/shared",' \
           -e 's|^mountopt[[:space:]]*=.*$|mountopt = "nodev,fsync=0"|g' \
           /usr/share/containers/storage.conf \
           > /etc/containers/storage.conf

VOLUME /var/lib/containers
VOLUME /home/podman/.local/share/containers

RUN mkdir -p /var/lib/shared/overlay-images \
             /var/lib/shared/overlay-layers \
             /var/lib/shared/vfs-images \
             /var/lib/shared/vfs-layers && \
    touch /var/lib/shared/overlay-images/images.lock && \
    touch /var/lib/shared/overlay-layers/layers.lock && \
    touch /var/lib/shared/vfs-images/images.lock && \
    touch /var/lib/shared/vfs-layers/layers.lock

ENV _CONTAINERS_USERNS_CONFIGURED=""

# local dev utilities
RUN apk add --no-cache bash git jq zsh vim coreutils ncurses python3 py3-pip
# leave a relatively recent package index explicitly
RUN apk update

COPY . /klein
RUN cp /klein/assets/config/.profile /root/.profile; \
    cp /klein/assets/config/.profile /etc/profile; \
    cp /klein/assets/config/.profile /home/podman/.profile; \
    cp /klein/assets/config/.profile /home/podman/.profile; \
    cp /klein/assets/config/.bashrc /root/.bashrc; \
    cp /klein/assets/config/.bashrc /home/podman/.bashrc; \
    cp /klein/assets/config/.bashrc /etc/bash/bashrc;\
    cp /klein/assets/enter-sh.sh /enter-sh; \
    cp -r /klein/assets/bootstrap /bootstrap; \
    env > /bootstrap/env_defaults; \
    echo "PATH=$PATH" >> /bootstrap/env_overrides
ENV PATH="${PATH}:/bootstrap"
WORKDIR /
