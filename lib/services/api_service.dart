import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vitacare_flutter/models/cep_address.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<CepAddress> fetchCep(String rawCep) async {
    final cep = rawCep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length != 8) {
      throw ArgumentError('Informe um CEP com 8 digitos.');
    }

    try {
      return await _fetchViaCep(cep);
    } catch (_) {
      try {
        return await _fetchBrasilApiCep(cep);
      } catch (_) {
        throw StateError(
          'Nao foi possivel consultar o CEP nas APIs publicas. Verifique sua conexao e tente novamente.',
        );
      }
    }
  }

  Future<CepAddress> _fetchViaCep(String cep) async {
    final uri = Uri.https('viacep.com.br', '/ws/$cep/json/');
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw StateError('Nao foi possivel consultar o CEP agora.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['erro'] == true) {
      throw StateError('CEP nao encontrado na base do ViaCEP.');
    }

    return CepAddress.fromJson(data);
  }

  Future<CepAddress> _fetchBrasilApiCep(String cep) async {
    final uri = Uri.https('brasilapi.com.br', '/api/cep/v1/$cep');
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 8));

    if (response.statusCode == 404) {
      throw StateError('CEP nao encontrado nas APIs publicas.');
    }
    if (response.statusCode != 200) {
      throw StateError('Nao foi possivel consultar o CEP agora.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return CepAddress.fromBrasilApiJson(data);
  }
}
