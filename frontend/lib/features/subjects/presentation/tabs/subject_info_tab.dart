import 'package:flutter/material.dart';
import '../../providers/subjects_provider.dart';

class SubjectInfoTab extends StatelessWidget {
  final SubjectData subject;

  const SubjectInfoTab({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final teachers = subject.teachers ?? [];

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Card de Información General
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Acerca de la Asignatura',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  subject.description ?? 'Sin descripción disponible.',
                  style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),

        // Sección de Profesores / Tutores
        const Text(
          'Equipo Docente',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        
        if (teachers.isEmpty)
          const Text('No hay profesores asignados aún.', style: TextStyle(color: Colors.black54))
        else
          ...teachers.map((teacher) {
            final name = "${teacher['first_name']} ${teacher['last_name']}";
            final avatarUrl = teacher['avatar_url'];
            
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade100),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null ? Text(teacher['first_name'][0]) : null,
                ),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Profesor / Tutor'),
                trailing: const Icon(Icons.mail_outline, size: 20),
              ),
            );
          }),
          
        const SizedBox(height: 24),

        // Información del Centro (si existe)
        if (subject.center != null) ...[
          const Text(
            'Centro Educativo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              leading: const Icon(Icons.school_outlined, color: Colors.orange),
              title: Text(subject.center!['name'] ?? 'Centro desconocido'),
              subtitle: Text(subject.center!['address'] ?? 'Sin dirección'),
            ),
          ),
        ],
      ],
    );
  }
}
