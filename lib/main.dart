import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const EliroxBotApp());
}

class EliroxBotApp extends StatelessWidget {
  const EliroxBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'V1 Elirox Bot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
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
  // Replace this with your actual Render backend URL
  final String backendUrl = 'https://v1-forex-bot.onrender.com';
  
  String status = 'Connecting...';
  double pnl = 0.0;
  int activeSignals = 0;
  bool isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchMetrics();
    // Poll the backend every 5 seconds for live updates
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) => fetchMetrics());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchMetrics() async {
    try {
      final response = await http.get(Uri.parse('$backendUrl/api/v1/metrics'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          status = data['status'] ?? 'Active';
          pnl = (data['pnl'] as num?)?.toDouble() ?? 0.0;
          activeSignals = data['active_signals'] ?? 0;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        status = 'Error connecting';
        isLoading = false;
      });
    }
  }

  Future<void> triggerKillswitch() async {
    try {
      final response = await http.post(Uri.parse('$backendUrl/api/v1/killswitch'));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Emergency Stop Activated!')),
        );
        fetchMetrics();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to trigger killswitch: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('V1 Elirox Bot Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchMetrics,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: ListTile(
                      title: Text('Status: $status'),
                      subtitle: const Text('Backend: Render Server'),
                      leading: Icon(
                        status == 'Active' ? Icons.check_circle : Icons.warning,
                        color: status == 'Active' ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Live Metrics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('PnL'),
                                Text(
                                  '${pnl >= 0 ? '+' : ''}\$${pnl.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: pnl >= 0 ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Active Signals'),
                                Text(
                                  '$activeSignals',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: triggerKillswitch,
                      icon: const Icon(Icons.stop_circle, color: Colors.white),
                      label: const Text(
                        'EMERGENCY STOP (KILLSWITCH)',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

