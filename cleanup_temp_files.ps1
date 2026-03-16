Write-Host "Limpando arquivos temporarios..."

# Limpar shared widgets
Set-Location lib\shared\widgets

Remove-Item shared_widgets_temp_backup.dart -ErrorAction SilentlyContinue
Remove-Item shared_widgets_old.dart -ErrorAction SilentlyContinue
Remove-Item shared_widgets_new.dart -ErrorAction SilentlyContinue
Remove-Item shared_widgets_temp.dart -ErrorAction SilentlyContinue
Remove-Item shared_widgets_final.dart -ErrorAction SilentlyContinue

# Limpar core errors
Set-Location ..\..\core\errors

Remove-Item error_handler.dart -ErrorAction SilentlyContinue
if (Test-Path error_handler_fixed.dart) {
    Rename-Item error_handler_fixed.dart error_handler.dart
}

Write-Host "Limpeza concluida!"
Read-Host "Pressione Enter para continuar"
