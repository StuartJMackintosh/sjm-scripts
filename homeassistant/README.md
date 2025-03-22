
# Tapo C200 PTZ managed by bash script

Created with the support of anonymous contributors curtesy of ChatGPT

There are SDKs and scripts demanding node, python, the Tapo online app etc.

This is the simplest method I could find with least depenadancies and no requirement for the cloud account.

> Note: pan/tilt works, soom doesn't

# To install

## bash script


Edit the script file and add user/pass/URL of the *camera* account (not tapo cloud account)

TODO: read user/pass this from the config file

TODO: pass parameters from the yaml card

## dependancies

To install in docker (Alpine):
```
sudo docker compose exec homeassistant bash
apk add --no-cache bash openssl xxd
```

## Main HA config

add to config/configuration.yaml:

```
shell_command:
  ptz_left: '/config/scripts/onvif_ptz_wsse.sh --left'
  ptz_right: '/config/scripts/onvif_ptz_wsse.sh --right'
  ptz_up: '/config/scripts/onvif_ptz_wsse.sh --up'
  ptz_down: '/config/scripts/onvif_ptz_wsse.sh --down'

```

## Scripts

add to config/scripts.yaml:

```
ptz_left:
  alias: "PTZ Left"
  sequence:
    - service: shell_command.ptz_left

ptz_right:
  alias: "PTZ Right"
  sequence:
    - service: shell_command.ptz_right

ptz_up:
  alias: "PTZ Up"
  sequence:
    - service: shell_command.ptz_up

ptz_down:
  alias: "PTZ Down"
  sequence:
    - service: shell_command.ptz_down

ptz_zoom_in:
  alias: "PTZ Zoom In"
  sequence:
    - service: shell_command.ptz_zoom_in

ptz_zoom_out:
  alias: "PTZ Zoom Out"
  sequence:
    - service: shell_command.ptz_zoom_out

```

Put bash script in to data/config/scripts/onvif_ptz_wsse.sh

restart homeassistant

## Card

Create a card like this:

```
camera_view: live
type: picture-glance
camera_image: camera.c200_mainstream
entities:
  - entity: camera.c200_mainstream
    icon: mdi:arrow-left-drop-circle-outline
    tap_action:
      action: call-service
      service: shell_command.ptz_left
  - entity: camera.c200_mainstream
    icon: mdi:arrow-up-drop-circle-outline
    tap_action:
      action: call-service
      service: shell_command.ptz_up
  - entity: camera.c200_mainstream
    icon: mdi:arrow-down-drop-circle-outline
    tap_action:
      action: call-service
      service: shell_command.ptz_down
  - entity: camera.c200_mainstream
    icon: mdi:arrow-right-drop-circle-outline
    tap_action:
      action: call-service
      service: shell_command.ptz_right
```

