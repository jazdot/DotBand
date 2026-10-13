import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/obsidian_theme.dart';
import 'core/widgets/dot_band_animated_logo.dart';
import 'core/widgets/jazdot_suite_drawer.dart';
import 'core/widgets/site_survey_report_sheet.dart';
import 'features/telemetry/presentation/cubit/wifi_scan_cubit.dart';
import 'features/telemetry/presentation/cubit/wifi_scan_state.dart';
import 'features/spectrum/presentation/spectrum_tab.dart';
import 'features/rating/presentation/rating_tab.dart';
import 'features/access_points/presentation/access_points_tab.dart';
import 'features/time_graph/presentation/time_graph_tab.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DotBandApp());
}

class DotBandApp extends StatelessWidget {
  const DotBandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ObsidianTheme.themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'DotBand',
          debugShowCheckedModeBanner: false,
          theme: ObsidianTheme.lightThemeData,
          darkTheme: ObsidianTheme.darkThemeData,
          themeMode: themeMode,
          home: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => WifiScanCubit()..init()),
            ],
            child: const SpectrumDashboardScreen(),
          ),
        );
      },
    );
  }
}

class SpectrumDashboardScreen extends StatefulWidget {
  const SpectrumDashboardScreen({super.key});

  @override
  State<SpectrumDashboardScreen> createState() => _SpectrumDashboardScreenState();
}

class _SpectrumDashboardScreenState extends State<SpectrumDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const JazdotSuiteDrawer(),
      appBar: AppBar(
        title: const DotBandAnimatedLogo(
          size: 28,
          variant: LogoVariant.compact,
          showWordmark: true,
        ),
        actions: [
          BlocBuilder<WifiScanCubit, WifiScanState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.assessment_outlined),
                tooltip: 'Export Site Survey Audit',
                onPressed: () {
                  SiteSurveyReportSheet.show(context, state.snapshot);
                },
              );
            },
          ),
          IconButton(
            icon: Icon(
              ObsidianTheme.isLight ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              size: 20,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () {
              ObsidianTheme.themeModeNotifier.value =
                  ObsidianTheme.isLight ? ThemeMode.dark : ThemeMode.light;
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ObsidianTheme.accentGold,
          labelColor: ObsidianTheme.accentGold,
          unselectedLabelColor: ObsidianTheme.textSecondary,
          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
          tabs: const [
            Tab(text: 'SPECTRUM', icon: Icon(Icons.waves, size: 18)),
            Tab(text: 'RATING', icon: Icon(Icons.star_border, size: 18)),
            Tab(text: 'ACCESS POINTS', icon: Icon(Icons.wifi, size: 18)),
            Tab(text: 'TIME GRAPH', icon: Icon(Icons.show_chart, size: 18)),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isExpanded = constraints.maxWidth >= 600;

          if (isExpanded) {
            // Dual-Pane Responsive CAD Console for Foldables and Tablets
            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: const SpectrumTab(),
                ),
                VerticalDivider(width: 1, color: ObsidianTheme.borderSubtle),
                Expanded(
                  flex: 2,
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      RatingTab(),
                      RatingTab(),
                      AccessPointsTab(),
                      TimeGraphTab(),
                    ],
                  ),
                ),
              ],
            );
          }

          // Single-Column Tabbed Phone View
          return TabBarView(
            controller: _tabController,
            children: const [
              SpectrumTab(),
              RatingTab(),
              AccessPointsTab(),
              TimeGraphTab(),
            ],
          );
        },
      ),
      floatingActionButton: BlocBuilder<WifiScanCubit, WifiScanState>(
        builder: (context, state) {
          final isCooldown = state.remainingCooldownSeconds > 0;
          final isScanning = state.status == ScanStatus.scanning;

          return FloatingActionButton.extended(
            onPressed: isCooldown || isScanning
                ? null
                : () {
                    context.read<WifiScanCubit>().triggerManualScan();
                  },
            backgroundColor: isCooldown ? ObsidianTheme.bgSubtle : ObsidianTheme.accentGold,
            foregroundColor: isCooldown ? ObsidianTheme.textTertiary : const Color(0xFF05070B),
            icon: isScanning
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF05070B)),
                  )
                : Icon(isCooldown ? Icons.hourglass_top : Icons.radar, size: 18),
            label: Text(
              isScanning
                  ? 'SCANNING...'
                  : (isCooldown ? 'COOLDOWN ${state.remainingCooldownSeconds}s' : 'SCAN NOW'),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 11,
                fontFamily: 'monospace',
                letterSpacing: 0.8,
              ),
            ),
          );
        },
      ),
    );
  }
}
