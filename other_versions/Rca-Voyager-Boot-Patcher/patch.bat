@echo off
if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )
cd "%~dp0"
Setlocal EnableDelayedExpansion
for /f "delims=" %%a in ('wmic os get LocalDateTime  ^| findstr ^[0-9]') do set "dt=%%a"
set "timestamp=%dt:~0,8%-%dt:~8,4%"	
IF EXIST "working" rd /s/q "working\"
IF EXIST "%~dp0\img" SET PATH=%PATH%;"%~dp0\img"
IF EXIST "%~dp0\bin" SET PATH=%PATH%;"%~dp0\bin"
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo( 
echo   ***************************************************
cecho   * {0B}MULTI PLATFORM ANDROID BOOT AND RECOVERY PORT{#}   *{\n}
cecho   * {0E}                       TOOL{#}                      *{\n}
echo   ***************************************************
echo( 
CHOICE  /C 12 /M "Which TYPE soc is Device 1=MTK or 2=Intel"
IF ERRORLEVEL 2 GOTO Intel-soc
IF ERRORLEVEL 1 GOTO MTK-soc
:Intel-soc
	set intended-device=sofia3gr
	set soc-type=intel
	set option-3=Flash
	set option-5=superSU
	set version-string=display.id
	set fastboot-cmd=fastboot
	set unlock-cmd=flashing unlock
	set recovery-type=CWM
	set fstab1=fstab.sofiaboard_emmc
	set fstab2=fstab.sofiaboard_nand
	goto start
:MTK-soc
	set intended-device=MTK
	set soc-type=MTK
	set option-3=Boot
	set option-5=TWRP
	set version-string=flavor
	set fastboot-cmd=bootloader
	set unlock-cmd=oem unlock
	set recovery-type=TWRP
	set fstab1=fstab.mt6735
	set fstab2=
	goto start
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:start
attrib +h "img" >nul
attrib +h "bin" >nul
attrib +h "fart" >nul
attrib +h "JREPL.BAT" >nul
attrib +h "repack_img.bat" >nul
attrib +h "unpack_img.bat" >nul
IF NOT EXIST working mkdir "%~dp0\working"
IF NOT EXIST output mkdir "%~dp0\output"
IF NOT EXIST patched-imgs mkdir "%~dp0\patched-imgs"
echo(
cecho   {01}****{#}{02}***{#}{03}***{#}{04}****{#}{05}***{#}{06}***{#}{07}****{#}{08}***{#}{09}***{#}{0A}****{#}{0B}***{#}{0C}***{#}{0D}****{#}{0E}***{#}{0F}***{#}*{\n}
adb shell getprop ro.build.product 
adb shell getprop ro.build.%version-string%
cecho   {01}****{#}{02}***{#}{03}***{#}{04}****{#}{05}***{#}{06}***{#}{07}****{#}{08}***{#}{09}***{#}{0A}****{#}{0B}***{#}{0C}***{#}{0D}****{#}{0E}***{#}{0F}***{#}*{\n}
timeout 6
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:main
cls
echo( 
echo 	***************************************************
echo 	*                                                 *
cecho 	*      {0C}%intended-device% Boot Patch Tool{#}                 *{\n}
echo 	*                                                 *
echo 	***************************************************
echo(
echo 		 Choose what you need to work on.
echo(
echo 		][********************************][
cecho 		][ {0A}1.  UNLOCK BOOTLOADER{#}          ][{\n}
echo 		][********************************][
cecho 		][ {0B}2.  LOAD INTO %recovery-type% pull IMG{#}     ][{\n}
echo 		][********************************][
cecho 		][ {0C}3.  UNPACK RECOVERY{#}            ][{\n}
echo 		][********************************][
cecho 		][ {0D}4.  UNPACK BOOT{#}                ][{\n}
echo 		][********************************][
cecho 		][ {0E}5.  PATCH BOOT{#}                 ][{\n}
echo 		][********************************][
cecho 		][ {0A}6.  PATCH RECOVERY{#}             ][{\n}
echo 		][********************************][
cecho 		][ {0B}7.  PATCH %recovery-type%{#}                 ][{\n}
echo 		][********************************][
cecho 		][ {0C}8.  FLASH MENU{#}                 ][{\n}
echo 		][********************************][
cecho 		][ {0D}E.  EXIT{#}                       ][{\n}
echo 		][********************************][
echo(
set /p env=Type your option [1,2,3,4,5,6,7,8,E] then press ENTER: || set env="0"
if /I %env%==1 goto bootloader
if /I %env%==2 goto %recovery-type%
if /I %env%==3 goto unpack_stock_recovery
if /I %env%==4 goto unpack_stock_boot
if /I %env%==5 goto patch_boot
if /I %env%==6 goto patch_stock_recovery
if /I %env%==7 goto patch_%recovery-type%
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
	adb reboot %fastboot-cmd%
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
SET RETURN=Label-bootloader
GOTO adb_check
:Label-bootloader
:::::::::::::::::::::::::::::::::::
::checking the getvar output to verify if phone is unlocked aready
:::::::::::::::::::::::::::::::::::::
fastboot getvar all 2> "%~dp0\working\getvar.txt"
find "unlocked: yes" /i "%~dp0\working\getvar.txt"
if errorlevel 1 (
    echo Not Unlocked 
GOTO continue_unlock
) else (
    echo Already UNLOCKED)
echo continue to TWRP option, you are alread unlocked
pause
fastboot reboot
GOTO main
:continue_unlock
:::::::::::::::::::::::::::::::::::
::checking the get_unlock_ability output string to verify it is greater than "0" because "0" is unlockable
::::::::::::::::::::::::::::::::::::
fastboot flashing get_unlock_ability 2> "%~dp0\working\unlockability.txt"
IF %soc-type%==intel GOTO intel
IF %soc-type%==MTK GOTO MTK
:MTK
for /f "tokens=4" %%i in ('findstr "^(bootloader) unlock_ability" "%~dp0\working\unlockability.txt"') do set unlock=%%i
echo output from find string = %unlock%
if %unlock% gtr 1 ( 
	echo unlockable
	pause
	GOTO Continue
) else (
	echo Not-unlockable
	pause
	GOTO main)
:intel
	find "The device can be unlocked" /i "%~dp0\working\unlockability.txt"
if errorlevel 1 (
    echo Not Unlockable
	pause
	GOTO main
) else (
	echo unlockable
	pause
	GOTO Continue)
:Continue
echo [*] ON YOUR PHONE YOU WILL SEE 
echo [*] PRESS THE VOLUME UP/DOWN BUTTONS TO SELECT YES OR NO
echo [*] JUST PRESS VOLUME UP TO START THE UNLOCK PROCESS.
echo.-------------------------------------------------------------------------
echo.-------------------------------------------------------------------------
pause
pause
fastboot %unlock-cmd%
:format-data
timeout 5
fastboot format userdata
timeout 5
fastboot format cache
timeout 5
fastboot reboot
IF %soc-type%==intel GOTO intel-comment
IF %soc-type%==MTK GOTO MTK-comment
:MTK-comment
echo [*]         IF PHONE DID NOT REBOOT ON ITS OWN 
echo [*]         HOLD POWER BUTTON UNTILL IT TURNS OFF
echo [*]         THEN TURN IT BACK ON
echo [*]         EITHER WAY YOU SHOULD SEE ANDROID ON HIS BACK 
echo [*]         WHEN PHONE BOOTS, FOLLOWED BY STOCK RECOVERY 
echo [*]         DOING A FACTORY RESET
pause
GOTO main
:intel-comment
echo --------------------------------------------------------------------------------------------
echo --------------------------------------------------------------------------------------------
echo [*] MUST REMOVE USB CABLE AND LET COUNTDOWN TIMER ON SCREEN COTINUE
echo [*] IF DEVICE POWERS OFF JUST HOLD POWER BUTTON TO TURN BACK ON
echo [*] skip steps in setup then re-enable developer options and abd debugging
echo [*] press any button to continue
pause
GOTO main
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
echo fastboot boot CWM.img
fastboot boot CWM.img
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
:TWRP
cls
echo(
cecho   {01}****{#}{02}***{#}{03}***{#}{04}****{#}{05}***{#}{06}***{#}{07}****{#}{08}***{#}{09}***{#}{0A}****{#}{0B}***{#}{0C}***{#}{0D}****{#}{0E}***{#}{0F}***{#}*{\n}
cecho   *  {0D}this function is not programed yet{#}         *{\n}
cecho   *  {01}ON INTEL DEVICE THIS WOULD LOAD CWM EVEN WITH WRONG KERNEL{#}               *{\n}
cecho   *  {01}BUT WOULD NOT HAVE DISPLAY BENIFIT WAS IT STILL HAD WORKING ROOT ADB{#}               *{\n}
cecho   *  {01}THAT ROOT SHELL COULD BE USED TO PULL STOCK PARTITIONS {#}               *{\n}
cecho   {01}****{#}{02}***{#}{03}***{#}{04}****{#}{05}***{#}{06}***{#}{07}****{#}{08}***{#}{09}***{#}{0A}****{#}{0B}***{#}{0C}***{#}{0D}****{#}{0E}***{#}{0F}***{#}*{\n}
echo( 
timeout 15
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
cls
echo(
cecho   {01}****{#}{02}***{#}{03}***{#}{04}****{#}{05}***{#}{06}***{#}{07}****{#}{08}***{#}{09}***{#}{0A}****{#}{0B}***{#}{0C}***{#}{0D}****{#}{0E}***{#}{0F}***{#}*{\n}
cecho   *  {0D}PATCHING STOCK RECOVERY IS ONLY INTENDED TO MAKE AVAILABLE{#}         *{\n}
cecho   *  {01}ADB REBOOT FROM STOCK RECOVERY__USED TO GET INTO BOOTLOADR MODE IF NEEDED{#}               *{\n}
cecho   {01}****{#}{02}***{#}{03}***{#}{04}****{#}{05}***{#}{06}***{#}{07}****{#}{08}***{#}{09}***{#}{0A}****{#}{0B}***{#}{0C}***{#}{0D}****{#}{0E}***{#}{0F}***{#}*{\n}
pause
IF EXIST stock-recovery\recovery.img* (
	mkdir stock-recovery\ramdisk\data\misc\adb
	copy %userprofile%\.android\adbkey.pub stock-recovery\ramdisk\data\misc\adb\adb_keys
	copy %userprofile%\.android\adbkey.pub stock-recovery\ramdisk\adb_keys
	call jrepl "ro.secure=1" "ro.secure=0" /M /l /f "stock-recovery\ramdisk\default.prop" /o -
	call jrepl "ro.debuggable=0" "ro.debuggable=1" /M /l /f "stock-recovery\ramdisk\default.prop" /o -
	call jrepl "persist.sys.usb.config=mtp" "persist.sys.usb.config=mtp,adb" /M /l /f "stock-recovery\ramdisk\default.prop" /o -
	call jrepl "persist.sys.usb.config=none" "persist.sys.usb.config=mtp,adb" /M /l /f "stock-recovery\ramdisk\default.prop" /o -
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
	copy img\boot_files_%soc-type% stock-boot\ramdisk
	copy img\boot_files_%soc-type%\sbin stock-boot\ramdisk\sbin
	call jrepl "ro.secure=1" "ro.secure=0" /M /l /f "stock-boot\ramdisk\default.prop" /o -
	call jrepl "ro.debuggable=0" "ro.debuggable=1" /M /l /f "stock-boot\ramdisk\default.prop" /o -
	call jrepl "persist.sys.usb.config=mtp" "persist.sys.usb.config=mtp,adb" /M /l /f "stock-boot\ramdisk\default.prop" /o -
	call jrepl "persist.sys.usb.config=none" "persist.sys.usb.config=mtp,adb" /M /l /f "stock-boot\ramdisk\default.prop" /o -
	call jrepl "forceencrypt" "encryptable" /M /l /f "stock-boot\ramdisk\%fstab1%" /o -
	call jrepl "forceencrypt" "encryptable" /M /l /f "stock-boot\ramdisk\%fstab2%" /o -
	echo persist.service.adb.enable=1 >> stock-boot\ramdisk\default.prop 
	echo persist.service.debuggable=1 >> stock-boot\ramdisk\default.prop
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
:patch_CWM
:patch_TWRP
cls 
IF EXIST stock-recovery\recovery.img-kernel (
	IF NOT EXIST patched-%recovery-type% mkdir patched-%recovery-type%
	call unpack_img.bat %recovery-type%.img patched-%recovery-type%
	echo Scroll up to see if any errors
	pause
	copy stock-recovery\recovery.img-kernel patched-%recovery-type%\%recovery-type%.img-kernel
	copy stock-recovery\recovery.img-second patched-%recovery-type%\%recovery-type%.img-second
	IF EXIST output\*%recovery-type%* del output\*%recovery-type%*
	call repack_img.bat "patched-%recovery-type%"
	cd output
	ren *%recovery-type%*.img %recovery-type%.img
	cd ..
	copy output\%recovery-type%.img patched-imgs\%recovery-type%_%timestamp%.img
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
cecho 	*      {0E}%intended-device% Unlock Tool{#}                 *{\n}
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
cecho 		][ {0B}3.  %option-3% PATCHED RECOVERY{#}     ][{\n}
echo 		][********************************][
cecho 		][ {0D}4.  BOOT %recovery-type%{#}                   ][{\n}
echo 		][********************************][
cecho 		][ {0E}5.  FLASH %option-5%{#}                 ][{\n}
echo 		][********************************][
cecho 		][ {0C}6.  MAIN MENU{#}                  ][{\n}
echo 		][********************************][
cecho 		][ {0A}E.  EXIT{#}                       ][{\n}
echo 		][********************************][
echo(
set /p env=Type your option [1,2,3,4,5,6,E] then press ENTER: || set env="0"
if /I %env%==1 goto test-boot
if /I %env%==2 goto flash-boot
if /I %env%==3 goto %option-3%-recovery
if /I %env%==4 goto load-%recovery-type%
if /I %env%==5 goto flash-%option-5%
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
echo You have flashed modified boot.img
echo If device had encrypted /data then
echo /data needs to be formated. This means
echo ALL your downloaded files and pictures
echo Will be removed.
echo( 
CHOICE  /C 12 /T 10 /D 1 /M "Continue to format DATA? 1=Yes or 2=No"
IF ERRORLEVEL 2 GOTO 200
IF ERRORLEVEL 1 GOTO 100
:200
echo Format canceled
pause
GOTO main
:100
GOTO format-data
:Boot-recovery
IF NOT EXIST output\recovery.img (
	cecho {0E}RECOVERY.IMG NOT FOUND{#}{\n}
	cecho {0B}MAKE SURE YOU HAVE PATCHED IMAGE FIRST OPTION 6 on MAIN MENU{#}{\n}
	pause
	goto main
) else (
	cls
	SET RETURN=Labelboot
	GOTO adb_check)
:Labelboot
echo fastboot boot output\recovery.img
fastboot boot output\recovery.img
echo waiting here to read any output before rebooting
echo continue if no errors seen
pause 
goto flash-menu
:Flash-recovery
IF NOT EXIST output\recovery.img (
	cecho {0E}RECOVERY.IMG NOT FOUND{#}{\n}
	cecho {0B}MAKE SURE YOU HAVE PATCHED IMAGE FIRST OPTION 6 on MAIN MENU{#}{\n}
	pause
	goto main
) else (
	cls
	SET RETURN=Labelflash
	GOTO adb_check)
:Labelflash
echo fastboot flash recovery output\recovery.img
fastboot flash recovery output\recovery.img
echo waiting here to read any output before rebooting
echo continue if no errors seen
pause 
fastboot reboot 
goto flash-menu
:load-TWRP
:load-CWM
IF NOT EXIST output\%recovery-type%.img (
	cecho {0E}%recovery-type%.IMG NOT FOUND{#}{\n}
	cecho {0B}MAKE SURE YOU HAVE PATCHED IMAGE FIRST OPTION 7 on MAIN MENU{#}{\n}
	pause
	goto main
) else (
cls
SET RETURN=Label6
GOTO adb_check)
:Label6
echo fastboot boot output\%recovery-type%.img
fastboot boot output\%recovery-type%.img
IF %RETURN%==Label6 GOTO flash-menu
GOTO %RETURN%
:flash-TWRP
cls
SET RETURN=Label7
GOTO adb_check
:Label7
SET RETURN=Labeltwrp
fastboot flash recovery output\%recovery-type%.img
GOTO Label6
:Labeltwrp
echo Swipe to allow modification
timeout 15
adb reboot recovery
timeout 15
adb reboot
GOTO main
:flash-superSU
IF NOT EXIST output\%recovery-type%.img (
	cecho {0E}%recovery-type%.IMG NOT FOUND{#}{\n}
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
SET RETURN=Labelsupersu
GOTO adb_check
:Labelsupersu
SET RETURN=Label9
GOTO Label6
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
