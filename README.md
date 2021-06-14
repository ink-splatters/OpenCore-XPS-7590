# OpenCore setup for Dell XPS 7590 4k

Yet another (unpolished) OpenCore setup for Dell XPS 7590

## Current OpenCore Version

`0.6.9`

## Tested on

* latest `Catalina`
* `Big Sur 11.4`

**WARNING**: **no** support will be provided for Catalina

## Devices

### System info

![System Info](README/system.png)

### Graphics

#### Intel UHD 630

![Graphics](README/graphics.png)

##### Caveats

* Display Profile: not set (presumably Sharp display); TODO
* external monitor(s)
  - `DeviceProperties -> Add` section contains just one line for UHD, making `AAPL,ig-platform-id` equal to `00009B3E` and this most likely **won't work** OOB for an external monitor
  - to have somewhat working HDMI / USB-C output you are very likely need to adjust framebuffer. I have one tested in my previous setup, pretty standard. if y want to test it, delete `DeviceProperties -> Add -> PciRoot(0x0)/Pci(0x2,0x0)` and uncomment `DeviceProperties -> Add -> #PciRoot(0x0)/Pci(0x2,0x0)` instead


### Networking

#### DW1820A

##### WiFi

![Graphics](README/WiFi.png)

##### Bluetooth

![Graphics](README/bluetooth.png)

##### Caveats

Hotspot does not work (Big Sur 11.4).

###### Sometimes-working workaround:

* discover and connect to iPhone via bluetooth first
* try to connect using hotspot


### NVMe SSD

#### Samsung EVO 970 1TB

![Graphics](README/NVMe.png)


### Thunderbolt

* Not tested, most likely will work with well-known caveats (refer to http://tonymacx86.com/, `Dortania OpenCore guides`, `r/hackintosh` / etc for more information)
* Very, very likely you would need then to regenerate `USBMap.kext`


## Sleep

```
> pmset -g 

System-wide power settings:
 DestroyFVKeyOnStandby		1
Currently in use:
 standbydelaylow      10800
 standby              0
 womp                 1
 halfdim              1
 hibernatefile        /var/vm/sleepimage
 proximitywake        1
 powernap             1
 networkoversleep     0
 disksleep            10
 standbydelayhigh     86400
 sleep                1
 hibernatemode        3
 ttyskeepawake        1
 displaysleep         60
 tcpkeepalive         1
 highstandbythreshold 50
 lidwake              1
 ```
 
 this works 90% of time (including correct waking up from hibernation)
 
**WARNING:** no wakes optimization has been done biside standard Dortania recommendations
Do it by yourself and send me a me a pull request :)

## CPUFriend

* enabled for Performance ; adjust if needed

## VoltagShift

* kext is present as a part of this set up and loaded by `OpenCore`

### Configuration
* you still need to download `Voltageshift Distribution`
* run the following

`cd <Voltageshift uncompressed folder> `
`chown -R 0:0 *`
`sudo cp ./voltageshift /usr/local/bin # if you need it`
`./voltageshift buildlaunchctl -125 -125 -125 -75 0 0 1 57 108 1 60 # those parameters may not work for you! use at your own risk!`

* optionally you may want to delete `VoltageShift.kext` from `/Library` as it's not needed becuase the kext is loaded by `OpenCore` in this setup.



## Additional Features

### git lfs

for the sake of flaunting I'm using `git lfs` for storing binary files


#### list of tracked files

`filter=("*.efi" "*.icns" ".*Contents/MacOS.*" "*.bin" "*.lbl" "*.l2x" "*.png" "*.icns")`

#### upon cloning first time

`git lfs update`

##### file operations cheat sheet

#### using lfs_control script


```
rm -f .gitattributes
./lfs_control.zsh
git add *
```

#### manually


##### if file was created
```
git lfs track <file>
git add <file>
```

##### if file to be renamed
```
git lfs untrack <old_file_name>
git mv <old_file_name> <new_file_name>
git lfs track <new_file_name>
```

##### if file to be deleted
```
git lfs untrack <file_name>
git rm -f <file_name>
```


### Encrypting config.plist containing sensitive data

Use if you forked the repo and want also to store your `config.plist` encrypted (the Feature)

**WARNING:** do **not** use this feature unless you fully understand how it's implemented inside `lfs_control.zsh` otherwise most likely you would face data loss (not limited to **config.plist**, consider all your data being at risk)

**WARNING:** the author bares zero responsibility for positive or negative impact caused by using / not using and/or misusing the Feature and **you and only you are responsible** for what you are doing and/or planning to do and/or have already done and the corresponding consequences!

in other words, read `lfs_control.zsh` and decide if it's ok enough for you to use it.



#### Encryption

##### Preparing Password

* make sure the desired encryption password is in your **clipboard** it will be passed to `openssl` using `pbpaste`!
* run `./lfs_control.zsh --enc`
* follow the instructions


##### Expected results
* `EFI/OC/config.iv` file containing `openssl aes-256-cbc` initialization vector will be created. this is not secret but **is** mandatory for decryption
* passwod fingerprint will be printed so that it's possible for the user to see if the password has been already used
* **WARNING** fingerprint is a metadata and publishing it is considered security flaw as it increases the chances of side channel attacks!
* git-untracked `EFI/OC/config.plist` file is encrypted and stored as `EFI/OC/config.enc`.
* `config.iv` and `config.enc` now may be committed; they should be automatically git lfs - tracked by the script


#### Decryption

* follow "Preparing Password" from previous chapter
* run `./lfs_control.zsh --dec`
* if decryption succeeds, decrypted data will be written to `OC/config.dec`
* you should then **manually** rename it to `config.plist` 

## TODO

a lot, actually
