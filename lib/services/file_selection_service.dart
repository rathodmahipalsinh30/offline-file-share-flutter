import 'package:file_picker/file_picker.dart';

import '../models/share_file.dart';

abstract class FileSelectionService {
  Future<List<ShareFile>> pickFiles();
}

class FilePickerSelectionService implements FileSelectionService {
  @override
  Future<List<ShareFile>> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) {
      return const [];
    }

    return result.files
        .map(
          (file) => ShareFile(
            name: file.name,
            sizeBytes: file.size,
            path: file.path,
          ),
        )
        .toList(growable: false);
  }
}
