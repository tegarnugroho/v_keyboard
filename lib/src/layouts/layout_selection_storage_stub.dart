import 'layout_selection_storage.dart';

LayoutSelectionStorage createPlatformLayoutStorage({String? customPath}) =>
    InMemoryLayoutSelectionStorage();
