import 'dart:io';

import 'package:admin_app/UI/components/home_header.dart';
import 'package:admin_app/UI/home/components/home_drawer.dart';
import 'package:admin_app/UI/home/components/menu_component.dart';
import 'package:admin_app/UI/home/cubit/home_cubit.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  Future<void> _fetchMenu() async {
    await context.read<HomeCubit>().getMenu();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    // Responsive constants you can tweak:
    final horizontalMargin = w * 0.05; // ~5% of width
    final verticalMargin = h * 0.02; // ~2% of height
    final contentPadding = w * 0.03; // ~3% of width inside the card
    final cornerRadius = w * 0.05; // ~5% of width for border radii
    final gridVSpacing = h * 0.015; // vertical spacing between tiles
    final gridHSpacing = w * 0.015; // horizontal spacing
    final gridCrossSpacing = w * 0.02; // cross-axis spacing
    final gridMainSpacing = h * 0.02; // main-axis spacing

    // Decide how many columns based on breakpoints:
    int columns;
    if (w >= 1200) {
      columns = 6;
    } else if (w >= 900) {
      columns = 4;
    } else if (w >= 600) {
      columns = 3;
    } else {
      columns = 3;
    }

    // Aspect ratio tweak for larger screens
    final childAspect = w > 600 ? 1.2 : 1.0;

    return BlocListener<HomeCubit, HomeState>(
      listener: (context, state) {
        state.whenOrNull(
          error: (msg) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(msg))),
        );
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: HomeDrawer(scaffoldKey: _scaffoldKey),
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with safe area inset
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalMargin,
                  vertical: Platform.isIOS ? verticalMargin : verticalMargin,
                ),
                child: HomeHeader(),
              ),
            ),

            // Main content
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: contentPadding),
                decoration: BoxDecoration(
                  color: ConstColors.backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(cornerRadius),
                    topRight: Radius.circular(cornerRadius),
                  ),
                ),
                child: BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    return RefreshIndicator(
                      onRefresh: _fetchMenu,
                      child: state.maybeWhen(
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        success: (menuItems) => GridView.builder(
                          padding: EdgeInsets.symmetric(
                            vertical: gridVSpacing,
                            horizontal: gridHSpacing,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: gridCrossSpacing,
                            mainAxisSpacing: gridMainSpacing,
                            childAspectRatio: childAspect,
                          ),
                          itemCount: menuItems.length,
                          itemBuilder: (ctx, i) {
                            return MenuComponent(
                              item: menuItems[i],
                            );
                          },
                        ),
                        orElse: () => const Center(
                          child: Text("No data available"),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
