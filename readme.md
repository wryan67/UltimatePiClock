Ultimate Pi Clock
-----------------

This is the ultimate clock for your Raspberry Pi.  Features include:

- Multiple time and date formats are supported.   
- Multiple displays are supported via the [universal display driver](https://github.com/wryan67/udd_rpi_lib/blob/master/README.md).  
- The current humidity and temperature are supported via a [BME280](https://smile.amazon.com/gp/product/B07KYJNFMD) chip.  
- The background changes every 30 seconds.  
- Multiple image formats are supported via [ImageMagic](https://imagemagick.org/)
- Scrolling marquee MOTD (message of the day)
- The [ST7789](https://smile.amazon.com/gp/product/B081Q79X2F) seems to be a rugged and easy to use display, and it's what I'm using for the Demos.

## TODO:
- Add alarms
- Add support for true type fonts
- instructions for sharing your image folder to make copying your photos to the RPi easy.  For now, just SFTP them using WinSCP.

## Prerequisites

Please follow the instructions for these projects to install the respective libraries:

> * https://github.com/wryan67/bme280_rpi_lib
> * https://github.com/wryan67/udd_rpi_lib/  && the [[Wiki page]](https://github.com/wryan67/udd_rpi_lib/wiki)
> * [WiringPi](http://wiringpi.com/), which should be installed already, but you may have to follow the [update instructions](http://wiringpi.com/wiringpi-updated-to-2-52-for-the-raspberry-pi-4b/) for a RPi4

## Downloading

Use git to download the software from github.com:

    $ cd ~/projects { or wherever you keep downloads }
    $ git clone https://github.com/wryan67/UltimatePiClock.git

## Compiling

Using make

    $ make clean && make

Using Visual Studio

    1. Open the piClock.sln using Visual Studio 
    2. Setup your Remote Build Machine
    3. Update the remote headers for your RPi (tools/Cross Platorm/Connection Manager/Remote Headers IntelliSense)
    3. Build Solution.

## Setup

Create this folder and put image files in the folder.  There's some demo images in the ~/projects/UltimatePiClock/imgages folder to get you started.

    $ mkdir -p /home/pi/Pictures/clock
    $ cp /home/pi/projects/UltimatePiClock/images/BlueAngles* /home/pi/Pictures/clock/

## Running

Example when compiled using make:

    $ ./piClock -r 90 -p /home/wryan/Pictures/clock -i 66000000 -d -f2 -m 'Hello World!!!!!'
    Program initialization
    displayId:         0
    width:             240
    height:            320
    xOffset:           0
    yOffset:           0
    mirror:            0
    rotation:          0
    cs:                21
    dc:                22
    rst:               23
    blk:               7
    busy pin:          -1
    spiChannel:        0
    spiSpeed:          66000000
    handle:            5
    bme280_address=76
    updating clock... speed=100ms
    imagemagick conversion cmd: convert /home/wryan/Pictures/clock/BlueAngles4.png -resize 320x240 -background black -gravity center -extent 320x240 -type truecolor bmp:-



Example when compiled using Visual Studio:

    $ /home/pi/projects/piClock/bin/ARM/Debug/piClock.out -p /home/pi/Pictures/clock -i 66000000 -d -f2 -m 'Hello World!!!!!!'
    Program initialization
    displayId:         0
    width:             240
    height:            320
    xOffset:           0
    yOffset:           0
    cs:                21
    dc:                22
    rst:               23
    blk:               7
    busy pin:          -1
    spiChannel:        0
    spiSpeed:          66000000
    handle:            5
    bme280_address=76
    updating clock... speed=100ms
    imagemagick conversion cmd: convert /home/pi/Pictures/clock/BlueAngles5.png -resize 320x240 -background black -gravity center -extent 320x240 -type truecolor bmp:-


## Demos

Follow the youtube link to see the scrolling marquee in action.

- https://youtu.be/iBVsrxbjaWs

![pi clock preview 1](https://github.com/wryan67/UltimatePiClock/blob/master/readme/image3.jpeg?raw=true)
![pi clock preview 2](https://github.com/wryan67/UltimatePiClock/blob/master/readme/image4.jpeg?raw=true)


## Circuit Diagram

![circuit diagram](https://github.com/wryan67/UltimatePiClock/blob/master/readme/circuit%20diagram.png?raw=true)


## Tip
I soldered an RJ45 jack directly onto the back of the display, to make connecting it and moving it around a bit easier.
![pi clock](https://github.com/wryan67/UltimatePiClock/blob/master/readme/example1.jpg?raw=true)

