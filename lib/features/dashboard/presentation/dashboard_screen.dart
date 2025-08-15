import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../auth/tasks/data/models/task_model.dart';
import '../../auth/tasks/providers/task_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:task_app/features/auth/data/providers/auth_providers.dart';


class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _touchedIndex = -1;

  // String getGreeting() {
  //   final hour = DateTime.now().hour;
  //   if (hour < 12) return 'Good Morning';
  //   if (hour < 17) return 'Good Afternoon';
  //   return 'Good Evening';
  // }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(dashboardProvider);
    final userProfile = ref.watch(userProfileProvider).value;
    final overdueTasks = ref.watch(overdueTasksProvider);
    final theme = Theme.of(context);

    if (stats.totalTasks == 0) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // _WelcomeHeader(
          //   greeting: getGreeting(),
          //   username: userProfile?.username ?? 'User',
          // ),
          // const SizedBox(height: 24),
          Row(
            children: [
              _StatCard(title: 'Total Tasks', count: stats.totalTasks.toString(), icon: Icons.all_inbox_rounded, color: Colors.blue.shade600),
              const SizedBox(width: 12),
              _StatCard(title: 'Completed', count: stats.doneCount.toString(), icon: Icons.check_circle_rounded, color: Colors.green.shade600),
              const SizedBox(width: 12),
              _StatCard(title: 'Incomplete', count: stats.incompleteTasks.toString(), icon: Icons.pending_actions_rounded, color: Colors.red.shade700),
            ],
          ),
          const SizedBox(height: 24),
          if (overdueTasks.isNotEmpty) ...[
            _SectionHeader(title: 'Overdue Tasks', count: overdueTasks.length),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: overdueTasks.length,
                itemBuilder: (context, index) {
                  return _OverdueTaskCard(task: overdueTasks[index]);
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
          _ChartCard(
            title: 'Task Breakdown',
            child: SizedBox(
              height: 200,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(touchCallback: (event, response) {
                        setState(() {
                          if (!event.isInterestedForInteractions || response == null || response.touchedSection == null) {
                            _touchedIndex = -1; return;
                          }
                          if (_touchedIndex != response.touchedSection!.touchedSectionIndex) {
                            HapticFeedback.lightImpact();
                          }
                          _touchedIndex = response.touchedSection!.touchedSectionIndex;
                        });
                      }),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 4,
                      centerSpaceRadius: 60,
                      sections: _buildPieChartSections(stats),
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 250),
                    swapAnimationCurve: Curves.easeOut,
                  ),
                  Center(child: _buildCenterText(stats)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _ChartCard(
            title: 'Weekly Progress',
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.grey[800]!,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toInt()} tasks',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: _buildBarChartTitles(),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: _buildBarChartGroups(stats.weeklyTasks, theme.primaryColor),
                ),
                swapAnimationDuration: const Duration(milliseconds: 450),
                swapAnimationCurve: Curves.easeOut,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CHART BUILDER AND HELPER METHODS ---

  List<PieChartSectionData> _buildPieChartSections(DashboardStats stats) {
    final sectionsData = [
      {'value': stats.todoCount, 'title': 'Total Task', 'color': Colors.blue.shade400, 'icon': Icons.list_alt_rounded},
      {'value': stats.doneCount, 'title': 'Completed', 'color': Colors.green.shade500, 'icon': Icons.check_circle_outline_rounded},
      {'value': stats.incompleteTasks, 'title': 'Incomplete', 'color': Colors.red.shade400, 'icon': Icons.error_outline_rounded},
    ];

    return List.generate(sectionsData.length, (i) {
      final isTouched = i == _touchedIndex;
      final radius = isTouched ? 45.0 : 35.0;
      final data = sectionsData[i];

      if (data['value'] == 0) {
        return PieChartSectionData(showTitle: false, value: 0, color: Colors.transparent);
      }

      return PieChartSectionData(
        color: data['color'] as Color,
        value: (data['value'] as int).toDouble(),
        radius: radius,
        showTitle: false,
        badgeWidget: _Badge(
          data['icon'] as IconData,
          size: isTouched ? 28.0 : 20.0,
          borderColor: Colors.white,
        ),
        badgePositionPercentageOffset: 0.9,
        borderSide: isTouched
            ? BorderSide(color: (data['color'] as Color).withAlpha(150), width: 4)
            : BorderSide.none,
      );
    });
  }

  Widget _buildCenterText(DashboardStats stats) {
    if (_touchedIndex == -1 || stats.totalTasks == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            stats.totalTasks.toString(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Text('Total Tasks'),
        ],
      );
    }

    final sectionsData = [
      {'value': stats.todoCount, 'title': 'To-Do'},
      {'value': stats.doneCount, 'title': 'Done'},
      {'value': stats.overdueCount, 'title': 'Overdue'},
    ];

    final selectedSection = sectionsData[_touchedIndex];
    final percentage = ((selectedSection['value'] as int) / stats.totalTasks * 100).toStringAsFixed(0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          selectedSection['value'].toString(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(selectedSection['title'] as String),
        const SizedBox(height: 4),
        Text(
          '$percentage%',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
        )
      ],
    );
  }

  FlTitlesData _buildBarChartTitles() {
    return FlTitlesData(
      show: true,
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 38,
          getTitlesWidget: (value, meta) {
            final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(days[value.toInt()], style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14)),
            );
          },
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarChartGroups(List<double> weeklyTasks, Color color) {
    return List.generate(7, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: weeklyTasks[i],
            gradient: LinearGradient(
              colors: [color.withOpacity(0.5), color],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 18,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          )
        ],
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline_rounded, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              "No Task Data Yet",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Your dashboard will light up with insights once you start adding tasks!",
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// --- REUSABLE CUSTOM WIDGETS ---

class _WelcomeHeader extends StatelessWidget {
  final String greeting;
  final String username;
  const _WelcomeHeader({required this.greeting, required this.username});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(greeting, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
        Text(username, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  const _SectionHeader({required this.title, this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        if (count != null) ...[
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 12,
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            child: Text(
              count.toString(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ],
    );
  }
}

class _OverdueTaskCard extends StatelessWidget {
  final TaskModel task;
  const _OverdueTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Card(
        margin: const EdgeInsets.only(right: 12, bottom: 4, top: 4),
        elevation: 1,
        color: Colors.red.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.red.withOpacity(0.2)),
        ),
        child: InkWell(
          onTap: () => context.go('/tasks/task/${task.id}', extra: task),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  task.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Created: ${DateFormat.yMMMd().format(task.createdAt.toDate())}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.count, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 12),
              Text(count, style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(title, style: textTheme.bodyMedium?.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

// --- THIS WIDGET IS CORRECTED ---
class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    // FIX: Replaced the Card widget with a Container and a custom BoxDecoration
    // to achieve a more pronounced and professional shadow effect.
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 5), // Shadow moves down slightly
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color borderColor;
  const _Badge(this.icon, {required this.size, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            offset: const Offset(1, 1),
            blurRadius: 1,
          ),
        ],
      ),
      child: Center(child: Icon(icon, color: Colors.black54, size: size * 0.6)),
    );
  }
}