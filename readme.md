LCD Clock
---------

This is the ultimate clock for your Raspberry Pi.  Features include:

- Multiple time and date formats are supported.   
- Multiple displays are supported via the [universal display driver](https://github.com/wryan67/udd_rpi_lib/blob/master/README.md).  
- The current humidity and temperature are supported via a [BME280](https://smile.amazon.com/gp/product/B07KYJNFMD) chip.  
- The background changes every 30 seconds.  
- Multiple image formats are supported via [ImageMagic](https://imagemagick.org/)
- Scrolling marquee MOTD (message of the day)

## TODO:
- Add alarms
- instructions for sharing your image folder to make copying your photos to the RPi easy.  For now, just SFTP them using WinSCP.

## Prerequisites

Please follow the instructions for these projects to install the respective libraries:

- https://github.com/wryan67/bme280_rpi_lib
- https://github.com/wryan67/udd_rpi_lib/blob/master/README.md  && the [[Wiki page]](https://github.com/wryan67/udd_rpi_lib/wiki)
- [WiringPi](http://wiringpi.com/)

## Downloading

Use git to download the software from github.com:

    $ cd ~/projects { or wherever you keep downloads }
    $ git clone https://github.com/wryan67/UltimatePiClock.git

## Compiling

    $ cd to 

## Setup

Create this folder and put image files in the folder.  There's some demo images in the ~/projects/UltimatePiClock/imgages folder to get you started.

    $ mkdir -p $HOME/Pictures/clock

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

