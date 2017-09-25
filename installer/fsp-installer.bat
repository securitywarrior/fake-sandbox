@echo off
:start
::   *------------------------------------------------------------------------------*
::   | This file is writing my optimized version of the fsp.ps1 script to           |
::   | your autostart directory. After you log in to your user account this script  |
::   | will launch automatically and start as ususal.                               |
::   |                                                                              |
::   | Like the original file, this script will simulate fake processes of analysis |
::   | sandbox/VM software some malware will try to evade. This just spawns         |
::   | ping.exe with different names (wireshark.exe, vboxtray.exe, etc...)          |
::   *------------------------------------------------------------------------------*-------*
::   | Hint: This works only for the current user. It will start at login and there is no   |
::   | way to stop the processes but to download the ps1 file and execute the stop action.  |
::   *--------------------------------------------------------------------------------------*

::  Default processes:
SET @proc='WinDbg.exe','idaq.exe','wireshark.exe','vmacthlp.exe','VBoxService.exe','VBoxTray.exe','procmon.exe','ollydbg.exe','vmware-tray.exe','idag.exe','ImmunityDebugger.exe'

:: Title and Version code
TITLE Fake Sandbox Processes Installer
COLOR 0F
SET @v=1.7
SET path=%~dp0

:: Just some nice user interface things
cls
echo Fake-Sandbox-Processes installation script. Version %@v%, 2017.
echo Visit https://github.com/phoenix1747/fake-sandbox/ for updates and fixes.
echo.
echo.
echo Firstly, thanks for your interest in FSP! Let's get started now.
echo.
echo.
echo.
echo # What do you want to do? You can (i)nstall or (u)ninstall this script.
SET /P ANSWER=# Would you like to continue? (i/u): 
if /i %ANSWER%==i goto INSTALL
if /i %ANSWER%==u goto UNINSTALL
goto unrecog

:: This is the uninstallation routine
:UNINSTALL
cls
echo.
echo # You are about to uninstall Fake Sandbox Processes from your computer.
SET /P ANSWER=# Are you sure you want to continue? (y/n): 
if /i %ANSWER%==y goto uninstally
if /i %ANSWER%==n goto no
goto unrecog
 
:: This will remove 
:uninstally
del "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\fsp.bat"
rmdir /s /q "%appdata%\FakeSandboxProcesses\"
goto DoneUninstall

:: Creation of the fsp.ps1 script in the new directory %appdata%\FakeSanboxProcesses\
:INSTALL
cls
echo.
echo # You are about to install the FSP scripts on your computer (autostart)
SET /P ANSWER=# Would you like to continue? (y/n): 
if /i %ANSWER%==y goto instally
if /i %ANSWER%==n goto no
goto unrecog

