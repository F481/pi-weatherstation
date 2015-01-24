pi-weatherstation
=================

How to set up the pi-weatherstation?
---------------------------------------

1. Connect the sensors to your raspberry (you can find the wire layout in the doc/ folder):  
https://github.com/F481/pi-weatherstation/blob/master/doc/wiring_bb.png
2. Get the project: `git clone https://github.com/F481/pi-weatherstation.git --recursive`
3. Configure your weatherstation in the `pi-weatherstation.cfg` config file 
4. Setup the pi-weatherstation: `cd pi-weatherstation/ && sudo bash setup.sh`
5. Check if all is working fine: `cd pi-weatherstation/ && sudo bash check.sh`
