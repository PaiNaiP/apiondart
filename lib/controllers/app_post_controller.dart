import 'dart:collection';
import 'dart:ffi';
import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:dart_application_1/model/author.dart';
import 'package:dart_application_1/model/history.dart';
import 'package:dart_application_1/model/model_responce.dart';
import 'package:dart_application_1/model/post.dart';
import 'package:dart_application_1/utils/app_responce.dart';
import 'package:dart_application_1/utils/app_utils.dart';

class AppPostController extends ResourceController {
  AppPostController(this.managedContext);

  final ManagedContext managedContext;

  @Operation.post()
  Future<Response> createPost(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.body() Post post) async {
    try {
      final id = AppUtils.getIdFromHeader(header);

      final author = await managedContext.fetchObjectWithID<Author>(id);

      if (author == null) {
        final qCreateAuthor = Query<Author>(managedContext)..values.id = id;
        await qCreateAuthor.insert();
      }

      final qCreatePost = Query<Post>(managedContext)
        ..values.author!.id = id
        ..values.name = post.name
        ..values.category = post.category
        ..values.description = post.description
        ..values.date = post.date
        ..values.sum = post.sum
        ..values.isEnabled = true;

      await qCreatePost.insert().then((value) async {
        var qCreateHistory = Query<History>(managedContext)
          ..values.date = DateTime.now()
          ..values.procedure = 'insert'
          ..values.post!.id = value.id;

        await qCreateHistory.insert();
      });

      return AppResponse.ok(message: 'Успешное создание поста');
    } catch (error) {
      return AppResponse.serverError(error, message: 'Ошибка создания поста');
    }
  }

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
        ..where((x) => x.isEnabled).equalTo(true)
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

  @Operation.get()
  Future<Response> getPost(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.query('name') String name) async {
    try {
      final currentAuthorId = AppUtils.getIdFromHeader(header);
      final heroQuery = Query<Post>(managedContext);
      if (name != null) {
        heroQuery.where((h) => h.name).contains(name, caseSensitive: false);
      }
      final heroes = await heroQuery.fetch();
      final post = await heroQuery.fetchOne();

      if (post == null) {
        return AppResponse.ok(message: "Пост не найден");
      }
      if (post.author?.id != currentAuthorId) {
        return AppResponse.ok(message: "Нет доступа к посту");
      }
      return Response.ok(heroes);
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка вывода поста");
    }
  }

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
          ..values.procedure = 'update'
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

      final qUpdatePost = Query<Post>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..values.name = bodyPst.name
        ..values.category = bodyPst.category
        ..values.description = bodyPst.description
        ..values.date = bodyPst.date
        ..values.sum = bodyPst.sum
        ..values.isEnabled = false;

      await qUpdatePost.update().then((value) async {
        var qCreateHistory = Query<History>(managedContext)
          ..values.date = DateTime.now()
          ..values.procedure = 'logical_delete'
          ..values.post!.id = value.first.id;

        await qCreateHistory.insert();
      });

      // final qDeletePost = Query<Post>(managedContext)
      //   ..where((x) => x.id).equalTo(id);

      //await qDeletePost.delete();
      return AppResponse.ok(message: "Успешное удаление поста");
    } catch (error) {
      return AppResponse.serverError(error, message: 'Ошибка удаление поста');
    }
  }
}
