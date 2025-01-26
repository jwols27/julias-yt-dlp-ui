class OpcaoYoutube {
  String id;
  String ext;
  final String _resolution;

  OpcaoYoutube(this.id, this.ext, this._resolution);

  String get res {
    if (_resolution == 'audio only') {
      return 'Somente áudio';
    }
    return _resolution.split('x').last;
  }

  @override
  String toString() {
    return 'ID: $id\tEXTENSION: $ext\tRESOLUTION: $res';
  }
}