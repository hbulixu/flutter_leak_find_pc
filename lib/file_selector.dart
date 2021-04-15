import 'dart:typed_data';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

  void saveFile(String content,String fileName) async {
    final path = await FileSelectorPlatform.instance.getSavePath();
    if (path == null) {
      return;
    }
    final fileData = Uint8List.fromList(content.codeUnits);
    const fileMimeType = 'text/plain';
    final textFile =
    XFile.fromData(fileData, mimeType: fileMimeType, name: fileName);
    await textFile.saveTo(path);
  }

  typedef IndexCallback = void Function(String filePath,String fileContent);
  void openFile(IndexCallback callback) async {
    final typeGroup = XTypeGroup(
      label: 'text',
      extensions: ['dart'],
    );
    final file = await FileSelectorPlatform.instance
        .openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) {
      return;
    }
    String  dartContent = await file.readAsString();
    String dartPath = file.path;
    callback(dartPath,dartContent);
  }
