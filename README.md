# TundraSoft - AlpineBase

![Build Status](https://github.com/TundraSoft/alpine/actions/workflows/ci.yml/badge.svg)
![Docker Pull](https://img.shields.io/github/repo-size/tundrasoft/alpine?color=brightgreen)
![Docker Pull](https://img.shields.io/docker/pulls/tundrasoft/alpine.svg)
![Docker Size](https://img.shields.io/docker/image-size/tundrasoft/alpine/latest?label=docker%20image%20size)

This is a base docker image used throughout all docker builds. This image uses s6-overlay to help with 
initialization and management of services.

## Installed Components

### [`S6`]([!https://github.com/just-containers/s6-overlay#the-docker-way "S6 Github link") - 3.0.0.1

The s6-overlay-builder project is a series of init scripts and utilities to ease creating Docker images using s6 as a process supervisor.

### Time Zone

Timezone is available pre-packaged. To set timezone, pass environment variable TZ, example TZ=Asia/Kolkata
**NOTE** This does not setup NTP or other service. The time is still fetched from the underlying host. The timezone is applied thereby
displaying the correct time.

### envsubst

Added envsubst to help in applying environment variables in config files. 

### User & Group

Default user and group created with UID as 1000 and GID as 1000. Username and Group Name is tundrasoft tundrasoft (yes not really creative at this point)

## ENVIRONMENT LABELS

### TZ

Timezone which needs to be set for the container. It obtains time from the host machine.

### S6 ENV VARS

See s6 documentation for other s6 environment arguments


## Usage

### Building

```docker
docker build --no-cache --build-arg ALPINE_VERSION=3.15.1 --build-arg S6_OVERLAY_VERSION=3.0.0.0-1 -t tundrasoft/alpine .
```

### Running

```docker 
docker run --name alpine tundrasoft/alpine
```
