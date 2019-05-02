#  PRISME Tracking System

**[Protocol Bernardo]** (Working title) allows for continuous tracking of multiple users using multiple OpenNI2
compatible captation devices – Tested only with Kinect 2, RealSense under way.
[Protocol Bernardo] works by using a layout built inside the application, specifying how the devices 
are placed in the real world. It enables the application to track a user as it moves accross multiple devices field of view.
[Protocol Bernardo] comes with a companion application *pb-slave* allowing for remote control of
captation devices. This way, it is possible to have any number of captation devices connected to any
number of slave machines, connected to the master app using a closed network. 

[Protocol Bernardo] *master* application is built using Swift, and thus works only on MacOS. The
*slave* application can work on MacOS and Linux. A Windows port of the slave is not planned at the moment but
should work the same way.

### Notice

* Connectivity between both slaves and master uses a relay server. Connectivity is currently built using websocket
for ease of use, but should ultimately be updated to use faster UDP connections.
* [Protocol Bernardo] is a university project and is provides as-is. We'll be glade to answer any questions
or discuss any functionnality

## System setup

### Master Application

[Protocol Bernardo] *Master* application is built with Swift and works exclusively with MacOS 10.14+.  
*Coming soon* A compiled version of the app is available with the latest release.

#### Requirements for compilation
If you want to compile [Protocol Bernardo] from scratch on your mac you'll need the following elements.

*Compilation is possible without using Xcode, but let's be honest, you're not gonna use anything else to
compile a Swift app on a Mac.*

* Xcode 10.2+
  - Developpement environnement
* OpenNI2 & Freenect2
  - OpenNI is used to connect to supported devices and gather RGB and Depth data. Freenect provides support for macOS.
    OpenNI & Freenect2 drivers and libraries are included with the source code.
* NiTE2
  - Works closely with OpenNI to provide real-time Human Pose Estimation.
    Nite drivers and libraries are included with the source code.
* OpenCV 4+
  - Used to display live views of the devices, useful for calibration. Only *core*, *highgui* and *imgproc* are used.  
    We recommend using *Brew* for the installation
* Boost
    - You know what Boost is right ? Only *system* is used.  
    We recommend using *Brew* for the installation
* SocketIO C++ Client
    - Used for communication between master and slaves. Should be replaced soon.
* CocoaPods
    - We're using a few pods.
    
At the time of writing, Xcode sometimes through a "Cycle inside Protocol Bernardo ..." error. This is a problem happening after compilation. If it happens, clean the project and compile again, the error will be gone.
