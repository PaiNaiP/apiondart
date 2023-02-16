import 'package:conduit/conduit.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:dart_application_1/model/model_responce.dart';

class AppResponse extends Response {
  AppResponse.serverError(dynamic error, {String? message})
      : super.serverError(body: _getResponseModel(error, message));

  static ModelResponce _getResponseModel(error, String? message) {
    if (error is QueryException) {
      return ModelResponce(
          error: error.toString(), message: message ?? error.message);
    }

    if (error is JwtException) {
      return ModelResponce(
          error: error.toString(), message: message ?? error.message);
    }

    return ModelResponce(
        error: error.toString(), message: message ?? "Неизвестная ошибка");
  }

  AppResponse.ok({dynamic body, String? message})
      : super.ok(ModelResponce(data: body, message: message));

  AppResponse.badrequest({dynamic body, String? message})
      : super.ok(ModelResponce(data: body, message: message));
}
