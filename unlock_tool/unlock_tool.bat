@echo off
cd "%~dp0"
IF EXIST "%~dp0\bin" SET PATH=%PATH%;"%~dp0\bin"
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
Setlocal EnableDelayedExpansion
attrib +h "bin" >nul
if %errorlevel% neq 0 goto error
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:main
cls
echo( 
echo ***************************************************
echo *                                                 *
cecho *      RCA Bootloader Unlock Tool                *{\n}
cecho *                                                *{\n}
cecho *                                                *{\n}
cecho *                                                *{\n}
echo *                                                 *
echo ***************************************************
echo(
echo  Choose what you need to work on.
echo(
echo ][********************************][
cecho ][ {0B}1. UNLOCK BOOTLOADER        {#}   ][{\n}
echo ][********************************][
cecho ][ {0B}2. FLASH BOOT IMAGE         {#}   ][{\n}
echo ][********************************][
cecho ][ {0E}3. FLASH RECOVERY IMAGE        {#}][{\n}
echo ][********************************][
cecho ][ {0A}4.  LOAD INTO CWM      {#}        ][{\n}
echo ][********************************][
cecho ][ {0A}5.  Hosts                  {#}    ][{\n}
echo ][********************************][
echo ][ 6.  SEE INSTRUCTIONS           ][
echo ][********************************][
cecho ][ {0C}E.  EXIT           {#}            ][{\n}
echo ][********************************][
echo(
set /p env=Type your option [1,2,3,4,5,6,E] then press ENTER: || set env="0"
if /I %env%==1 goto bootloader
if /I %env%==2 goto boot
if /I %env%==3 goto recovery
if /I %env%==4 goto CWM
if /I %env%==5 goto hosts
if /I %env%==6 goto instructions
if /I %env%==E goto end
echo(
cecho {0C}%env% is not a valid option. Please try again! {#}{\n}
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
echo [*] formating data and cache, after reboot you may see recovery android first
echo [*] 
echo fastboot format userdata
fastboot format userdata
echo fastboot format cache
fastboot format cache
echo fastboot reboot
fastboot reboot
echo --------------------------------------------------------------------------------------------
echo --------------------------------------------------------------------------------------------
echo [*] MUST REMOVE USB CABLE AND LET COUNTDOWN TIMER ON SCREEN COTINUE
echo [*] IF DEVICE POWERS OFF JUST HOLD POWER BUTTON TO TURN BACK ON
echo [*] skip steps in setup then re-enable developer options and abd debugging
pause
goto main
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:boot
cls
SET RETURN=Label2
GOTO adb_check
:Label2
echo fastboot flash boot no-force-encrypt-boot.img
fastboot flash boot no-force-encrypt-boot.img
CHOICE  /C YN /T 20 /D Y /M "Is This First time Flashing boot.img ?"
IF ERRORLEVEL 2 GOTO 20
IF ERRORLEVEL 1 GOTO 10
:10
echo fastboot format userdata
fastboot format userdata
echo fastboot format cache
fastboot format cache
goto main
:20
goto main
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:recovery
cls
SET RETURN=Label3
GOTO adb_check
:Label3
echo fastboot flash recovery no-force-encrypt-recovery.img
fastboot flash recovery no-force-encrypt-recovery.img
GOTO main
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CWM
cls
SET RETURN=Label4
GOTO adb_check
:Label4
echo fastboot boot rca-recovery-cwm-ramdisk.img
fastboot boot rca-recovery-cwm-ramdisk.img
::IF RETURN=Label4 GOTO main
:: (emulated "Return")
GOTO %RETURN%
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:instructions
cls
type "Instructions.txt"
pause
GOTO main
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
:end
echo(
for /f %%a in ("%~dp0\working\*") do del /q "%%a" >nul
PING -n 1 127.0.0.1>nul
