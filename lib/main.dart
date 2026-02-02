// =============================================================================
// main.dart — Ponto de entrada da aplicação IPMA Tempo
// =============================================================================
//
// Responsabilidades:
// - Inicializar a aplicação Flutter (runApp).
// - Definir o widget raiz (App) que configura o MaterialApp: tema, título,
//   rota inicial e rotas nomeadas para Locais, Avisos e Sobre.
// - Instanciar uma única vez o serviço IpmaApi e injectá-lo nas páginas
//   que precisam de dados da API (Locais, Avisos; Previsão recebe via Locais).
//
// Rotas nomeadas:
// - "/"         → PaginaLocais (lista de distritos/ilhas, pesquisa, acesso à previsão).
// - "/avisos"   → PaginaAvisos (avisos meteorológicos ativos hoje, filtro por área).
// - "/sobre"    → PaginaSobre (informação da app e da fonte de dados).
//
// =============================================================================

import 'package:flutter/material.dart';

import 'ipma/ipma_api.dart';
import 'paginas/pagina_locais.dart';
import 'paginas/pagina_avisos.dart';
import 'paginas/pagina_sobre.dart';
import 'paginas/pagina_inovacao.dart';

void main() {
  runApp(const App());
}

/// Widget raiz: configura o [MaterialApp] com tema Material 3, rota inicial
/// e mapa de rotas nomeadas. A instância de [IpmaApi] é criada em [initState]
/// e passada às rotas que precisam de dados da API.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final IpmaApi api;

  @override
  void initState() {
    super.initState();
    api = IpmaApi();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IPMA Tempo',
      theme: ThemeData(useMaterial3: true),
      initialRoute: PaginaLocais.nomeRota,
      routes: {
        PaginaInovocao.nomeRota: (_) => PaginaInovocao(api: api),
        PaginaLocais.nomeRota: (_) => PaginaLocais(api: api),
        PaginaAvisos.nomeRota: (_) => PaginaAvisos(api: api),
        PaginaSobre.nomeRota: (_) => const PaginaSobre(),
        
      },
    );
  }
}
