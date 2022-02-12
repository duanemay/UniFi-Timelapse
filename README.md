# UniFi-Timelapse

Creates a Timelapse from Unifi G3 (flex) Camera
(derived from: https://github.com/aroundmyroom/timelapsesnap, 
which was derived from: https://github.com/sfeakes/UniFi-Timelapse)

2 Snaps a minute will produce: 2880 files a day...
20 fps = 2:24 long movie a day...
25 fps = 1:55 long movie a day...

Needs:
- Unifi G3 (Flex) camera with public snap.jpeg option (to be set in the camera) (no username/password)
- FFMPEG

# License
License should be considered Public Domain as it is derived from above github source ;)

# How to use

## Update config-camera.sh

Simply add the URL to your Unifi cameras, for the snap.jpeg, to  `config-camera.sh`

```bash
CAMS["Voordeur"]="http://10.1.1.244/snap.jpeg"
```

## Add schedules

This example in crontab is to save an image every minute

```crontab
*/1 * * * * /path/to/script/captureImage.sh
```

This can be done to get 2 images per minute. 
```crontab
*/1 * * * * /path/to/script/captureImage.sh; sleep 30; /path/to/script/captureImage.sh
```

## Create the Timelapse movie

`/path/to/script/createMovies.sh`
Will create a timelapse of yesterday's files
You can pass a param `yesterday`, `today`, `all`, or a specific date e.g. `2022-02-22`

And in a crontab
```crontab
5 0 * * * /path/to/script/createMovies.sh
```

## Add Background music

If the file `audio.mp3` is detected, in the directory with the scripts, that file will be used as background music to the timelapse.

## Advanced Configuration

You can adjust other settings like framerate, location of Timelapse files, and 
date formats in the file: `config-common.sh`
