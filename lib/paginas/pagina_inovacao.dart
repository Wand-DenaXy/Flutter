// =============================================================================
// pagina_locais.dart — Página da lista de locais (distritos/ilhas)
// =============================================================================
//
// Primeira página da aplicação (rota "/"). Mostra a lista de locais obtida
// da API do IPMA, com caixa de pesquisa para filtrar por nome. Cada item
// da lista permite navegar para a página de previsão diária desse local.
//
// Comportamento:
// - FutureBuilder usa um Future guardado em estado para não repetir o pedido
//   HTTP em cada rebuild.
// - RefreshIndicator permite recarregar a lista (pull-to-refresh).
// - AlwaysScrollableScrollPhysics garante que o pull-to-refresh funciona
//   mesmo quando a lista tem poucos itens.
//
// =============================================================================

import 'package:flutter/material.dart';

import '../ipma/ipma_api.dart';
import '../ipma/modelos.dart';
import '../widgets/menu_drawer.dart';


/// Página que lista os locais (distritos/ilhas) e permite pesquisar e
/// abrir a previsão de um local. Recebe [api] para pedir os dados.
class PaginaInovocao extends StatefulWidget {
  static const String nomeRota = '/inovacao';

  final IpmaApi api;

  const PaginaInovocao({super.key, required this.api});

  @override
  State<PaginaInovocao> createState() => _PaginaInovocaoState();
}

class _PaginaInovocaoState extends State<PaginaInovocao> {
  late Future<List<InovacaoIpma>> _futureLocais;
  String _pesquisa = '';

  @override
  void initState() {
    super.initState();
    _futureLocais = widget.api.obterInovacao();
  }

  Future<void> _recarregar() async {
    setState(() {
      _futureLocais = widget.api.obterInovacao();
    });
    await _futureLocais;
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Inovação (IPMA)'),
    ),
    drawer: MenuDrawer(rotaAtual: PaginaInovocao.nomeRota),

    body: FutureBuilder<List<InovacaoIpma>>(
      future: _futureLocais,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Erro: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final locais = snapshot.data!;
        final listaFiltrada = _pesquisa.trim().isEmpty
            ? locais
            : locais
                .where(
                  (l) => l.nomeLocal.toLowerCase().contains(_pesquisa.toLowerCase()),
                )
                .toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Pesquisar local (ex.: Lisboa, Porto, Faro)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (texto) {
                  setState(() => _pesquisa = texto);
                },
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _recarregar,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: listaFiltrada.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final local = listaFiltrada[i];

                    return ListTile(
                      title: Text(local.nomeLocal), // aqui
                      subtitle: Text('globalIdLocal: ${local.time}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // podes adicionar ação aqui se necessário
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
}