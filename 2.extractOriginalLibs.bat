@echo off
call config.bat

mkdir lib
%ssbbarc% -o lib\common3.pac.out brawl\DATA\files\system\common3.pac
%ssbbarc% lib\common3.pac.out
move lib\common3.pac.out.d\002.pac lib\002.pac
rmdir /s /q lib\common3.pac.out.d
%ssbbarc% -o lib\items lib\002.pac


pause