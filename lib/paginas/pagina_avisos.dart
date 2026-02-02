// =============================================================================
// pagina_avisos.dart — Página de avisos meteorológicos
// =============================================================================
//
// Mostra os avisos meteorológicos do IPMA em vigor no dia actual. Filtra por:
// - Data: apenas avisos em que startTime <= hoje <= endTime (API: startTime/endTime em ISO).
// - Nível: apenas yellow, orange, red (green é informativo e não é mostrado).
// - Área: dropdown permite filtrar por distrito/região (idAreaAviso).
//
// API: https://api.ipma.pt/open-data/forecast/warnings/warnings_www.json
// Campos usados: startTime, endTime, awarenessTypeName, awarenessLevelID, idAreaAviso.
//
// Cada aviso é exibido num card com ícone e cor por tipo (vento, chuva, nevoeiro,
// etc.), área (código e nome) e nível (Amarelo/Laranja/Vermelho).
//
// =============================================================================

import 'package:flutter/material.dart';

import '../ipma/ipma_api.dart';
import '../ipma/modelos.dart';
import '../widgets/menu_drawer.dart';

/// Extrai a data (ano/mês/dia) de uma string ISO da API (ex: "2021-03-25T07:25:00").
DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  final s = value.toString().trim();
  if (s.isEmpty) return null;
  final dt = DateTime.tryParse(s);
  return dt == null ? null : DateTime(dt.year, dt.month, dt.day);
}

/// Verdadeiro se o aviso está em vigor no dia [dia] (startTime <= dia <= endTime).
bool _avisoAtivoNaData(Map<String, dynamic> aviso, DateTime dia) {
  final start = _parseDate(aviso['startTime']);
  final end = _parseDate(aviso['endTime']);
  if (start == null || end == null) return false;
  final diaOnly = DateTime(dia.year, dia.month, dia.day);
  return !diaOnly.isBefore(start) && !diaOnly.isAfter(end);
}

/// Verdadeiro se o aviso é um aviso “real” (amarelo, laranja ou vermelho). Green = informativo, não mostrar.
bool _avisoComNivelAtivo(Map<String, dynamic> aviso) {
  final level = (aviso['awarenessLevelID'] ?? aviso['awarenessLevel'] ?? 'green').toString().toLowerCase();
  return level == 'yellow' || level == 'orange' || level == 'red';
}

/// Página de avisos meteorológicos (rota "/avisos"). Recebe [api] para pedir
/// os dados. Mostra apenas avisos ativos hoje, com nível yellow/orange/red,
/// e permite filtrar por área via dropdown.
class PaginaAvisos extends StatefulWidget {
  static const String nomeRota = '/avisos';

  final IpmaApi api;

  const PaginaAvisos({super.key, required this.api});

  @override
  State<PaginaAvisos> createState() => _PaginaAvisosState();
}

class _PaginaAvisosState extends State<PaginaAvisos> {
  late Future<RespostaAvisosIpma> _futureAvisos;
  /// null = Todas as áreas; caso contrário código da área (ex: EVR, LSB).
  String? _areaSelecionada;

  @override
  void initState() {
    super.initState();
    _futureAvisos = widget.api.obterAvisos();
  }

  Future<void> _recarregar() async {
    setState(() {
      _futureAvisos = widget.api.obterAvisos();
    });
    await _futureAvisos;
  }

  /// Códigos de área IPMA (distritos/regiões) → nome legível.
  static const Map<String, String> _nomesArea = {
    'AVR': 'Aveiro', 'BJA': 'Beja', 'BRG': 'Braga', 'BGC': 'Bragança',
    'CBO': 'Castelo Branco', 'CBR': 'Coimbra', 'EVR': 'Évora', 'FAR': 'Faro',
    'GDA': 'Guarda', 'LRA': 'Leiria', 'LSB': 'Lisboa', 'PTG': 'Portalegre',
    'PTO': 'Porto', 'STM': 'Santarém', 'STB': 'Setúbal', 'VCT': 'Viana do Castelo',
    'VRL': 'Vila Real', 'VIS': 'Viseu',
    'MCN': 'Madeira Norte', 'MRM': 'Madeira Sul', 'MCS': 'Porto Santo', 'MPS': 'Selvagens',
    'AOC': 'Açores Ocidental', 'ACE': 'Açores Central', 'AOR': 'Açores Oriental',
  };

  /// Opções do dropdown de áreas (código → "Código (Nome)").
  static List<DropdownMenuItem<String>> get _nomesAreaEntradas => _nomesArea.entries
      .map((e) => DropdownMenuItem<String>(
            value: e.key,
            child: Text('${e.key} (${e.value})'),
          ))
      .toList();

