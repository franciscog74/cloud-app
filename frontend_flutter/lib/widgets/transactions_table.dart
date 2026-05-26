import 'package:flutter/material.dart';

class TransactionsTable extends StatelessWidget {
  const TransactionsTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          const Text("Transacciones", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ListView.builder(
            shrinkWrap: true,
            itemCount: 3,
            itemBuilder: (ctx, i) => ListTile(title: Text("Gasto #$i"), trailing: Text("\$100")),
          ),
        ],
      ),
    );
  }
}