import 'package:flutter/material.dart';
import 'package:vitacare_flutter/theme/vitacare_colors.dart';
import 'package:vitacare_flutter/widgets/vitacare_glass_card.dart';
import 'package:vitacare_flutter/widgets/vitacare_page_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VitacarePageScaffold(
      title: 'Sobre o VitaCare',
      selectedRoute: '/about',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: VitacareGlassCard(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VitaCare',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: VitacareColors.textStrong,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Objetivo do aplicativo',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: VitacareColors.primaryStrong,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Simular o acompanhamento de pacientes crônicos e idosos, '
                      'com registro de dados de saúde, histórico de evolução e alertas '
                      'de prioridade para apoiar profissionais e cuidadores.',
                      style: TextStyle(
                        color: VitacareColors.textSoft,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Integrantes',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: VitacareColors.primaryStrong,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Mateus Mendonça de Ávila\n'
                      'Joaquim Neto',
                      style: TextStyle(
                        color: VitacareColors.textSoft,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Informações acadêmicas',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: VitacareColors.primaryStrong,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Disciplina: Programação Mobile II\n'
                      'Instituição: UNAERP - Universidade de Ribeirão Preto\n'
                      'Professor: Rodrigo Plotze\n'
                      'Versão do aplicativo: 0.1',
                      style: TextStyle(
                        color: VitacareColors.textSoft,
                        height: 1.6,
                      ),
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
                        'Projeto acadêmico sem backend real. Dados e autenticação são simulados para demonstração das interfaces, navegação e uso de ChangeNotifier.',
                        style: TextStyle(
                          color: VitacareColors.textStrong,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
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
