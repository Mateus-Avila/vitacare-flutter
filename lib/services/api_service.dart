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

    final uri = Uri.https('viacep.com.br', '/ws/$cep/json/');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw StateError('Nao foi possivel consultar o CEP agora.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['erro'] == true) {
      throw StateError('CEP nao encontrado na base do ViaCEP.');
    }

    return CepAddress.fromJson(data);
  }
}
