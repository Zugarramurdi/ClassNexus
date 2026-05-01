import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:frontend/features/subjects/providers/subjects_provider.dart';
import 'package:frontend/features/subjects/providers/assignments_provider.dart';
import 'package:frontend/features/profile/providers/profile_provider.dart';
import 'package:frontend/features/subjects/presentation/tabs/subject_info_tab.dart';
import 'package:frontend/features/subjects/presentation/tabs/subject_topics_tab.dart';
import 'package:frontend/features/subjects/presentation/tabs/subject_assignments_tab.dart';

import 'package:frontend/core/theme/app_colors.dart';

class SubjectDetailScreen extends ConsumerStatefulWidget {
  final String subjectId;

  const SubjectDetailScreen({super.key, required this.subjectId});

  @override
  ConsumerState<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends ConsumerState<SubjectDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Escuchamos los cambios de pestaña para actualizar las acciones del AppBar
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
        // Al cambiar de pestaña, reclamamos el foco para asegurar los atajos
        _focusNode.requestFocus();
      }
    });
    // Reclamamos el foco inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _focusNode.dispose();
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

        return KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (event) {
            if (event is KeyDownEvent) {
              final isControlPressed = HardwareKeyboard.instance.isControlPressed;
              final isF5 = event.logicalKey == LogicalKeyboardKey.f5;
              final isCtrlR = isControlPressed && event.logicalKey == LogicalKeyboardKey.keyR;

              if (isF5 || isCtrlR) {
                if (_tabController.index == 2) {
                  ref.invalidate(assignmentsProvider(intId));
                }
              }
            }
          },
          child: Scaffold(
          appBar: AppBar(
            title: Text(
              subject.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              if (_tabController.index == 2)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refrescar tareas',
                  onPressed: () {
                    ref.invalidate(assignmentsProvider(intId));
                  },
                ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.black54,
              indicatorColor: AppColors.primary,
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
        ),
      );
    },
  );
  }
}
