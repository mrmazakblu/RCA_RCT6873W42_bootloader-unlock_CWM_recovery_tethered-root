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
adb wait-for-device
adb devices
echo --------------------------------------------------------------------------------------------
echo --------------------------------------------------------------------------------------------
echo [*] This is to unlock bootloader DO NOT CONTINUE if already done
pause 
echo --------------------------------------------------------------------------------------------
echo --------------------------------------------------------------------------------------------
echo [*] MAKE SURE YOUR ARE READY TO UNLOCK
pause 
adb reboot fastboot
timeout 10
echo --------------------------------------------------------------------------------------------
echo --------------------------------------------------------------------------------------------
echo [*] next we issue unlock and then you need to confirm with pushing volume button
echo [*] one last chance to cancel 
echo [*] CLOSE WINDOW IF YOU WANT TO CANCEL
pause
fastboot flashing unlock
echo --------------------------------------------------------------------------------------------
echo --------------------------------------------------------------------------------------------
echo [*] formating data and cache, after reboot you may see recovery android first
echo [*] 
fastboot format userdata
fastboot format cache
fastboot reboot
echo --------------------------------------------------------------------------------------------
echo --------------------------------------------------------------------------------------------
echo [*] MUST REMOVE USB CABLE AND LET COUNTDOWN TIMER ON SCREEN COTINUE
echo [*] IF DEVICE POWERS OFF JUST HOLD POWER BUTTON TO TURN BACK ON
echo [*] skip steps in setup then re-enable developer options and abd debugging
adb reboot fastbot
fastboot flash boot no-force-encrypt-boot.img
fastboot flash recovery no-force-encrypt-recovery.img
fastboot format userdata
fastboot format cache
fastboot reboot
pause
exit