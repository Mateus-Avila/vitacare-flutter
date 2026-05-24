import 'package:flutter/material.dart';
import 'package:vitacare_flutter/core/vitacare_feedback.dart';
import 'package:vitacare_flutter/core/vitacare_routes.dart';
import 'package:vitacare_flutter/models/cep_address.dart';
import 'package:vitacare_flutter/services/api_service.dart';
import 'package:vitacare_flutter/theme/vitacare_colors.dart';
import 'package:vitacare_flutter/theme/vitacare_input_decoration.dart';
import 'package:vitacare_flutter/widgets/vitacare_glass_card.dart';
import 'package:vitacare_flutter/widgets/vitacare_page_scaffold.dart';
import 'package:vitacare_flutter/widgets/vitacare_primary_button.dart';

class CepLookupScreen extends StatefulWidget {
  const CepLookupScreen({super.key});

  @override
  State<CepLookupScreen> createState() => _CepLookupScreenState();
}

class _CepLookupScreenState extends State<CepLookupScreen> {
  final TextEditingController _cepController = TextEditingController();
  final ApiService _apiService = ApiService();

  CepAddress? _address;
  bool _isLoading = false;

  @override
  void dispose() {
    _cepController.dispose();
    super.dispose();
  }

  Future<void> _searchCep() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _address = null;
    });

    try {
      final address = await _apiService.fetchCep(_cepController.text);
      if (!mounted) {
        return;
      }
      setState(() => _address = address);
      showVitacareSnackBar(context, 'CEP consultado com sucesso via ViaCEP.');
    } catch (error) {
      if (!mounted) {
        return;
      }
      showVitacareSnackBar(
        context,
        error is ArgumentError || error is StateError
            ? error.toString().replaceFirst('Invalid argument(s): ', '')
            : 'Nao foi possivel consultar o CEP.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VitacarePageScaffold(
      title: 'Consulta CEP',
      subtitle:
          'Consumo de API REST publica ViaCEP com loading, erro e resultado para demonstracao do RF007.',
      selectedRoute: VitacareRoutes.apiCep,
      actions: [
        IconButton(
          tooltip: 'Ir para pesquisa',
          onPressed: () =>
              Navigator.pushReplacementNamed(context, VitacareRoutes.search),
          icon: const Icon(Icons.search_rounded),
        ),
      ],
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: VitacareGlassCard(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _cepController,
                      keyboardType: TextInputType.number,
                      decoration: vitacareInputDecoration(
                        label: 'CEP',
                        hint: 'Ex: 14010000',
                        icon: Icons.location_on_outlined,
                      ),
                      onFieldSubmitted: (_) => _searchCep(),
                    ),
                    const SizedBox(height: 14),
                    VitacarePrimaryButton(
                      onPressed: _searchCep,
                      label: _isLoading ? 'Consultando...' : 'Consultar CEP',
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 18),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: _address == null
                          ? const _ApiEmptyState()
                          : _AddressResult(address: _address!),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ApiEmptyState extends StatelessWidget {
  const _ApiEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('empty-api-state'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: VitacareColors.surfaceTint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: VitacareColors.border),
      ),
      child: const Text(
        'Digite um CEP para consultar logradouro, bairro, cidade, UF, IBGE e DDD retornados pela API publica ViaCEP.',
        style: TextStyle(color: VitacareColors.textSoft, height: 1.45),
      ),
    );
  }
}

class _AddressResult extends StatelessWidget {
  const _AddressResult({required this.address});

  final CepAddress address;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(address.cep),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: VitacareColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${address.city} - ${address.state}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: VitacareColors.textStrong,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _ResultLine(label: 'CEP', value: address.cep),
          _ResultLine(label: 'Logradouro', value: address.street),
          _ResultLine(label: 'Bairro', value: address.neighborhood),
          _ResultLine(label: 'IBGE', value: address.ibge),
          _ResultLine(label: 'DDD', value: address.ddd),
        ],
      ),
    );
  }
}

class _ResultLine extends StatelessWidget {
  const _ResultLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$label: ${value.isEmpty ? 'Nao informado' : value}',
        style: const TextStyle(color: VitacareColors.textSoft, height: 1.45),
      ),
    );
  }
}
