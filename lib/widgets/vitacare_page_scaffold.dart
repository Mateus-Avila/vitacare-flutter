import 'package:flutter/material.dart';
import 'package:vitacare_flutter/theme/vitacare_colors.dart';
import 'package:vitacare_flutter/widgets/vitacare_app_drawer.dart';
import 'package:vitacare_flutter/widgets/vitacare_background.dart';

class VitacarePageScaffold extends StatelessWidget {
  const VitacarePageScaffold({
    super.key,
    required this.title,
    required this.selectedRoute,
    required this.child,
    this.subtitle,
    this.actions,
    this.maxContentWidth = 1100,
  });

  final String title;
  final String selectedRoute;
  final Widget child;
  final String? subtitle;
  final List<Widget>? actions;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool showSideNavigation = constraints.maxWidth >= 1180;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Vitacare'),
            foregroundColor: VitacareColors.primaryStrong,
            actions: actions,
          ),
          drawer: showSideNavigation
              ? null
              : VitacareAppDrawer(selectedRoute: selectedRoute),
          body: Stack(
            children: [
              const VitacareBackground(),
              SafeArea(
                child: Row(
                  children: [
                    if (showSideNavigation)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
                        child: SizedBox(
                          width: 300,
                          child: Card(
                            child: VitacareAppDrawer(
                              selectedRoute: selectedRoute,
                              embedded: true,
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: maxContentWidth,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _PageHeader(title: title, subtitle: subtitle),
                                const SizedBox(height: 20),
                                Expanded(child: child),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: VitacareColors.textStrong,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: VitacareColors.textSoft,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}
