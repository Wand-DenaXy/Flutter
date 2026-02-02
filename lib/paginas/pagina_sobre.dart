// =============================================================================
// pagina_sobre.dart — Página "Sobre"
// =============================================================================
//
// Página informativa com o nome da aplicação, uma breve descrição e a
// indicação de que os dados são fornecidos pelo IPMA (api.ipma.pt).
// Inclui também a versão da aplicação.
//
// Não utiliza a API; não recebe [IpmaApi].
//
// =============================================================================

import 'package:flutter/material.dart';

import '../widgets/menu_drawer.dart';

/// Página "Sobre" com informação da aplicação e da fonte de dados.
class PaginaSobre extends StatelessWidget {
  static const String nomeRota = '/sobre';

  const PaginaSobre({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre'),
      ),
      drawer: MenuDrawer(rotaAtual: PaginaSobre.nomeRota),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(
            Icons.cloud,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'IPMA Tempo',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Previsão do tempo e avisos meteorológicos em Portugal.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dados',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Os dados são fornecidos pelo Instituto Português do Mar e da Atmosfera (IPMA) através da API pública em api.ipma.pt.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Versão 1.0.0',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
