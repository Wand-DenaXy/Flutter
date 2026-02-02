// =============================================================================
// menu_drawer.dart — Menu lateral (Drawer) de navegação
// =============================================================================
//
// Widget partilhado pelas páginas Locais, Avisos e Sobre. Permite navegar
// entre elas sem empilhar ecrãs: usa pushReplacementNamed para substituir
// a rota actual pela seleccionada.
//
// Uso: cada página inclui o Drawer no Scaffold e passa [rotaAtual] com o
// nome da rota dessa página, para que o item correspondente fique destacado.
//
// =============================================================================

import 'package:flutter/material.dart';

import '../paginas/pagina_locais.dart';
import '../paginas/pagina_avisos.dart';
import '../paginas/pagina_sobre.dart';
import '../paginas/pagina_inovacao.dart';

/// Menu lateral (Drawer) com três opções: Locais, Avisos, Sobre.
/// [rotaAtual] deve ser o nome da rota da página que está a ser exibida
/// (ex.: PaginaLocais.nomeRota), para marcar o item seleccionado.
class MenuDrawer extends StatelessWidget {
  final String rotaAtual;

  const MenuDrawer({
    super.key,
    required this.rotaAtual,
  });

  /// Fecha o drawer e navega para a rota indicada, substituindo a rota actual.
  void _navegarPara(BuildContext context, String rota) {
    Navigator.pop(context);
    if (rota == rotaAtual) return;
    Navigator.pushReplacementNamed(context, rota);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.cloud,
                  size: 48,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 8),
                Text(
                  'IPMA Tempo',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Previsão e avisos',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Locais'),
            subtitle: const Text('Distritos e previsão'),
            selected: rotaAtual == PaginaLocais.nomeRota,
            onTap: () => _navegarPara(context, PaginaLocais.nomeRota),
          ),
          ListTile(
            leading: const Icon(Icons.warning_amber_outlined),
            title: const Text('Avisos'),
            subtitle: const Text('Avisos meteorológicos'),
            selected: rotaAtual == PaginaAvisos.nomeRota,
            onTap: () => _navegarPara(context, PaginaAvisos.nomeRota),
          ),
          ListTile(
            leading: const Icon(Icons.warning_amber_outlined),
            title: const Text('Inovação'),
            subtitle: const Text('Acerca da inovação'),
            selected: rotaAtual == PaginaInovocao.nomeRota,
            onTap: () => _navegarPara(context, PaginaInovocao.nomeRota),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Sobre'),
            subtitle: const Text('Acerca da aplicação'),
            selected: rotaAtual == PaginaSobre.nomeRota,
            onTap: () => _navegarPara(context, PaginaSobre.nomeRota),
          ),
        ],
      ),
    );
  }
}
