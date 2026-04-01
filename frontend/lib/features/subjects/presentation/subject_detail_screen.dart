import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/subjects_provider.dart';
import '../../profile/providers/profile_provider.dart';
import 'tabs/subject_info_tab.dart';
import 'tabs/subject_topics_tab.dart';
import 'tabs/subject_assignments_tab.dart';

class SubjectDetailScreen extends ConsumerStatefulWidget {
  final String subjectId;

  const SubjectDetailScreen({super.key, required this.subjectId});

  @override
  ConsumerState<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends ConsumerState<SubjectDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsProvider);
    final profileAsync = ref.watch(profileProvider);

    final isTeacher = profileAsync.value?.role?['name'] == 'teacher';
    final intId = int.tryParse(widget.subjectId) ?? 0;

    return subjectsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (subjects) {
        final subject = subjects.firstWhere(
          (s) => s.id == intId,
          orElse: () => throw Exception('Asignatura no encontrada'),
        );

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            title: Text(
              subject.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.blue.shade700,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.blue.shade700,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'INFO', icon: Icon(Icons.info_outline, size: 20)),
                Tab(text: 'TEMARIO', icon: Icon(Icons.menu_book_outlined, size: 20)),
                Tab(text: 'TAREAS', icon: Icon(Icons.assignment_outlined, size: 20)),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              SubjectInfoTab(subject: subject),
              SubjectTopicsTab(subjectId: intId, isTeacher: isTeacher),
              SubjectAssignmentsTab(subjectId: intId, isTeacher: isTeacher),
            ],
          ),
        );
      },
    );
  }
}
