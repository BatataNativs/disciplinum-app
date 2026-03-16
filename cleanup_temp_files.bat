@echo off
echo Limpando arquivos temporarios...

cd lib\shared\widgets

del shared_widgets_temp_backup.dart 2>nul
del shared_widgets_old.dart 2>nul
del shared_widgets_new.dart 2>nul
del shared_widgets_temp.dart 2>nul
del shared_widgets_final.dart 2>nul

cd ..\..\core\errors

del error_handler.dart 2>nul
ren error_handler_fixed.dart error_handler.dart

echo Limpeza concluida!
pause
