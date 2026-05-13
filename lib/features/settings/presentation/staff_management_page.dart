import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/constants/theme.dart';

class StaffManagementPage extends ConsumerWidget {
  const StaffManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock data for demonstration
    final staff = [
      {'name': 'Sarah Smith', 'role': 'Secretary', 'status': 'Active'},
      {'name': 'John Doe', 'role': 'Assistant', 'status': 'Active'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
        actions: [
          IconButton(
            onPressed: () => _showInviteDialog(context),
            icon: const Icon(Icons.person_add_alt_1_outlined),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: staff.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final s = staff[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: CliniGoTheme.primaryColor.withAlpha(30),
              child: Text(s['name']![0], style: TextStyle(color: CliniGoTheme.primaryColor)),
            ),
            title: Text(s['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(s['role']!),
            trailing: Chip(
              label: Text(s['status']!, style: const TextStyle(fontSize: 10)),
              backgroundColor: Colors.green[100],
            ),
          );
        },
      ),
    );
  }

  void _showInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Staff'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Email Address'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              items: const [
                DropdownMenuItem(value: 'secretary', child: Text('Secretary')),
                DropdownMenuItem(value: 'assistant', child: Text('Assistant')),
              ],
              onChanged: (v) {},
              decoration: const InputDecoration(labelText: 'Role'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Send Invitation')),
        ],
      ),
    );
  }
}
