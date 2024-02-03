# TundraSoft - Alpine

[![GitHub Workflow Status (with event)](https://img.shields.io/github/actions/workflow/status/TundraSoft/alpine/build-docker.yml?event=push&logo=github)](https://github.com/TundraSoft/alpine/actions/workflows/build-docker.yml?logo=github)
[![GitHub issues](https://img.shields.io/github/issues-raw/tundrasoft/alpine.svg?logo=github)](https://github.com/tundrasoft/alpine/issues)
[![GitHub PRs](https://img.shields.io/github/issues-pr-raw/tundrasoft/alpine.svg?logo=github)](https://github.com/tundrasoft/alpine/pulls) 
[![License](https://img.shields.io/github/license/tundrasoft/alpine.svg)](https://github.com/tundrasoft/alpine/blob/master/LICENSE)

[![Repo size](https://img.shields.io/github/repo-size/tundrasoft/alpine?logo=github)](#)
[![Docker image size](https://img.shields.io/docker/image-size/tundrasoft/alpine?logo=docker)](https://hub.docker.com/r/tundrasoft/alpine)

[![Docker Pulls](https://img.shields.io/docker/pulls/tundrasoft/alpine.svg?logo=docker)](https://hub.docker.com/r/tundrasoft/alpine)

This is a base docker image used throughout all docker builds. This image 
uses s6-overlay to help with initialization and management of services, crond 
for managing scheduled jobs and envsubst to handle environment variable 
substitution.

## Usage

This image, would ideally form as the base image for your containers. You can 
import this as any other docker file:

```docker
FROM tundrasoft/alpine
```

or a specific version
```docker
FROM tundrasoft/alpine:3.15
```

By default, this image provides user `tundra` and group `tundra` which runs 
on id 1000 and 1000 (UID, GID respectively).

### Volumes

Provides an optional volume /crons where you can add crontab items. 

### Writing services

This image uses S6 to handle startup scripts. You can read more about s6 [`here`]([!https://github.com/just-containers/s6-overlay#the-docker-way "S6 Github link")

#### Service Triggers

S6 provides a handy little way to manage dependeny by adding dependencies.d 
folder containing the trigger point. By default our image provides the 
below list of trigger points. We strongly recommend you use these in your 
images.

| Name | Description |
| --- | --- |
| os-ready | Container is booted and basic setup is complete (Timezone, and user/group created)) |
| config-start | Start making configuration changes to the container. Triggered post os-ready |
| config-ready | Marks the end of configuration - Cron config is the only dependant |
| service-start | Marks the start of initializing services |
| service-ready | Marks the end of service initialization |

*Notes*
- The events config-ready and service ready are just trigger points. It does 
not track if any new custom dependencies are loaded. 

Example - Assume we have created a new container with 2 new services:
1. config-nginx - This creates/manipulates nginx config. Dependency is config-start
2. nginx - This starts nginx process and is to start post config-nginx

Now for nginx to actually start, the dependency.d must include both 
service-start and config-nginx. This is because the event config-ready is not 
watching for config-nginx as a dependency! 

Besides the above mentioned triggers, below services are also present which 
can be used as trigger points, though it is highly advisable not to

| Name | Action performed |
| --- | --- |
| timezone | The timezone is set as per the env variable. This has no dependency |
| init-user | The user & Group ID is modified as per env variable. This has no dependency |
| config-cron | Any files in /crons folder is loaded into crontab. config-start triggers this execution |
| crond | Starts the cron daemon. This depends on service-start and config-cron |


### Writing Cron jobs

This image supports dynamic inclusion of CRON job where the schedule can be 
set via environment variables. To setup a cron job:

- Add a file in `/cron` folder (exposed as volume)
    - This file can contain variables which would be replaced by envsubst
- Start/Restart container

example cron file in /crons/test
```sh
$TEST_SCHEDULE echo 'This is a test' >> /tmp/test 2>&1
```

now run container, setting environment variable `TEST_SCHEDULE`
```sh
docker run -e TEST_SCHEDULE='* * * * * ' --name test-cron -d tundrasoft/alpine
```

Lets connect to the container
```sh
docker exec -it test-cron /bin/sh
#/ crontab -l
* * * * * echo 'This is a test' >> /tmp/test 2>&1
```

As you can see, the schedule is automatically replaced. You can add as many 
files as you want in the folder /crons, but avoid folders. Multiple entries 
can also be entered in same file. Due to this approach all inherited image 
can inherit the cron job and specify their own.

## Building the image

The image can be built using the below command

```sh
docker build --no-cache --build-arg ALPINE_VERSION=3.19.1 --build-arg S6_OVERLAY_VERSION=3.1.3.0 -t tundrasoft/alpine .
```

### Build Arguments

Below are the arguments available:


| Name | Description |
|---|---|
| S6_OVERLAY_VERSION | The version of S6 to use. |
| ALPINE_VERSION | The version of alpine to build on |


### Environment variables

Below are the environment variables available

| Name | Description | Default Value |
|---|---|---|
| PUID | The User ID (created) | 1000 |
| PGID | The Group ID (created) | 1000 |
| TZ | The timezone to set | UTC |


## Installed Components

### [`S6`]([!https://github.com/just-containers/s6-overlay#the-docker-way "S6 Github link")

The s6-overlay-builder project is a series of init scripts and utilities to ease creating Docker images using s6 as a process supervisor.

### Time Zone

Timezone is available pre-packaged. To set timezone, pass environment variable TZ, example TZ=Asia/Kolkata
**NOTE** This does not setup NTP or other service. The time is still fetched from the underlying host. The timezone is applied thereby
displaying the correct time.

### envsubst

Added envsubst to help in applying environment variables in config files. 
