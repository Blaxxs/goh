import 'web_location_stub.dart'
    if (dart.library.html) 'web_location_web.dart' as impl;

String currentHref() => impl.currentHref();
String currentHash() => impl.currentHash();
