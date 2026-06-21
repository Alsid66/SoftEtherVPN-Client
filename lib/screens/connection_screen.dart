import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vpn_profile.dart';
import '../services/vpn_service.dart';
import '../services/storage_service.dart';

class ConnectionScreen extends StatefulWidget {
  final VpnProfile profile;

  const ConnectionScreen({super.key, required this.profile});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  late VpnService _vpnService;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _vpnService = context.read<VpnService>();
  }

  Future<void> _connect() async {
    setState(() => _isConnecting = true);

    final success = await _vpnService.connect(widget.profile);

    if (mounted) {
      setState(() => _isConnecting = false);

      if (success) {
        final storageService = context.read<StorageService>();
        await storageService.saveLastConnectedProfile(widget.profile.id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('اتصال برقرار شد'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_vpnService.errorMessage ?? 'خطا در برقراری اتصال'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _disconnect() async {
    final success = await _vpnService.disconnect();

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('اتصال قطع شد'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_vpnService.errorMessage ?? 'خطا در قطع اتصال'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor() {
    switch (_vpnService.status) {
      case VpnStatus.connected:
        return Colors.green;
      case VpnStatus.connecting:
        return Colors.orange;
      case VpnStatus.disconnecting:
        return Colors.orange;
      case VpnStatus.error:
        return Colors.red;
      case VpnStatus.disconnected:
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (_vpnService.status) {
      case VpnStatus.connected:
        return Icons.check_circle;
      case VpnStatus.connecting:
      case VpnStatus.disconnecting:
        return Icons.sync;
      case VpnStatus.error:
        return Icons.error;
      case VpnStatus.disconnected:
      default:
        return Icons.vpn_lock;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profile.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status Icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getStatusColor().withOpacity(0.2),
                border: Border.all(
                  color: _getStatusColor(),
                  width: 4,
                ),
              ),
              child: Icon(
                _getStatusIcon(),
                size: 80,
                color: _getStatusColor(),
              ),
            ),
            const SizedBox(height: 32),

            // Status Text
            Text(
              _vpnService.getStatusText(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(),
              ),
            ),
            const SizedBox(height: 16),

            // Profile Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      Icons.dns,
                      'سرور',
                      '${widget.profile.serverAddress}:${widget.profile.port}',
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.hub,
                      'Hub',
                      widget.profile.hubName,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.person,
                      'کاربر',
                      widget.profile.username,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.security,
                      'پروتکل',
                      widget.profile.protocol,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Error Message
            if (_vpnService.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _vpnService.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            // Connect/Disconnect Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isConnecting
                    ? null
                    : (_vpnService.isConnected
                        ? _disconnect
                        : _connect),
                icon: _isConnecting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        _vpnService.isConnected
                            ? Icons.power_off
                            : Icons.power,
                      ),
                label: Text(
                  _isConnecting
                      ? 'در حال اتصال...'
                      : (_vpnService.isConnected ? 'قطع اتصال' : 'اتصال'),
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _vpnService.isConnected
                      ? Colors.red
                      : Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
