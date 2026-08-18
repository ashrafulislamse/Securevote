import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/providers.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    await context.read<AuthProvider>().updateProfile(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Color(0xFF2ADEC0),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final fullName = user?.fullName ?? 'User';
    final nameParts = fullName.split(' ');
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : fullName.length >= 2
        ? fullName.substring(0, 2).toUpperCase()
        : fullName[0].toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0E13),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0E13).withValues(alpha: 0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB9C3FF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFFE3E1E9),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFF4F6EF7),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar Section
            Stack(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB9C3FF), Color(0xFFD2BBFF)],
                    ),
                    border: Border.all(
                      color: const Color(0xFF0D0E13),
                      width: 4,
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF292A2F),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0D0E13),
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: TextStyle(
                          color: Color(0xFFE3E1E9),
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB9C3FF),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0D0E13),
                        width: 4,
                      ),
                    ),
                    child: const Icon(
                      Icons.photo_camera,
                      color: Color(0xFF001D79),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Change Profile Photo',
              style: TextStyle(
                color: Color(0xFFC4C5D7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 32),

            // Form Fields
            _buildTextField('Full Name', _nameController, Icons.person),
            const SizedBox(height: 24),
            _buildTextField(
              'Email',
              _emailController,
              Icons.mail,
              readOnly: true,
            ),
            const SizedBox(height: 24),
            _buildTextField('Phone', _phoneController, Icons.phone),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Only Full Name and Phone are editable. Email changes are not supported.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
        ),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB9C3FF),
              foregroundColor: const Color(0xFF001D79),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Icon(Icons.check_circle, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFFC4C5D7),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF292A2F),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            style: TextStyle(
              color: readOnly
                  ? Colors.white.withValues(alpha: 0.5)
                  : const Color(0xFFE3E1E9),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF8E90A0), size: 20),
              suffixIcon: readOnly
                  ? const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF8E90A0),
                      size: 18,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
