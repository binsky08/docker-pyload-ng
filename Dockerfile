FROM ghcr.io/linuxserver/baseimage-alpine:3.15

# set version label
ARG BUILD_DATE
ARG VERSION
ARG PYLOAD_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

ENV HOME="/config"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    cargo \
    curl-dev \
    libffi-dev \
    libjpeg-turbo-dev \
    openssl-dev \
    python3-dev \
    zlib-dev && \
  echo "**** install packages ****" && \
  apk add --no-cache \
    curl \
    libjpeg-turbo \
    py3-pip \
    python3 \
    sqlite \
    tesseract-ocr && \
  echo "**** install unrar ****" && \
  mkdir /tmp/unrar && \
  curl -o /tmp/unrar.tar.gz \
    -L "https://www.rarlab.com/rar/unrarsrc-6.1.4.tar.gz" && \
  tar xf /tmp/unrar.tar.gz -C \
    /tmp/unrar --strip-components=1 && \
  cd /tmp/unrar && \
  make && \
  make install && \
  mkdir -p /usr/share/licenses/unrar && \
  mv license.txt /usr/share/licenses/unrar/ && \
  echo "**** install pyload ****" && \
  if [ -z ${PYLOAD_VERSION+x} ]; then \
    PYLOAD="pyload-ng[all]"; \
  else \
    PYLOAD="pyload-ng[all]==${PYLOAD_VERSION}"; \
  fi && \
  pip3 install -U pip setuptools wheel && \
  pip install -U --find-links https://wheel-index.linuxserver.io/alpine-3.15/ \
    "${PYLOAD}" && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    ${HOME}/.cache \
    ${HOME}/.cargo

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8000
VOLUME /config
