import 'dart:async';

import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/directory/domain/directory_repository.dart';
import 'package:admin_app/staff/directory/domain/staff_member.dart';
import 'package:admin_app/staff/directory/presentation/directory_cubit.dart';
import 'package:admin_app/staff/directory/presentation/staff_member_sheet.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_avatar.dart';
import 'package:admin_app/staff/widgets/staff_form.dart';
import 'package:admin_app/staff/widgets/staff_load_view.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Menu > Staff: find a colleague and call or email them.
class DirectoryPage extends StatefulWidget {
  const DirectoryPage({super.key, this.title = 'Staff'});

  final String title;

  @override
  State<DirectoryPage> createState() => _DirectoryPageState();
}

class _DirectoryPageState extends State<DirectoryPage> {
  late final DirectoryRepository _repository = locator<DirectoryRepository>();
  late final DirectoryCubit _cubit = DirectoryCubit(_repository)..search('');
  final _scroll = ScrollController();
  final _query = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) _cubit.loadMore();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _query.dispose();
    _cubit.close();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _cubit.search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return StaffPage(
      child: Column(
        children: [
          BlocBuilder<DirectoryCubit, DirectoryState>(
            bloc: _cubit,
            buildWhen: (a, b) => a.total != b.total,
            builder: (context, state) => StaffPageHeader(
              title: widget.title,
              subtitle: state.total > 0
                  ? '${state.total} people'
                  : 'Colleagues',
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: StaffField(
              label: 'Search',
              hint: 'Name, role or department',
              controller: _query,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              suffixGlyph: StaffGlyphs.search,
            ),
          ),
          Expanded(
            child: BlocBuilder<DirectoryCubit, DirectoryState>(
              bloc: _cubit,
              builder: (context, state) {
                if (state.loading) {
                  return ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      for (var i = 0; i < 6; i++) ...[
                        const StaffSkeleton(height: 68, radius: 18),
                        const SizedBox(height: 10),
                      ],
                    ],
                  );
                }
                return RefreshIndicator(
                  color: p.amberText,
                  backgroundColor: p.surface,
                  onRefresh: () => _cubit.search(state.query),
                  child: state.error != null
                      ? ListView(
                          physics: staffScrollPhysics,
                          children: [
                            SizedBox(
                              height: 380,
                              child: StaffStateMessage(
                                glyph: StaffGlyphs.users,
                                title: 'Could not load staff',
                                message: state.error,
                                actionLabel: 'Try again',
                                onAction: () => _cubit.search(state.query),
                                accent: StaffAccent.blue,
                              ),
                            ),
                          ],
                        )
                      : state.items.isEmpty
                      ? const StaffEmptyList(
                          glyph: StaffGlyphs.users,
                          title: 'No one found',
                          message: 'Try another name or department.',
                          accent: StaffAccent.blue,
                        )
                      : ListView.separated(
                          controller: _scroll,
                          physics: staffScrollPhysics,
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount:
                              state.items.length + (state.hasMore ? 1 : 0),
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            if (i >= state.items.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                    ),
                                  ),
                                ),
                              );
                            }
                            final member = state.items[i];
                            return _MemberTile(
                              member: member,
                              onTap: () => showStaffMemberSheet(
                                context,
                                _repository,
                                member,
                              ),
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member, required this.onTap});

  final StaffMember member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final line = [
      member.designation,
      member.department,
    ].where((e) => e.isNotEmpty).join(' · ');
    return StaffCard(
      radius: 18,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          StaffAvatar(name: member.name, photo: member.photo),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sora(14, weight: FontWeight.w700, color: p.text),
                ),
                if (line.isNotEmpty)
                  Text(
                    line,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: sora(11.5, color: p.muted),
                  ),
              ],
            ),
          ),
          StaffIcon(StaffGlyphs.chevronRight, size: 18, color: p.muted),
        ],
      ),
    );
  }
}
