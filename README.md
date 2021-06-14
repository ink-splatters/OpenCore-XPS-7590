# OpenCore-XPS-7590

Yet another (unpolished) OpenCore setup for Dell XPS 7590

## Features

for the sake of flaunting:

* using `git lfs` for storing binary files, so `git lfs update` upon cloning
* storing `config.plist` in encrypted form (well, because it's my backup)
* there is unencrypted `config.plist` without System Information


## System info

![System Info](README/system.png)

## Graphics

### Intel UHD 630

* Display Profile: not set (presumably Sharp display); TODO

![Graphics](README/graphics.png)


## Networking

### DW1820A

#### WiFi

![Graphics](README/WiFi.png)

#### Bluetooth

![Graphics](README/bluetooth.png)

#### Caveats

Hotspot does not work (Big Sur 11.4).

##### Sometimes-working workaround:

* discover and connect to iPhone via bluetooth first
* try to connect using hotspot


## NVMe

### Samsung EVO 970 1TB

![Graphics](README/NVMe.png)



## TODO

refine
