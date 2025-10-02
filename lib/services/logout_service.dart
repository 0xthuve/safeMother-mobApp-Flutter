import 'package:flutter/material.dart';
import '../services/user_management_service.dart';
import '../signin.dart';

class LogoutService {
  
  static Future<void> showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.logout,
                color: Color(0xFFE91E63),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Sign Out',
                style: TextStyle(
                  color: Color(0xFF7B1FA2),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to sign out of your account?',
            style: TextStyle(
              color: Color(0xFF5A5A5A),
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF9575CD),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await performLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> performLogout(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
          ),
        );
      },
    );

    try {
      // Sign out user
      await UserManagementService.signOutUser();
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Successfully signed out'),
            backgroundColor: const Color(0xFFE91E63),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Navigate to sign in screen and clear all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const SignInScreen(),
          ),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign out: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  // Quick logout without confirmation dialog
  static Future<void> quickLogout(BuildContext context) async {
    await performLogout(context);
  }

  // Logout widget that can be used in app bars, drawers, etc.
  static Widget logoutButton(BuildContext context, {
    String? text,
    IconData? icon,
    Color? color,
    bool showConfirmDialog = true,
  }) {
    return InkWell(
      onTap: () {
        if (showConfirmDialog) {
          showLogoutDialog(context);
        } else {
          quickLogout(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.logout,
              color: color ?? const Color(0xFFE91E63),
              size: 20,
            ),
            if (text != null) ...[
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: color ?? const Color(0xFF7B1FA2),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Logout list tile for use in drawers
  static Widget logoutListTile(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.logout,
        color: Color(0xFFE91E63),
      ),
      title: const Text(
        'Sign Out',
        style: TextStyle(
          color: Color(0xFF7B1FA2),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () => showLogoutDialog(context),
    );
  }
}