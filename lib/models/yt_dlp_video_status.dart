enum VideoStatus {
  carregando, video, audio, videoAudio, combinando, convertendo
}

class YtDlpVideoStatus {
  VideoStatus status;
  double progresso;

  YtDlpVideoStatus(this.status, this.progresso);

  static VideoStatus getFormato(String? vcodec, String? acodec) {
    if (vcodec == null || vcodec == 'none') {
      return VideoStatus.audio;
    }
    if (acodec == null || acodec == 'none') {
      return VideoStatus.video;
    }
    if (vcodec != 'none' && acodec != 'none') {
      return VideoStatus.videoAudio;
    }
    return VideoStatus.carregando;
  }
}