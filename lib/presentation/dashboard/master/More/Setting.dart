import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // ================= ACCOUNT =================
          _sectionTitle("Account"),

          _settingsTile(
            icon: Icons.person_outline,
            title: "Profile",
            subtitle: "View and update your profile",
            onTap: () {
              // TODO: Navigate to Profile Page
            },
          ),

          _settingsTile(
            icon: Icons.lock_outline,
            title: "Change Password",
            subtitle: "Update your login password",
            onTap: () {
              Navigator.pushNamed(context, '/change-password');
            },
          ),

          const Divider(),

          // ================= PREFERENCES =================
          _sectionTitle("Preferences"),

          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text("Dark Mode"),
            value: _darkMode,
            onChanged: (value) {
              setState(() => _darkMode = value);
              // TODO: Hook into ThemeProvider
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text("Notifications"),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
          ),

          const Divider(),

          // ================= SECURITY =================
          _sectionTitle("Security"),

          _settingsTile(
            icon: Icons.verified_user_outlined,
            title: "Privacy Policy",
            onTap: () {
              // TODO: Open privacy policy
            },
          ),

          _settingsTile(
            icon: Icons.description_outlined,
            title: "Terms & Conditions",
            onTap: () {
              // TODO: Open terms page
            },
          ),

          const Divider(),

          // ================= SUPPORT =================
          _sectionTitle("Support"),

          _settingsTile(
            icon: Icons.help_outline,
            title: "Help & Support",
            onTap: () {
              // TODO: Open help page
            },
          ),

          _settingsTile(
            icon: Icons.info_outline,
            title: "About App",
            subtitle: "Version 1.0.0",
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Factory App",
                applicationVersion: "1.0.0",
                applicationLegalese: "© 2026 Your Company",
              );
            },
          ),

          const Divider(),

          // ================= LOGOUT =================
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                _showLogoutDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout"),
            onPressed: () {
              Navigator.pop(context);
              // TODO: auth.logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/',
                (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
