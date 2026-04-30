import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
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
    PlatformFile? pickedFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 32, // Padding extra para evitar cortes
                left: 28,
                right: 28,
                top: 12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    'Nueva Tarea', 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título de la Tarea',
                      prefixIcon: Icon(Icons.title_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Instrucciones / Descripción',
                      alignLabelWithHint: true,
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: Icon(Icons.description_outlined, size: 20),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  
                  // Sección de Archivo Adjunto
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.attach_file_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            const Text(
                              'Documento adjunto (opcional)',
                              style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 13),
                            ),
                            const Spacer(),
                            if (pickedFile == null)
                              TextButton(
                                onPressed: () async {
                                  final result = await FilePicker.platform.pickFiles();
                                  if (result != null) {
                                    setModalState(() => pickedFile = result.files.first);
                                  }
                                },
                                child: const Text('Seleccionar'),
                              )
                            else
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18, color: Colors.red),
                                onPressed: () => setModalState(() => pickedFile = null),
                              ),
                          ],
                        ),
                        if (pickedFile != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.insert_drive_file_outlined, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    pickedFile!.name,
                                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${(pickedFile!.size / 1024).toStringAsFixed(1)} KB',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: maxScoreController,
                          decoration: const InputDecoration(
                            labelText: 'Nota Máxima',
                            prefixIcon: Icon(Icons.score_outlined, size: 20),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
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
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 18, color: Colors.black54),
                                const SizedBox(width: 10),
                                Text(
                                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (titleController.text.isEmpty) return;
                            setModalState(() => _isLoading = true);
                            try {
                              String? uploadedUrl;
                              
                              if (pickedFile != null) {
                                final client = ref.read(supabaseClientProvider);
                                final fileName = pickedFile!.name.replaceAll(' ', '_');
                                // Estructura: {id_asignatura}/tareas/{nombre_archivo}
                                final path = '${widget.subjectId}/tareas/${DateTime.now().millisecondsSinceEpoch}_$fileName';
                                
                                if (pickedFile!.bytes != null) {
                                  await client.storage.from('classnexus_material').uploadBinary(path, pickedFile!.bytes!);
                                } else if (pickedFile!.path != null) {
                                  final file = File(pickedFile!.path!);
                                  await client.storage.from('classnexus_material').upload(path, file);
                                }
                                
                                uploadedUrl = client.storage.from('classnexus_material').getPublicUrl(path);
                              }

                              await ref.read(assignmentsNotifierProvider).createAssignment(
                                    subjectId: widget.subjectId,
                                    title: titleController.text,
                                    description: descriptionController.text,
                                    dueDate: selectedDate,
                                    maxScore: double.tryParse(maxScoreController.text) ?? 10.0,
                                    fileUrl: uploadedUrl,
                                  );

                              if (context.mounted) {
                                Navigator.pop(context);
                                ref.invalidate(assignmentsProvider(widget.subjectId));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Tarea creada con éxito'),
                                    backgroundColor: Colors.green,
                                  ),
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
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                      : const Text('Crear Tarea', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              left: 28,
              right: 28,
              top: 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(existing != null ? 'Actualizar Entrega' : 'Entregar Tarea', 
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                const SizedBox(height: 24),
                
                // Selector de Archivo de Entrega
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.upload_file_rounded, size: 18, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            'Archivo de la entrega',
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue, fontSize: 13),
                          ),
                          const Spacer(),
                          if (selectedFile == null)
                            TextButton(
                              onPressed: () async {
                                final result = await FilePicker.platform.pickFiles();
                                if (result != null) {
                                  setModalState(() => selectedFile = result.files.first);
                                }
                              },
                              child: const Text('Adjuntar'),
                            )
                          else
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18, color: Colors.red),
                              onPressed: () => setModalState(() => selectedFile = null),
                            ),
                        ],
                      ),
                      if (selectedFile != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.insert_drive_file_outlined, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  selectedFile!.name,
                                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${(selectedFile!.size / 1024).toStringAsFixed(1)} KB',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: linkController,
                  decoration: const InputDecoration(
                    labelText: 'Link adicional (GitHub, Drive, etc.)',
                    prefixIcon: Icon(Icons.link_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Comentario para el profesor',
                    prefixIcon: Icon(Icons.mode_comment_outlined),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setModalState(() => _isLoading = true);
                          try {
                            String? uploadedUrl;
                            
                            // Subida de archivo de entrega
                            if (selectedFile != null) {
                              final client = ref.read(supabaseClientProvider);
                              final user = ref.read(currentUserProvider);
                              final studentId = user?.id ?? '0';
                              final fileName = selectedFile!.name.replaceAll(' ', '_');
                              
                              // Estructura: {id_asignatura}/entregas/{id_tarea}/{id_alumno}/{archivo}
                              final path = '${widget.subjectId}/entregas/$assignmentId/$studentId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
                              
                              if (selectedFile!.bytes != null) {
                                await client.storage.from('classnexus_material').uploadBinary(path, selectedFile!.bytes!);
                              } else if (selectedFile!.path != null) {
                                final file = File(selectedFile!.path!);
                                await client.storage.from('classnexus_material').upload(path, file);
                              }
                              
                              uploadedUrl = client.storage.from('classnexus_material').getPublicUrl(path);
                            }

                            await ref.read(submissionsNotifierProvider).createSubmission(
                              assignmentId: assignmentId, 
                              fileUrl: uploadedUrl,
                              linkUrl: linkController.text.isEmpty ? null : linkController.text,
                              studentComment: commentController.text.isEmpty ? null : commentController.text,
                            );

                            if (context.mounted) {
                              Navigator.pop(context);
                              ref.invalidate(assignmentsProvider(widget.subjectId));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(existing != null ? 'Entrega actualizada' : 'Tarea entregada correctamente'),
                                  backgroundColor: Colors.green,
                                ),
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
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(existing != null ? 'Actualizar Entrega' : 'Enviar Entrega', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
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
                  onTap: () async {
                    if (widget.isTeacher) {
                      await context.push(
                        '/subjects/${widget.subjectId}/submissions/${task.id}',
                        extra: task,
                      );
                      // Refrescamos al volver para ver si hay cambios
                      if (context.mounted) {
                        ref.invalidate(assignmentsProvider(widget.subjectId));
                      }
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
                      if (task.fileUrl != null) ...[
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => launchUrl(Uri.parse(task.fileUrl!)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.description_outlined, size: 16, color: AppColors.primary),
                                SizedBox(width: 8),
                                Text(
                                  'Ver documento adjunto',
                                  style: TextStyle(
                                    fontSize: 12, 
                                    fontWeight: FontWeight.bold, 
                                    color: AppColors.primary
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                          else if (hasSubmitted && task.submissions!.first.score != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Nota: ${task.submissions!.first.score} / ${task.maxScore}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
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
