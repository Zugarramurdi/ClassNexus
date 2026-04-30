import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/subjects/providers/subjects_provider.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/nexus_card.dart';
import 'package:frontend/core/widgets/responsive_layout.dart';
import 'package:frontend/core/widgets/nexus_sidebar.dart';

class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      body: subjectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (subjects) {
          return ResponsiveLayout(
            mobile: _SubjectsMobile(subjects: subjects),
            desktop: _SubjectsDesktop(subjects: subjects),
          );
        },
      ),
    );
  }
}

class _SubjectsDesktop extends StatelessWidget {
  final List<dynamic> subjects;
  const _SubjectsDesktop({required this.subjects});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
          child: Text(
            'Mis Asignaturas',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: _SubjectsGrid(subjects: subjects),
        ),
      ],
    );
  }
}

class _SubjectsMobile extends StatelessWidget {
  final List<dynamic> subjects;
  const _SubjectsMobile({required this.subjects});

  @override
  Widget build(BuildContext context) {
    return _SubjectsGrid(subjects: subjects);
  }
}

class _SubjectsGrid extends StatelessWidget {
  final List<dynamic> subjects;
  const _SubjectsGrid({required this.subjects});

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) {
      return const Center(child: Text('No hay asignaturas disponibles.'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = constraints.maxWidth > 1200 ? 4 : constraints.maxWidth > 800 ? 3 : constraints.maxWidth > 600 ? 2 : 1;
        
        return GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.2, 
          ),
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            final subject = subjects[index];
            return _SubjectCard(subject: subject);
          },
        );
      },
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final dynamic subject;

  const _SubjectCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    const color = AppColors.primary; 

    return NexusCard(
      onTap: () {
        context.push('/subjects/${subject.id}');
      },
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.menu_book_rounded, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  subject.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subject.center != null)
                  Text(
                    subject.center!['name'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
