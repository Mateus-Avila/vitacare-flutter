import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitacare_flutter/core/vitacare_feedback.dart';
import 'package:vitacare_flutter/core/vitacare_formatters.dart';
import 'package:vitacare_flutter/core/vitacare_routes.dart';
import 'package:vitacare_flutter/models/care_goal.dart';
import 'package:vitacare_flutter/models/care_task.dart';
import 'package:vitacare_flutter/models/patient.dart';
import 'package:vitacare_flutter/providers/patient_provider.dart';
import 'package:vitacare_flutter/theme/vitacare_colors.dart';
import 'package:vitacare_flutter/theme/vitacare_input_decoration.dart';
import 'package:vitacare_flutter/widgets/vitacare_glass_card.dart';
import 'package:vitacare_flutter/widgets/vitacare_page_scaffold.dart';

class CareManagementScreen extends StatelessWidget {
  const CareManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PatientProvider>();

    return VitacarePageScaffold(
      title: 'Acoes e Metas de Cuidado',
      subtitle:
          'Gerencie atividades e metas no Firestore, com uid e atualizacao em tempo real.',
      selectedRoute: VitacareRoutes.careManagement,
      child: StreamBuilder<List<Patient>>(
        stream: provider.watchPatients(),
        builder: (context, patientSnapshot) {
          if (patientSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (patientSnapshot.hasError) {
            return const Center(child: Text('Erro ao carregar pacientes.'));
          }

          final patients = patientSnapshot.data ?? <Patient>[];
          if (patients.isEmpty) {
            return _NoPatientsState();
          }

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Atividades'),
                    Tab(text: 'Metas'),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    children: [
                      _TaskTab(patients: patients),
                      _GoalTab(patients: patients),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TaskTab extends StatelessWidget {
  const _TaskTab({required this.patients});

  final List<Patient> patients;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PatientProvider>();

    return VitacareGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => _TaskDialog.show(context, patients: patients),
                icon: const Icon(Icons.add_task_rounded),
                label: const Text('Nova atividade'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<CareTask>>(
                stream: provider.watchCareTasks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Erro ao carregar atividades.'),
                    );
                  }

                  final tasks = snapshot.data ?? <CareTask>[];
                  if (tasks.isEmpty) {
                    return _EmptyCollectionState(
                      title: 'Nenhuma atividade cadastrada.',
                      buttonLabel: 'Cadastrar atividade',
                      onPressed: () =>
                          _TaskDialog.show(context, patients: patients),
                    );
                  }

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == tasks.length - 1 ? 0 : 10,
                        ),
                        child: _TaskTile(
                          task: task,
                          onEdit: () => _TaskDialog.show(
                            context,
                            patients: patients,
                            task: task,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalTab extends StatelessWidget {
  const _GoalTab({required this.patients});

  final List<Patient> patients;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PatientProvider>();

    return VitacareGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => _GoalDialog.show(context, patients: patients),
                icon: const Icon(Icons.flag_outlined),
                label: const Text('Nova meta'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<CareGoal>>(
                stream: provider.watchCareGoals(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Erro ao carregar metas.'));
                  }

                  final goals = snapshot.data ?? <CareGoal>[];
                  if (goals.isEmpty) {
                    return _EmptyCollectionState(
                      title: 'Nenhuma meta cadastrada.',
                      buttonLabel: 'Cadastrar meta',
                      onPressed: () =>
                          _GoalDialog.show(context, patients: patients),
                    );
                  }

                  return ListView.builder(
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      final goal = goals[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == goals.length - 1 ? 0 : 10,
                        ),
                        child: _GoalTile(
                          goal: goal,
                          onEdit: () => _GoalDialog.show(
                            context,
                            patients: patients,
                            goal: goal,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task, required this.onEdit});

  final CareTask task;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final color = task.completed
        ? Colors.green.shade700
        : Colors.orange.shade800;

    return _CollectionTile(
      title: task.title,
      subtitle:
          '${task.patientName} | ${task.priority} | ${VitacareFormatters.date(task.dueDate)}',
      detail: task.description,
      chip: task.completed ? 'Concluida' : task.status,
      chipColor: color,
      onEdit: onEdit,
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({required this.goal, required this.onEdit});

  final CareGoal goal;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final color = goal.progress >= 80
        ? Colors.green.shade700
        : goal.progress >= 40
        ? Colors.orange.shade800
        : VitacareColors.primary;

    return _CollectionTile(
      title: goal.title,
      subtitle:
          '${goal.patientName} | ${goal.status} | ate ${VitacareFormatters.date(goal.endDate)}',
      detail: goal.description,
      chip: '${goal.progress}%',
      chipColor: color,
      onEdit: onEdit,
    );
  }
}

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.chip,
    required this.chipColor,
    required this.onEdit,
  });

  final String title;
  final String subtitle;
  final String detail;
  final String chip;
  final Color chipColor;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: VitacareColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: VitacareColors.textStrong,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: VitacareColors.textSoft),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(
                    color: VitacareColors.textSoft,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: chipColor.withValues(alpha: 0.13),
                ),
                child: Text(
                  chip,
                  style: TextStyle(
                    color: chipColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Editar',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskDialog {
  static Future<void> show(
    BuildContext context, {
    required List<Patient> patients,
    CareTask? task,
  }) async {
    final formKey = GlobalKey<FormState>();
    String patientId = task?.patientId ?? patients.first.id;
    final titleController = TextEditingController(text: task?.title ?? '');
    final descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    final dateController = TextEditingController(
      text: _dateInput(
        task?.dueDate ?? DateTime.now().add(const Duration(days: 1)),
      ),
    );
    String priority = task?.priority ?? 'Media';
    String status = task?.status ?? 'Pendente';
    bool completed = task?.completed ?? false;
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> save() async {
              if (!(formKey.currentState?.validate() ?? false)) {
                return;
              }

              final dueDate = _parseDate(dateController.text);
              if (dueDate == null) {
                showVitacareSnackBar(
                  context,
                  'Use a data no formato AAAA-MM-DD.',
                  isError: true,
                );
                return;
              }

              final patient = patients.firstWhere(
                (item) => item.id == patientId,
              );
              setState(() => isSaving = true);
              try {
                if (task == null) {
                  await context.read<PatientProvider>().addCareTask(
                    patientId: patient.id,
                    patientName: patient.name,
                    title: titleController.text,
                    description: descriptionController.text,
                    priority: priority,
                    status: status,
                    dueDate: dueDate,
                    completed: completed,
                  );
                } else {
                  await context.read<PatientProvider>().updateCareTask(
                    task: task,
                    title: titleController.text,
                    description: descriptionController.text,
                    priority: priority,
                    status: status,
                    dueDate: dueDate,
                    completed: completed,
                  );
                }

                if (context.mounted) {
                  Navigator.pop(dialogContext);
                  showVitacareSnackBar(
                    context,
                    task == null
                        ? 'Atividade salva no Firestore.'
                        : 'Atividade atualizada no Firestore.',
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  showVitacareSnackBar(
                    context,
                    'Nao foi possivel salvar a atividade.',
                    isError: true,
                  );
                }
              } finally {
                setState(() => isSaving = false);
              }
            }

            return AlertDialog(
              title: Text(task == null ? 'Nova atividade' : 'Editar atividade'),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _patientDropdown(
                          patients: patients,
                          value: patientId,
                          enabled: task == null,
                          onChanged: (value) =>
                              setState(() => patientId = value!),
                        ),
                        const SizedBox(height: 10),
                        _requiredField(
                          controller: titleController,
                          label: 'Titulo',
                          hint: 'Ex: Conferir medicacao',
                          icon: Icons.task_alt_rounded,
                        ),
                        const SizedBox(height: 10),
                        _requiredField(
                          controller: descriptionController,
                          label: 'Descricao',
                          hint: 'Detalhe a acao de cuidado',
                          icon: Icons.notes_outlined,
                          minLines: 2,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _simpleDropdown(
                                label: 'Prioridade',
                                value: priority,
                                icon: Icons.priority_high_rounded,
                                options: const ['Baixa', 'Media', 'Alta'],
                                onChanged: (value) =>
                                    setState(() => priority = value!),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _simpleDropdown(
                                label: 'Status',
                                value: status,
                                icon: Icons.pending_actions_outlined,
                                options: const [
                                  'Pendente',
                                  'Em andamento',
                                  'Concluida',
                                ],
                                onChanged: (value) =>
                                    setState(() => status = value!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _requiredField(
                          controller: dateController,
                          label: 'Data limite',
                          hint: 'AAAA-MM-DD',
                          icon: Icons.event_outlined,
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: completed,
                          onChanged: (value) => setState(() {
                            completed = value ?? false;
                            status = completed ? 'Concluida' : status;
                          }),
                          title: const Text('Atividade concluida'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: isSaving ? null : save,
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
  }
}

class _GoalDialog {
  static Future<void> show(
    BuildContext context, {
    required List<Patient> patients,
    CareGoal? goal,
  }) async {
    final formKey = GlobalKey<FormState>();
    String patientId = goal?.patientId ?? patients.first.id;
    final titleController = TextEditingController(text: goal?.title ?? '');
    final descriptionController = TextEditingController(
      text: goal?.description ?? '',
    );
    final progressController = TextEditingController(
      text: (goal?.progress ?? 0).toString(),
    );
    final startDateController = TextEditingController(
      text: _dateInput(goal?.startDate ?? DateTime.now()),
    );
    final endDateController = TextEditingController(
      text: _dateInput(
        goal?.endDate ?? DateTime.now().add(const Duration(days: 30)),
      ),
    );
    String status = goal?.status ?? 'Em andamento';
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> save() async {
              if (!(formKey.currentState?.validate() ?? false)) {
                return;
              }

              final progress = int.tryParse(progressController.text.trim());
              final startDate = _parseDate(startDateController.text);
              final endDate = _parseDate(endDateController.text);
              if (progress == null ||
                  progress < 0 ||
                  progress > 100 ||
                  startDate == null ||
                  endDate == null) {
                showVitacareSnackBar(
                  context,
                  'Revise progresso e datas no formato AAAA-MM-DD.',
                  isError: true,
                );
                return;
              }

              final patient = patients.firstWhere(
                (item) => item.id == patientId,
              );
              setState(() => isSaving = true);
              try {
                if (goal == null) {
                  await context.read<PatientProvider>().addCareGoal(
                    patientId: patient.id,
                    patientName: patient.name,
                    title: titleController.text,
                    description: descriptionController.text,
                    progress: progress,
                    startDate: startDate,
                    endDate: endDate,
                    status: status,
                  );
                } else {
                  await context.read<PatientProvider>().updateCareGoal(
                    goal: goal,
                    title: titleController.text,
                    description: descriptionController.text,
                    progress: progress,
                    startDate: startDate,
                    endDate: endDate,
                    status: status,
                  );
                }

                if (context.mounted) {
                  Navigator.pop(dialogContext);
                  showVitacareSnackBar(
                    context,
                    goal == null
                        ? 'Meta salva no Firestore.'
                        : 'Meta atualizada no Firestore.',
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  showVitacareSnackBar(
                    context,
                    'Nao foi possivel salvar a meta.',
                    isError: true,
                  );
                }
              } finally {
                setState(() => isSaving = false);
              }
            }

            return AlertDialog(
              title: Text(goal == null ? 'Nova meta' : 'Editar meta'),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _patientDropdown(
                          patients: patients,
                          value: patientId,
                          enabled: goal == null,
                          onChanged: (value) =>
                              setState(() => patientId = value!),
                        ),
                        const SizedBox(height: 10),
                        _requiredField(
                          controller: titleController,
                          label: 'Titulo',
                          hint: 'Ex: Aumentar adesao alimentar',
                          icon: Icons.flag_outlined,
                        ),
                        const SizedBox(height: 10),
                        _requiredField(
                          controller: descriptionController,
                          label: 'Descricao',
                          hint: 'Detalhe a meta de cuidado',
                          icon: Icons.notes_outlined,
                          minLines: 2,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _requiredField(
                                controller: progressController,
                                label: 'Progresso',
                                hint: '0 a 100',
                                icon: Icons.percent_rounded,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _simpleDropdown(
                                label: 'Status',
                                value: status,
                                icon: Icons.timeline_rounded,
                                options: const [
                                  'Em andamento',
                                  'Pausada',
                                  'Concluida',
                                ],
                                onChanged: (value) =>
                                    setState(() => status = value!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _requiredField(
                          controller: startDateController,
                          label: 'Data inicio',
                          hint: 'AAAA-MM-DD',
                          icon: Icons.event_available_outlined,
                        ),
                        const SizedBox(height: 10),
                        _requiredField(
                          controller: endDateController,
                          label: 'Data fim',
                          hint: 'AAAA-MM-DD',
                          icon: Icons.event_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: isSaving ? null : save,
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
    progressController.dispose();
    startDateController.dispose();
    endDateController.dispose();
  }
}

class _EmptyCollectionState extends StatelessWidget {
  const _EmptyCollectionState({
    required this.title,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.playlist_add_check_rounded,
            color: VitacareColors.textSoft,
            size: 48,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: VitacareColors.textStrong,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(onPressed: onPressed, child: Text(buttonLabel)),
        ],
      ),
    );
  }
}

class _NoPatientsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: VitacareGlassCard(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_add_alt_1_outlined,
                  color: VitacareColors.textSoft,
                  size: 52,
                ),
                const SizedBox(height: 12),
                Text(
                  'Cadastre um paciente antes de criar atividades e metas.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: VitacareColors.textStrong,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    VitacareRoutes.patientRegistration,
                  ),
                  child: const Text('Cadastrar paciente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _patientDropdown({
  required List<Patient> patients,
  required String value,
  required bool enabled,
  required ValueChanged<String?> onChanged,
}) {
  return DropdownButtonFormField<String>(
    initialValue: value,
    isExpanded: true,
    decoration: vitacareInputDecoration(
      label: 'Paciente',
      hint: 'Selecione',
      icon: Icons.person_outline_rounded,
    ),
    items: patients
        .map(
          (patient) => DropdownMenuItem<String>(
            value: patient.id,
            child: Text(
              patient.name,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        )
        .toList(),
    onChanged: enabled ? onChanged : null,
  );
}

Widget _simpleDropdown({
  required String label,
  required String value,
  required IconData icon,
  required List<String> options,
  required ValueChanged<String?> onChanged,
}) {
  return DropdownButtonFormField<String>(
    initialValue: value,
    isExpanded: true,
    decoration: vitacareInputDecoration(label: label, hint: label, icon: icon),
    items: options
        .map(
          (option) => DropdownMenuItem<String>(
            value: option,
            child: Text(option, overflow: TextOverflow.ellipsis),
          ),
        )
        .toList(),
    onChanged: onChanged,
  );
}

Widget _requiredField({
  required TextEditingController controller,
  required String label,
  required String hint,
  required IconData icon,
  int minLines = 1,
  TextInputType? keyboardType,
}) {
  return TextFormField(
    controller: controller,
    minLines: minLines,
    maxLines: minLines > 1 ? minLines + 1 : 1,
    keyboardType: keyboardType,
    decoration: vitacareInputDecoration(label: label, hint: hint, icon: icon),
    validator: (value) =>
        (value ?? '').trim().isEmpty ? 'Campo obrigatorio.' : null,
  );
}

String _dateInput(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

DateTime? _parseDate(String value) {
  final parts = value.trim().split('-');
  if (parts.length != 3) {
    return null;
  }
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) {
    return null;
  }
  return DateTime(year, month, day);
}
