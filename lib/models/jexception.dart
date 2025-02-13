class JException implements Exception {
  final dynamic message;

  JException([this.message]);

  @override
  String toString() {
    Object? message = this.message;
    if (message == null) return "Exception";
    return message.toString();
  }
}

class AlreadyExistsException extends JException {
  AlreadyExistsException([super.message = 'Este arquivo já existe na sua máquina.']);
}

class FFmpegException extends JException {
  FFmpegException([super.message]);
}

class YtDlpException extends JException {
  YtDlpException([super.message]);
}