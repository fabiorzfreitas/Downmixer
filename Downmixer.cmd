@echo off
setlocal EnableExtensions DisableDelayedExpansion
set "WindowTitle=%~n0"
setlocal EnableDelayedExpansion
for /F "tokens=1,2" %%G in ("!CMDCMDLINE!") do (
    if /I "%%~nG" == "cmd" if /I "%%~H" == "/c" (
        endlocal
        start %SystemRoot%\System32\cmd.exe /D /K %0
        if not errorlevel 1 exit /B
        setlocal EnableDelayedExpansion
    )
)
title !WindowTitle!
endlocal

for /F "tokens=*" %%G in ('%SystemRoot%\System32\chcp.com') do for %%H in (%%G) do set /A "CodePage=%%H" 2>nul
%SystemRoot%\System32\chcp.com 65001 >nul 2>&1

if not exist "%~dpn0.log" break >"%~dpn0.log"

set "FileList=%~dp0FileList.txt"
set "LogFile=%~dpn0.log"

for /f "usebackq delims=" %%G in ("%FileList%") do (
    set "SkipFile="
    for /f "usebackq delims=" %%H in ("%LogFile%") do (
        if "%%G" == "%%H" (
            set "SkipFile=1"
        )
    )
    if not defined SkipFile (
        echo --^> Processing file "%%~nG"
        ffmpeg -i "%%~fG" -filter_complex "[0:a:0]volume=1.66,pan=stereo|FL=0.5*FC+0.707*FL+0.707*BL+0.5*LFE|FR=0.5*FC+0.707*FR+0.707*BR+0.5*LFE[filtered]" -map 0:v -c:v copy -map [filtered] -c:a:0 ac3 -metadata:s:a:0 title="Stereo 2.0" -metadata:s:a:0 language=eng -map 0:a:0 -c:a:1 copy -disposition:a:1 0 "%%~dpnG.downmix%%~xG"
        if not errorlevel 1 (
    	    echo --^> Deleting old file
            del /f "%%~fG"
    	    echo --^> Renaming new file
    	    ren "%%~dpnG.downmix%%~xG" "%%~nxG"
        ) else (
            echo Warnings/errors generated during remuxing, original file not deleted, check errors.txt
            mkvmerge.exe -i --ui-language en "%%~fG" >> Errors.txt
            del "%%~dpnG.downmix%%~xG" 2>nul
        )
        echo.
        echo ##########
        echo.
        >>"%~dpn0.log" echo %%G
    ) else (
        echo "%%~nG" has already been processed
        echo.
        echo ##########
        echo.
    )
)

%SystemRoot%\System32\chcp.com %CodePage% >nul
endlocal