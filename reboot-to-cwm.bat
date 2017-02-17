::Set our Window Title
@title REBOOT RCA TO FASTBOOT AND THEN CWM
mode 100,30
::Set our default parameters
@echo off
color 0b
echo --------------------------------------------------------------------------------------------
echo --------------------------------------------------------------------------------------------
echo [*] BEFORE WE BEGIN THE SCRIPT WILL RUN "ADB DEVICES" AND SEE IF YOU HAVE DRIVERS INSTLLED
echo [*] THE NEEDED RESPONSE IS SIMILAR TO BELOW 
echo [*]
echo [*] List of devices attached
echo [*] ****************        device
echo [*] 
echo [*] INSTEAD OF STARS IT WILL BE YOUR SERIAL NUMBER 
echo [*] IF NO DEVICE LISTED YOU ARE NOT READY TO RUN THIS SCRIPT. CLOSE THIS WINDOW NOW IF NOT READY
echo [*] 
echo [*] IF DEVICE IS LISTED PRESS ANY KEY ON COMPUTER TO START
echo [*]
echo adb wait-for-device
adb wait-for-device
echo adb devices
adb devices
echo adb reboot fastboot
adb reboot fastboot
echo timeout 10
timeout 10
echo fastboot boot rca-recovery-cwm-ramdisk.img
fastboot boot rca-recovery-cwm-ramdisk.img
echo [*] 15 SECOND TIMEOUT TO ALLOW CWM TO LOAD ADBD
timeout 15
adb wait-for-device
echo adb remount
adb remount
timeout 2
echo adb push hosts--2-4-2017 /system/etc/hosts
adb push hosts--2-4-2017 /system/etc/hosts
echo [*] IF THERE WAS NO ERROR MESSAGE YOU HAVE JUST ADDED ADAWAY HOSTS
echo [*] TO YOUR UNROOTED RCA TABLET. SAY GOODBYE TO ADS
pause
exit
