setlocal


set corgiversion=0.8.5e
set archive=Corg.Source.%corgiversion%.7z
set zip="C:\Program Files\7-Zip\7z.exe"

%zip% a %archive% *.au3
%zip% a %archive% *.kxf
%zip% a %archive% *.txt
%zip% a %archive% archive.bat
%zip% a %archive% icons\*.ico

copy %archive% archives\

endlocal

pause
