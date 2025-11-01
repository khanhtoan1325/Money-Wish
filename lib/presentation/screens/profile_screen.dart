import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expanse_management/Constants/color.dart';
import 'package:expanse_management/services/firebase_db_service.dart';
import 'package:expanse_management/services/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseDbService _dbService = FirebaseDbService();
  final AppLocalizations _appLocalizations = AppLocalizations();
  String _displayName = '';
  String _gender = '';
  String _dateOfBirth = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _listenToProfile();
  }

  void _loadProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _displayName = user?.displayName ?? _appLocalizations.get('user');
    });

    try {
      final profile = await _dbService.getProfile();
      setState(() {
        _displayName = profile['displayName'] ?? user?.displayName ?? 'Người dùng';
        _gender = profile['gender'] ?? '';
        _dateOfBirth = profile['dateOfBirth'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _listenToProfile() {
    _dbService.listenProfile().listen((profile) {
      if (mounted) {
        setState(() {
          _displayName = profile['displayName'] ?? FirebaseAuth.instance.currentUser?.displayName ?? 'Người dùng';
          _gender = profile['gender'] ?? '';
          _dateOfBirth = profile['dateOfBirth'] ?? '';
        });
      }
    });
  }

  Future<void> _editDisplayName() async {
    final TextEditingController controller = TextEditingController(text: _displayName);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ValueListenableBuilder<String>(
        valueListenable: _appLocalizations.languageNotifier,
        builder: (ctx, lang, _) => AlertDialog(
          title: Text(_appLocalizations.get('edit_profile')),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: _appLocalizations.get('display_name'),
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_appLocalizations.get('cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text(_appLocalizations.get('save')),
            ),
          ],
        ),
      ),
    );

    if (result != null && result.isNotEmpty && result != _displayName) {
      try {
        await _dbService.updateProfile(displayName: result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ValueListenableBuilder<String>(
                valueListenable: _appLocalizations.languageNotifier,
                builder: (context, lang, _) => Text(_appLocalizations.get('display_name_updated')),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ValueListenableBuilder<String>(
                valueListenable: _appLocalizations.languageNotifier,
                builder: (context, lang, _) => Text('${_appLocalizations.get('error')}: $e'),
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _editGender() async {
    String? selectedGender = _gender.isEmpty ? null : _gender;
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => ValueListenableBuilder<String>(
          valueListenable: _appLocalizations.languageNotifier,
          builder: (ctx, lang, _) => AlertDialog(
            title: Text(_appLocalizations.get('gender')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: Text(_appLocalizations.get('male')),
                  value: 'Nam',
                  groupValue: selectedGender,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedGender = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text(_appLocalizations.get('female')),
                  value: 'Nữ',
                  groupValue: selectedGender,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedGender = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text(_appLocalizations.get('other')),
                  value: 'Khác',
                  groupValue: selectedGender,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedGender = value;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(_appLocalizations.get('cancel')),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, selectedGender ?? ''),
                child: Text(_appLocalizations.get('save')),
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null && result != _gender) {
      try {
        await _dbService.updateProfile(gender: result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ValueListenableBuilder<String>(
                valueListenable: _appLocalizations.languageNotifier,
                builder: (context, lang, _) => Text(_appLocalizations.get('gender_updated')),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ValueListenableBuilder<String>(
                valueListenable: _appLocalizations.languageNotifier,
                builder: (context, lang, _) => Text('${_appLocalizations.get('error')}: $e'),
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _editDateOfBirth() async {
    DateTime initialDate = _dateOfBirth.isNotEmpty
        ? DateTime.tryParse(_dateOfBirth) ?? DateTime.now()
        : DateTime.now();
    
    final result = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (result != null) {
      final formattedDate = '${result.day}/${result.month}/${result.year}';
      final isoDate = result.toIso8601String();
      
      if (isoDate != _dateOfBirth) {
        try {
          await _dbService.updateProfile(dateOfBirth: isoDate);
          if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ValueListenableBuilder<String>(
                valueListenable: _appLocalizations.languageNotifier,
                builder: (context, lang, _) => Text(_appLocalizations.get('date_of_birth_updated')),
              ),
            ),
          );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: $e')),
            );
          }
        }
      }
    }
  }

  String _formatDateOfBirth(String isoDate) {
    if (isoDate.isEmpty) return '';
    final date = DateTime.tryParse(isoDate);
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String email = user?.email ?? _appLocalizations.get('no_email');
    final String? photoUrl = user?.photoURL;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayNameForHeader = _displayName.isEmpty ? _appLocalizations.get('user') : _displayName;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xfff5f5f5),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔹 Header với avatar và thông tin
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [gradientStart, gradientEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Nút quay lại
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          
                          // Avatar
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white,
                            backgroundImage: photoUrl != null 
                                ? NetworkImage(photoUrl) 
                                : null,
                            child: photoUrl == null
                                ? Text(
                                    displayNameForHeader.isNotEmpty 
                                        ? displayNameForHeader[0].toUpperCase() 
                                        : 'U',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 8),
                          
                          // Tên người dùng
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              displayNameForHeader,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 3),
                          
                          // Email
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              email,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Thông tin chi tiết
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      ValueListenableBuilder<String>(
                        valueListenable: _appLocalizations.languageNotifier,
                        builder: (context, lang, _) => Column(
                          children: [
                            _buildEditableInfoCard(
                              context: context,
                              icon: Icons.person_outline,
                              title: _appLocalizations.get('display_name'),
                              value: _displayName.isEmpty ? _appLocalizations.get('user') : _displayName,
                              onTap: _editDisplayName,
                            ),
                            const SizedBox(height: 12),
                            
                            _buildEditableInfoCard(
                              context: context,
                              icon: Icons.people_outline,
                              title: _appLocalizations.get('gender'),
                              value: _gender.isEmpty ? _appLocalizations.get('not_updated') : _gender,
                              onTap: _editGender,
                            ),
                            const SizedBox(height: 12),
                            
                            _buildEditableInfoCard(
                              context: context,
                              icon: Icons.cake_outlined,
                              title: _appLocalizations.get('date_of_birth'),
                              value: _dateOfBirth.isEmpty ? _appLocalizations.get('not_updated') : _formatDateOfBirth(_dateOfBirth),
                              onTap: _editDateOfBirth,
                            ),
                            const SizedBox(height: 12),
                            
                            _buildInfoCard(
                              context: context,
                              icon: Icons.email_outlined,
                              title: _appLocalizations.get('email'),
                              value: email,
                            ),
                            const SizedBox(height: 12),
                            
                            _buildInfoCard(
                              context: context,
                              icon: Icons.verified_user_outlined,
                              title: _appLocalizations.get('email_verified'),
                              value: user?.emailVerified == true ? _appLocalizations.get('verified') : _appLocalizations.get('not_verified'),
                              valueColor: user?.emailVerified == true ? Colors.green : Colors.orange,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Thông tin tài khoản
                      Builder(
                        builder: (context) {
                          final isDark = Theme.of(context).brightness == Brightness.dark;
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: isDark ? [] : [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ValueListenableBuilder<String>(
                                  valueListenable: _appLocalizations.languageNotifier,
                                  builder: (context, lang, _) => Row(
                                    children: [
                                      const Icon(
                                        Icons.info_outline,
                                        color: primaryColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _appLocalizations.get('account_info'),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 24),
                                
                                ValueListenableBuilder<String>(
                                  valueListenable: _appLocalizations.languageNotifier,
                                  builder: (context, lang, _) => Column(
                                    children: [
                                      _buildInfoRow(
                                        context,
                                        _appLocalizations.get('uid'),
                                        user?.uid ?? 'N/A',
                                        Icons.tag,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoRow(
                                        context,
                                        _appLocalizations.get('account_created'),
                                        user?.metadata.creationTime != null
                                            ? '${user!.metadata.creationTime!.day}/${user.metadata.creationTime!.month}/${user.metadata.creationTime!.year}'
                                            : 'N/A',
                                        Icons.calendar_today,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoRow(
                                        context,
                                        _appLocalizations.get('last_login'),
                                        user?.metadata.lastSignInTime != null
                                            ? '${user!.metadata.lastSignInTime!.day}/${user.metadata.lastSignInTime!.month}/${user.metadata.lastSignInTime!.year}'
                                            : 'N/A',
                                        Icons.access_time,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEditableInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
    Color? valueColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xffe6f5f3),
              child: Icon(icon, color: primaryColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? (isDark ? Colors.white : Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit_outlined,
              size: 20,
              color: isDark ? Colors.white54 : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xffe6f5f3),
            child: Icon(icon, color: primaryColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? (isDark ? Colors.white : Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 18, color: isDark ? Colors.white54 : Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}