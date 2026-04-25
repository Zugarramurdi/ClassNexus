import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/nexus_card.dart';

class SubjectInfoTab extends StatelessWidget {
  final dynamic subject;

  const SubjectInfoTab({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final teachers = subject.teachers ?? [];

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Card de Información General
        NexusCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Acerca de la Asignatura',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                subject.description ?? 'Sin descripción disponible.',
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),

        // Sección de Profesores / Tutores
        const Text(
          'Equipo Docente',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        if (teachers.isEmpty)
          const Text('No hay profesores asignados aún.', style: TextStyle(color: Colors.black54))
        else
          ...teachers.map((teacher) {
            final name = "${teacher['first_name']} ${teacher['last_name']}";
            final avatarUrl = teacher['avatar_url'];
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: NexusCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null ? Text(teacher['first_name'][0], style: const TextStyle(color: AppColors.primary)) : null,
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Profesor / Tutor'),
                  trailing: IconButton(
                    icon: const Icon(Icons.mail_outline, size: 20),
                    onPressed: () {},
                  ),
                ),
              ),
            );
          }),
          
        const SizedBox(height: 32),

        // Información del Centro (si existe)
        if (subject.center != null) ...[
          const Text(
            'Centro Educativo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          NexusCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.school_outlined, color: Colors.orange),
              ),
              title: Text(subject.center!['name'] ?? 'Centro desconocido', style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(subject.center!['address'] ?? 'Sin dirección'),
            ),
          ),
        ],
      ],
    );
  }
}
