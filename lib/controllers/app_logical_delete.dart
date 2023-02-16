import 'dart:collection';
import 'dart:ffi';
import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:dart_application_1/model/author.dart';
import 'package:dart_application_1/model/model_responce.dart';
import 'package:dart_application_1/model/post.dart';
import 'package:dart_application_1/utils/app_responce.dart';
import 'package:dart_application_1/utils/app_utils.dart';
import 'package:dart_application_1/model/history.dart';

class AppLogicalDeleteController extends ResourceController {
  AppLogicalDeleteController(this.managedContext);

  final ManagedContext managedContext;

  // @Operation.get()
  // Future<Response> getPosts(
  //     @Bind.header(HttpHeaders.authorizationHeader) String header) async {
  //   try {
  //     final id = AppUtils.getIdFromHeader(header);

  //     final qCreatePost = Query<Post>(managedContext)
  //       ..where((x) => x.author!.id).equalTo(id);

  //     final List<Post> list = await qCreatePost.fetch();

  //     if (list.isEmpty)
  //       return Response.notFound(
  //           body: ModelResponce(data: [], message: 'Нет ни одного поста'));

  //     return Response.ok(list);
  //   } catch (e) {
  //     return AppResponse.serverError(e);
  //   }
  // }

  @Operation.get('id')
  Future<Response> getPostsPag(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path('id') int page) async {
    try {
      final id = AppUtils.getIdFromHeader(header);

      final qCreatePost = Query<Post>(managedContext)
        ..where((x) => x.author!.id).equalTo(id)
        ..where((x) => x.isEnabled).equalTo(false)
        ..sortBy((x) => x.category, QuerySortOrder.descending)
        ..offset = page * 20
        ..fetchLimit = 20;

      final List<Post> list = await qCreatePost.fetch();

      if (list.isEmpty)
        return Response.notFound(
            body: ModelResponce(data: [], message: 'Нет ни одного поста'));

      return Response.ok(list);
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }

  // @Operation.get("id")
  // Future<Response> getPost(
  //   @Bind.header(HttpHeaders.authorizationHeader) String header,
  //   @Bind.path("id") int id,
  // ) async {
  //   try {
  //     final currentAuthorId = AppUtils.getIdFromHeader(header);

  //     final postQuery = Query<Post>(managedContext)
  //       ..where((h) => h.id).equalTo(id);

  //     final post = await postQuery.fetchOne();

  //     if (post == null) {
  //       return AppResponse.ok(message: "Пост не найден");
  //     }
  //     if (post.author?.id != currentAuthorId) {
  //       return AppResponse.ok(message: "Нет доступа к посту");
  //     }

  //     post.backing.removeProperty("author");
  //     return AppResponse.ok(
  //         body: post.backing.contents, message: "Пост успешно найден");
  //   } catch (error) {
  //     return AppResponse.serverError(error, message: "Ошибка создания поста");
  //   }
  // }

  @Operation.put('id')
  Future<Response> updatePost(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path("id") int id,
      @Bind.body() Post bodyPst) async {
    try {
      final currentAuthorId = AppUtils.getIdFromHeader(header);
      final post = await managedContext.fetchObjectWithID<Post>(id);

      if (post == null) {
        return AppResponse.ok(message: "Пост не найден");
      }

      if (post.author?.id != currentAuthorId) {
        return AppResponse.ok(message: "Нет доступа к посту");
      }

      final qUpdatePost = Query<Post>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..values.name = bodyPst.name
        ..values.category = bodyPst.category
        ..values.description = bodyPst.description
        ..values.date = bodyPst.date
        ..values.sum = bodyPst.sum
        ..values.isEnabled = true;

      await qUpdatePost.update().then((value) async {
        var qCreateHistory = Query<History>(managedContext)
          ..values.date = DateTime.now()
          ..values.procedure = 'logical_return'
          ..values.post!.id = value.first.id;

        await qCreateHistory.insert();
      });

      return AppResponse.ok(message: "Пост успешно обновлён");
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }

  @Operation.delete("id")
  Future<Response> deletePost(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path("id") int id,
      @Bind.body() Post bodyPst) async {
    try {
      final currentAuthorId = AppUtils.getIdFromHeader(header);
      final post = await managedContext.fetchObjectWithID<Post>(id);

      if (post == null) {
        return AppResponse.ok(message: "Пост не найден");
      }

      if (post.author?.id != currentAuthorId) {
        return AppResponse.ok(message: "Нет доступа к посту");
      }

      // final qUpdatePost = Query<Post>(managedContext)
      //   ..where((x) => x.id).equalTo(id)
      //   ..values.name = bodyPst.name
      //   ..values.category = bodyPst.category
      //   ..values.description = bodyPst.description
      //   ..values.date = bodyPst.date
      //   ..values.sum = bodyPst.sum
      //   ..values.isEnabled = false;

      // await qUpdatePost.update();

      final qDeletePost = Query<Post>(managedContext)
        ..where((x) => x.id).equalTo(id);

      await qDeletePost.delete();
      return AppResponse.ok(message: "Успешное удаление поста");
    } catch (error) {
      return AppResponse.serverError(error, message: 'Ошибка удаление поста');
    }
  }
}
