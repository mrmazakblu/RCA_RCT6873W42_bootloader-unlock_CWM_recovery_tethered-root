@echo off
if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )
cd "%~dp0"
set tool-folder=%~dp0
for /f "delims=" %%a in ('wmic os get LocalDateTime  ^| findstr ^[0-9]') do set "dt=%%a"
set "timestamp=%dt:~0,8%-%dt:~8,4%"	
for /f %%a in ("%~dp0\working\*") do del /q "%%a" >nul
IF EXIST "%~dp0\img" SET PATH=%PATH%;"%~dp0\img"
IF EXIST "%~dp0\bin" SET PATH=%PATH%;"%~dp0\bin"
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
Setlocal EnableDelayedExpansion
attrib +h "img" >nul
attrib +h "bin" >nul
attrib +h "fart" >nul
attrib +h "JREPL.BAT" >nul
attrib +h "repack_img.bat" >nul
attrib +h "unpack_img.bat" >nul
IF NOT EXIST working mkdir "%~dp0\working"
IF NOT EXIST output mkdir "%~dp0\output"
IF NOT EXIST patched-imgs mkdir "%~dp0\patched-imgs"
adb shell getprop ro.build.product > working\product.txt
adb shell getprop ro.build.display.id >> working\product.txt
for /f %%i in ('FINDSTR "sofia3gr" working\product.txt') do set device=%%i
for /f %%i in ('FINDSTR "RCT6873W42" working\product.txt') do set build=%%i
echo(
cecho   {01}****{#}{02}***{#}{03}***{#}{04}****{#}{05}***{#}{06}***{#}{07}****{#}{08}***{#}{09}***{#}{0A}****{#}{0B}***{#}{0C}***{#}{0D}****{#}{0E}***{#}{0F}***{#}*{\n}
cecho   * Your Build Product says it is a {0D}%device%{#}         *{\n}
cecho   * Your Build Device Type is {01}%build%{#}               *{\n}
cecho   {01}****{#}{02}***{#}{03}***{#}{04}****{#}{05}***{#}{06}***{#}{07}****{#}{08}***{#}{09}***{#}{0A}****{#}{0B}***{#}{0C}***{#}{0D}****{#}{0E}***{#}{0F}***{#}*{\n}
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
find "sofia3gr" "%~dp0\working\product.txt" >nul
if errorlevel 1 (
    echo   ***************************************************
	cecho   *   {0A}Not sofia3gr device{#}                           *{\n}
	cecho   *   {0C}Closing in 10 seconds{#}                         *{\n}
	echo   ***************************************************
	timeout 10
) else (
	echo %device% device)	
echo( 
echo   ***************************************************
cecho   * {0B}DEFAULT CHOICE HAS BEEN SET TO "RCT6873W42"{#}     *{\n}
cecho   * {0E}DEFAULT Timeout will continue in 15 seconds"{#}    *{\n}
echo   ***************************************************
echo( 
CHOICE  /C 12 /T 15 /D 1 /M "Is this Device RCA Voyager RCT6873W42 1=Yes or 2=No"
IF ERRORLEVEL 2 GOTO 20
IF ERRORLEVEL 1 GOTO 10

:10
find "RCT6873W42" "%~dp0\working\product.txt" >nul
if errorlevel 1 (
    echo   ***************************************************
	cecho   *   {02}Not RCT6873W42 device{#}                          *{\n}
	cecho   *   {05}Closing in 10 seconds{#}                         *{\n}
	echo   ***************************************************
	timeout 10
	goto end
) else (
echo RCT6873W42 build)	
timeout 5
:20
GOTO main
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:main
cls
echo( 
echo 	***************************************************
echo 	*                                                 *
cecho 	*      {0C}RCA Bootloader Unlock Tool{#}                 *{\n}
echo 	*                                                 *
echo 	***************************************************
echo(
echo 		 Choose what you need to work on.
echo(
echo 		][********************************][
cecho 		][ {0A}1.  UNLOCK BOOTLOADER{#}          ][{\n}
echo 		][********************************][
cecho 		][ {0B}2.  LOAD INTO CWM pull IMG{#}     ][{\n}
echo 		][********************************][
cecho 		][ {0C}3.  UNPACK RECOVERY{#}            ][{\n}
echo 		][********************************][
cecho 		][ {0D}4.  UNPACK BOOT{#}                ][{\n}
echo 		][********************************][
cecho 		][ {0E}5.  PATCH BOOT{#}                 ][{\n}
echo 		][********************************][
cecho 		][ {0A}6.  PATCH RECOVERY{#}             ][{\n}
echo 		][********************************][
cecho 		][ {0B}7.  PATCH CWM{#}                  ][{\n}
echo 		][********************************][
cecho 		][ {0C}8.  Flash MENU{#}                 ][{\n}
echo 		][********************************][
cecho 		][ {0D}E.  EXIT{#}                       ][{\n}
echo 		][********************************][
echo(
set /p env=Type your option [1,2,3,4,5,6,7,8,E] then press ENTER: || set env="0"
if /I %env%==1 goto bootloader
if /I %env%==2 goto CWM
if /I %env%==3 goto unpack_stock_recovery
if /I %env%==4 goto unpack_stock_boot
if /I %env%==5 goto patch_boot
if /I %env%==6 goto patch_stock_recovery
if /I %env%==7 goto patch_cwm
if /I %env%==8 goto flash-menu
if /I %env%==E goto end
echo(
echo %env% is not a valid option. Please try again! 
PING -n 3 127.0.0.1>nul
goto main
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:adb_check
adb devices -l | find "product:" >nul
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
echo fastboot flashing unlock
echo you need to hold volume up on tablet then press any key to continue
pause
fastboot flashing unlock
timeout 15
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
echo [*] press any button to continue
pause
echo fastboot reboot is next
fastboot reboot
goto main
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo --------------------------------------------------------------------------------------------
echo --------------------------------------------------------------------------------------------
goto main
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CWM
IF EXIST boot.img (
	cecho {0E}You HAVE ALREADY PULLED BOOT AND RECOVERY IMAGES{#}{\n}
	cecho {0A}IF YOU WANT TO PULL AGAIN , DELETE OLD IMG FROM FOLDER{#}{\n}
	cecho {0B}IF YOU JUST WANT TO BOOT INTO CWM USE OPTION ON MENU #8{#}{\n}
	pause
	goto main
) else (
cls
SET RETURN=Label4
GOTO adb_check)
:Label4
echo fastboot boot img\v19-cwm.img
fastboot boot img\v19-cwm.img
cecho {0A}YOU NEED EXTERNAL SD INSERTED INTO TABLET FOR NEXT STEP TO WORK{#}{\n}
cecho {0E}YOU NEED EXTERNAL SD INSERTED INTO TABLET FOR NEXT STEP TO WORK{#}{\n}
cecho {0E}IT IS EXPECTED THAT THE DEVICE SCREEN MAY NOT BE ON DURING THIS STEP{#}{\n}
timeout 20
adb shell mount external_sd
adb shell mkdir /external_sd/RCA
adb shell dd if=/dev/block/platform/soc0/e0000000.noc/by-name/ImcPartID071 of=/external_sd/RCA/mmcblk0p9-boot.img
adb shell dd if=/dev/block/platform/soc0/e0000000.noc/by-name/ImcPartID121 of=/external_sd/RCA/mmcblk0p10-recovery.img
adb pull /external_sd/RCA/mmcblk0p9-boot.img boot.img
adb pull /external_sd/RCA/mmcblk0p10-recovery.img recovery.img
timeout 10
cecho {0C}TABLET IS REBOOTING PLEASE GIVE IT SOME TIME{#}{\n}
adb reboot
pause
goto main
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:unpack_stock_recovery
IF EXIST recovery.img (
	mkdir stock-recovery
	call unpack_img.bat recovery.img stock-recovery
	echo Scroll up to see if any errors
	pause
	goto main
) else (
	cecho {0D}DID NOT FIND recovery.img{#}{\n}
	cecho {0A}MAKE SURE YOU DO STEP 2 TO PULL IMAGES{#}{\n}
	pause
	goto main)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:patch_stock_recovery
IF EXIST stock-recovery\recovery.img* (
	mkdir stock-recovery\ramdisk\data\misc\adb
	copy %userprofile%\.android\adbkey.pub stock-recovery\ramdisk\data\misc\adb\adb_keys
	copy %userprofile%\.android\adbkey.pub stock-recovery\ramdisk\adb_keys
	fart\fart.exe stock-recovery\ramdisk\default.prop ro.secure=1 ro.secure=0
	fart\fart.exe stock-recovery\ramdisk\default.prop ro.debuggable=0 ro.debuggable=1
	fart\fart.exe stock-recovery\ramdisk\default.prop persist.sys.usb.config=none persist.sys.usb.config=mtp,adb
	echo( >> stock-recovery\ramdisk\default.prop
	echo persist.service.adb.enable=1 >> stock-recovery\ramdisk\default.prop                                                   
	echo persist.service.debuggable=1 >> stock-recovery\ramdisk\default.prop
	IF EXIST output\*recovery* del output\*recovery*
	call repack_img.bat "stock-recovery"
	cd output
	ren *recovery*.img recovery.img
	cd ..
	copy output\recovery.img patched-imgs\recovery_%timestamp%.img
	cecho {0E}Scroll up to see if any errors{#}{\n}
	pause
	goto main
) else (
	cecho {0D}DID NOT FIND files in stock-recovery{#}{\n}
	cecho {0A}MAKE SURE YOU DO STEP 3 TO UNPACK RECOVERY{#}{\n}
	pause
	goto main)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:unpack_stock_boot
mkdir stock-boot
call unpack_img.bat boot.img stock-boot
echo Scroll up to see if any errors
pause
goto main
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:patch_boot
IF EXIST stock-boot\boot.img* (
	mkdir stock-boot\ramdisk\data\misc\adb
	copy %userprofile%\.android\adbkey.pub stock-boot\ramdisk\data\misc\adb\adb_keys
	copy %userprofile%\.android\adbkey.pub stock-boot\ramdisk\adb_keys
	copy img\boot_files stock-boot\ramdisk
	copy img\boot_files\sbin stock-boot\ramdisk\sbin
	fart\fart.exe stock-boot\ramdisk\default.prop ro.secure=1 ro.secure=0
	fart\fart.exe stock-boot\ramdisk\default.prop ro.debuggable=0 ro.debuggable=1
	fart\fart.exe stock-boot\ramdisk\default.prop persist.sys.usb.config=none persist.sys.usb.config=adb
	fart\fart.exe stock-boot\ramdisk\fstab.sofiaboard_emmc forceencrypt encryptable
	fart\fart.exe stock-boot\ramdisk\fstab.sofiaboard_nand forceencrypt encryptable
	call jrepl "on init" "on init~	# root use Permissive~	write /sys/fs/selinux/enforce 0~" /M /l /f "stock-boot\ramdisk\init.rc" /o -
	call jrepl "~" "\n" /M /X /f "stock-boot\ramdisk\init.rc" /o -
	IF EXIST output\*boot* del output\*boot*
	call repack_img.bat "stock-boot"
	cd output
	ren *boot*.img boot.img
	cd ..
	copy output\boot.img "patched-imgs\boot_%timestamp%.img"
	cecho {0E}Scroll up to see if any errors{#}{\n}
	pause
	goto main
) else (
	cecho {0D}DID NOT FIND files in stock-boot{#}{\n}
	cecho {0A}MAKE SURE YOU DO STEP 4 TO UNPACK BOOT{#}{\n}
	pause
	goto main
	)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:patch_cwm
IF EXIST stock-recovery\recovery.img-kernel (
	IF NOT EXIST patched-cwm mkdir patched-cwm
	xcopy /y img\base-cwm patched-cwm /s /e /h
	copy stock-recovery\recovery.img-kernel patched-cwm
	copy stock-recovery\recovery.img-second patched-cwm
	IF EXIST output\*cwm* del output\*cwm*
	call repack_img.bat "patched-cwm"
	cd output
	ren *cwm*.img cwm.img
	cd ..
	copy output\cwm.img patched-imgs\cwm_%timestamp%.img
	cecho {0C}Scroll up to see if any errors{#}{\n}
	pause
	goto main
) else (
	cecho {0D}DID NOT FIND files in stock-recovery{#}{\n}
	cecho {0A}MAKE SURE YOU DO STEP 3 TO UNPACK RECOVERY{#}{\n}
	pause
	goto main
	)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:flash-menu
cls
echo( 
echo 	***************************************************
echo 	*                                                 *
cecho 	*      {0E}RCA Bootloader Unlock Tool{#}                 *{\n}
echo 	*                                                 *
echo 	***************************************************
echo(
echo 		 Choose what you need to work on.
echo(
echo 		][********************************][
cecho 		][ {0E}1.  TEST BOOT PATCHED-BOOT{#}     ][{\n}
echo 		][********************************][
cecho 		][ {0A}2.  FLASH PATCHED-BOOT{#}         ][{\n}
echo 		][********************************][
cecho 		][ {0B}3.  FLASH PATCHED RECOVERY{#}     ][{\n}
echo 		][********************************][
cecho 		][ {0D}4.  BOOT CWM{#}                   ][{\n}
echo 		][********************************][
cecho 		][ {0E}5.  FLASH SuperSU{#}              ][{\n}
echo 		][********************************][
cecho 		][ {0C}6.  MAIN MENU{#}                  ][{\n}
echo 		][********************************][
cecho 		][ {0A}E.  EXIT{#}                       ][{\n}
echo 		][********************************][
echo(
set /p env=Type your option [1,2,3,4,5,6,E] then press ENTER: || set env="0"
if /I %env%==1 goto test-boot
if /I %env%==2 goto flash-boot
if /I %env%==3 goto flash-recovery
if /I %env%==4 goto load-cwm
if /I %env%==5 goto flash-superSU
if /I %env%==6 goto main
if /I %env%==E goto end
echo(
echo %env% is not a valid option. Please try again! 
PING -n 3 127.0.0.1>nul
goto main
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:test-boot
IF NOT EXIST output\boot.img (
	cecho {0E}BOOT.IMG NOT FOUND{#}{\n}
	cecho {0B}MAKE SURE YOU HAVE PATCHED IMAGE FIRST OPTION 5 on MAIN MENU{#}{\n}
	pause
	goto main
) else (
	cls
	SET RETURN=Label5
	GOTO adb_check)
:Label5
echo fastboot boot output\boot.img
fastboot boot output\boot.img
echo(
cecho {0C}IF TABLET BOOTS WITH THIS IMAGE IT IS ASSUMED THAT IT WILL BE SAFE TO FLASH IT{#}{\n}
cecho {0D}Attemping to reboot next{#}{\n}
cecho {0E}IF THE DEVICE DID NOT BOOT OR DID NOT WORK CORRECTLY AFTER WAITING AT LEAST 10 MINUTES{#}{\n}
cecho {0A}YOU MAY NEED TO FORCE POWER CYCYLE BY HOLDING POWER BUTTON 30 seconds PLUS{#}{\n}
cecho {0D}PRESS any button to Try adb reboot{#}{\n}
pause
adb reboot
goto flash-menu
:flash-boot
IF NOT EXIST output\boot.img (
	cecho {0E}BOOT.IMG NOT FOUND{#}{\n}
	cecho {0B}MAKE SURE YOU HAVE PATCHED IMAGE FIRST OPTION 5 on MAIN MENU{#}{\n}
	cecho {0B}MAKE SURE YOU HAVE RUN OPTION 1 -TEST BOOT from flash-MENU{#}{\n}
	pause
	goto main
) else (
	cls
	SET RETURN=Label2
	GOTO adb_check)
:Label2
cecho {0C}you chose to instal modified boot{#}{\n}
cecho {0D}CLOSE WINDOW NOW IF YOU DO NOT WANT TO FLASH{#}{\n} 
pause
pause
echo fastboot flash boot output\boot.img
fastboot flash boot output\boot.img
GOTO formatdata
:flash-recovery
IF NOT EXIST output\recovery.img (
	cecho {0E}RECOVERY.IMG NOT FOUND{#}{\n}
	cecho {0B}MAKE SURE YOU HAVE PATCHED IMAGE FIRST OPTION 6 on MAIN MENU{#}{\n}
	pause
	goto main
) else (
	cls
	SET RETURN=Label3
	GOTO adb_check)
:Label3
echo fastboot flash recovery output\recovery.img
fastboot flash recovery output\recovery.img
echo waiting here to read any output before rebooting
echo continue if no errors seen
pause 
fastboot reboot 
goto flash-menu
:load-cwm
IF NOT EXIST output\cwm.img (
	cecho {0E}CWM.IMG NOT FOUND{#}{\n}
	cecho {0B}MAKE SURE YOU HAVE PATCHED IMAGE FIRST OPTION 7 on MAIN MENU{#}{\n}
	pause
	goto main
) else (
cls
SET RETURN=Label6
GOTO adb_check)
:Label6
echo fastboot boot output\cwm.img
fastboot boot output\cwm.img
IF %RETURN%==Label6 GOTO flash-menu
:: (emulated "Return")
GOTO %RETURN%
:flash-superSU
IF NOT EXIST output\cwm.img (
	cecho {0E}CWM.IMG NOT FOUND{#}{\n}
	cecho {0B}MAKE SURE YOU HAVE PATCHED IMAGE FIRST OPTION 7 on MAIN MENU{#}{\n}
	pause
	goto main
) else (
	echo pushing superSU to the internal storage
	adb push img\UPDATE-SuperSU-v2.79-SYSTEMMODE.zip /sdcard/Download/
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
	pause)
SET RETURN=Label7
GOTO adb_check
:Label7
SET RETURN=Label9
goto Label6
:Label9
echo wait for recovery to fully load then press button to continue
echo press any key to have adb remount before starting superSU install
pause
adb remount
echo now safe to start the install steps listed above
echo press any button for tool to return to menu
pause
goto flash-menu
:error
echo Image File not Found!!
echo Check that you have unzipped the 
echo whole Tool Package
pause
goto end
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:error1
echo Boot.img not Found!!
echo Check that you have unzipped the 
echo whole Tool Package
pause
goto end
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:error2
echo Recovery.img not Found!!
echo Check that you have unzipped the 
echo whole Tool Package
pause
goto end
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
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
