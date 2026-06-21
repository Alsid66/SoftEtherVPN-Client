import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vpn_profile.dart';

class StorageService {
  static const String _profilesKey = 'vpn_profiles';
  static const String _lastConnectedKey = 'last_connected_profile';

  // Save all profiles
  Future<void> saveProfiles(List<VpnProfile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    final profilesJson = profiles.map((p) => p.toJson()).toList();
    await prefs.setString(_profilesKey, jsonEncode(profilesJson));
  }

  // Load all profiles
  Future<List<VpnProfile>> loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final profilesString = prefs.getString(_profilesKey);
    
    if (profilesString == null || profilesString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> profilesJson = jsonDecode(profilesString);
      return profilesJson.map((json) => VpnProfile.fromJson(json)).toList();
    } catch (e) {
      print('Error loading profiles: $e');
      return [];
    }
  }

  // Add a new profile
  Future<void> addProfile(VpnProfile profile) async {
    final profiles = await loadProfiles();
    profiles.add(profile);
    await saveProfiles(profiles);
  }

  // Update an existing profile
  Future<void> updateProfile(VpnProfile profile) async {
    final profiles = await loadProfiles();
    final index = profiles.indexWhere((p) => p.id == profile.id);
    
    if (index != -1) {
      profiles[index] = profile;
      await saveProfiles(profiles);
    }
  }

  // Delete a profile
  Future<void> deleteProfile(String profileId) async {
    final profiles = await loadProfiles();
    profiles.removeWhere((p) => p.id == profileId);
    await saveProfiles(profiles);
  }

  // Get a specific profile by ID
  Future<VpnProfile?> getProfile(String profileId) async {
    final profiles = await loadProfiles();
    try {
      return profiles.firstWhere((p) => p.id == profileId);
    } catch (e) {
      return null;
    }
  }

  // Save last connected profile ID
  Future<void> saveLastConnectedProfile(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastConnectedKey, profileId);
  }

  // Get last connected profile ID
  Future<String?> getLastConnectedProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastConnectedKey);
  }

  // Clear all data
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profilesKey);
    await prefs.remove(_lastConnectedKey);
  }
}
