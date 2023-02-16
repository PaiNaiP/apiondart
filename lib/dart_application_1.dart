import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:dart_application_1/controllers/app_auth_controller.dart';
import 'package:dart_application_1/controllers/app_history_controller.dart';
import 'package:dart_application_1/controllers/app_logical_delete.dart';
import 'package:dart_application_1/controllers/app_post_controller.dart';
import 'package:dart_application_1/controllers/app_token_controller.dart';
import 'package:dart_application_1/controllers/app_user_controller.dart';
import 'model/author.dart';
import 'model/post.dart';

class AppService extends ApplicationChannel {
  late final ManagedContext managedContext;

  @override
  Future prepare() {
    final persistentStore = _initDatabase();
    managedContext = ManagedContext(
        ManagedDataModel.fromCurrentMirrorSystem(), persistentStore);
    return super.prepare();
  }

  @override
  Controller get entryPoint => Router()
    ..route('post/[:id]')
        .link(AppTokenController.new)!
        .link(() => AppPostController(managedContext))
    ..route('history/[:id]')
        .link(AppTokenController.new)!
        .link(() => AppHistoryController(managedContext))
    ..route('logincalDelete/[:id]')
        .link(AppTokenController.new)!
        .link(() => AppLogicalDeleteController(managedContext))
    ..route('token/[:refresh]').link(
      () => AppAuthController(managedContext),
    )
    ..route('user')
        .link(AppTokenController.new)!
        .link(() => AppUserController(managedContext));

  PersistentStore _initDatabase() {
    final username = Platform.environment['DB_USERNAME'] ?? 'postgres';
    final password = Platform.environment['DB_PASSWORD'] ?? 'Qwer2345';
    final host = Platform.environment['DB_HOST'] ?? '127.0.0.1';
    final port = int.parse(Platform.environment['DB_PORT'] ?? '5433');
    final databaseName = Platform.environment['DB_NAME'] ?? 'bank';
    return PostgreSQLPersistentStore(
        username, password, host, port, databaseName);
  }
}
