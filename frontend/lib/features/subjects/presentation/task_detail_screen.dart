import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/widgets/nexus_card.dart';
import 'package:frontend/core/widgets/responsive_layout.dart';
import 'package:frontend/features/subjects/models/assignment_data.dart';
import 'package:frontend/features/subjects/providers/assignments_provider.dart';
import 'package:frontend/features/subjects/providers/submissions_provider.dart';
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

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(submissionsNotifierProvider).createSubmission(
            assignmentId: widget.assignment.id,
            linkUrl: _linkController.text.isEmpty ? null : _linkController.text,
            studentComment: _commentController.text.isEmpty ? null : _commentController.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entrega realizada correctamente')),
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
    final submission = widget.assignment.submissions?.firstOrNull;

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
            onTap: () {},
            child: Row(
              children: [
                const Icon(Icons.file_present, color: Colors.blue),
                const SizedBox(width: 12),
                const Expanded(child: Text('Enunciado de la tarea.pdf')),
                Icon(Icons.download, color: Colors.grey.shade400),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmissionSection(BuildContext context, bool hasSubmitted, bool isOverdue, dynamic submission) {
    if (hasSubmitted && submission?.score != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                const Text('Puntuación final'),
                if (submission.feedback != null) ...[
                  const Divider(height: 32),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Feedback del profesor:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  Align(alignment: Alignment.centerLeft, child: Text(submission.feedback!)),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(hasSubmitted ? 'Tu entrega' : 'Realizar entrega', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        NexusCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _linkController,
                enabled: !hasSubmitted || (hasSubmitted && !isOverdue),
                decoration: const InputDecoration(
                  labelText: 'URL de entrega (GitHub/Drive)',
                  prefixIcon: Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                enabled: !hasSubmitted || (hasSubmitted && !isOverdue),
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Comentario (opcional)',
                  prefixIcon: Icon(Icons.comment_outlined),
                ),
              ),
              const SizedBox(height: 24),
              if (!hasSubmitted || !isOverdue)
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
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
                        Text('Entregado el ${DateFormat('dd/MM/yyyy').format(DateTime.now())}', style: const TextStyle(color: Colors.green)),
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
