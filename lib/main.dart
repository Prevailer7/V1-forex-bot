import 'package:flutter/material.dart';

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

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('V1 Elirox Bot Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Card(
              child: ListTile(
                title: Text('Status: Active'),
                subtitle: Text('Backend: Connected to Render'),
                leading: Icon(Icons.check_circle, color: Colors.green),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Live Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PnL'),
                          Text(
                            '+\$0.00',
                            style: TextStyle(
                              fontSize: 20, 
                              fontWeight: FontWeight.bold,
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
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Active Signals'),
                          Text(
                            '0',
                            style: TextStyle(
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
          ],
        ),
      ),
    );
  }
}
