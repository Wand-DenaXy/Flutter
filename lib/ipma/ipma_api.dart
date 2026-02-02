// =============================================================================
// ipma_api.dart — Serviço de acesso à API aberta do IPMA
// =============================================================================
//
// Base URL: https://api.ipma.pt
//
// Responsabilidades:
// - Executar pedidos HTTP GET aos endpoints de dados abertos do IPMA.
// - Validar o status HTTP da resposta e lançar exceção em caso de erro.
// - Decodificar o corpo da resposta com UTF-8 (para preservar acentos) e
//   converter JSON em modelos tipados definidos em modelos.dart.
//
// Endpoints utilizados:
// - distrits-islands.json     → lista de locais (distritos/ilhas).
// - weather-type-classe.json  → dicionário id → descrição do tipo de tempo.
// - forecast/.../daily/{id}.json → previsão diária por globalIdLocal.
// - forecast/warnings/warnings_www.json → avisos meteorológicos.
//
// =============================================================================

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'modelos.dart';

/// Serviço que centraliza todas as chamadas à API do IPMA.
/// Não mantém estado; cada método devolve os dados pedidos ou lança exceção.
class IpmaApi {
  static const String _baseUrl = 'https://api.ipma.pt';

  /// Devolve a lista de locais (distritos e ilhas) disponíveis na API.
  /// Os resultados são ordenados alfabeticamente por nome.
  /// O campo [LocalIpma.idGlobalLocal] é usado para pedir a previsão diária.
  Future<List<LocalIpma>> obterLocais() async {
    final uri = Uri.parse('$_baseUrl/open-data/distrits-islands.json');
    final resposta = await http.get(uri);

    if (resposta.statusCode != 200) {
      throw Exception('Erro ao obter locais (HTTP ${resposta.statusCode})');
    }

    final json = jsonDecode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>;
    final lista = (json['data'] as List<dynamic>? ?? const []);

    final locais = lista
        .map((e) => LocalIpma.fromJson(e as Map<String, dynamic>))
        .toList();

    locais.sort((a, b) => a.nomeLocal.compareTo(b.nomeLocal));
    return locais;
  }

  /// Devolve um mapa que associa o identificador do tipo de tempo ao objeto
  /// [TipoTempo] (descrição em português). Usado na página de previsão para
  /// mostrar o texto correspondente a cada [PrevisaoDiaria.idTipoTempo].
  Future<Map<int, TipoTempo>> obterTiposTempo() async {
    final uri = Uri.parse('$_baseUrl/open-data/weather-type-classe.json');
    final resposta = await http.get(uri);

    if (resposta.statusCode != 200) {
      throw Exception('Erro ao obter tipos de tempo (HTTP ${resposta.statusCode})');
    }

    final json = jsonDecode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>;
    final lista = (json['data'] as List<dynamic>? ?? const []);

    final tipos = lista
        .map((e) => TipoTempo.fromJson(e as Map<String, dynamic>))
        .toList();

    return {for (final t in tipos) t.idTipoTempo: t};
  }
  //----------------------------------------------------------------------------
  Future<List<InovacaoIpma>> obterInovacao() async {
    final uri = Uri.parse('$_baseUrl/open-data/observation/seismic/3.json');
    final resposta = await http.get(uri);

    if (resposta.statusCode != 200) {
      throw Exception('Erro ao obter tipos de tempo (HTTP ${resposta.statusCode})');
    }

    final json = jsonDecode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>;
    final lista = (json['data'] as List<dynamic>? ?? const []);

    return lista
        .map((e) => InovacaoIpma.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Devolve a previsão diária (tipicamente 5–7 dias) para o local indicado
  /// pelo [idGlobalLocal]. Esse identificador é obtido da lista de locais.
  Future<List<PrevisaoDiaria>> obterPrevisaoDiaria(int idGlobalLocal) async {
    final uri = Uri.parse(
      '$_baseUrl/open-data/forecast/meteorology/cities/daily/$idGlobalLocal.json',
    );

    final resposta = await http.get(uri);

    if (resposta.statusCode != 200) {
      throw Exception('Erro ao obter previsão (HTTP ${resposta.statusCode})');
    }

    final json = jsonDecode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>;
    final lista = (json['data'] as List<dynamic>? ?? const []);

    return lista
        .map((e) => PrevisaoDiaria.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Devolve a resposta bruta de avisos meteorológicos. A API pode devolver
  /// um array na raiz (formato atual) ou um objeto com a chave "data";
  /// ambos os formatos são tratados.
  Future<RespostaAvisosIpma> obterAvisos() async {
    final uri = Uri.parse('$_baseUrl/open-data/forecast/warnings/warnings_www.json');
    final resposta = await http.get(uri);

    if (resposta.statusCode != 200) {
      throw Exception('Erro ao obter avisos (HTTP ${resposta.statusCode})');
    }

    final decoded = jsonDecode(utf8.decode(resposta.bodyBytes));

    if (decoded is List<dynamic>) {
      return RespostaAvisosIpma(data: decoded);
    }

    return RespostaAvisosIpma.fromJson(decoded as Map<String, dynamic>);
  }
}
