import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../paywall/paywall_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<StorageService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('Account'),
          ListTile(
            leading: const Icon(Icons.star, color: AppColors.primary),
            title: storage.isPremium
                ? const Text('Premium Member ✨')
                : const Text('Upgrade to Premium'),
            subtitle: storage.isPremium
                ? const Text('Thank you for supporting Readilio!')
                : const Text('Unlock unlimited stories & more'),
            trailing: storage.isPremium
                ? null
                : ElevatedButton(
                    onPressed: () => Get.to(() => const PaywallScreen()),
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(100, 36)),
                    child: const Text('Upgrade'),
                  ),
          ),
          const _SectionHeader('Playback'),
          _VoiceSpeedSetting(),
          const _SectionHeader('Accessibility'),
          _LargeTextSetting(),
          const _SectionHeader('About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            trailing: Text('1.0.0',
                style: TextStyle(color: Colors.grey)),
          ),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Privacy Policy'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.textDark.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _VoiceSpeedSetting extends StatefulWidget {
  @override
  State<_VoiceSpeedSetting> createState() => _VoiceSpeedSettingState();
}

class _VoiceSpeedSettingState extends State<_VoiceSpeedSetting> {
  double _speed = 0.75;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      setState(() => _speed = p.getDouble('tts_speed') ?? 0.75);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.speed),
      title: const Text('Reading speed'),
      subtitle: Slider(
        value: _speed,
        min: 0.75,
        max: 1.5,
        divisions: 3,
        label: '${_speed}x',
        activeColor: AppColors.primary,
        onChanged: (v) async {
          setState(() => _speed = v);
          final p = await SharedPreferences.getInstance();
          await p.setDouble('tts_speed', v);
        },
      ),
      trailing: Text('${_speed}x',
          style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class _LargeTextSetting extends StatefulWidget {
  @override
  State<_LargeTextSetting> createState() => _LargeTextSettingState();
}

class _LargeTextSettingState extends State<_LargeTextSetting> {
  bool _largeText = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      setState(() => _largeText = p.getBool('large_text') ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: const Icon(Icons.text_fields),
      title: const Text('Large Text'),
      subtitle: const Text('Increase text size for easier reading'),
      value: _largeText,
      activeThumbColor: AppColors.primary,
      onChanged: (v) async {
        setState(() => _largeText = v);
        final p = await SharedPreferences.getInstance();
        await p.setBool('large_text', v);
      },
    );
  }
}
