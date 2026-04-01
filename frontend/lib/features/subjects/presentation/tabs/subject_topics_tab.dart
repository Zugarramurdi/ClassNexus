import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/topics_provider.dart';
import '../../../../core/network/api_client.dart';

class SubjectTopicsTab extends ConsumerStatefulWidget {
  final int subjectId;
  final bool isTeacher;

  const SubjectTopicsTab({
    super.key, 
    required this.subjectId, 
    required this.isTeacher
  });

  @override
  ConsumerState<SubjectTopicsTab> createState() => _SubjectTopicsTabState();
}

class _SubjectTopicsTabState extends ConsumerState<SubjectTopicsTab> {
  bool _isUploading = false;

  void _showAddTopicDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    PlatformFile? selectedFile;

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
                  const Text('Nuevo Temario', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Título del Tema (Ej: Tema 1)'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Descripción (Opcional)'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.attach_file),
                    label: Text(selectedFile?.name ?? 'Adjuntar Archivo (PDF, PPTX)'),
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'zip'],
                        withData: true,
                      );
                      if (result != null) {
                        setModalState(() {
                          selectedFile = result.files.first;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isUploading
                        ? null
                        : () async {
                            if (titleController.text.isEmpty) return;

                            setModalState(() => _isUploading = true);
                            String? fileUrl;

                            try {
                              if (selectedFile != null && selectedFile!.bytes != null) {
                                final fileName = '${widget.subjectId}/temario/${DateTime.now().millisecondsSinceEpoch}_${selectedFile!.name}';
                                
                                await Supabase.instance.client.storage
                                    .from('classnexus_material')
                                    .uploadBinary(fileName, selectedFile!.bytes!);

                                fileUrl = Supabase.instance.client.storage
                                    .from('classnexus_material')
                                    .getPublicUrl(fileName);
                              }

                              final dio = ref.read(dioProvider);
                              await dio.post('/subjects/${widget.subjectId}/topics', data: {
                                'title': titleController.text,
                                'description': descriptionController.text,
                                'file_url': fileUrl,
                              });

                              if (context.mounted) {
                                Navigator.pop(context);
                                final _ = ref.refresh(topicsProvider(widget.subjectId));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Tema creado con éxito')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            } finally {
                              setModalState(() => _isUploading = false);
                            }
                          },
                    child: _isUploading
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Guardar Tema'),
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

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('No se pudo abrir $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final topicsAsync = ref.watch(topicsProvider(widget.subjectId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: topicsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (topics) {
          if (topics.isEmpty) {
            return const Center(child: Text('Aún no hay temas publicados.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  topic.title, 
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                                ),
                                if (topic.description?.isNotEmpty ?? false)
                                  const SizedBox(height: 4),
                                if (topic.description?.isNotEmpty ?? false)
                                  Text(topic.description!, style: const TextStyle(color: Colors.black54)),
                              ],
                            ),
                          ),
                          if (topic.fileUrl != null)
                             const Icon(Icons.file_present_outlined, color: Colors.blue),
                        ],
                      ),
                      if (topic.fileUrl != null) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _launchUrl(topic.fileUrl!),
                            icon: const Icon(Icons.download_rounded),
                            label: const Text('Descargar Material'),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ]
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
              onPressed: () => _showAddTopicDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo Tema'),
              backgroundColor: Colors.blue.shade600,
            )
          : null,
    );
  }
}
