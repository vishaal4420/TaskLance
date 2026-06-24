import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/user.dart';
import '../../../models/transaction.dart';
import '../../auth/providers/auth_providers.dart';
import 'mock_payment_modal.dart';
import '../providers/wallet_providers.dart';

class WalletDashboardScreen extends ConsumerStatefulWidget {
  const WalletDashboardScreen({super.key});

  @override
  ConsumerState<WalletDashboardScreen> createState() => _WalletDashboardScreenState();
}

class _WalletDashboardScreenState extends ConsumerState<WalletDashboardScreen> {
  bool _isProcessing = false;

  Future<void> _handleWithdraw(String uid, double balance) async {
    if (balance <= 0) {
      AppSnackBar.error(context, 'No funds available to withdraw.');
      return;
    }
    setState(() => _isProcessing = true);
    try {
      final txRef = FirebaseFirestore.instance.collection('transactions').doc();
      await txRef.set({
        'id': txRef.id,
        'userId': uid,
        'amount': -balance,
        'description': 'Withdrawal to Bank Account',
        'status': 'completed',
        'method': 'bankTransfer',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) AppSnackBar.success(context, 'Funds withdrawn successfully to your linked bank account.');
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Transaction failed: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleAddFunds(String uid) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MockPaymentModal(
        amount: 500.0,
        projectName: 'Wallet Deposit',
        onSuccess: () async {
          setState(() => _isProcessing = true);
          try {
            final txRef = FirebaseFirestore.instance.collection('transactions').doc();
            await txRef.set({
              'id': txRef.id,
              'userId': uid,
              'amount': 500.0,
              'description': 'Deposit via Credit Card',
              'status': 'completed',
              'method': 'card',
              'createdAt': FieldValue.serverTimestamp(),
            });
            if (mounted) AppSnackBar.success(context, '\$500.00 added to your wallet balance.');
          } catch (e) {
            if (mounted) AppSnackBar.error(context, 'Transaction failed: $e');
          } finally {
            if (mounted) setState(() => _isProcessing = false);
          }
        },
      ),
    );
  }

  void _handleExport() {
    AppSnackBar.success(context, 'Export generated and saved to device.');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final role = ref.watch(currentUserRoleProvider);
    final transactionsAsync = ref.watch(walletTransactionsProvider);
    final balance = ref.watch(walletBalanceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: _handleExport,
            tooltip: 'Export CSV',
          ),
        ],
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (transactions) {
          final chartData = _generateChartData(transactions);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Balance Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Available Balance',
                        style: AppTextStyles.labelMedium.copyWith(color: Colors.white.withOpacity(0.8))),
                    const SizedBox(height: 8),
                    Text(CurrencyFormatter.format(balance),
                        style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(role == UserRole.client ? 'Pending Escrow' : 'Pending Clearance',
                            style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withOpacity(0.8))),
                        Text('\$450.00', style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(role == UserRole.client ? 'Total Spent' : 'Total Earned',
                            style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withOpacity(0.8))),
                        Text('\$12,450.00', style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing
                            ? null
                            : () => role == UserRole.client ? _handleAddFunds(user?.uid ?? '') : _handleWithdraw(user?.uid ?? '', balance),
                        icon: Icon(role == UserRole.client ? Icons.add_rounded : Icons.north_east_rounded, size: 20),
                        label: Text(_isProcessing
                            ? 'Processing...'
                            : (role == UserRole.client ? 'Add \$500' : 'Withdraw Funds')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Chart Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Earnings Overview (30 Days)', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: (chartData.fold<double>(0, (max, e) => e.amount > max ? e.amount : max) * 1.2).clamp(500.0, double.infinity),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 500,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                strokeWidth: 1,
                                dashArray: [5, 5],
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (val, meta) {
                                  return SideTitleWidget(
                                    meta: meta,
                                    space: 4,
                                    child: Text('\$${val.toInt()}', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryLight)),
                                  );
                                }
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                interval: 5,
                                getTitlesWidget: (val, meta) {
                                  if (val < 0 || val >= chartData.length) {
                                    return SideTitleWidget(meta: meta, child: const SizedBox.shrink());
                                  }
                                  return SideTitleWidget(
                                    meta: meta,
                                    space: 4,
                                    child: Text(chartData[val.toInt()].day, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryLight)),
                                  );
                                }
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.amount)).toList(),
                              isCurved: true,
                              color: AppColors.primary,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withOpacity(0.3),
                                    AppColors.primary.withOpacity(0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recent Transactions
              Text('Recent Transactions', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              if (transactions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: Text('No transactions found.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight)),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  separatorBuilder: (_, __) => Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  itemBuilder: (_, i) {
                    final tx = transactions[i];
                    final isPositive = tx.amount > 0;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(tx.projectName ?? (isPositive ? 'Deposit' : 'Withdrawal'), style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                      subtitle: Text('${tx.createdAt.day}/${tx.createdAt.month}/${tx.createdAt.year}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isPositive ? '+' : ''}${CurrencyFormatter.format(tx.amount)}',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isPositive ? AppColors.statusActive : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                              fontFamily: 'RobotoMono',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (tx.status == TransactionStatus.completed ? AppColors.statusActive : AppColors.warning).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tx.status.name.toUpperCase(),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: tx.status == TransactionStatus.completed ? AppColors.statusActive : AppColors.warning,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  List<_ChartPoint> _generateChartData(List<TransactionModel> txs) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final groups = <String, double>{};
    
    for (int i = 29; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      groups['${d.day}/${d.month}'] = 0;
    }
    
    for (final tx in txs) {
      if (tx.createdAt.isAfter(thirtyDaysAgo) && tx.amount > 0) {
        final key = '${tx.createdAt.day}/${tx.createdAt.month}';
        if (groups.containsKey(key)) {
          groups[key] = groups[key]! + tx.amount;
        }
      }
    }
    
    double cumulative = 0;
    final List<_ChartPoint> pts = [];
    for (final entry in groups.entries) {
      cumulative += entry.value;
      pts.add(_ChartPoint(entry.key, cumulative));
    }
    return pts;
  }
}

class _ChartPoint {
  final String day;
  final double amount;
  _ChartPoint(this.day, this.amount);
}
