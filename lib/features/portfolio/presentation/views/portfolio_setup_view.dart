import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';
import 'package:connecthub/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:connecthub/features/portfolio/presentation/cubit/portfolio_state.dart';

class PortfolioSetupView extends StatefulWidget {
  final UserModel user;

  const PortfolioSetupView({
    super.key,
    required this.user,
  });

  @override
  State<PortfolioSetupView> createState() =>
      _PortfolioSetupViewState();
}

class _PortfolioSetupViewState
    extends State<PortfolioSetupView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _headlineController;
  late TextEditingController _aboutController;
  late TextEditingController _locationController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;
  late TextEditingController _linkedinController;
  late TextEditingController _githubController;
  late TextEditingController _portfolioController;
  late TextEditingController _slugController;

  late SectionVisibilityModel _visibility;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    final links = u.socialLinks;

    _headlineController = TextEditingController(text: u.headline ?? '');
    _aboutController = TextEditingController(text: u.about ?? '');
    _locationController = TextEditingController(text: u.location ?? '');
    _phoneController = TextEditingController(text: u.phone ?? '');
    _websiteController = TextEditingController(text: links.website ?? '');
    _linkedinController = TextEditingController(text: links.linkedin ?? '');
    _githubController = TextEditingController(text: links.github ?? '');
    _portfolioController = TextEditingController(text: links.portfolio ?? '');
    _slugController = TextEditingController(text: u.profileSlug ?? '');

    _visibility = u.sectionVisibility;
  }

  @override
  void dispose() {
    _headlineController.dispose();
    _aboutController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _portfolioController.dispose();
    _slugController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PortfolioCubit, PortfolioState>(
      listener: (context, state) {
        if (state is PortfolioUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Portfolio updated successfully!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.pop(context);
        } else if (state is PortfolioError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          elevation: 0,
          title: const Text(
            'Configure Portfolio',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    title: 'Professional Identity',
                    subtitle:
                        'Define your headline, summary, and public URL slug.',
                  ),
                  const SizedBox(height: 12),
                  _buildDarkTextField(
                    controller: _headlineController,
                    label: 'Headline',
                    hint: 'e.g. Senior Flutter Architect | Open Source Contributor',
                    icon: Icons.title_rounded,
                  ),
                  const SizedBox(height: 14),
                  _buildDarkTextField(
                    controller: _aboutController,
                    label: 'About Summary',
                    hint: 'A comprehensive summary of your background, achievements, and technical focus...',
                    icon: Icons.notes_rounded,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 14),
                  _buildDarkTextField(
                    controller: _slugController,
                    label: 'Portfolio URL Slug',
                    hint: 'username (e.g. connecthub.app/u/username)',
                    icon: Icons.link_rounded,
                    helperText: 'Used for your future public portfolio URL.',
                  ),
                  const SizedBox(height: 28),
                  _SectionHeader(
                    title: 'Contact Details',
                    subtitle: 'Where potential clients and employers can reach you.',
                  ),
                  const SizedBox(height: 12),
                  _buildDarkTextField(
                    controller: _locationController,
                    label: 'Location',
                    hint: 'e.g. San Francisco, CA or Remote',
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 14),
                  _buildDarkTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: 'e.g. +1 555 123 4567',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 28),
                  _SectionHeader(
                    title: 'Professional & Social Links',
                    subtitle: 'All links are grouped in a modern interactive card.',
                  ),
                  const SizedBox(height: 12),
                  _buildDarkTextField(
                    controller: _websiteController,
                    label: 'Personal Website',
                    hint: 'https://yourwebsite.com',
                    icon: Icons.language_rounded,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 14),
                  _buildDarkTextField(
                    controller: _linkedinController,
                    label: 'LinkedIn Profile',
                    hint: 'https://linkedin.com/in/username',
                    icon: Icons.business_center_outlined,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 14),
                  _buildDarkTextField(
                    controller: _githubController,
                    label: 'GitHub Profile / Username',
                    hint: 'https://github.com/username or @username',
                    icon: Icons.code_rounded,
                  ),
                  const SizedBox(height: 14),
                  _buildDarkTextField(
                    controller: _portfolioController,
                    label: 'Portfolio Website',
                    hint: 'https://portfolio.dev',
                    icon: Icons.web_asset_rounded,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 28),
                  _SectionHeader(
                    title: 'Section Visibility',
                    subtitle: 'Toggle visibility of individual portfolio sections.',
                  ),
                  const SizedBox(height: 12),
                  _buildVisibilityCard(),
                  const SizedBox(height: 32),
                  BlocBuilder<PortfolioCubit, PortfolioState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF38BDF8),
                            foregroundColor: const Color(0xFF0F172A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: state is PortfolioUpdating
                              ? null
                              : _saveProfile,
                          child: state is PortfolioUpdating
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF0F172A),
                                  ),
                                )
                              : const Text(
                                  'Save Portfolio',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDarkTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFCBD5E1),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
            prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
            filled: true,
            fillColor: const Color(0xFF1E293B),
            helperText: helperText,
            helperStyle:
                const TextStyle(color: Color(0xFF64748B), fontSize: 11),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisibilityCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        children: [
          _buildToggle(
            'About Section',
            _visibility.about,
            (v) => setState(() => _visibility = _visibility.copyWith(about: v)),
          ),
          const Divider(color: Color(0xFF334155), height: 1),
          _buildToggle(
            'Experience Section',
            _visibility.experience,
            (v) => setState(
                () => _visibility = _visibility.copyWith(experience: v)),
          ),
          const Divider(color: Color(0xFF334155), height: 1),
          _buildToggle(
            'Projects Section',
            _visibility.projects,
            (v) => setState(
                () => _visibility = _visibility.copyWith(projects: v)),
          ),
          const Divider(color: Color(0xFF334155), height: 1),
          _buildToggle(
            'Skills Section',
            _visibility.skills,
            (v) =>
                setState(() => _visibility = _visibility.copyWith(skills: v)),
          ),
          const Divider(color: Color(0xFF334155), height: 1),
          _buildToggle(
            'Education Section',
            _visibility.education,
            (v) => setState(
                () => _visibility = _visibility.copyWith(education: v)),
          ),
          const Divider(color: Color(0xFF334155), height: 1),
          _buildToggle(
            'Certificates Section',
            _visibility.certificates,
            (v) => setState(
                () => _visibility = _visibility.copyWith(certificates: v)),
          ),
          const Divider(color: Color(0xFF334155), height: 1),
          _buildToggle(
            'Contact Section',
            _visibility.contact,
            (v) =>
                setState(() => _visibility = _visibility.copyWith(contact: v)),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String title, bool val, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      value: val,
      onChanged: onChanged,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      activeThumbColor: const Color(0xFF38BDF8),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    final socialLinks = SocialLinksModel(
      website: _websiteController.text.trim(),
      linkedin: _linkedinController.text.trim(),
      github: _githubController.text.trim(),
      portfolio: _portfolioController.text.trim(),
    );

    context.read<PortfolioCubit>().updatePortfolio(
          uid: widget.user.uid,
          headline: _headlineController.text.trim(),
          about: _aboutController.text.trim(),
          location: _locationController.text.trim(),
          phone: _phoneController.text.trim(),
          socialLinks: socialLinks,
          profileSlug: _slugController.text.trim(),
          portfolioCompleted: true,
          sectionVisibility: _visibility,
        );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF38BDF8),
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
