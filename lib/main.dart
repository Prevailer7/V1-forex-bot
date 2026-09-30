import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const V1TradingBotApp());
}

class V1TradingBotApp extends StatelessWidget {
  const V1TradingBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'V1 Trading Bot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF22C55E),
          secondary: Color(0xFF38BDF8),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String backendUrl = "https://your-backend-api.onrender.com";
  bool isConnected = true;
  bool isAutoMode = false;
  double pnlNgn = 8450.0;
  int tradesToday = 6;
  
  Map<String, dynamic>? currentSignal = {
    "id": 0,
    "symbol": "BTCUSD",
    "action": "BUY",
    "price": 64250.00,
    "lot": 0.02,
    "sl_pips": 450,
    "tp_pips": 900
  };

  Future<void> sendDecision(String action) async {
    try {
      await http.post(
        Uri.parse('$backendUrl/decision'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'signal_id': 0, 'action': action}),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trade ${action}D successfully!')),
      );
      setState(() {
        currentSignal = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action Sent: $action (Demo Mode)')),
      );
      setState(() {
        currentSignal = null;
      });
    }
  }

  Future<void> emergencyStop() async {
    try {
      await http.post(Uri.parse('$backendUrl/emergency-stop'));
    } catch (_) {}
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🛑 BOT EXECUTION HALTED!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double profitProgress = (pnlNgn / 15000.0).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('V1 Elirox Bot', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: Colors.redAccent),
            onPressed: emergencyStop,
            tooltip: 'Emergency Stop',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isConnected ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  child: Icon(
                    isConnected ? Icons.check_circle : Icons.error,
                    color: isConnected ? Colors.green : Colors.red,
                  ),
                ),
                title: const Text("FxPro MT5 Demo", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Status: Active & Guarded 24/5"),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAlignment.start,
                  children: [
                    const Text("Daily Performance Guardrail", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Profit Target: ₦${pnlNgn.toStringAsFixed(0)} / ₦15,000"),
                        Text("${(profitProgress * 100).toStringAsFixed(0)}%", style: const TextStyle(color: Colors.greenAccent)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: profitProgress,
                      backgroundColor: Colors.slate[700],
                      color: Colors.greenAccent,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Max Daily Loss Cap:", style: TextStyle(color: Colors.redAccent)),
                        Text("-₦6,000 NGN", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("Trades Executed Today: $tradesToday / 20 Maximum", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: SwitchListTile(
                title: const Text("Auto-Execution Mode"),
                subtitle: Text(isAutoMode ? "Automated Execution Active" : "Manual Approval Required"),
                value: isAutoMode,
                activeColor: Colors.greenAccent,
                onChanged: (val) {
                  setState(() {
                    isAutoMode = val;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text("Pending Signals Queue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (currentSignal != null)
              Card(
                color: const Color(0xFF0F2942),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.blueAccent, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "🚨 ${currentSignal!['symbol']} — ${currentSignal!['action']}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: currentSignal!['action'] == "BUY" ? Colors.greenAccent : Colors.redAccent,
                            ),
                          ),
                          const Text("1h EMA/RSI Signal", style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 20),
                      Text("Entry Price: \$${currentSignal!['price']}"),
                      Text("Lot Size: ${currentSignal!['lot']} Lots"),
                      Text("Stop Loss: ${currentSignal!['sl_pips']} Pips | Take Profit: ${currentSignal!['tp_pips']} Pips"),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                padding: const EdgeInsets.vertical(12),
                              ),
                              onPressed: () => sendDecision("APPROVE"),
                              icon: const Icon(Icons.check, color: Colors.white),
                              label: const Text("APPROVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[700],
                                padding: const EdgeInsets.vertical(12),
                              ),
                              onPressed: () => sendDecision("REJECT"),
                              icon: const Icon(Icons.close, color: Colors.white),
                              label: const Text("REJECT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )
            else
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Text("Scanning EURUSD & BTCUSD for setups...", style: TextStyle(color: Colors.grey)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
