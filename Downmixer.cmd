@echo off
for /f in () do (
    ffmpeg -i "%%~fg" -filter_complex "[0:a:0]volume=1.66,pan=stereo|FL=0.5*FC+0.707*FL+0.707*BL+0.5*LFE|FR=0.5*FC+0.707*FR+0.707*BR+0.5*LFE[filtered]" -map 0:v -c:v copy -map [filtered] -c:a:0 ac3 -metadata:s:a:0 title="Stereo 2.0" -metadata:s:a:0 language=eng -map 0:a:0 -c:a:1 copy -disposition:a:1 0 "%%~dpnG.downmix%%~xG"
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
)