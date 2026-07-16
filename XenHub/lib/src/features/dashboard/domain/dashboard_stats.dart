class DashboardStats {
  const DashboardStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
  });

  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
}
