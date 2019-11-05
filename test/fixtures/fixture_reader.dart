import 'dart:io';
import 'package:path/path.dart' show join, dirname;

String fixture(String name) =>
    File(join(dirname('test/'), 'fixtures', name)).readAsStringSync();
