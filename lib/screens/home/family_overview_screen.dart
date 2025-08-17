import 'package:flutter/material.dart';

class FamilyOverviewScreen extends StatelessWidget {
  const FamilyOverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Overview')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Family Members',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            // TODO: Replace with dynamic list of family members
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text('Parent: Jane Doe'),
                subtitle: Text('Balance: R200'),
              ),
            ),
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Icon(Icons.child_care)),
                title: Text('Child: John Doe'),
                subtitle: Text('Balance: R50 | Streak: 3 days'),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Progress & Rewards',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            // TODO: Replace with dynamic progress and rewards
            LinearProgressIndicator(value: 0.5),
            const SizedBox(height: 8),
            Text('John is halfway to his "Movie Night" reward!'),
          ],
        ),
      ),
    );
  }
}
