import 'package:admin_app/UI/public/application/bloc/application_events.dart';
import 'package:admin_app/UI/public/application/bloc/application_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/application_bloc.dart';
import '../models/application_models.dart';
import '../widgets/application_card.dart';
import '../widgets/application_empty_state.dart';
import '../widgets/application_loading_state.dart';
import '../widgets/status_filter_chip.dart';

class MyApplicationsPage extends StatefulWidget {
  final int candidateId;

  const MyApplicationsPage({
    Key? key,
    required this.candidateId,
  }) : super(key: key);

  @override
  State<MyApplicationsPage> createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends State<MyApplicationsPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Load initial applications
    context.read<ApplicationBloc>().add(
          LoadApplicationsEvent(candId: widget.candidateId),
        );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<ApplicationBloc>().add(
            LoadMoreApplicationsEvent(candId: widget.candidateId),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Applications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ApplicationBloc>().add(
                    RefreshApplicationsEvent(candId: widget.candidateId),
                  );
            },
          ),
        ],
      ),
      body: BlocBuilder<ApplicationBloc, ApplicationState>(
        builder: (context, state) {
          if (state is ApplicationLoading) {
            return const ApplicationLoadingState();
          }

          if (state is ApplicationError) {
            return _buildErrorState(state.message);
          }

          if (state is ApplicationLoaded && state.applications.isEmpty) {
            return const ApplicationEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ApplicationBloc>().add(
                    RefreshApplicationsEvent(candId: widget.candidateId),
                  );
            },
            child: Column(
              children: [
                // Status Filter Chips
                Container(
                  padding: EdgeInsets.all(16.w),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter by Status',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            StatusFilterChip(
                              label: 'All',
                              isSelected: state is ApplicationLoaded &&
                                  state.selectedStatus == null,
                              onTap: () {
                                context.read<ApplicationBloc>().add(
                                      FilterApplicationsByStatusEvent(
                                          status: null),
                                    );
                              },
                            ),
                            SizedBox(width: 8.w),
                            ...ApplicationStatus.values.map(
                              (status) => Padding(
                                padding: EdgeInsets.only(right: 8.w),
                                child: StatusFilterChip(
                                  label: status.displayName,
                                  isSelected: state is ApplicationLoaded &&
                                      state.selectedStatus == status,
                                  onTap: () {
                                    context.read<ApplicationBloc>().add(
                                          FilterApplicationsByStatusEvent(
                                              status: status),
                                        );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Applications List
                Expanded(
                  child: state is ApplicationLoaded
                      ? ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(16.w),
                          itemCount: state.filteredApplications.length +
                              (state is ApplicationLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= state.filteredApplications.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final application =
                                state.filteredApplications[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: ApplicationCard(application: application),
                            );
                          },
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.w,
              color: Colors.red[300],
            ),
            SizedBox(height: 16.h),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ApplicationBloc>().add(
                      LoadApplicationsEvent(candId: widget.candidateId),
                    );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
