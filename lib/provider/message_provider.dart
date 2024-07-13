import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class MessageProvider extends ChangeNotifier {
  List<XFile?> listmessageURL = [];

  void addlistMessageURL(List<XFile?> list) {
    listmessageURL.addAll(list);
    notifyListeners();
  }

  void removelistMessageURL(int index) {
    listmessageURL.removeAt(index);
    notifyListeners();
  }

  void clearlistMessageURL() {
    listmessageURL.clear();
    notifyListeners();
  }
}
