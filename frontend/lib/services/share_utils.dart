import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareUtils {
  static Future<void> compartirOutfitSinMarca({
    required String base64Imagen,
    required String username,
  }) async {
    try {
      final Uint8List outfitBytes = base64Decode(base64Imagen);

      // Guarda temporalmente
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/outfit_reverie_solo.png');
      await file.writeAsBytes(outfitBytes);

      // Comparte solo la imagen original
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Te recomiendo este outfit de $username en Reverie 👗✨\nhttps://reverie.app',
      );
    } catch (e) {
      print('Error al compartir imagen del outfit: $e');
    }
  }
}
