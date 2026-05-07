import 'package:admin_app/UI/auth/cubit/auth_cubit.dart';
import 'package:admin_app/UI/employee/profile/components/document_section.dart';
import 'package:admin_app/UI/employee/profile/components/expandable_tile.dart';
import 'package:admin_app/UI/employee/profile/cubit/profile_cubit.dart';
import 'package:admin_app/UI/employee/profile/model/profile_data_model.dart';
import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  final String appTitle;
  const ProfilePage({Key? key, required this.appTitle}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().getEmpProfile();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final currentUri = GoRouterState.of(context).uri;
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: AppBar(
        title: Text(widget.appTitle,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(Routes.home.path);
            }
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return state.when(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              success: (profileDataModel) => SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(profileDataModel),
                    const SizedBox(height: 16),
                    if (profileDataModel.emp != null)
                      ExpandableTile(
                        title: "Primary Details",
                        icon: Icons.person,
                        expandedContent: _buildPrimaryDetails(profileDataModel),
                      ),
                    const SizedBox(height: 16),
                    profileDataModel.doc != null &&
                            profileDataModel.doc!.isEmpty
                        ? const SizedBox()
                        : DocumentSection(
                            documentStatus: profileDataModel.documentStatus!,
                            documents: profileDataModel.doc!),
                    const SizedBox(height: 16),
                    profileDataModel.emp == null
                        ? const SizedBox()
                        : ExpandableTile(
                            title: "Emergency Contact",
                            icon: Icons.phone,
                            expandedContent:
                                _buildEmergencyContact(profileDataModel),
                          ),
                    const SizedBox(height: 16),
                    // if (currentUri.path == Routes.home.path)
                    GestureDetector(
                      onTap: () {
                        context.push(Routes.usersPage.path);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.015),
                          child: Row(
                            children: [
                              Icon(Icons.swap_vert,
                                  size: screenWidth * 0.06, color: Colors.blue),
                              SizedBox(width: screenWidth * 0.03),
                              Text(
                                "Switch User",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            title: const Text("Logout",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            content:
                                const Text("Are you sure you want to log out?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => Navigator.pop(context, true),
                                icon: const Icon(Icons.logout_rounded),
                                label: const Text("Logout"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (shouldLogout == true) {
                          locator<AuthCubit>().logout();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.015),
                          child: Row(
                            children: [
                              Icon(Icons.logout_rounded,
                                  size: screenWidth * 0.06, color: Colors.blue),
                              SizedBox(width: screenWidth * 0.03),
                              Text(
                                "Logout",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              error: (message) => Center(
                  child:
                      Text(message, style: const TextStyle(color: Colors.red))),
            );
          },
        ),
      ),
    );
  }

  /// 🟢 **Profile Header - Avatar & Name**
  Widget _buildProfileHeader(ProfileDataModel profileDataModel) {
    return Column(
      children: [
        Center(
          child: CircleAvatar(
            radius: 50,
            backgroundImage: profileDataModel.photo != null &&
                    profileDataModel.photo!.isNotEmpty
                ? NetworkImage(profileDataModel.photo!)
                : const AssetImage("assets/image/user.png") as ImageProvider,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            profileDataModel.user.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  /// 🔹 **Primary Details Section**
  Widget _buildPrimaryDetails(ProfileDataModel profileDataModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow("Employee ID", profileDataModel.emp!.empId),
        _buildDetailRow("Designation", profileDataModel.emp!.designation),
        _buildDetailRow("Nationality", profileDataModel.emp!.nationality),
        _buildDetailRow("Date of Birth",
            profileDataModel.emp!.dob.toString().split(" ")[0]),
      ],
    );
  }

  /// 📜 **Documents Section**
  Widget _buildDocuments(ProfileDataModel profileDataModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: profileDataModel.doc!.map((doc) {
        return Column(
          children: [
            _buildDetailRow(doc.alias, doc.docNo),
            const Divider(),
          ],
        );
      }).toList(),
    );
  }

  /// 📞 **Emergency Contact Section**
  Widget _buildEmergencyContact(ProfileDataModel profileDataModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow("Emergency Contact", profileDataModel.emp!.relName),
        _buildDetailRow("Phone", profileDataModel.emp!.relTelMob),
      ],
    );
  }

  /// 🔹 **Reusable Detail Row**
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54)),
          Text(value,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