:instally
if not exist %appdata%\FakeSandboxProcesses\ (md "%appdata%\FakeSandboxProcesses\")
del "%appdata%\FakeSandboxProcesses\fsp.ps1"
del "%appdata%\FakeSandboxProcesses\current_version.txt"

(
echo # This file is part of Fake Sandbox Processes (Version %@v%^) available on https://github.com/phoenix1747/fake-sandbox/
echo $fakeProcesses = @(%@proc%^)
echo     $tmpdir = [System.Guid]::NewGuid(^).ToString(^)
echo     $binloc = Join-path $env:temp $tmpdir
echo     New-Item -Type Directory -Path $binloc
echo     $oldpwd = $pwd
echo     Set-Location $binloc
echo     foreach ($proc in $fakeProcesses^) {
echo       Copy-Item c:\windows\system32\ping.exe '$binloc\$proc'
echo       Start-Process '.\$proc' -WindowStyle Hidden -ArgumentList '-t -w 3600000 -4 1.1.1.1'
echo      write-host '[+] Process $proc spawned'
echo    }
echo    Set-Location $oldpwd
)>%appdata%\FakeSandboxProcesses\fsp.ps1

:: Creation of the file that will execute the Powershell script upon login
del "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\fsp.bat"

(
echo @echo off
echo :: This file is part of Fake Sandbox Processes (Version %@v%^) available on https://github.com/phoenix1747/fake-sandbox/
echo COLOR 0F
echo TITLE FSP is starting...
echo echo [*] Starting FSP script...
echo start /MIN powershell -executionpolicy remotesigned -WindowStyle Hidden -File "%appdata%\FakeSandboxProcesses\fsp.ps1"
)>"%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\fsp.bat"

cls
echo.
COLOR 0E
echo Would you like to enable the auto-updater to search and install updates regularly? (recommended)
SET /p asw=Choose (y/n): 
COLOR 0F
if /i %asw%==y (goto updater)
if /i %asw%==n (goto done)
goto unrecog

:: This writes additional code to the execution file and the FSP directory to allow auto-updates
:updater
echo %@v%>"%appdata%\FakeSandboxProcesses\current_version.txt"

(
echo.
echo echo [*] Starting updater...
echo start /MIN %appdata%\FakeSandboxProcesses\updater.bat
)>>"%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\fsp.bat"

:: Creation of the updater-updater (lol) script in the same directory
(
echo :: This file is part of Fake Sandbox Processes (Version %@v%^) available on https://github.com/phoenix1747/fake-sandbox/
echo @echo off
echo COLOR 0F
echo TITLE Installing latest version of FSP updater...
echo.
echo ping -n 1 127.0.0.1^>NUL
echo del %appdata%\FakeSandboxProcesses\uversion.txt
echo move /y %appdata%\FakeSandboxProcesses\updater_new.bat %appdata%\FakeSandboxProcesses\updater.bat
echo ping -n 1 127.0.0.1^>NUL
echo del %appdata%\FakeSandboxProcesses\updater_new.bat
echo start /MIN %appdata%\FakeSandboxProcesses\updater.bat
echo exit
)>"%appdata%\FakeSandboxProcesses\update-installer.bat"

:: Creation of the updater.bat script in the install directory
(
echo @echo off
echo COLOR 0F
echo echo [*] First install of FSP updater...
echo echo [*] Downloading...
echo start /wait /MIN powershell -executionpolicy remotesigned -WindowStyle Hidden -Command "(New-Object Net.WebClient^).DownloadFile('https://raw.githubusercontent.com/Phoenix1747/fake-sandbox/master/updater/updater.bat', '%appdata%\FakeSandboxProcesses\updater_new.bat')"
echo ping -n 2 127.0.0.1^>NUL
echo	if exist %appdata%\FakeSandboxProcesses\updater_new.bat (
echo		start /min %appdata%\FakeSandboxProcesses\update-installer.bat
echo		exit
echo	^)
echo exit
)>"%appdata%\FakeSandboxProcesses\updater.bat"

:: Look for any installation-error
:done
if errorlevel 1 goto error
COLOR 0A
cls
echo.
echo Done, all files have been created. FSP will launch after a relogin or reboot.
echo Thanks for installing this script!
echo.
echo Press any key to exit...
pause>NUL
exit

:: Look for any uninstallation-error
:DoneUninstall
if errorlevel 1 goto error
COLOR 0A
cls
echo.
echo Successfully removed FSP. All remaining processes will be gone once you relogin or reboot your PC.
echo.
echo # Sorry to see you go. Got any feedback? Please submit it here:
echo # https://github.com/phoenix1747/fake-sandbox/issues
echo.
echo.
echo Press any key to exit...
pause>NUL
exit


:: If there was an error the following commands will be used
:error
COLOR 0C
cls
echo.
echo An error occured!
echo If you tried to install this script, but already had it installed, ignore this error. 
echo Otherwise, please try again or debug this script.
echo.
echo The file can be found here:
echo %path:~0,-1%
echo.
echo Press any key to exit...
pause>NUL
exit

:: If you chose not to (un)install this will execute
:no
cls
echo.
echo Aborted by user. Press any key to exit...
pause>NUL
exit

:: If you did not choose one of the available parameters
:unrecog
COLOR 0C
echo.
echo ^>^>Bad usage. You have to use one of the available letters as command.
echo.
echo Press any key to restart...
pause>NUL
goto start