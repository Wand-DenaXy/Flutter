// =============================================================================
// pagina_previsao.dart — Página da previsão diária por local
// =============================================================================
//
// Mostra a previsão diária (tipicamente 5–7 dias) para o local seleccionado
// na página de locais. Cada dia exibe: data, descrição do tipo de tempo
// (obtida do dicionário de tipos), temperaturas mínima e máxima.
//
// A API devolve [idTipoTempo] por dia; o dicionário [TipoTempo] (obtido
// de weather-type-classe.json) é usado para converter o id na descrição
// em português (ex.: "Céu limpo", "Chuva").
//
// Dois FutureBuilders em sequência: primeiro a previsão, depois o dicionário
// de tipos; o segundo usa mapa vazio se ainda não tiver carregado, para não
// bloquear a UI.
//
// =============================================================================

import 'package:flutter/material.dart';

import '../ipma/ipma_api.dart';
import '../ipma/modelos.dart';

/// Página de previsão diária para o local [local]. Recebe [api] para pedir
/// a previsão e o dicionário de tipos de tempo.
class PaginaPrevisao extends StatefulWidget {
  final IpmaApi api;
  final LocalIpma local;

  const PaginaPrevisao({
    super.key,
    required this.api,
    required this.local,
  });

  @override
  State<PaginaPrevisao> createState() => _PaginaPrevisaoState();
}

class _PaginaPrevisaoState extends State<PaginaPrevisao> {
  late Future<List<PrevisaoDiaria>> _futurePrevisao;
  late Future<Map<int, TipoTempo>> _futureTiposTempo;

  @override
  void initState() {
    super.initState();
    _futurePrevisao = widget.api.obterPrevisaoDiaria(widget.local.idGlobalLocal);
    _futureTiposTempo = widget.api.obterTiposTempo();
  }

  Future<void> _recarregar() async {
    setState(() {
      _futurePrevisao = widget.api.obterPrevisaoDiaria(widget.local.idGlobalLocal);
      _futureTiposTempo = widget.api.obterTiposTempo();
    });
    await Future.wait([_futurePrevisao, _futureTiposTempo]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Previsão: ${widget.local.nomeLocal}'),
      ),

      body: FutureBuilder<List<PrevisaoDiaria>>(
        future: _futurePrevisao,
        builder: (context, snapPrevisao) {
          if (snapPrevisao.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Erro: ${snapPrevisao.error}'),
            );
          }

          if (!snapPrevisao.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final previsao = snapPrevisao.data!;

          return FutureBuilder<Map<int, TipoTempo>>(
            future: _futureTiposTempo,
            builder: (context, snapTipos) {
              final tipos = snapTipos.data ?? const <int, TipoTempo>{};

              return RefreshIndicator(
                onRefresh: _recarregar,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: previsao.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final dia = previsao[i];
                    final descricao = tipos[dia.idTipoTempo]?.descricaoPt ?? 'Sem informação';

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.cloud),
                        title: Text(dia.dataPrevisao),
                        subtitle: Text(descricao),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Mín: ${dia.tempMin ?? '-'} °C'),
                            Text('Máx: ${dia.tempMax ?? '-'} °C'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
