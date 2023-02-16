import 'dart:ffi';

import 'package:conduit/conduit.dart';
import 'package:dart_application_1/model/post.dart';

class History extends ManagedObject<_History> implements _History {}

class _History {
  @primaryKey
  int? id;
  @Column(defaultValue: "now()", indexed: true)
  DateTime? date;
  @Column()
  String? procedure;
  @Relate(#historyList, isRequired: true, onDelete: DeleteRule.cascade)
  Post? post;
}
