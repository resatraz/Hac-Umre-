enum AppErrorType { network, server, cache, unknown }

class AppError implements Exception {
  final String message;
  final AppErrorType type;
  final int? code;
  const AppError(this.message, {this.type = AppErrorType.unknown, this.code});

  factory AppError.network(String m) => AppError(m, type: AppErrorType.network);
  factory AppError.server(String m, {int? code}) => AppError(m, type: AppErrorType.server, code: code);

  @override
  String toString() => message;
}
