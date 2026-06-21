import 'package:flutter/material.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const VpnHomeScreen(),
      theme: ThemeData.dark(),
    );
  }
}

class VpnHomeScreen extends StatefulWidget {
  const VpnHomeScreen({Key? key}) : super(key: key);

  @override
  State<VpnHomeScreen> createState() => _VpnHomeScreenState();
}

class _VpnHomeScreenState extends State<VpnHomeScreen> {
  late OpenVPN engine;
  VpnStatus? status;
  VPNStage? stage;

  @override
  void initState() {
    super.initState();
    engine = OpenVPN(
      onVpnStatusChanged: (data) => setState(() => status = data),
      onVpnStageChanged: (currentStage, raw) => setState(() => stage = currentStage),
    );
    
    engine.initialize(
      groupId: "com.alsid66.softether",
      providerBundleIdentifier: "com.alsid66.softether.vpn",
      localizedDescription: "SoftEther VPN Connection",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SoftEther OpenVPN')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("وضعیت اتصال: ${stage?.name ?? 'قطع ارتباط'}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (stage == VPNStage.connected) {
                  engine.disconnect();
                } else {
                  // کانفیگ نمونه سرور شما
                  engine.connect("OVPN_CONFIG_TEXT_HERE", "SoftEther Server");
                }
              },
              child: Text(stage == VPNStage.connected ? "قطع اتصال" : "اتصال به سرور"),
            ),
          ],
        ),
      ),
    );
  }
}