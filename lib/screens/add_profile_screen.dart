import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/vpn_profile.dart';
import '../services/storage_service.dart';

class AddProfileScreen extends StatefulWidget {
  const AddProfileScreen({super.key});

  @override
  State<AddProfileScreen> createState() => _AddProfileScreenState();
}

class _AddProfileScreenState extends State<AddProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _serverController = TextEditingController();
  final _portController = TextEditingController(text: '443');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _hubController = TextEditingController();
  
  String _selectedProtocol = 'L2TP';
  bool _isPasswordVisible = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _serverController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _hubController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final profile = VpnProfile(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        serverAddress: _serverController.text.trim(),
        port: int.parse(_portController.text.trim()),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        hubName: _hubController.text.trim(),
        protocol: _selectedProtocol,
      );

      final storageService = context.read<StorageService>();
      await storageService.addProfile(profile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('پروفایل با موفقیت ذخیره شد')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در ذخیره پروفایل: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('پروفایل جدید'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'نام پروفایل',
                hintText: 'مثال: سرور شرکت',
                prefixIcon: Icon(Icons.label),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'لطفاً نام پروفایل را وارد کنید';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Server Address
            TextFormField(
              controller: _serverController,
              decoration: const InputDecoration(
                labelText: 'آدرس سرور',
                hintText: 'مثال: vpn.example.com',
                prefixIcon: Icon(Icons.dns),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'لطفاً آدرس سرور را وارد کنید';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Port
            TextFormField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: 'پورت',
                hintText: '443 یا 992',
                prefixIcon: Icon(Icons.settings_ethernet),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'لطفاً پورت را وارد کنید';
                }
                final port = int.tryParse(value.trim());
                if (port == null || port < 1 || port > 65535) {
                  return 'پورت باید بین 1 تا 65535 باشد';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Hub Name
            TextFormField(
              controller: _hubController,
              decoration: const InputDecoration(
                labelText: 'نام Hub',
                hintText: 'مثال: VPN',
                prefixIcon: Icon(Icons.hub),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'لطفاً نام Hub را وارد کنید';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Username
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'نام کاربری',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'لطفاً نام کاربری را وارد کنید';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'رمز عبور',
                prefixIcon: const Icon(Icons.lock),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isPasswordVisible,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'لطفاً رمز عبور را وارد کنید';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Protocol Selection
            DropdownButtonFormField<String>(
              value: _selectedProtocol,
              decoration: const InputDecoration(
                labelText: 'پروتکل',
                prefixIcon: Icon(Icons.security),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'L2TP', child: Text('L2TP/IPsec')),
                DropdownMenuItem(value: 'OpenVPN', child: Text('OpenVPN')),
                DropdownMenuItem(value: 'SSTP', child: Text('SSTP')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedProtocol = value);
                }
              },
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveProfile,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'در حال ذخیره...' : 'ذخیره پروفایل'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
