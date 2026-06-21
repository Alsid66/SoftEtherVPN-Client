import 'package:flutter/services.dart';
import '../models/vpn_profile.dart';

enum VpnStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

class VpnService {
  static const platform = MethodChannel('com.softether.vpn/vpn');
  
  VpnStatus _status = VpnStatus.disconnected;
  VpnProfile? _currentProfile;
  String? _errorMessage;

  VpnStatus get status => _status;
  VpnProfile? get currentProfile => _currentProfile;
  String? get errorMessage => _errorMessage;

  // Connect to VPN
  Future<bool> connect(VpnProfile profile) async {
    try {
      _status = VpnStatus.connecting;
      _currentProfile = profile;
      _errorMessage = null;

      // Prepare VPN configuration
      final config = {
        'serverAddress': profile.serverAddress,
        'port': profile.port,
        'username': profile.username,
        'password': profile.password,
        'hubName': profile.hubName,
        'protocol': profile.protocol,
      };

      // Call native Android VPN service
      final result = await platform.invokeMethod('connect', config);
      
      if (result == true) {
        _status = VpnStatus.connected;
        return true;
      } else {
        _status = VpnStatus.error;
        _errorMessage = 'Failed to connect to VPN';
        return false;
      }
    } on PlatformException catch (e) {
      _status = VpnStatus.error;
      _errorMessage = e.message ?? 'Unknown error occurred';
      print('VPN Connection Error: ${e.message}');
      return false;
    } catch (e) {
      _status = VpnStatus.error;
      _errorMessage = e.toString();
      print('VPN Connection Error: $e');
      return false;
    }
  }

  // Disconnect from VPN
  Future<bool> disconnect() async {
    try {
      _status = VpnStatus.disconnecting;

      final result = await platform.invokeMethod('disconnect');
      
      if (result == true) {
        _status = VpnStatus.disconnected;
        _currentProfile = null;
        _errorMessage = null;
        return true;
      } else {
        _status = VpnStatus.error;
        _errorMessage = 'Failed to disconnect from VPN';
        return false;
      }
    } on PlatformException catch (e) {
      _status = VpnStatus.error;
      _errorMessage = e.message ?? 'Unknown error occurred';
      print('VPN Disconnection Error: ${e.message}');
      return false;
    } catch (e) {
      _status = VpnStatus.error;
      _errorMessage = e.toString();
      print('VPN Disconnection Error: $e');
      return false;
    }
  }

  // Get current VPN status
  Future<VpnStatus> getStatus() async {
    try {
      final result = await platform.invokeMethod('getStatus');
      
      switch (result) {
        case 'connected':
          _status = VpnStatus.connected;
          break;
        case 'connecting':
          _status = VpnStatus.connecting;
          break;
        case 'disconnecting':
          _status = VpnStatus.disconnecting;
          break;
        case 'disconnected':
        default:
          _status = VpnStatus.disconnected;
          break;
      }
      
      return _status;
    } catch (e) {
      print('Error getting VPN status: $e');
      return VpnStatus.disconnected;
    }
  }

  // Check if VPN is connected
  bool get isConnected => _status == VpnStatus.connected;

  // Check if VPN is connecting
  bool get isConnecting => _status == VpnStatus.connecting;

  // Check if VPN is disconnecting
  bool get isDisconnecting => _status == VpnStatus.disconnecting;

  // Get status text
  String getStatusText() {
    switch (_status) {
      case VpnStatus.connected:
        return 'متصل';
      case VpnStatus.connecting:
        return 'در حال اتصال...';
      case VpnStatus.disconnecting:
        return 'در حال قطع اتصال...';
      case VpnStatus.disconnected:
        return 'قطع شده';
      case VpnStatus.error:
        return 'خطا';
    }
  }

  // Reset error
  void clearError() {
    _errorMessage = null;
    if (_status == VpnStatus.error) {
      _status = VpnStatus.disconnected;
    }
  }
}
