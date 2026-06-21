import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vpn_profile.dart';
import '../services/storage_service.dart';
import '../services/vpn_service.dart';
import 'add_profile_screen.dart';
import 'connection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<VpnProfile> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);
    final storageService = context.read<StorageService>();
    final profiles = await storageService.loadProfiles();
    setState(() {
      _profiles = profiles;
      _isLoading = false;
    });
  }

  Future<void> _deleteProfile(VpnProfile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف پروفایل'),
        content: Text('آیا مطمئن هستید که می‌خواهید "${profile.name}" را حذف کنید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لغو'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final storageService = context.read<StorageService>();
      await storageService.deleteProfile(profile.id);
      _loadProfiles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('پروفایل حذف شد')),
        );
      }
    }
  }

  void _navigateToAddProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProfileScreen()),
    );
    if (result == true) {
      _loadProfiles();
    }
  }

  void _connectToProfile(VpnProfile profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConnectionScreen(profile: profile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SoftEther VPN'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfiles,
            tooltip: 'بارگذاری مجدد',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profiles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.vpn_lock_outlined,
                        size: 100,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'هیچ پروفایلی وجود ندارد',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'برای شروع، یک پروفایل جدید اضافه کنید',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _profiles.length,
                  itemBuilder: (context, index) {
                    final profile = _profiles[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: const Icon(
                            Icons.vpn_key,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          profile.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('${profile.serverAddress}:${profile.port}'),
                            Text('Hub: ${profile.hubName}'),
                            Text('User: ${profile.username}'),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('حذف'),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'delete') {
                              _deleteProfile(profile);
                            }
                          },
                        ),
                        onTap: () => _connectToProfile(profile),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddProfile,
        icon: const Icon(Icons.add),
        label: const Text('پروفایل جدید'),
      ),
    );
  }
}
