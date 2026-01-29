import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:factory_app/state/auth_provider.dart';
import 'package:factory_app/presentation/login/login_controller.dart';
import 'package:factory_app/presentation/dashboard/master/More/ChangePassword.dart';
import 'package:factory_app/presentation/dashboard/master/More/ContactSupport.dart';
import 'package:factory_app/presentation/dashboard/master/More/Help&FAQ.dart';
import 'package:factory_app/presentation/dashboard/master/More/Notification.dart';
import 'package:factory_app/presentation/dashboard/master/More/PrivacyPolicy.dart';
import 'package:factory_app/presentation/dashboard/master/More/Setting.dart';
import 'package:factory_app/presentation/dashboard/master/More/Term&Conditions.dart';

class MasterMorePage extends StatelessWidget {
  const MasterMorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.userData; // Logged-in user details

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ================= PROFILE HEADER =================
          _profileHeader(auth, context),

          const SizedBox(height: 24),

          // ================= ACCOUNT =================
          _sectionTitle('Account'),
          _cardSection([
            _menuItem(
              icon: Icons.person_outline,
              title: 'My Profile',
              onTap: () {
                // TODO: Navigate to profile page
              },
            ),
            _menuItem(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                );
              },
            ),
          ]),

          const SizedBox(height: 16),

          // ================= PREFERENCES =================
          _sectionTitle('Preferences'),
          _cardSection([
            _menuItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),
            _menuItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                );
              },
            ),
          ]),

          const SizedBox(height: 16),

          // ================= SUPPORT =================
          _sectionTitle('Support'),
          _cardSection([
            _menuItem(
              icon: Icons.help_outline,
              title: 'Help & FAQ',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpFaqPage()),
                );
              },
            ),
            _menuItem(
              icon: Icons.support_agent_outlined,
              title: 'Contact Support',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ContactSupportPage()),
                );
              },
            ),
          ]),

          const SizedBox(height: 16),

          // ================= LEGAL =================
          _sectionTitle('Legal'),
          _cardSection([
            _menuItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
                );
              },
            ),
            _menuItem(
              icon: Icons.description_outlined,
              title: 'Terms & Conditions',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TermsConditionsPage()),
                );
              },
            ),
          ]),

          const SizedBox(height: 24),

          // ================= LOGOUT =================
          _cardSection([
            _menuItem(
              icon: Icons.logout,
              title: 'Logout',
              color: Colors.red,
              onTap: () => _showLogoutDialog(context, auth),
            ),
          ]),
        ],
      ),
    );
  }

  /* ================= UI COMPONENTS ================= */
Widget _profileHeader(AuthProvider auth, BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        const CircleAvatar(radius: 32, child: Icon(Icons.person, size: 32)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Use getter from AuthProvider
              Text(
                auth.employeeName ?? 'Employee Name',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              
                 if (auth.employeeEmail != null) ...[
                const SizedBox(height: 2),
                Text(
                  auth.employeeEmail!,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
              if (auth.employeePhone != null) ...[
                const SizedBox(height: 2),
                Text(
                  auth.employeePhone!,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
              if (auth.userRole != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Role: ${auth.userRole}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
              if (auth.tenantName != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Tenant: ${auth.tenantName}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ],
          ),
        ),
        const Icon(Icons.chevron_right),
      ],
    ),
  );
}

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _cardSection(List<Widget> children) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await auth.logout();
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
