sealed class ApiResult<T> {
  ApiResult();
}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  ApiSuccess(this.data);
}

class ApiFailure<T> extends ApiResult<T> {
  final String message;

  ApiFailure(this.message);
}
