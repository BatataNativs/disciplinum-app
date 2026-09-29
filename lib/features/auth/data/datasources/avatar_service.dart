import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Serviço para gerenciamento de avatar 100% local no dispositivo
class AvatarService {
  /// Salva a foto do avatar na pasta de documentos local do aplicativo
  static Future<String?> saveAvatarLocally({required File file}) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final avatarDir = Directory('${appDir.path}/avatars');
      if (!avatarDir.existsSync()) {
        avatarDir.createSync(recursive: true);
      }

      final targetPath = '${avatarDir.path}/avatar.png';
      await file.copy(targetPath);
      LoggerService.instance.i('Avatar salvo localmente com sucesso: $targetPath');
      return targetPath;
    } catch (e, st) {
      LoggerService.instance.e('Erro ao salvar avatar local', error: e, stackTrace: st);
      return null;
    }
  }

  /// Compatibilidade com chamadas existentes: salva localmente
  static Future<bool> uploadAvatar({
    required String userId,
    required File file,
  }) async {
    final path = await saveAvatarLocally(file: file);
    return path != null;
  }

  /// Seleciona imagem da galeria
  static Future<File?> pickAvatar() async {
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
      );
      if (picked == null) return null;
      return File(picked.path);
    } catch (e) {
      LoggerService.instance.e('Erro ao selecionar imagem', error: e);
      return null;
    }
  }
}
