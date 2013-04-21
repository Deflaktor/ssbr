@echo off & setlocal enabledelayedexpansion
call config.bat

REM REM ---------------------------- REM REM
REM REM ------- backup test -------- REM REM
REM REM ---------------------------- REM REM

rmdir /q /s temp\temp
rmdir temp
IF EXIST temp (
  echo "Backup still exists, restoring first..."
  goto :restore
)

REM REM ---------------------------- REM REM
REM REM ------- copy files --------- REM REM
REM REM ---------------------------- REM REM

pushd source\files
  REM /* create temp directories */
  for /F %%i in ('dir /A:D /b /s') do (
    set A=%%i
    mkdir ..\..\temp\!A:%CD%\=!
  )
  REM /* move original files to temp directory and copy hacked files over original files */
  for /F %%i in ('dir /A:-D /b /s') do (
    set A=%%i
    move ..\..\brawl\DATA\files\!A:%CD%\=! ..\..\temp\!A:%CD%\=!
    copy !A:%CD%\=! ..\..\brawl\DATA\files\!A:%CD%\=!
  )
popd

REM REM ---------------------------- REM REM
REM REM ------ compile items ------- REM REM
REM REM ---------------------------- REM REM

REM /* make backup */
mkdir temp\system
move brawl\DATA\files\system\common3.pac temp\system\common3.pac
REM /* make working directory */
mkdir temp\temp

for /F %%i in ('dir source\items /A:-D /b') do (
  %findpac% source\items\%%i lib\items temp\temp
)

REM /* dont touch original lib files */
mkdir temp\temp\lib
copy lib\002.pac temp\temp\lib\002.pac
copy lib\common3.pac.out temp\temp\lib\common3.pac.out

pushd temp\temp
  for /F %%i in ('dir /A:-D /b') do (
    move %%i lib\%%i
    pushd lib
      %ssbbarc% -i %%i 002.pac
    popd
  )
  pushd lib
    %ssbbarc% -i 002.pac common3.pac.out
  popd
popd

%nt% -l -o brawl\DATA\files\system\common3.pac -A4 temp\temp\lib\common3.pac.out

rmdir /q /s temp\temp

REM REM ---------------------------- REM REM
REM REM ------- create iso --------- REM REM
REM REM ---------------------------- REM REM

%wit% COPY brawl brawl.iso -P --name "Super Smash Bros. Rumble" --id K --overwrite


REM REM ---------------------------- REM REM
REM REM -- restore original files -- REM REM
REM REM ---------------------------- REM REM

:restore
pushd temp
  REM /* restore original files from temp directory */
  for /F %%i in ('dir /A:-D /b /s') do (
    set A=%%i
    move !A:%CD%\=! ..\brawl\DATA\files\!A:%CD%\=!
  )
  
  REM /* remove temp sub-directories */
  for /l %%i in (1,1,10) DO (
    for /F %%i in ('dir /A:D /b /s') do (
      set A=%%i
      rmdir !A:%CD%\=!
    )
  )
popd

REM /* remove temp main directory */
rmdir temp

