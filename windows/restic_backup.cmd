@echo off
cls

rem *****************************************************
rem Environment variables
rem *****************************************************
rem RESTIC_REPO         : the RESTIC repository (see https://restic.readthedocs.io/en/latest/030_preparing_a_new_repo.html)
rem RESTIC_PASSWORD     : the password associated with that repository
rem TG_CHATID           : the Telegram chat ID you want to use
rem TG_BOT              : the Telegram bot to send the message
rem BK_LOG_DAYS         : the number of days you want to keep log files
rem BK_LOG_MIN          : the minimum number of log files to keep


rem *****************************************************
rem Set log file with date time stamp
rem *****************************************************
For /f "tokens=1-3 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%b-%%a)
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a%%b)
set LOGFILE=restic-%mydate%_%mytime%.log

rem *****************************************************
rem If no option passed, use interactive menu
rem *****************************************************
if '%1' EQU '' goto menu
set ID=%1
goto process

rem *****************************************************
rem Main menu
rem *****************************************************
:menu
echo.
echo.
echo Choices:
echo.
echo   1 - Daily - Documents, Utils, Appdata, SSH
echo   2 - Media
echo   3 - Video Creation
echo   4 - 
echo   5 - VMWare - Atos, eOS, Shared, Host
echo   6 - 
echo   7 -
echo   8 - Test
echo.
echo   9 - All of the above
echo.
echo  98 - Check repo
echo  99 - Clean up restic local cache
echo.
echo  0 - Exit
echo.
set /p id="Enter choice: "

rem *****************************************************
rem Main process
rem *****************************************************
:process
if "%id%" EQU "0" goto end
if "%id%" EQU "1" call :bk_daily
if "%id%" EQU "2" call :bk_media
if "%id%" EQU "3" call :bk_vid
if "%id%" EQU "5" call :bk_vmware
if "%id%" EQU "8" call :bk_test

if "%id%" EQU "9" call :bk_all

if "%id%" EQU "98" call :repo_check
if "%id%" EQU "99" call :bk_clean

rem If interactive then go to menu so user can run another backup, else stop
if '%1' EQU '' goto menu
goto end

rem *****************************************************
rem Configure backup details
rem *****************************************************
:bk_all
call :bk_daily
call :bk_media
call :bk_vid
call :bk_vmware
exit /b

:bk_test
echo PRETEND BACKUP! 2>&1 | tee %LOGFILE%
exit /b

:bk_daily
echo Backing up Daily ...
taskkill /IM Mailbird.exe
call :go "C:\Users\Steve\Documents"
call :go "C:\Users\Steve\Desktop"
call :go "C:\Users\Steve\Desktop 2"
call :go "C:\Users\Steve\Desktop 3"
call :go "C:\Utils"
call :go "C:\Users\steve\AppData\Local\Mailbird"
start /min "" "C:\Program Files\Mailbird\Mailbird.exe"
call :go "C:\Users\steve\.ssh"
exit /b

:bk_media
echo Backing up media ...
call :go "D:\Media\Photos"
call :go "D:\Media\Photos - ORIGINALS"
call :go "D:\Media\Video Creation"
call :go "D:\Media\Videos"
exit /b

:bk_vid
echo Backing up Video bits  ...
call :go "C:\Media"
call :go "C:\Users\steve\AppData\Roaming\obs-studio"
exit /b

:bk_vmware
echo Backing up VMWare VMs ...
call :go "C:\VM\Atos"
call :go "C:\VM\eos"
call :go "C:\VM\Shared"
exit /b

rem *****************************************************
rem Maintenance jobs
rem *****************************************************
:bk_clean
echo Cleaning cache ...
restic -r %REPO% cache --cleanup 2>&1 | tee %LOGFILE%
exit /b

:repo_check
echo Checking repo ...
restic -r %REPO% check 2>&1 | tee %LOGFILE%
exit /b

rem *****************************************************
rem Actual backup job
rem *****************************************************
:go
restic -r %REPO% backup %1 2>&1 | tee %LOGFILE%
if errorlevel 1 goto broken
exit /b

rem *****************************************************
rem Clean up logs
rem *****************************************************
:cleanup
for %%X in (log) do (
  set "skip=1"
  for /f "skip=%BK_LOG_MIN% delims=" %%F in ('dir /b /a-d /o-d /tw *.%%X') do (
    if defined skip forfiles /d -%BK_LOG_DAYS% /m "%%F" >nul 2>nul && set "skip="
    if not defined skip del "%%F" 
  )
)
exit /b

rem *****************************************************
rem Alert if something failed and end
rem *****************************************************
:broken
echo.
curl -s -X POST --data-urlencode "chat_id=%TG_CHATID%" --data-urlencode "text=Backup failed on DEV - check log file %LOGFILE%" "https://api.telegram.org/bot%TG_BOT%/sendMessage"
echo.
goto end

rem *****************************************************
rem Tidy up and finish
rem *****************************************************
:end
call :cleanup
echo Finished