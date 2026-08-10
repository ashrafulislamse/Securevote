import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  double _passwordStrength = 0.75;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08090E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0E13).withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB9C3FF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Security',
          style: TextStyle(
            color: Color(0xFFE3E1E9),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFFB9C3FF)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Security Shield Icon
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB9C3FF).withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0E13).withOpacity(0.5),
                  border: Border.all(color: const Color(0xFFB9C3FF), width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: const [
                    Icon(
                      Icons.shield_outlined,
                      color: Color(0xFFB9C3FF),
                      size: 40,
                    ),
                    Icon(Icons.lock, color: Color(0xFFB9C3FF), size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Heading
            const Text(
              'Change Password',
              style: TextStyle(
                color: Color(0xFFE3E1E9),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Update your credentials to maintain vault integrity.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFC4C5D7), fontSize: 14),
            ),

            const SizedBox(height: 32),

            // Current Password
            _buildPasswordField(
              'Current Password',
              _obscureCurrent,
              () => setState(() => _obscureCurrent = !_obscureCurrent),
            ),

            const SizedBox(height: 24),

            // New Password with Strength
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPasswordField(
                  'New Password',
                  _obscureNew,
                  () => setState(() => _obscureNew = !_obscureNew),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: _passwordStrength >= 0.25
                                    ? const Color(0xFF2ADEC0)
                                    : const Color(0xFF2ADEC0).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: _passwordStrength >= 0.5
                                    ? const Color(0xFF2ADEC0)
                                    : const Color(0xFF2ADEC0).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: _passwordStrength >= 0.75
                                    ? const Color(0xFF2ADEC0)
                                    : const Color(0xFF2ADEC0).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: _passwordStrength >= 1.0
                                    ? const Color(0xFF2ADEC0)
                                    : const Color(0xFF2ADEC0).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2ADEC0).withOpacity(0.1),
                        border: Border.all(
                          color: const Color(0xFF2ADEC0).withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2ADEC0),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'STRONG',
                            style: TextStyle(
                              color: Color(0xFF2ADEC0),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Confirm Password
            _buildPasswordField(
              'Confirm New Password',
              _obscureConfirm,
              () => setState(() => _obscureConfirm = !_obscureConfirm),
              hasCheck: true,
            ),

            const SizedBox(height: 24),

            // Security Checklist
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SECURITY CHECKLIST',
                    style: TextStyle(
                      color: Color(0xFFC4C5D7).withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildChecklistItem('At least 12 characters long', true),
                  const SizedBox(height: 12),
                  _buildChecklistItem('Includes a unique symbol', true),
                  const SizedBox(height: 12),
                  _buildChecklistItem(
                    'Includes uppercase and lowercase',
                    false,
                  ),
                  const SizedBox(height: 12),
                  _buildChecklistItem('Not used in previous 3 months', true),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Update Button
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB9C3FF),
                  foregroundColor: const Color(0xFF001D79),
                  elevation: 10,
                  shadowColor: const Color(0xFFB9C3FF).withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Update Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    bool obscure,
    VoidCallback onToggle, {
    bool hasCheck = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFFC4C5D7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
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
            obscureText: obscure,
            style: const TextStyle(color: Color(0xFFE3E1E9)),
            decoration: InputDecoration(
              hintText: '••••••••••••',
              hintStyle: TextStyle(
                color: const Color(0xFF8E90A0).withOpacity(0.4),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              suffixIcon: hasCheck
                  ? const Icon(
                      Icons.check_circle,
                      color: Color(0xFF2ADEC0),
                      size: 20,
                    )
                  : IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF8E90A0).withOpacity(0.6),
                      ),
                      onPressed: onToggle,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(String text, bool isChecked) {
    return Row(
      children: [
        Icon(
          isChecked ? Icons.check_circle : Icons.schedule,
          color: isChecked
              ? const Color(0xFF2ADEC0)
              : const Color(0xFF8E90A0).withOpacity(0.4),
          size: 18,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: isChecked
                ? const Color(0xFFE3E1E9)
                : const Color(0xFFC4C5D7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
