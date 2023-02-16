import 'dart:ffi';

import 'package:conduit/conduit.dart';
import 'package:dart_application_1/model/author.dart';
import 'package:dart_application_1/model/history.dart';

class Post extends ManagedObject<_Post> implements _Post {}

class _Post {
  @primaryKey
  int? id;
  @Column()
  String? name;
  @Column()
  String? category;
  @Column()
  String? description;
  @Column(defaultValue: "now()", indexed: true)
  DateTime? date;
  @Column()
  double? sum;
  @Column()
  bool? isEnabled;
  @Relate(#postList, isRequired: true, onDelete: DeleteRule.cascade)
  Author? author;
  ManagedSet<History>? historyList;
}
