import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

final supabase = Supabase.instance.client;

class AvatarService {
  static const _bucket = 'avatars';

  // Faz upload E atualiza a URL do usuário no banco de dados
  static Future<bool> uploadAvatar({
    required String userId,
    required File file,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      // Caminho: {userId}/avatar.png - necessário para as policies de storage
      final filePath = '$userId/avatar.png';

      // 1. Upload para o Bucket (na pasta do usuário)
      await supabase.storage.from(_bucket).uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              upsert: true, // Sobrescreve se já existir
              contentType: 'image/png',
            ),
          );

      // 2. Pega a URL pública do arquivo recém enviado
      final publicUrl = supabase.storage.from(_bucket).getPublicUrl(filePath);

      // 3. Atualiza o campo avatar_url na tabela users
      await supabase.from('users').update({
        'avatar_url': publicUrl,
      }).eq('id', userId);

      return true;
    } catch (e) {
      LoggerService.instance.e('Erro upload avatar', error: e);
      return false;
    }
  }

  // Seleciona imagem da galeria
  // Retorna null se cancelar ou der erro (erro logado no console)
  static Future<File?> pickAvatar() async {
    // Removido context daqui
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
