@ECHO OFF

REM This script cleans the public folder and then generates the new hugo content.

REM SET PATH=C:\Users\Josep\Desktop\GoDev\hugo\bin;%PATH%

ECHO Deleting old files...
DEL /a:-h /f /s "../blue-jay.github.io/*"

ECHO Deleting old folders (except .git)...
FOR /d %%x IN (../blue-jay.github.io/*) DO (
@RD /s /q "../blue-jay.github.io/%%x"
)

ECHO Generating content from hugo...
hugo

ECHO Content generated and ready to be pushed to GitHub.

PAUSE