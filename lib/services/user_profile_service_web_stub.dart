// Stub para plataformas no-web.
import 'dart:typed_data';

Object bytesToBlob(Uint8List bytes, String contentType) {
  throw UnsupportedError('bytesToBlob solo está disponible en web');
}

