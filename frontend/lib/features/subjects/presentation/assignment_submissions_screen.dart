import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:frontend/features/subjects/models/assignment_data.dart';
import 'package:frontend/features/subjects/models/submission_data.dart';
import 'package:frontend/features/subjects/providers/submissions_provider.dart';

import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/nexus_card.dart';

class AssignmentSubmissionsScreen extends ConsumerStatefulWidget {
  final AssignmentData assignment;

  const AssignmentSubmissionsScreen({super.key, required this.assignment});

  @override
  ConsumerState<AssignmentSubmissionsScreen> createState() => _AssignmentSubmissionsScreenState();
}

class _AssignmentSubmissionsScreenState extends ConsumerState<AssignmentSubmissionsScreen> {
  
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('No se pudo abrir $url');
    }
  }

  void _showGradeDialog(BuildContext context, SubmissionData submission) {
    final scoreController = TextEditingController(text: (submission.score ?? widget.assignment.maxScore).toString());
    final feedbackController = TextEditingController(text: submission.feedback ?? '');
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Calificar: ${submission.student?['first_name'] ?? 'Alumno'}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: scoreController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Nota (Máx: ${widget.assignment.maxScore})',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: feedbackController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Feedback / Observaciones',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    setModalState(() => isSaving = true);
                    try {
                      await ref.read(submissionsNotifierProvider).gradeSubmission(
                        submission.id,
                        double.parse(scoreController.text),
                        feedbackController.text,
                        widget.assignment.id,
                      );
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    } finally {
                      setModalState(() => isSaving = false);
                    }
                  },
                  child: isSaving 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                    : const Text('Guardar Nota'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final submissionsAsync = ref.watch(submissionsProvider(widget.assignment.id));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.assignment.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Text('Entregas y Calificaciones', style: TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
      body: submissionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (submissions) {
          if (submissions.isEmpty) {
            return const Center(
              child: Text('Aún no hay entregas para esta tarea.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final sub = submissions[index];
              final studentName = "${sub.student?['first_name'] ?? ''} ${sub.student?['last_name'] ?? 'Alumno'}";
              final avatarUrl = sub.student?['avatar_url'];
              final isGraded = sub.score != null;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: NexusCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                            child: avatarUrl == null 
                              ? Text(sub.student?['first_name']?[0] ?? 'A', style: const TextStyle(color: AppColors.primary)) 
                              : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                if (isGraded)
                                  Text('Nota: ${sub.score} / ${widget.assignment.maxScore}', 
                                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                                else
                                  const Text('Pendiente de corregir', style: TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _showGradeDialog(context, sub),
                            icon: Icon(isGraded ? Icons.edit_note : Icons.grade, color: AppColors.primary),
                            tooltip: 'Calificar',
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      if (sub.studentComment != null && sub.studentComment!.isNotEmpty) ...[
                        const Text('Comentario del alumno:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                        const SizedBox(height: 4),
                        Text(sub.studentComment!, style: const TextStyle(fontStyle: FontStyle.italic)),
                        const SizedBox(height: 16),
                      ],
                      Wrap(
                        spacing: 8,
                        children: [
                          if (sub.fileUrl != null)
                            ActionChip(
                              avatar: const Icon(Icons.file_present, size: 16),
                              label: const Text('Ver Archivo', style: TextStyle(fontSize: 12)),
                              onPressed: () => _launchUrl(sub.fileUrl!),
                            ),
                          if (sub.linkUrl != null)
                            ActionChip(
                              avatar: const Icon(Icons.link, size: 16),
                              label: const Text('Abrir Enlace', style: TextStyle(fontSize: 12)),
                              onPressed: () => _launchUrl(sub.linkUrl!),
                            ),
                        ],
                      ),
                      if (isGraded && sub.feedback != null) ...[
                        const SizedBox(height: 16),
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
                              const Text('Tu Feedback:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                              Text(sub.feedback!),
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
    );
  }
}
