FROM debian:stable as builder

ARG INSTALL_PREFIX=/opt/wine

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update &&\
    apt-get install -y devscripts build-essential wget curl

ENV CFLAGS="-O2 -pipe"

RUN apt-get install -y --no-install-recommends\
        autotools-dev\
        autoconf\
        bison\
        bsdmainutils\
        flex\
        fontforge\
        gawk\
        gcc\
        gcc-mingw-w64-i686\
        gcc-mingw-w64-x86-64\
        gettext\
        libacl1-dev\
        libasound2-dev\
        libfontconfig-dev\
        libfreetype6-dev\
        libgl1-mesa-dev\
        libglu1-mesa-dev\
        libgnutls28-dev\
        libgtk-3-dev\
        libice-dev\
        libkrb5-dev\
        libncurses-dev\
        libopenal-dev\
        libosmesa6-dev\
        libpcap-dev\
        libpulse-dev\
        libsane-dev\
        libsdl2-dev\
        libssl-dev\
        libstdc++-11-dev\
        libudev-dev\
        libvulkan-dev\
        libx11-dev\
        libxcomposite-dev\
        libxcursor-dev\
        libxext-dev\
        libxi-dev\
        libxinerama-dev\
        libxrandr-dev\
        libxrender-dev\
        libxt-dev\
        libxxf86vm-dev\
        linux-libc-dev\
        ocl-icd-opencl-dev\
        patch\
        perl\
        sharutils\
        unixodbc-dev\
        x11proto-xinerama-dev\
    && apt clean -y

WORKDIR /usr/src/wine

ARG WINE_GIT=wine-mirror/wine
ARG WINE_VERSION
ARG WINE_TAG=wine-$WINE_VERSION
RUN curl -L https://github.com/$WINE_GIT/archive/$WINE_TAG.tar.gz \
    | tar xz --strip-components 1

COPY *.patch /usr/src/wine/
RUN for p in *.patch; do patch -p1 < $p; done

WORKDIR /usr/src/wine/build
RUN ../configure \
        --without-tests \
        --prefix=$INSTALL_PREFIX \
        --libdir=$INSTALL_PREFIX/lib \
        --enable-archs=x86_64,i386
RUN make -j4
RUN make install
RUN i686-w64-mingw32-strip --strip-unneeded "$INSTALL_PREFIX"/lib/wine/i386-windows/*.dll
RUN x86_64-w64-mingw32-strip --strip-unneeded "$INSTALL_PREFIX"/lib/wine/x86_64-windows/*.dll

FROM debian:stable-slim
ENV DEBIAN_FRONTEND noninteractive

COPY --from=builder /opt/wine/ /opt/wine/

ARG WINETRICKS_VERSION=master
ADD https://raw.githubusercontent.com/Winetricks/winetricks/$WINETRICKS_VERSION/src/winetricks /usr/local/bin/winetricks
RUN chmod 755 /usr/local/bin/winetricks

ENV PATH=/opt/wine/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

RUN apt-get update && \
    apt install -y --no-install-recommends \
        ca-certificates\
        cabextract\
        curl\
        libasound2-plugins\
        libcap2-bin\
        libfontconfig1\
        libfreetype6\
        libglu1-mesa\
        libgnutls30\
        libgssapi-krb5-2\
        libkrb5-3\
        libncurses6\
        libodbc1\
        libosmesa6\
        libsdl2-2.0-0\
        libv4l-0\
        libxcomposite1\
        libxcursor1\
        libxfixes3\
        libxi6\
        libxinerama1\
        libxrandr2\
        libxrandr2\
        libxrender1\
        libxxf86vm1\
        winbind\
    && apt clean -y && \
    rm -rf /var/lib/apt/lists/*