  /// Ícone e cor consoante o tipo de aviso (Nível).
  static (IconData icon, Color color) _iconeECorParaNivel(String nivel) {
    final n = nivel.toLowerCase();
    if (n.contains('marítim') || n.contains('agitação') || n.contains('mar')) {
      return (Icons.waves, const Color(0xFF1565C0)); // azul
    }
    if (n.contains('nevoeiro') || n.contains('fog')) {
      return (Icons.foggy, const Color(0xFF78909C)); // cinza
    }
    if (n.contains('quente') || n.contains('calor') || n.contains('heat')) {
      return (Icons.wb_sunny, const Color(0xFFE65100)); // laranja
    }
    if (n.contains('frio') || n.contains('cold') || n.contains('neve')) {
      return (Icons.ac_unit, const Color(0xFF0277BD)); // azul frio
    }
    if (n.contains('precipitação') || n.contains('chuva') || n.contains('rain')) {
      return (Icons.water_drop, const Color(0xFF00838F)); // teal
    }
    if (n.contains('neve') || n.contains('snow')) {
      return (Icons.cloud, const Color(0xFF4FC3F7)); // azul claro
    }
    if (n.contains('trovoada') || n.contains('thunder') || n.contains('raio')) {
      return (Icons.flash_on, const Color(0xFFF9A825)); // amarelo
    }
    if (n.contains('vento') || n.contains('wind')) {
      return (Icons.air, const Color(0xFF455A64)); // cinza azulado
    }
    return (Icons.warning_amber_rounded, const Color(0xFFBF360C)); // laranja aviso
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avisos (IPMA)'),
        elevation: 0,
      ),
      drawer: MenuDrawer(rotaAtual: PaginaAvisos.nomeRota),

      body: FutureBuilder<RespostaAvisosIpma>(
        future: _futureAvisos,
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

          final todosAvisos = snapshot.data!.data as List<dynamic>;
          final hoje = DateTime.now();
          final avisos = todosAvisos
              .where((a) {
                final m = a as Map<String, dynamic>;
                return _avisoAtivoNaData(m, hoje) && _avisoComNivelAtivo(m);
              })
              .toList();

          // Filtrar por área selecionada (null = todas).
          final avisosFiltrados = _areaSelecionada == null || _areaSelecionada!.isEmpty
              ? avisos
              : avisos
                  .where((a) {
                    final codigo = ((a as Map<String, dynamic>)['idAreaAviso'] ?? a['areaId'] ?? '').toString().trim().toUpperCase();
                    return codigo == _areaSelecionada!.toUpperCase();
                  })
                  .toList();

          if (avisos.isEmpty) {
            return RefreshIndicator(
              onRefresh: _recarregar,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
                      const SizedBox(height: 16),
                      Text(
                        'Sem avisos ativos para hoje',
                        style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Não há avisos meteorológicos em vigor para o dia de hoje.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _recarregar,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                // Explicação para quem não conhece a página
                Card(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.today, color: theme.colorScheme.primary, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              'Avisos ativos para hoje',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Mostra apenas avisos em vigor hoje (amarelo, laranja ou vermelho). O nível «green» não é mostrado (é informativo). Cada linha é um tipo de aviso (vento, chuva, frio, etc.) ativo numa região (distrito).',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Em cada cartão: título = tipo de aviso; Área = distrito (código e nome); Nível = amarelo/laranja/vermelho.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Select da área
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<String>(
                    value: _areaSelecionada,
                    decoration: InputDecoration(
                      labelText: 'Filtrar por área',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.location_on_outlined),
                    ),
                    hint: const Text('Todas as áreas'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Todas as áreas'),
                      ),
                      ..._nomesAreaEntradas,
                    ],
                    onChanged: (String? value) {
                      setState(() => _areaSelecionada = value);
                    },
                  ),
                ),
                if (avisosFiltrados.isEmpty && avisos.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Nenhum aviso para a área selecionada.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  )
                else
                  ...List.generate(avisosFiltrados.length, (i) {
                  final aviso = avisosFiltrados[i] as Map<String, dynamic>;

                final areaCodigo = (aviso['idAreaAviso'] ?? aviso['areaId'] ?? '').toString().trim();
                final areaNome = areaCodigo.isEmpty ? '—' : (_nomesArea[areaCodigo.toUpperCase()] ?? areaCodigo);
                final areaStr = areaCodigo.isEmpty ? '—' : '$areaCodigo ($areaNome)';

                final nivel = (aviso['awarenessTypeName'] ??
                        aviso['awarenessLevel'] ??
                        aviso['level'] ??
                        '—')
                    .toString();
                final fenomeno = (aviso['phenomenonTypeName'] ??
                        aviso['phenomenon'] ??
                        aviso['type'] ??
                        '')
                    .toString()
                    .trim();
                final temFenomeno = fenomeno.isNotEmpty && fenomeno != '—';

                final (icon, color) = _iconeECorParaNivel(nivel);
                final levelId = (aviso['awarenessLevelID'] ?? aviso['awarenessLevel'] ?? 'yellow').toString().toLowerCase();
                final (levelLabel, levelColor) = levelId == 'red'
                    ? ('Vermelho', Colors.red)
                    : levelId == 'orange'
                        ? ('Laranja', Colors.orange)
                        : ('Amarelo', Colors.amber);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      elevation: 1,
                      shadowColor: Colors.black26,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border(
                              left: BorderSide(color: color, width: 4),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(icon, color: color, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            nivel,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: levelColor.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            levelLabel,
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: levelColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on_outlined, size: 14, color: theme.colorScheme.outline),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Área: $areaStr',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (temFenomeno) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        fenomeno,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.outline,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
