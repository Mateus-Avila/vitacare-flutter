import 'package:flutter/material.dart';
import 'package:vitacare_flutter/core/vitacare_routes.dart';
import 'package:vitacare_flutter/theme/vitacare_colors.dart';
import 'package:vitacare_flutter/widgets/vitacare_glass_card.dart';
import 'package:vitacare_flutter/widgets/vitacare_page_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VitacarePageScaffold(
      title: 'Sobre o VitaCare',
      subtitle:
          'Resumo institucional do projeto academico, seu contexto de uso e o escopo desta demonstracao.',
      selectedRoute: VitacareRoutes.about,
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: VitacareGlassCard(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VitaCare',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: VitacareColors.textStrong,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Portal responsivo com foco em acompanhamento continuo, documentacao dos cuidados e coordenacao entre equipe de saude, cuidadores e familiares.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: VitacareColors.textSoft,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _AboutSection(
                      title: 'Problema atendido pelo projeto',
                      content:
                          'Pacientes cronicos, especialmente idosos, costumam registrar dados em papel, esquecer medicacoes e gerar poucas informacoes entre consultas. O VitaCare surge para centralizar registros, reduzir falhas de acompanhamento e melhorar a comunicacao entre cuidadores e equipe clinica.',
                    ),
                    const SizedBox(height: 18),
                    _AboutSection(
                      title: 'Publico-alvo',
                      content:
                          'Clinicas, servicos de enfermagem, enfermeiros autonomos, agencias de cuidadores, profissionais de saude e cuidadores que acompanham pacientes idosos ou com doencas cronicas como diabetes, hipertensao e DPOC.',
                    ),
                    const SizedBox(height: 18),
                    _AboutSection(
                      title: 'Funcionalidades demonstradas nesta etapa',
                      content:
                          'O aplicativo apresenta login, cadastro, recuperacao de senha e tela sobre, alem de modulos especificos: cadastro de paciente, listagem em tempo real, registro de dados de saude, historico com indicadores, alertas/status, acoes e metas, pesquisa ordenada e consulta CEP por API REST.',
                    ),
                    const SizedBox(height: 18),
                    _AboutSection(
                      title: 'Indicadores clinicos e operacionais',
                      content:
                          'A interface de historico consolida media do periodo, variacao absoluta e percentual, percentual dentro da faixa ideal, taxa de adesao aos registros e tendencia linear simplificada. Com esses indicadores, o projeto classifica o acompanhamento em melhora, estabilidade ou piora.',
                    ),
                    const SizedBox(height: 18),
                    _AboutSection(
                      title: 'Firebase e API REST',
                      content:
                          'A versao atual utiliza Firebase Authentication para acesso, Cloud Firestore para usuarios, pacientes, registros, atividades e metas, sempre filtrando dados por uid. O requisito de API publica e demonstrado pela consulta ViaCEP.',
                    ),
                    const SizedBox(height: 18),
                    _AboutSection(
                      title: 'Informacoes academicas',
                      content:
                          'Disciplina: Programacao Mobile II\nInstituicao: UNAERP - Universidade de Ribeirao Preto\nProfessor: Rodrigo Plotze\nVersao do aplicativo: 0.1',
                    ),
                    const SizedBox(height: 18),
                    _AboutSection(
                      title: 'Equipe',
                      content: 'Mateus Mendonca de Avila\nJoaquim Neto',
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: VitacareColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: VitacareColors.border),
                      ),
                      child: const Text(
                        'Observacao: nesta entrega academica, o app foi preparado para demonstrar autenticacao, CRUD, tempo real, pesquisa, API REST e futura publicacao no Firebase Hosting.',
                        style: TextStyle(
                          color: VitacareColors.textStrong,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                        ),
                      ),
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

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: VitacareColors.primaryStrong,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: const TextStyle(color: VitacareColors.textSoft, height: 1.6),
        ),
      ],
    );
  }
}
