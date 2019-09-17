FROM lsiobase/alpine:3.10
#FROM migoller/shinobidocker:2-alpine # I wish
# Setup shinobi with S6
RUN \
    apk add --no-cache \
        git \
        nodejs npm \
        freetype-dev \ 
        gnutls-dev \ 
        lame-dev \ 
        libass-dev \ 
        libogg-dev \ 
        libtheora-dev \ 
        libvorbis-dev \ 
        libvpx-dev \ 
        libwebp-dev \ 
        libssh2 \ 
        opus-dev \ 
        rtmpdump-dev \ 
        x264-dev \ 
        x265-dev \ 
        yasm-dev && \
    apk add --no-cache --virtual \ 
        .build-dependencies \ 
        build-base \ 
        bzip2 \ 
        coreutils \ 
        gnutls \ 
        nasm \ 
        tar \ 
        x264 && \
    apk add --no-cache \
        ffmpeg \
        git \
        make \
        mariadb \
        mariadb-client \
        openrc \
        pkgconfig \
        python \
        wget \
        tar \
        xz && \
    apk add --no-cache \
        pango \
        pango-dev \
        libjpeg-turbo \
        libjpeg-turbo-dev \
        cairo \
        cairo-dev && \
    apk add --no-cache \
        ffmpeg && \
#   sed -ie "s/^bind-address\s*=\s*127\.0\.0\.1$/#bind-address = 0.0.0.0/" /etc/mysql/my.cnf && \
#   wget --quiet https://cdn.shinobi.video/installers/ffmpeg-release-64bit-static.tar.xz && \
#   tar xpvf ./ffmpeg-release-64bit-static.tar.xz -C ./ && \
#   cp -f ./ffmpeg-3.3.4-64bit-static/ff* /usr/bin/ && \
#   chmod +x /usr/bin/ff* && \
#   rm -f ffmpeg-release-64bit-static.tar.xz && \
#   rm -rf ./ffmpeg-3.3.4-64bit-static && \
   git clone --single-branch --branch dev --depth 1 https://gitlab.com/Shinobi-Systems/Shinobi.git /opt/shinobi && \
#   git clone --single-branch --branch dev --depth 1 https://gitlab.com/lostlakkris/Shinobi.git /opt/shinobi && \
   cd /opt/shinobi && /usr/bin/npm install && \
   npm install canvas@1.6 moment --unsafe-perm

VOLUME ["/opt/shinobi/videos"]
VOLUME ["/config"]
VOLUME ["/var/lib/mysql"]

EXPOSE 8080

COPY s6.shinobi/ /

# Lakkris common
ENV SET_SERVICE="shinobi"
COPY s6.lakkris/ /
