@echo off

:START_BATCH_SCRIPT
bcdedit /enum {current} | find "flightsigning" | find "Yes" > nul 2>&1
echo [DEBUG] %ERRORLEVEL% is the error level (0 = "flightsigning" is enabled; 1 = "flightsigning" is disabled)

if %ERRORLEVEL% == 0 (
    echo [DEBUG] "flightsigning" is enabled ^(exists in the boot configuration data store^) on this device.
    echo [DEBUG] Setting the "flightsigning" variable to 1 ^(true^).
    set flightsigning=1
) else if %ERRORLEVEL% == 1 (
    echo [DEBUG] "flightsigning" is not enabled ^(does not exist in the boot configuration data store^) on this device.
    echo [DEBUG] Setting the "flightsigning" variable to 0 ^(false^).
    set flightsigning=0
)

goto :MAIN_MENU

:MAIN_MENU
set option=

echo.
echo 1 - Register this device to the Dev Channel
echo 2 - Register this device to the Beta Channel
echo 3 - Register this device to the Release Preview Channel
echo.
echo 4 - Remove this device from the Windows Insider Program

echo.
set /p option="Choose an option: "
echo.

if %option% == 1 (
    goto :REGISTER_DEVICE_TO_THE_DEV_CHANNEL
) else if %option% == 2 (
    goto :REGISTER_DEVICE_TO_THE_BETA_CHANNEL
) else if %option% == 3 (
    goto :REGISTER_DEVICE_TO_THE_RELEASE_PREVIEW_CHANNEL
) else if %option% == 4 (
    goto :REMOVE_DEVICE_FROM_THE_WINDOWS_INSIDER_PROGRAM
)

:REGISTER_DEVICE_TO_THE_DEV_CHANNEL
set getChannel=Dev
set getChannelName=Dev
goto :REGISTER_DEVICE_TO_THE_WINDOWS_INSIDER_PROGRAM

:REGISTER_DEVICE_TO_THE_BETA_CHANNEL
set getChannel=Beta
set getChannelName=Beta
goto :REGISTER_DEVICE_TO_THE_WINDOWS_INSIDER_PROGRAM

:REGISTER_DEVICE_TO_THE_RELEASE_PREVIEW_CHANNEL
set getChannel=ReleasePreview
set getChannelName=Release Preview
goto :REGISTER_DEVICE_TO_THE_WINDOWS_INSIDER_PROGRAM

:DEREGISTER_DEVICE_FROM_THE_WINDOWS_INSIDER_PROGRAM
reg delete HKLM\SOFTWARE\Microsoft\WindowsSelfHost /f > nul 2>&1
reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs /f > nul 2>&1
goto :EOF

:REGISTER_DEVICE_TO_THE_WINDOWS_INSIDER_PROGRAM
echo This device is being registered to the Windows Insider Program.
echo.

call :DEREGISTER_DEVICE_FROM_THE_WINDOWS_INSIDER_PROGRAM

reg add HKLM\SOFTWARE\Microsoft\WindowsSelfhost\Applicability /v BranchName /t REG_SZ /d %getChannel% /f > nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\WindowsSelfhost\Applicability /v ContentType /t REG_SZ /d Mainline /f > nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\WindowsSelfhost\Applicability /v EnablePreviewBuilds /t REG_DWORD /d 1 /f > nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\WindowsSelfhost\Applicability /v IsBuildFlightingEnabled /t REG_DWORD /d 1 /f > nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\WindowsSelfhost\Applicability /v Ring /t REG_SZ /d External /f > nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\WindowsSelfhost\Applicability /v TestFlags /t REG_DWORD /d 32 /f > nul 2>&1

reg add HKLM\SOFTWARE\Microsoft\WindowsSelfhost\UI\Strings /v StickyXaml /t REG_SZ /d "<StackPanel xmlns="^""http://schemas.microsoft.com/winfx/2006/xaml/presentation"^""><TextBlock Style="^""{StaticResource BodyTextBlockStyle}"^"">This device has been registered to the Windows Insider Program. If you want to change which channel you receive your builds from, or if you want to stop receiving builds, please use the batch script.</TextBlock><TextBlock Style="^""{StaticResource BodyTextBlockStyle}"^"" Margin="^""0,10,0,0"^"" FontSize="^""20"^"">Which channel has this device been registered to?</TextBlock><TextBlock Style="^""{StaticResource BodyTextBlockStyle}"^"" Margin="^""0,5,0,0"^"">This device has been registered to the <Run FontWeight="^""SemiBold"^"">%getChannelName% Channel</Run>.</TextBlock><TextBlock Style="^""{StaticResource BodyTextBlockStyle}"^"" Margin="^""0,10,0,0"^"" FontSize="^""20"^"">Why am I not receiving builds from my chosen channel?</TextBlock><TextBlock Style="^""{StaticResource BodyTextBlockStyle}"^"" Margin="^""0,5,0,0"^"">The Windows Insider Program requires you to send <Run FontWeight="^""SemiBold"^"">Optional</Run> diagnostic data. Please check your diagnostic data setting in <Run FontWeight="^""SemiBold"^"">Diagnostics &amp; feedback</Run>.</TextBlock><Button Margin="^""0,10,0,0"^"" Command="^""{StaticResource ActivateUriCommand}"^"" CommandParameter="^""ms-settings:privacy-feedback"^""><TextBlock Style="^""{StaticResource BodyTextBlockStyle}"^"" Margin="^""5,0,5,0"^"">Open Diagnostics &amp; feedback</TextBlock></Button></StackPanel>" /f > nul 2>&1

reg add HKLM\SOFTWARE\Microsoft\WindowsSelfhost\UI\Visibility /v UIDisabledElements /t REG_DWORD /d 65535 /f > nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\WindowsSelfhost\UI\Visibility /v UIErrorMessageVisibility /t REG_DWORD /d 65535 /f > nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\WindowsSelfhost\UI\Visibility /v UIHiddenElements /t REG_DWORD /d 65535 /f > nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\WindowsSelfhost\UI\Visibility /v UIServiceDrivenElementVisibility /t REG_DWORD /d 65535 /f > nul 2>&1

reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingExternal /v Enabled /t REG_DWORD /d 1 /f > nul 2>&1

if %flightsigning% == 0 (
    echo [DEBUG] Adding "flightsigning" to the boot configuration data store.
    bcdedit /set {current} flightsigning Yes > nul 2>&1
    echo [DEBUG] Added "flightsigning" to the boot configuration data store.
    echo.
)

echo You have registered this device to the Windows Insider Program.
echo.

if %flightsigning% == 0 goto :ASK_FOR_REBOOT
pause
goto :EOF

:REMOVE_DEVICE_FROM_THE_WINDOWS_INSIDER_PROGRAM
echo You are removing this device from the Windows Insider Program.

call :DEREGISTER_DEVICE_FROM_THE_WINDOWS_INSIDER_PROGRAM

if %flightsigning% == 1 (
    echo.
    echo [DEBUG] Removing "flightsigning" from the boot configuration data store.
    bcdedit /deletevalue {current} flightsigning > nul 2>&1
    echo [DEBUG] Removed "flightsigning" from the boot configuration data store.
    echo.
)

echo You have removed this device from the Windows Insider Program.
echo.

if %flightsigning% == 1 goto :ASK_FOR_REBOOT
pause
goto :EOF

:ASK_FOR_REBOOT
set option=

echo This device needs to be rebooted to apply changes.
echo 1 - Yes
echo 2 - No

echo.
set /p option="Do you want to reboot your device now? "
goto :EOF
