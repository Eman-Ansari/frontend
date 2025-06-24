import 'package:authenticationtry/about.dart';
import 'package:authenticationtry/faqs.dart';
import 'package:authenticationtry/myprofile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'login_screen.dart';
import 'package:authenticationtry/virtual_keyboard.dart/virtual_keyboard_screen.dart';


class NavBarDrawer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: Colors.grey[100],
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CircleAvatar(
                  radius: 30,
                  child: Icon(
                    Icons.memory, // Brain icon
                    size: 45,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "Welcome!",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  "Virtual EEG · BCI Interface",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.portrait,
            title: "My Profile",
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProfileScreen())),
          ),
          _buildDrawerItem(
            icon: Icons.home,
            title: "Home",
            onTap: () => Navigator.pop(context),
          ),
          _buildDrawerItem(
            icon: Icons.keyboard,
            title: "Virtual Keyboard",
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VirtualKeyboardScreen())),
          ),
          _buildDrawerItem(
            icon: Icons.info,
            title: "About",
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => AboutScreen())),
          ),
          _buildDrawerItem(
            icon: Icons.help,
            title: "FAQs",
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => FAQScreen())),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              tileColor: Colors.red[50],
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        tileColor: Colors.white,
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        onTap: onTap,
      ),
    );
  }
}
