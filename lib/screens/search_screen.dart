import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitacare_flutter/core/firestore_serialization.dart';
import 'package:vitacare_flutter/core/vitacare_formatters.dart';
import 'package:vitacare_flutter/core/vitacare_routes.dart';
import 'package:vitacare_flutter/models/patient.dart';
import 'package:vitacare_flutter/providers/patient_provider.dart';
import 'package:vitacare_flutter/theme/vitacare_colors.dart';
import 'package:vitacare_flutter/theme/vitacare_input_decoration.dart';
import 'package:vitacare_flutter/widgets/vitacare_glass_card.dart';
import 'package:vitacare_flutter/widgets/vitacare_page_scaffold.dart';

enum SearchSortOption { name, createdAt, status, age }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  SearchSortOption _sortOption = SearchSortOption.name;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PatientProvider>();

    return VitacarePageScaffold(
      title: 'Pesquisa de Dados',
      subtitle:
          'Busque pacientes no Firestore com filtro por uid, texto sem diferenciar maiusculas e ordenacao propria.',
      selectedRoute: VitacareRoutes.search,
      actions: [
        IconButton(
          tooltip: 'Consulta CEP',
          onPressed: () =>
              Navigator.pushReplacementNamed(context, VitacareRoutes.apiCep),
          icon: const Icon(Icons.travel_explore_rounded),
        ),
      ],
      child: VitacareGlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _searchController,
                decoration:
                    vitacareInputDecoration(
                      label: 'Buscar paciente',
                      hint: 'Nome, condicao ou cuidador',
                      icon: Icons.search_rounded,
                    ).copyWith(
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Limpar busca',
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                onChanged: (value) {
                  setState(() => _query = normalizedSearchText(value));
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<SearchSortOption>(
                initialValue: _sortOption,
                decoration: const InputDecoration(
                  labelText: 'Ordenar resultados',
                  prefixIcon: Icon(Icons.sort_rounded),
                ),
                items: const [
                  DropdownMenuItem(
                    value: SearchSortOption.name,
                    child: Text('Ordem alfabetica'),
                  ),
                  DropdownMenuItem(
                    value: SearchSortOption.createdAt,
                    child: Text('Data de cadastro'),
                  ),
                  DropdownMenuItem(
                    value: SearchSortOption.status,
                    child: Text('Status clinico'),
                  ),
                  DropdownMenuItem(
                    value: SearchSortOption.age,
                    child: Text('Idade'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _sortOption = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<List<Patient>>(
                  stream: provider.searchPatients(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Erro ao pesquisar no Firestore.'),
                      );
                    }

                    final patients = _applySearchAndSort(
                      snapshot.data ?? <Patient>[],
                    );

                    if (patients.isEmpty) {
                      return _EmptySearchState(hasQuery: _query.isNotEmpty);
                    }

                    return ListView.builder(
                      itemCount: patients.length,
                      itemBuilder: (context, index) {
                        final patient = patients[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == patients.length - 1 ? 0 : 10,
                          ),
                          child: _SearchResultTile(patient: patient),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Patient> _applySearchAndSort(List<Patient> patients) {
    final filtered = patients.where((patient) {
      if (_query.isEmpty) {
        return true;
      }
      final searchable =
          '${patient.name} ${patient.chronicCondition} ${patient.caregiver}'
              .toLowerCase();
      return searchable.contains(_query);
    }).toList();

    switch (_sortOption) {
      case SearchSortOption.name:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SearchSortOption.createdAt:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SearchSortOption.status:
        filtered.sort((a, b) => a.status.compareTo(b.status));
        break;
      case SearchSortOption.age:
        filtered.sort((a, b) => b.age.compareTo(a.age));
        break;
    }

    return filtered;
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (patient.status) {
      'critico' => Colors.red.shade700,
      'estavel' => Colors.green.shade700,
      _ => Colors.orange.shade800,
    };
    final String label = switch (patient.status) {
      'critico' => 'Critico',
      'estavel' => 'Estavel',
      _ => 'Atencao',
    };

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.pushNamed(
          context,
          VitacareRoutes.recordsHistory,
          arguments: patient.id,
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: VitacareColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: const TextStyle(
                        color: VitacareColors.textStrong,
                        fontWeight: FontWeight.w700,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${patient.age} anos | ${patient.chronicCondition}',
                      style: const TextStyle(color: VitacareColors.textSoft),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cuidador: ${patient.caregiver} | Cadastro: ${VitacareFormatters.date(patient.createdAt)}',
                      style: const TextStyle(color: VitacareColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({required this.hasQuery});

  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.search_off_rounded,
            color: VitacareColors.textSoft,
            size: 48,
          ),
          const SizedBox(height: 10),
          Text(
            hasQuery
                ? 'Nenhum resultado encontrado.'
                : 'Nenhum paciente cadastrado para pesquisar.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: VitacareColors.textStrong,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () => Navigator.pushReplacementNamed(
              context,
              VitacareRoutes.patientRegistration,
            ),
            child: const Text('Cadastrar paciente'),
          ),
        ],
      ),
    );
  }
}
