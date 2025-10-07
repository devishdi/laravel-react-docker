FROM node:23.11.1-alpine3.22
LABEL maintainer="dev@ishdi.com"

ARG UID=82
ENV UV_THREADPOOL_SIZE=64


RUN echo "@edge-main https://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "@edge-community https://nl.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && apk add --update alpine-sdk bash curl python3

RUN yarn

EXPOSE 3000