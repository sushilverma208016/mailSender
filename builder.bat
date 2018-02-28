
::written by: sushilverma208016@gmail.com
::script to pull latest code from master, do clean/dev build and send mail to user about what happened to build
::you can add a task in windows task scheduler to run this file daily at specific time
::customize/comment it according to your need
@echo off
setlocal enabledelayedexpansion

::user should give these parameters for accessing project and sending mail
::write path of your project path folder below
set project_path=PROJECT_PATH
::write path of your server folder below
set server_path=SERVER_PATH
::write path of the folder where this script resides  
set script_path=SCRIPT_PATH
::write email address to send notification below (receiver)
set emailTo=EMAIL_TO
::write your email address below (sender)
set emailFrom=EMAIL_FROM
::write your login password below
set password=*********
::your outlook smtp server address is below
set smtpServer=outlook.office365.com

set /A flag=0  rem flag=1 is success and 0 is failure 
call :VariousTasks return_output  rem Calling build process
set subject="%return_output%"  rem Setting mail subject as output of build
set body="%return_output%"	rem Setting mail body as output of build

::sending mail
cd %script_path%
powershell.exe -ExecutionPolicy ByPass -File mail-sender.ps1 %emailTo% %subject% %body% %password% %emailFrom% %smtpServer% 
echo email sent
echo -------------- 

::start tomcat and other services if build is successful
if !flag!==1 (
	cd %project_path%\other
	start gradlew run
	timeout /T 20
	call %server_path%\bin\startup.bat
	echo tomcat and other services started
	exit 0  rem To exit from this window
)
::prefer not to start tomcat and other services when build is unsuccessful
echo not starting tomcat and other services
EXIT /B %ERRORLEVEL%

:VariousTasks
	::starting tasks
	date /t
	echo --------------
	if exist T:\nul (
		echo drive T: exists
	)
	echo --------------
	cd %project_path%
	echo --------------
	git checkout master 
	echo --------------
	git stash
	echo --------------
	git pull --rebase 
	echo --------------
	
	::clean build in project
	cd %project_path%
	set /A flag=0
	for /F "tokens=*" %%F in ('call gradlew clean build') do (
		set result=%%F
		if "!result!"=="BUILD SUCCESSFUL" (
			set /A flag=1
		)
	)
	if !flag!==0 (
		set "%~1=Alert: clean build failed in project"
		echo clean build failed in project
		EXIT /B 0
	)
	echo clean build succesful in project
	
	echo --------------
	
	::devbuild in project
	cd %project_path%
	set /A flag=0
	for /F "tokens=*" %%F in ('call gradlew devbuild') do (
		set result=%%F
		if "!result!"=="BUILD SUCCESSFUL" (
			set /A flag=1
		)
	)
	if !flag!==0 (
		set "%~1=Alert: devbuild failed in project"
		echo devbuild failed in project
		EXIT /B 0
	)
	echo devbuild succesful in project
	
	echo --------------
	
	::ending tasks with success
	set "%~1=Congrates: your system is succesfully built and updated"
	echo your system is succesfully built and updated
	echo --------------
	EXIT /B 0
