enum AppError {
  notFound,
  badRequest,
  unauthorized,
  forbidden,
  internalServerError,
  unknown,
  apiError,
}

class MyError {
  final AppError key;
  final String message;
  final Map<String, dynamic>? data;

  const MyError({
    required this.key,
    this.message = "Something Went Wrong",
    this.data,
  });
}
