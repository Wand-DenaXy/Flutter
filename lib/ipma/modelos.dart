// =============================================================================
// modelos.dart — Modelos de dados da API do IPMA
// =============================================================================
//
// Estes tipos representam as estruturas devolvidas em JSON pela API.
// Usar modelos em vez de Map<String, dynamic> em todo o código permite
// tipagem forte, autocomplete e deteção de erros em tempo de desenvolvimento.
//
// Convenção: os nomes dos campos em Dart seguem camelCase; o mapeamento
// para as chaves JSON da API é feito nos factory fromJson.
//
// =============================================================================

/// Um local (distrito ou ilha) disponível para previsão.
/// [idGlobalLocal] é o identificador usado no endpoint de previsão diária.
/// [idAreaAviso] corresponde ao código de área usado nos avisos meteorológicos.
class LocalIpma {
  final int idGlobalLocal;
  final String nomeLocal;
  final String latitude;
  final String longitude;
  final String idAreaAviso;
  final int idRegiao;
  final int idDistrito;

  LocalIpma({
    required this.idGlobalLocal,
    required this.nomeLocal,
    required this.latitude,
    required this.longitude,
    required this.idAreaAviso,
    required this.idRegiao,
    required this.idDistrito,
  });

  factory LocalIpma.fromJson(Map<String, dynamic> json) {
    return LocalIpma(
      idGlobalLocal: json['globalIdLocal'] as int,
      nomeLocal: json['local'] as String,
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
      idAreaAviso: (json['idAreaAviso'] ?? '') as String,
      idRegiao: json['idRegiao'] as int,
      idDistrito: json['idDistrito'] as int,
    );
  }
}

/// Um tipo de tempo (ex.: "Céu limpo", "Chuva") identificado por [idTipoTempo].
/// Usado como dicionário na previsão para converter o id devolvido pela API
/// na descrição em português [descricaoPt].
class TipoTempo {
  final int idTipoTempo;
  final String descricaoPt;

  TipoTempo({required this.idTipoTempo, required this.descricaoPt});

  factory TipoTempo.fromJson(Map<String, dynamic> json) {
    return TipoTempo(
      idTipoTempo: json['idWeatherType'] as int,
      descricaoPt: json['descWeatherTypePT'] as String,
    );
  }
}
//----------------------------------------------------------------------------
class InovacaoIpma {
  final String time;
  final String nomeLocal;
  final String? lat;
  final String? long;
  final String? magnitud;
  final String? magType;
  final String? degree;
  final String? depth;

  InovacaoIpma({
    required this.time,
    required this.nomeLocal,
    this.lat,
    this.long,
    this.magnitud,
    this.magType,
    this.degree,
    this.depth,
  });

  factory InovacaoIpma.fromJson(Map<String, dynamic> json) {
  return InovacaoIpma(
    time: json['time'] as String,
    nomeLocal: (json['local'] ?? json['obsRegion'] ?? 'Desconhecido') as String,
    lat: json['lat']?.toString(),
    long: json['lon']?.toString(),
    magnitud: json['magnitud']?.toString(),
    magType: json['magType']?.toString(),
    degree: json['degree']?.toString(),
    depth: json['depth']?.toString(),
  );
  }
}
/// Previsão para um dia: data, tipo de tempo, temperaturas min/max e
/// opcionalmente probabilidade de precipitação, vento, etc. Alguns campos
/// podem vir nulos na API, por isso usamos tipos nullable (String?).
class PrevisaoDiaria {
  final String dataPrevisao;
  final int idTipoTempo;
  final String? tempMin;
  final String? tempMax;
  final String? probPrecipitacao;
  final String? direccaoVento;
  final String? classeVelocidadeVento;

  PrevisaoDiaria({
    required this.dataPrevisao,
    required this.idTipoTempo,
    this.tempMin,
    this.tempMax,
    this.probPrecipitacao,
    this.direccaoVento,
    this.classeVelocidadeVento,
  });

  factory PrevisaoDiaria.fromJson(Map<String, dynamic> json) {
    return PrevisaoDiaria(
      dataPrevisao: json['forecastDate'] as String,
      idTipoTempo: (json['idWeatherType'] ?? 0) as int,
      tempMin: json['tMin']?.toString(),
      tempMax: json['tMax']?.toString(),
      probPrecipitacao: json['precipitaProb']?.toString(),
      direccaoVento: json['predWindDir']?.toString(),
      classeVelocidadeVento: json['classWindSpeed']?.toString(),
    );
  }
}

/// Resposta do endpoint de avisos. O conteúdo exacto de cada elemento da
/// lista [data] depende do esquema da API; na UI os campos são lidos de
/// forma defensiva (com fallbacks) para evitar falhas se o esquema mudar.
class RespostaAvisosIpma {
  final List<dynamic> data;

  RespostaAvisosIpma({required this.data});

  factory RespostaAvisosIpma.fromJson(Map<String, dynamic> json) {
    return RespostaAvisosIpma(
      data: (json['data'] as List<dynamic>? ?? const []),
    );
  }
}
