import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/dashboard/domain/staff_dashboard.dart';
import 'package:admin_app/staff/dashboard/presentation/dashboard_cubit.dart';
import 'package:admin_app/staff/home/cubit/home_cubit.dart';
import 'package:admin_app/staff/home/menu/staff_menu_catalog.dart';
import 'package:admin_app/staff/home/menu/staff_menu_tile.dart';
import 'package:admin_app/staff/home/models/menu_model.dart';
import 'package:admin_app/staff/home/pages/staff_coming_soon_page.dart';
import 'package:admin_app/staff/home/utils/active_staff_user.dart';
import 'package:admin_app/staff/home/utils/menu_route_helper.dart';
import 'package:admin_app/staff/shell/staff_shell.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/tickets/tickets/cubit/tickets_cubit.dart';
import 'package:admin_app/staff/tickets/tickets/cubit/tickets_state.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

/// Main menu opened from the raised dock button: role modules in sections.
class StaffMenuPage extends StatefulWidget {
  const StaffMenuPage({super.key});

  @override
  State<StaffMenuPage> createState() => _StaffMenuPageState();
}

class _StaffMenuPageState extends State<StaffMenuPage> {
  final TextEditingController _search = TextEditingController();
  List<MenuModel>? _lastMenus;
  String _query = '';

  @override
  void initState() {
    super.initState();
    final cubit = context.read<HomeCubit>();
    cubit.state.maybeWhen(initial: cubit.getMenu, orElse: () {});
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _refresh() => context.read<HomeCubit>().getMenu(quiet: true);

  void _open(StaffMenuEntry entry) {
    final menu = entry.menu;
    if (menu != null) {
      openStaffMenu(context, menu);
      return;
    }
    final soon = entry.soon;
    if (soon != null) openComingSoon(context, soon);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final role = activeStaffUser().designation.trim();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 20, 4),
            child: Row(
              children: [
                ?staffOriginBack(context),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Menu',
                        style: sora(
                          28,
                          weight: FontWeight.w700,
                          color: p.text,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        role.isEmpty
                            ? 'Modules available to your role'
                            : 'Modules available to your role: $role',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: sora(
                          12.5,
                          weight: FontWeight.w400,
                          color: p.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
            child: _SearchField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                final menus = state.maybeWhen(
                  success: (m) => m,
                  orElse: () => _lastMenus,
                );
                if (menus != null) _lastMenus = menus;

                if (menus == null) {
                  return state.maybeWhen(
                    error: (message) => StaffStateMessage(
                      glyph: StaffGlyphs.grid,
                      title: 'Menu unavailable',
                      message: message,
                      actionLabel: 'Try again',
                      onAction: _refresh,
                    ),
                    orElse: () => const _MenuSkeleton(),
                  );
                }
                return _MenuBody(
                  menus: menus,
                  query: _query,
                  onOpen: _open,
                  onRefresh: _refresh,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuBody extends StatelessWidget {
  const _MenuBody({
    required this.menus,
    required this.query,
    required this.onOpen,
    required this.onRefresh,
  });

  final List<MenuModel> menus;
  final String query;
  final ValueChanged<StaffMenuEntry> onOpen;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final sections = buildStaffMenu(menus, query: query);

    return BlocBuilder<DashboardCubit, StaffDashboard?>(
      bloc: locator<DashboardCubit>(),
      builder: (context, dashboard) {
        return BlocBuilder<TicketsCubit, TicketsState>(
          bloc: locator<TicketsCubit>(),
          buildWhen: (_, next) =>
              next is TicketsLoadingSuccess || next is TicketsLoadingError,
          builder: (context, ticketState) {
            final openTickets = ticketState is TicketsLoadingSuccess
                ? openTicketCount(ticketState)
                : 0;

            return RefreshIndicator(
              color: p.amberText,
              backgroundColor: p.surface,
              onRefresh: onRefresh,
              child: CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  if (sections.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: StaffStateMessage(
                        glyph: StaffGlyphs.search,
                        title: 'No modules found',
                        message:
                            'Nothing matches "$query". Try a different word.',
                      ),
                    ),
                  for (var index = 0; index < sections.length; index++) ...[
                    if (sections[index].title.isNotEmpty)
                      SliverToBoxAdapter(
                        child: SectionLabel(
                          sections[index].title.toUpperCase(),
                        ),
                      )
                    else if (index > 0)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(22, 18, 22, 6),
                          child: Divider(height: 1, color: p.border),
                        ),
                      )
                    else
                      const SliverToBoxAdapter(child: SizedBox(height: 14)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      sliver: SliverGrid(
                        gridDelegate: staffMenuGridDelegate(context),
                        delegate: SliverChildBuilderDelegate(
                          childCount: sections[index].items.length,
                          (context, i) {
                            final entry = sections[index].items[i];
                            final apiBadge = entry.menu?.badge ?? 0;
                            final pending = dashboard?.tasksPending;
                            final badge =
                                entry.page == 'tickets' &&
                                    ticketState is TicketsLoadingSuccess
                                ? openTickets
                                : entry.page == 'tasks' && pending != null
                                ? pending
                                : apiBadge;
                            return StaffMenuTile(
                              label: entry.label,
                              glyph: entry.style.glyph,
                              accent: entry.style.accent,
                              iconUrl: entry.iconUrl,
                              soon: entry.isSoon,
                              badge: badge,
                              onTap: () => onOpen(entry),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          StaffIcon(StaffGlyphs.search, size: 19, color: p.muted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              cursorColor: p.amberText,
              style: sora(13.5, weight: FontWeight.w500, color: p.text),
              decoration: InputDecoration(
                isCollapsed: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: 'Search modules',
                hintStyle: sora(13.5, weight: FontWeight.w400, color: p.muted),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () {
                  controller.clear();
                  onChanged('');
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: StaffIcon(StaffGlyphs.close, size: 18, color: p.muted),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MenuSkeleton extends StatelessWidget {
  const _MenuSkeleton();

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Shimmer.fromColors(
      baseColor: p.surfaceRaised,
      highlightColor: p.surface,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        children: [
          for (var s = 0; s < 3; s++) ...[
            const StaffSkeleton(width: 80, height: 10),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < 4; i++)
                  const StaffSkeleton(width: 58, height: 58, radius: 20),
              ],
            ),
            const SizedBox(height: 26),
          ],
        ],
      ),
    );
  }
}
