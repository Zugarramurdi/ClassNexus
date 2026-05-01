import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:frontend/core/widgets/nexus_card.dart';
import 'package:frontend/core/widgets/responsive_layout.dart';
import 'package:frontend/features/subjects/models/assignment_data.dart';
import 'package:frontend/features/subjects/models/submission_data.dart';
import 'package:frontend/features/subjects/providers/assignments_provider.dart';
import 'package:frontend/features/subjects/providers/submissions_provider.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/core/theme/app_colors.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final AssignmentData assignment;

  const TaskDetailScreen({super.key, required this.assignment});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final _linkController = TextEditingController();
  final _commentController = TextEditingController();
  PlatformFile? _selectedFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final submission = widget.assignment.submissions?.firstOrNull;
    if (submission != null) {
      _linkController.text = submission.linkUrl ?? '';
      _commentController.text = submission.studentComment ?? '';
    }
  }

  @override
  void dispose() {
    _linkController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir la URL: $urlString')),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      String? uploadedFileUrl;

      // 1. Subir archivo si existe
      if (_selectedFile != null) {
        final client = ref.read(supabaseClientProvider);
        final user = ref.read(currentUserProvider);
        final studentId = user?.id ?? '0';
        final fileName = _selectedFile!.name.replaceAll(' ', '_');
        
        // Estructura: {id_asignatura}/entregas/{id_tarea}/{id_alumno}/{archivo}
        final path = '${widget.assignment.subjectId}/entregas/${widget.assignment.id}/$studentId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
        
        if (_selectedFile!.bytes != null) {
          await client.storage.from('classnexus_material').uploadBinary(path, _selectedFile!.bytes!);
        } else if (_selectedFile!.path != null) {
          final file = File(_selectedFile!.path!);
          await client.storage.from('classnexus_material').upload(path, file);
        }
        
        uploadedFileUrl = client.storage.from('classnexus_material').getPublicUrl(path);
      }

      // 2. Crear/Actualizar entrega
      await ref.read(submissionsNotifierProvider).createSubmission(
            assignmentId: widget.assignment.id,
            fileUrl: uploadedFileUrl, // Usar el nuevo archivo si se subió
            linkUrl: _linkController.text.isEmpty ? null : _linkController.text,
            studentComment: _commentController.text.isEmpty ? null : _commentController.text,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entrega realizada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
        ref.invalidate(assignmentsProvider(widget.assignment.subjectId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSubmitted = widget.assignment.submissions != null && widget.assignment.submissions!.isNotEmpty;
    final isOverdue = widget.assignment.dueDate.isBefore(DateTime.now());
    
    // Priorizamos la entrega que tenga nota para mostrarla en el detalle
    SubmissionData? submission;
    if (widget.assignment.submissions != null && widget.assignment.submissions!.isNotEmpty) {
      submission = widget.assignment.submissions!.firstWhere(
        (s) => s.score != null,
        orElse: () => widget.assignment.submissions!.firstWhere(
          (s) => s.feedback != null,
          orElse: () => widget.assignment.submissions!.first,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Tarea'),
      ),
      body: ResponsiveLayout(
        mobile: _buildContent(context, hasSubmitted, isOverdue, submission, isMobile: true),
        desktop: _buildContent(context, hasSubmitted, isOverdue, submission, isMobile: false),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool hasSubmitted, bool isOverdue, dynamic submission, {required bool isMobile}) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTaskHeader(context, isOverdue, hasSubmitted),
        const SizedBox(height: 32),
        if (isMobile) ...[
          _buildTaskInfo(context),
          const SizedBox(height: 32),
          _buildSubmissionSection(context, hasSubmitted, isOverdue, submission),
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildTaskInfo(context)),
              const SizedBox(width: 40),
              Expanded(flex: 1, child: _buildSubmissionSection(context, hasSubmitted, isOverdue, submission)),
            ],
          ),
      ],
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 24.0 : 40.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: content,
        ),
      ),
    );
  }

  Widget _buildTaskHeader(BuildContext context, bool isOverdue, bool hasSubmitted) {
    final statusColor = hasSubmitted ? Colors.green : (isOverdue ? Colors.red : Theme.of(context).colorScheme.primary);
    final statusText = hasSubmitted ? 'ENTREGADA' : (isOverdue ? 'PLAZO VENCIDO' : 'PENDIENTE');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            statusText,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.assignment.title,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              'Fecha límite: ${DateFormat('dd/MM/yyyy HH:mm').format(widget.assignment.dueDate)}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTaskInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Instrucciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text(widget.assignment.description, style: const TextStyle(fontSize: 16, height: 1.5)),
        if (widget.assignment.fileUrl != null) ...[
          const SizedBox(height: 24),
          const Text('Recursos adjuntos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          NexusCard(
            onTap: () => _launchUrl(widget.assignment.fileUrl!),
            child: Row(
              children: [
                const Icon(Icons.file_present, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.assignment.fileUrl!.split('/').last.split('?').first,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.open_in_new, color: Colors.grey.shade400, size: 20),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmissionSection(BuildContext context, bool hasSubmitted, bool isOverdue, dynamic submission) {
    final canSubmit = !hasSubmitted || (hasSubmitted && !isOverdue);
    final isGraded = hasSubmitted && submission?.score != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isGraded) ...[
          const Text('Calificación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          NexusCard(
            color: Colors.green.withOpacity(0.05),
            child: Column(
              children: [
                Text(
                  '${submission.score} / ${widget.assignment.maxScore}',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const Text('Puntuación final', style: TextStyle(color: Colors.black54, fontSize: 12)),
                if (submission.feedback != null && submission.feedback!.isNotEmpty) ...[
                  const Divider(height: 32),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Feedback del profesor:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft, 
                    child: Text(
                      submission.feedback!,
                      style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],

        Text(hasSubmitted ? 'Tu entrega' : 'Realizar entrega', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        NexusCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Selector de archivo
              if (canSubmit) ...[
                const Text('Archivo de entrega', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _isLoading ? null : _pickFile,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    child: Row(
                      children: [
                        Icon(_selectedFile != null ? Icons.check_circle : Icons.upload_file, 
                             color: _selectedFile != null ? Colors.green : AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedFile?.name ?? 'Seleccionar archivo (PDF, ZIP...)',
                            style: TextStyle(
                              color: _selectedFile != null ? Colors.black87 : Colors.black54,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              if (hasSubmitted && submission?.fileUrl != null && _selectedFile == null) ...[
                const Text('Archivo entregado:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => _launchUrl(submission.fileUrl!),
                  child: Row(
                    children: [
                      const Icon(Icons.description_outlined, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text('Ver mi archivo actual', style: TextStyle(color: AppColors.primary, fontSize: 13, decoration: TextDecoration.underline)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextField(
                controller: _linkController,
                enabled: canSubmit,
                decoration: const InputDecoration(
                  labelText: 'URL de entrega (GitHub/Drive)',
                  prefixIcon: Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                enabled: canSubmit,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Comentario (opcional)',
                  prefixIcon: Icon(Icons.comment_outlined),
                ),
              ),
              const SizedBox(height: 24),
              if (canSubmit)
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(hasSubmitted ? 'Actualizar entrega' : 'Enviar tarea'),
                ),
              if (hasSubmitted)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Entregada',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
