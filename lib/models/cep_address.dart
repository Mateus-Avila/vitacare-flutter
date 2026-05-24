class CepAddress {
  const CepAddress({
    required this.cep,
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.ibge,
    required this.ddd,
  });

  final String cep;
  final String street;
  final String neighborhood;
  final String city;
  final String state;
  final String ibge;
  final String ddd;

  factory CepAddress.fromJson(Map<String, dynamic> json) {
    return CepAddress(
      cep: json['cep'] as String? ?? '',
      street: json['logradouro'] as String? ?? '',
      neighborhood: json['bairro'] as String? ?? '',
      city: json['localidade'] as String? ?? '',
      state: json['uf'] as String? ?? '',
      ibge: json['ibge'] as String? ?? '',
      ddd: json['ddd'] as String? ?? '',
    );
  }
}
