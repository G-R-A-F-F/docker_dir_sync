# docker_dir_sync
Docker container to sync two folders.

[docker hub](https://hub.docker.com/r/sfilabs/dir_sync) | [github](https://github.com/G-R-A-F-F/docker_dir_sync)

![Docker Pulls](https://img.shields.io/docker/pulls/sfilabs/dir_sync)

## Logic \ Idea
* Initial sync is done to union both folders using these flags [rsync](https://linux.die.net/man/1/rsync) `-aruv --no-perms --no-owner --no-group`
* File with recent modified date always wins
* Two threads are started to watch folders for changes using [inotifywait](https://linux.die.net/man/1/inotifywait) `-r -e modify,attrib,close_write,move,create,delete`
* Sync runs once there is a change.
* If source folder has 0 files, syncing is skipped to prevent data loss at the destination

## Before use
* Make sure you have a backup of your data
* Test container on dummy data to make sure settings work for you and you cover all potential use cases
* There is no warranty. Author is not responsible for any damage or data loss, use at your own risk

## Run using Docker
```bash
 docker run --rm --name dir_sync \
 -v "/tmp/A":"/sync/data/A" \
 -v "/tmp/B":"/sync/data/B" \
 -e RSYNC_DELETE=false \
 sfilabs/dir_sync:latest
```

## Run using docker-compose
```yaml
version: '3'

services:
  dir_sync:
    image: sfilabs/dir_sync:latest
    volumes:
      - /tmp/A:/sync/data/A
      - /tmp/B:/sync/data/B
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Toronto
      - RSYNC_DELETE=true
      - HEALTHCHECK_STATE=false
    healthcheck:
      disable: true
```

## Configuration via environment variables

Certain values can be set via environment variables, using the `-e` parameter on the docker command line, or the `environment:` section in docker-compose.

| Variable | Default |||
| ----------- | ----------- | ----------- | ----------- |
| `RSYNC_DELETE` | true | this is used to control presence of rsync --delete flag when syncing incremental changes. | Do you want to sync delete operations files/folders? Yes - set RSYNC_DELETE to true; No - false |
| `HEALTHCHECK_STATE` | true | Set this to false if you have disabled the healthcheck. This disables caching file hashes after rsync has done its job. | Is folder you are syncing is in the cloud, large and/or has a slow connection? Yes - set environment var HEALTHCHECK_STATE=false and docker compose healthcheck: disable: true; No - go with defaults. |

### healthcheck
Container's healthcheck is implemented by generating hashes of both folders and comparing them.

### mount points
The folders to sync must be mounted to `/sync/data/A` and `/sync/data/B`

Both folders are treated as source and destination at the same time to form the exact mirror.

## Additional considerations

When using with rclone mounts, if rclone remote is slow or contains large files you might want to disable health check in docker compose and set `HEALTHCHECK_STATE=false`

Health check is hashing all files and caches that value for one hour. That might take sometime on a slow remote mount and can flag container as unhealthy.

## How to Contribute

1. Create an issue first to discuss
2. Clone repo and create a new branch: `$ git checkout https://github.com/G-R-A-F-F/docker_dir_sync -b name_for_new_branch`.
3. Make changes and test
4. Submit Pull Request with comprehensive description of changes

## Donations
If you like to support the development, or say thanks for this one consider to 
[![PayPal](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://paypal.me/sfilabs?country.x=CA&locale.x=en_US)
