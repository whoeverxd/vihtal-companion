// Este archivo existe para permitir una importación condicional en web.
// En web convertimos bytes a `html.Blob` para usar `putBlob`, que suele ser
// más confiable que `putData` en Chrome.

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

html.Blob bytesToBlob(Uint8List bytes, String contentType) {
  return html.Blob(<dynamic>[bytes], contentType);
}

