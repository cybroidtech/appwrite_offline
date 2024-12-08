import 'dart:async';

import 'package:flutter_data/flutter_data.dart';

extension ToStringX on DataRequestMethod {
  String toShortString() => toString().split('.').last;
}

typedef OnSuccessGeneric<R> = FutureOr<R?> Function(
    DataResponse response, DataRequestLabel label);

typedef OnErrorGeneric<R> = FutureOr<R?> Function(
    DataException e, DataRequestLabel label);