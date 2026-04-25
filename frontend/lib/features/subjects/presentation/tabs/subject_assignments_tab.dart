import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/features/subjects/models/submission_data.dart';
import 'package:frontend/features/subjects/providers/assignments_provider.dart';
import 'package:frontend/features/subjects/providers/submissions_provider.dart';
import 'package:frontend/features/subjects/presentation/assignment_submissions_screen.dart';
import 'package:frontend/features/subjects/models/assignment_data.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/nexus_card.dart';

class SubjectAssignmentsTab extends ConsumerStatefulWidget {
  final int subjectId;
  final bool isTeacher;

  const SubjectAssignmentsTab({
    super.key, 
    required this.subjectId, 
    required this.isTeacher
  });

  @override
  ConsumerState<SubjectAssignmentsTab> createState() => _SubjectAssignmentsTabState();
}

class _SubjectAssignmentsTabState extends ConsumerState<SubjectAssignmentsTab> {
  bool _isLoading = false;

  void _showAddAssignmentDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final maxScoreController = TextEditingController(text: '10');
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Nueva Tarea', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Título de la Tarea'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Instrucciones'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: maxScoreController,
                          decoration: const InputDecoration(labelText: 'Nota Máxima'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setModalState(() => selectedDate = picked);
                            }
                          },
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (titleController.text.isEmpty) return;
                            setModalState(() => _isLoading = true);
                            try {
                              await ref.read(assignmentsNotifierProvider).createAssignment(
                                    subjectId: widget.subjectId,
                                    title: titleController.text,
                                    description: descriptionController.text,
                                    dueDate: selectedDate,
                                    maxScore: double.tryParse(maxScoreController.text) ?? 10.0,
                                  );
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Tarea creada con éxito')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            } finally {
                              setModalState(() => _isLoading = false);
                            }
                          },
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('Crear Tarea'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSubmitDialog(BuildContext context, int assignmentId, {SubmissionData? existing}) {
    final linkController = TextEditingController(text: existing?.linkUrl);
    final commentController = TextEditingController(text: existing?.studentComment);
    PlatformFile? selectedFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(existing != null ? 'Actualizar Entrega' : 'Entregar Tarea', 
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: linkController,
                  decoration: const InputDecoration(
                    labelText: 'Link de entrega (GitHub, Drive, etc.)',
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Comentario para el profesor',
                    prefixIcon: Icon(Icons.comment_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setModalState(() => _isLoading = true);
                          try {
                            await ref.read(submissionsNotifierProvider).createSubmission(
                              assignmentId: assignmentId, 
                              linkUrl: linkController.text.isEmpty ? null : linkController.text,
                              studentComment: commentController.text.isEmpty ? null : commentController.text,
                            );

                            if (context.mounted) {
                              Navigator.pop(context);
                              ref.invalidate(assignmentsProvider(widget.subjectId));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(existing != null ? 'Entrega actualizada' : 'Tarea entregada correctamente')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error al entregar: $e')),
                              );
                            }
                          } finally {
                            setModalState(() => _isLoading = false);
                          }
                        },
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(existing != null ? 'Actualizar Entrega' : 'Enviar Entrega'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final assignmentsAsync = ref.watch(assignmentsProvider(widget.subjectId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: assignmentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (assignments) {
          if (assignments.isEmpty) {
            return const Center(child: Text('No hay tareas pendientes en esta asignatura.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final task = assignments[index];
              final isOverdue = task.dueDate.isBefore(DateTime.now());
              final hasSubmitted = task.submissions != null && task.submissions!.isNotEmpty;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: NexusCard(
                  onTap: () {
                    if (widget.isTeacher) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssignmentSubmissionsScreen(assignment: task),
                        ),
                      );
                    } else {
                      context.push('/subjects/${widget.subjectId}/tasks/${task.id}', extra: task);
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: hasSubmitted 
                                ? Colors.green.withOpacity(0.1) 
                                : (isOverdue ? Colors.red.withOpacity(0.1) : AppColors.primary.withOpacity(0.1)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              hasSubmitted ? 'ENTREGADA' : (isOverdue ? 'FINALIZADA' : 'PENDIENTE'),
                              style: TextStyle(
                                fontSize: 11, 
                                fontWeight: FontWeight.bold,
                                color: hasSubmitted 
                                  ? Colors.green 
                                  : (isOverdue ? Colors.red : AppColors.primary)
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Fecha límite: ${task.dueDate.day.toString().padLeft(2, '0')}/${task.dueDate.month.toString().padLeft(2, '0')}/${task.dueDate.year}',
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        task.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Nota Máx: ${task.maxScore}',
                            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                          if (widget.isTeacher)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                children: [
                                  const Icon(Icons.people_outline, size: 14, color: Colors.black54),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${task.submissionsCount ?? 0} entregas',
                                    style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.chevron_right, size: 14, color: Colors.black54),
                                ],
                              ),
                            )
                          else
                            const Text(
                              'Abrir tarea',
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                        ],
                      ),
                      if (!widget.isTeacher && hasSubmitted && task.submissions!.first.feedback != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Feedback del Profesor:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                              Text(task.submissions!.first.feedback!),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: widget.isTeacher
          ? FloatingActionButton.extended(
              onPressed: () => _showAddAssignmentDialog(context),
              icon: const Icon(Icons.assignment_add),
              label: const Text('Nueva Tarea'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }
}
