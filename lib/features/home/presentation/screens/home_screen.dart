import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.indigo,
            flexibleSpace: const FlexibleSpaceBar(title: Text('Continua')),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 50),
                const Text(
                  'hello to home screen',
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
