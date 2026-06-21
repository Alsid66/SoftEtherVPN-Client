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
  bool isConnected = false;

  // اطلاعات سرور SoftEther خود را اینجا وارد کنید
  final String configOvpnText = """
# متن کامل فایل کانفیگ .ovpn سرور سافت‌اتر را اینجا کپی کنید
""";
  final String username = "username_here";
  final String password = "password_here";

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
      appBar: AppBar(title: const Text('SoftEther OpenVPN Client')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("مرحله فعلی: ${stage?.name ?? 'قطع ارتباط'}"),
            Text("سرعت دانلود: ${status?.byteIn ?? '0'}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (stage == VPNStage.connected) {
                  engine.disconnect();
                } else {
                  engine.connect(
                    configOvpnText,
                    "SoftEther Server",
                    username: username,
                    password: password,
                  );
                }
              },
              child: Text(stage == VPNStage.connected ? "قطع اتصال" : "اتصال به وی‌پي‌ان"),
            ),
          ],
        ),
      ),
    );
  }
}