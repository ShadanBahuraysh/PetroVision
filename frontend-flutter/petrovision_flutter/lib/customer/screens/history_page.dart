import 'package:flutter/material.dart';
import '../../services/loyalty_api_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final Color primaryNavy = const Color(0xFF1A2E35);
  final Color accentBlue = const Color(0xFF4195AF);

  List<dynamic> transactions = [];
  bool isLoading = true;

  final String userId = "U-0003";

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final data = await LoyaltyApiService.getTransactions(userId);
    setState(() {
      transactions = data;
      isLoading = false;
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "";
    try {
      final dt = DateTime.parse(dateStr);
      return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} | ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
     appBar: AppBar(
  title: const Text(
    "TRANSACTION HISTORY",
    style: TextStyle(
      color: Color(0xFF1A2E35),
      fontWeight: FontWeight.w900,
      fontSize: 16,
      letterSpacing: 2,
    ),
  ),
  centerTitle: true,
  backgroundColor: const Color(0xFFFBFBFB),
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF1A2E35), size: 20),
    onPressed: () => Navigator.pop(context),
  ),
),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? const Center(child: Text("No transactions yet"))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final item = transactions[index];
                    final String type = item["type"] ?? "fuel";
                    final Color themeColor = accentBlue;
                    final int points = item["points"] ?? 0;
                    final double amount = (item["amount"] ?? 0).toDouble();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              color: themeColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.add_circle_outline_rounded, color: themeColor, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["transaction_id"] ?? "",
                                  style: TextStyle(fontWeight: FontWeight.w900, color: primaryNavy, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  type.toUpperCase(),
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatDate(item["date"]),
                                  style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "+$points PTS",
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: themeColor),
                              ),
                              Text(
                                "${amount.toStringAsFixed(2)} SAR",
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade400),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
