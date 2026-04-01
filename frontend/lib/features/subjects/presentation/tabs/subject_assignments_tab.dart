import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/submission_data.dart';
import '../../providers/assignments_provider.dart';
import '../../providers/submissions_provider.dart';
import '../assignment_submissions_screen.dart';

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
    final scoreController = TextEditingController(text: '10');
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    PlatformFile? enunciadoFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
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
                  const Text('Nueva Tarea Entregable', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Título de la Tarea'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Instrucciones para los alumnos'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(withData: true);
                      if (result != null) {
                        setModalState(() => enunciadoFile = result.files.first);
                      }
                    },
                    icon: const Icon(Icons.attach_file),
                    label: Text(enunciadoFile?.name ?? 'Adjuntar Enunciado (Opcional)'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: scoreController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Nota Máxima'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                              locale: const Locale('es', 'ES'),
                            );
                            if (picked != null) {
                              setModalState(() => selectedDate = picked);
                            }
                          },
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text("${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}"),
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
                              String? fileUrl;
                              if (enunciadoFile != null) {
                                final fileName = 'subjects/${widget.subjectId}/assignments/enunciado_${DateTime.now().millisecondsSinceEpoch}_${enunciadoFile!.name}';
                                await Supabase.instance.client.storage
                                    .from('classnexus_material')
                                    .uploadBinary(fileName, enunciadoFile!.bytes!);
                                fileUrl = Supabase.instance.client.storage
                                    .from('classnexus_material')
                                    .getPublicUrl(fileName);
                              }

                              await ref.read(assignmentsNotifierProvider).createAssignment(
                                    subjectId: widget.subjectId,
                                    title: titleController.text,
                                    description: descriptionController.text,
                                    dueDate: selectedDate,
                                    maxScore: double.tryParse(scoreController.text) ?? 10.0,
                                    fileUrl: fileUrl,
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
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Publicar Tarea'),
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

  void _showSubmissionDialog(BuildContext context, int assignmentId, [SubmissionData? existing]) {
    PlatformFile? selectedFile;
    final linkController = TextEditingController(text: existing?.linkUrl);
    final commentController = TextEditingController(text: existing?.studentComment);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24, right: 24, top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(existing != null ? 'Editar Entrega' : 'Entregar Tarea', 
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: linkController,
                  decoration: const InputDecoration(
                    labelText: 'Link de entrega (GitHub, Drive, etc.)',
                    hintText: 'https://...',
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
                OutlinedButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(withData: true);
                    if (result != null) {
                      setModalState(() => selectedFile = result.files.first);
                    }
                  },
                  icon: const Icon(Icons.upload_file),
                  label: Text(selectedFile?.name ?? (existing?.fileUrl != null ? 'Reemplazar archivo actual' : 'Subir archivo opcional')),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setModalState(() => _isLoading = true);
                          try {
                            String? fileUrl = existing?.fileUrl;
                            if (selectedFile != null) {
                              final fileName = 'subjects/${widget.subjectId}/submissions/$assignmentId/student_${DateTime.now().millisecondsSinceEpoch}_${selectedFile!.name}';
                              await Supabase.instance.client.storage
                                  .from('classnexus_material')
                                  .uploadBinary(fileName, selectedFile!.bytes!);
                              fileUrl = Supabase.instance.client.storage
                                  .from('classnexus_material')
                                  .getPublicUrl(fileName);
                            }

                            await ref.read(submissionsNotifierProvider).createSubmission(
                              assignmentId: assignmentId, 
                              fileUrl: fileUrl,
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

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('No se pudo abrir $url');
    }
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
            return const Center(
              child: Text('No hay tareas pendientes en esta asignatura.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final task = assignments[index];
              final isOverdue = task.dueDate.isBefore(DateTime.now());
              final hasSubmitted = task.submissions != null && task.submissions!.isNotEmpty;

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: hasSubmitted ? Colors.green.shade200 : (isOverdue ? Colors.red.shade100 : Colors.grey.shade200)),
                ),
                child: InkWell(
                  onTap: widget.isTeacher ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssignmentSubmissionsScreen(assignment: task),
                      ),
                    );
                  } : null,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: hasSubmitted ? Colors.green.shade50 : (isOverdue ? Colors.red.shade50 : Colors.blue.shade50),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                hasSubmitted ? 'ENTREGADA' : (isOverdue ? 'FINALIZADA' : 'PENDIENTE'),
                                style: TextStyle(
                                  fontSize: 11, 
                                  fontWeight: FontWeight.bold,
                                  color: hasSubmitted ? Colors.green.shade700 : (isOverdue ? Colors.red : Colors.blue.shade700)
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
                          style: const TextStyle(color: Colors.black87),
                        ),
                        if (task.fileUrl != null) ...[
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () => _launchUrl(task.fileUrl!),
                            icon: const Icon(Icons.download_for_offline_outlined, size: 20),
                            label: const Text('Descargar Enunciado'),
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Nota Máx: ${task.maxScore}',
                              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue),
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
                            else if (!hasSubmitted)
                              ElevatedButton(
                                onPressed: isOverdue ? null : () => _showSubmissionDialog(context, task.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade600,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Hacer Entrega'),
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (task.submissions != null && task.submissions!.first.score != null)
                                    Text(
                                      'Tu Nota: ${task.submissions!.first.score} / ${task.maxScore}',
                                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                                    )
                                  else
                                    Row(
                                      children: [
                                        const Expanded(
                                          child: Row(
                                            children: [
                                              Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                                              SizedBox(width: 4),
                                              Text('Esperando Calificación', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        if (!widget.isTeacher && !isOverdue)
                                          TextButton.icon(
                                            onPressed: () => _showSubmissionDialog(context, task.id, task.submissions!.first),
                                            icon: const Icon(Icons.edit_outlined, size: 16),
                                            label: const Text('Editar', style: TextStyle(fontSize: 12)),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.blue.shade700,
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                            ),
                                          ),
                                      ],
                                    ),
                                ],
                              ),
                          ],
                        ),
                        if (!widget.isTeacher && hasSubmitted && task.submissions!.first.feedback != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
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
              backgroundColor: Colors.blue.shade600,
            )
          : null,
    );
  }
}
