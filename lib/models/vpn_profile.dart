import 'dart:convert';

class VpnProfile {
  final String id;
  final String name;
  final String serverAddress;
  final int port;
  final String username;
  final String password;
  final String hubName;
  final String protocol; // L2TP, OpenVPN, etc.
  final DateTime createdAt;

  VpnProfile({
    required this.id,
    required this.name,
    required this.serverAddress,
    required this.port,
    required this.username,
    required this.password,
    required this.hubName,
    this.protocol = 'L2TP',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'serverAddress': serverAddress,
      'port': port,
      'username': username,
      'password': password,
      'hubName': hubName,
      'protocol': protocol,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory VpnProfile.fromJson(Map<String, dynamic> json) {
    return VpnProfile(
      id: json['id'],
      name: json['name'],
      serverAddress: json['serverAddress'],
      port: json['port'],
      username: json['username'],
      password: json['password'],
      hubName: json['hubName'],
      protocol: json['protocol'] ?? 'L2TP',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Convert to string for storage
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // Create from string
  factory VpnProfile.fromJsonString(String jsonString) {
    return VpnProfile.fromJson(jsonDecode(jsonString));
  }

  // Copy with modifications
  VpnProfile copyWith({
    String? id,
    String? name,
    String? serverAddress,
    int? port,
    String? username,
    String? password,
    String? hubName,
    String? protocol,
    DateTime? createdAt,
  }) {
    return VpnProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      serverAddress: serverAddress ?? this.serverAddress,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
      hubName: hubName ?? this.hubName,
      protocol: protocol ?? this.protocol,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'VpnProfile(name: $name, server: $serverAddress:$port, hub: $hubName)';
  }
}
