@echo off
if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )
cd "%~dp0"
IF EXIST "%~dp0\img" SET PATH=%PATH%;"%~dp0\img"
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
Setlocal EnableDelayedExpansion
attrib +h "img" >nul
IF NOT EXIST working mkdir "%~dp0\working"
IF NOT EXIST "img\no-force-encrypt-boot.img" GOTO error1
IF NOT EXIST "img\no-force-encrypt-recovery.img" GOTO error2
IF NOT EXIST "img\rca-recovery-cwm-ramdisk.img" GOTO error3
if %errorlevel% neq 0 goto error
:start
adb shell getprop ro.build.product > working\product.txt
for /f %%i in ('FINDSTR "sofia3gr" working\product.txt') do set device=%%i
echo %device%
find "sofia3gr" "%~dp0\working\product.txt"
if errorlevel 1 (
    echo Not sofia3gr device
	echo ending in 10 seconds
	timeout 10
	goto instructions
) else (
echo sofia3gr device ok to start tool)	
timeout 5
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:main
cls
echo( 
echo 	***************************************************
echo 	*                                                 *
echo 	*      RCA Bootloader Unlock Tool                 *
echo 	*                                                 *
echo 	***************************************************
echo(
echo 		 Choose what you need to work on.
echo(
echo 		][********************************][
echo 		][ 1. UNLOCK BOOTLOADER           ][
echo 		][********************************][
echo 		][ 2. FLASH BOOT IMAGE            ][
echo 		][********************************][
echo 		][ 3. FLASH RECOVERY IMAGE        ][
echo 		][********************************][
echo 		][ 4.  LOAD INTO CWM              ][
echo 		][********************************][
echo 		][ 5.  Hosts                      ][
echo 		][********************************][
echo 		][ 6.  SEE INSTRUCTIONS           ][
echo 		][********************************][
echo 		][ 7.  Install SuperSU            ][
echo 		][********************************][
echo 		][ E.  EXIT                       ][
echo 		][********************************][
echo(
set /p env=Type your option [1,2,3,4,5,6,7,E] then press ENTER: || set env="0"
if /I %env%==1 goto bootloader
if /I %env%==2 goto boot
if /I %env%==3 goto recovery
if /I %env%==4 goto CWM
if /I %env%==5 goto hosts
if /I %env%==6 goto instructions
if /I %env%==7 goto SuperSU
if /I %env%==E goto end
echo(
echo %env% is not a valid option. Please try again! 
PING -n 3 127.0.0.1>nul
goto main
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:adb_check
adb devices -l | find "device product:" >nul
if errorlevel 1 (
    echo No adb connected devices
GOTO fastboot_check
) else (
    echo Found ADB!
	adb reboot fastboot
	timeout 10)
GOTO fastboot_check
::::::::::::::::::::::::::::::
:fastboot_check
	fastboot devices -l | find "fastboot" >nul
if errorlevel 1 (
    echo No connected devices
pause
goto main
) else (
    echo Found FASTBOOT!)
:: (emulated "Return")
GOTO %RETURN%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:bootloader
cls 
SET RETURN=Label1
GOTO adb_check
:Label1
echo --------------------------------------------------------------------------------------------
echo --------------------------------------------------------------------------------------------
echo [*] next we issue unlock and then you need to confirm with pushing volume button
echo [*] one last chance to cancel 
echo [*] CLOSE WINDOW or Ctrl c IF YOU WANT TO CANCEL
pause
echo fastboot flashing unlock
fastboot flashing unlock
echo --------------------------------------------------------------------------------------------
echo --------------------------------------------------------------------------------------------
:formatdata
echo [*] 
echo fastboot format userdata
fastboot format userdata
echo fastboot format cache
fastboot format cache
echo --------------------------------------------------------------------------------------------
echo --------------------------------------------------------------------------------------------
echo [*] MUST REMOVE USB CABLE AND LET COUNTDOWN TIMER ON SCREEN COTINUE
echo [*] IF DEVICE POWERS OFF JUST HOLD POWER BUTTON TO TURN BACK ON
echo [*] skip steps in setup then re-enable developer options and abd debugging
pause
echo fastboot reboot is next
fastboot reboot
goto main
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:boot
cls
SET RETURN=Label2
GOTO adb_check
:Label2
echo [*] DEFAULT CHOISE OF Boot Has been set to Permissive
CHOICE  /C 12 /T 10 /D 1 /M "Do You Want To Install 1=Permissive or 2=Enforcing Boot"
IF ERRORLEVEL 2 GOTO 20
IF ERRORLEVEL 1 GOTO 10

:10
echo you chose to instal Permissive Boot
pause
fastboot flash boot img/rca-boot_permissive-20170316-1706.img
GOTO formatdata
:20
echo you chose to instal Original no-force-encrypt-enforceing boot
pause
echo fastboot flash boot img/no-force-encrypt-boot.img
fastboot flash boot img/no-force-encrypt-boot.img
GOTO formatdata
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:recovery
cls
SET RETURN=Label3
GOTO adb_check
:Label3
echo fastboot flash recovery img/no-force-encrypt-recovery.img
fastboot flash recovery img/no-force-encrypt-recovery.img
echo waiting here to read any output before rebooting
pause 
fastboot reboot 
GOTO main
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CWM
cls
SET RETURN=Label4
GOTO adb_check
:Label4
echo fastboot boot img/rca-recovery-cwm-ramdisk.img
fastboot boot img/rca-recovery-cwm-ramdisk.img
IF %RETURN%==Label4 GOTO main
:: (emulated "Return")
GOTO %RETURN%
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:instructions
cls
type "Instructions.txt"
pause
GOTO start
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:hosts
cls
SET RETURN=Label5
GOTO adb_check
:Label5
SET RETURN=Label6
GOTO Label4
:Label6
timeout 20
echo adb remount
adb remount
timeout 2
echo adb push hosts--2-4-2017 /system/etc/hosts
adb push hosts--2-4-2017 /system/etc/hosts
echo [*] IF THERE WAS NO ERROR MESSAGE YOU HAVE JUST ADDED ADAWAY HOSTS
echo [*] TO YOUR UNROOTED RCA TABLET. SAY GOODBYE TO ADS
pause
goto main
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SuperSU
echo pushing superSU to the internal storage
adb push img/UPDATE-SuperSU-v2.79-SYSTEMMODE.zip /sdcard/Download/
echo rebooting into CWM recovery.
echo When fully loaded
echo select "install zip"
echo select "choose zip from /sdcard"
echo selrct "0"
echo select "Download"
echo select "UPDATE-SuperSU-v2.79-SYSTEMMODE.zip"
echo select "yes" to install zip
echo when done select go back
echo select reboot system
echo select "no" when CWM asks to fix root
echo press any key when ready to start
pause
SET RETURN=Label7
GOTO adb_check
:Label7
SET RETURN=Label9
goto Label4
:Label9
echo wait for recovery to fully load then press button to continue
echo press any key to have adb remount before starting superSU install
pause
adb remount
:: This line needs adjusting, it does not function as is yet
:: 
:: adb shell recovery --update_package=/sdcard/0/Download/UPDATE-SuperSU-v2.79-SYSTEMMODE.zip
echo now safe to start the install step listed above
echo press any button for tool to return to menu
pause
goto main
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:error
echo Image File not Found!!
echo Check that you have unzipped the 
echo whole Tool Package
pause
goto end
:error1
echo Boot.img not Found!!
echo Check that you have unzipped the 
echo whole Tool Package
pause
goto end
:error2
echo Recovery.img not Found!!
echo Check that you have unzipped the 
echo whole Tool Package
pause
goto end
:error3
echo CWM File not Found!!
echo Check that you have unzipped the 
echo whole Tool Package
pause
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:end
echo(
for /f %%a in ("%~dp0\working\*") do del /q "%%a" >nul
PING -n 1 127.0.0.1>nul
exit
