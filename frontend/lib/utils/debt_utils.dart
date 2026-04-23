Map<String, String> analyzeDebtSeverity({
  required int totalDebtMinutes,
  required int freeTimeMinutes,
}) {
  final ratio = totalDebtMinutes / (freeTimeMinutes > 0 ? freeTimeMinutes : 1);
  if (ratio > 2) {
    return {'level': 'critical', 'color': 'error600', 'message': 'Deuda crítica'};
  }
  if (ratio > 1) {
    return {'level': 'warning', 'color': 'neutral400', 'message': 'Deuda considerable'};
  }
  return {'level': 'healthy', 'color': 'neutral50', 'message': 'En balance'};
}
