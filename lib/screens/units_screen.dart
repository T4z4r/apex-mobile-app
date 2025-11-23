import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/units_provider.dart';
import '../providers/auth_provider.dart';

class UnitsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final unitsProvider = Provider.of<UnitsProvider>(context);
    final token = Provider.of<AuthProvider>(context, listen: false).token!;
    if (!unitsProvider.loading && unitsProvider.units.isEmpty) {
      unitsProvider.fetchUnits(token);
    }

    return Scaffold(
      appBar: AppBar(title: Text("Units")),
      body: unitsProvider.loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: unitsProvider.units.length,
              itemBuilder: (ctx, i) {
                final u = unitsProvider.units[i];
                return ListTile(
                  title: Text(u.unitLabel),
                  subtitle: Text("Rent: ${u.rentAmount}, Deposit: ${u.depositAmount}"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => unitsProvider.deleteUnit(token, u.id),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}
