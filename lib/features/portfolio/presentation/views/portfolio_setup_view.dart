import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/theme/theme_cubit.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';
import 'package:connecthub/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:connecthub/features/portfolio/presentation/cubit/portfolio_state.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/setup/portfolio_setup_text_field.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/setup/portfolio_setup_section_header.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/setup/portfolio_visibility_card.dart';

class PortfolioSetupView extends StatefulWidget {
  final UserModel user;

  const PortfolioSetupView({
    super.key,
    required this.user,
  });

  @override
  State<PortfolioSetupView> createState() => _PortfolioSetupViewState();
}

class _PortfolioSetupViewState extends State<PortfolioSetupView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _headlineController;
  late TextEditingController _aboutController;
  late TextEditingController _locationController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;
  late TextEditingController _linkedinController;
  late TextEditingController _githubController;
  late TextEditingController _portfolioController;
  late TextEditingController _cvLinkController;
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
    _cvLinkController = TextEditingController(text: u.cvLink ?? u.resumeUrl ?? '');
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
    _cvLinkController.dispose();
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
              content: const Text('Portfolio configuration updated!'),
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
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, _) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'Configure Portfolio',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            leading: AppIconButton(
              icon: Icons.arrow_back_ios_new,
              size: 16,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: DarkGlassBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PortfolioSetupSectionHeader(
                        title: 'Professional Identity',
                        subtitle: 'Define your headline, summary, and public URL slug.',
                      ),
                      const SizedBox(height: 12),
                      PortfolioSetupTextField(
                        controller: _headlineController,
                        label: 'Headline',
                        hint: 'e.g. Senior Flutter Architect | Open Source Contributor',
                        icon: Icons.title_rounded,
                      ),
                      const SizedBox(height: 14),
                      PortfolioSetupTextField(
                        controller: _aboutController,
                        label: 'About Summary',
                        hint: 'A comprehensive summary of your background, achievements, and technical focus...',
                        icon: Icons.notes_rounded,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 14),
                      PortfolioSetupTextField(
                        controller: _slugController,
                        label: 'Portfolio URL Slug',
                        hint: 'username (e.g. connecthub.app/u/username)',
                        icon: Icons.link_rounded,
                        helperText: 'Used for your future public portfolio URL.',
                      ),
                      const SizedBox(height: 28),
                      const PortfolioSetupSectionHeader(
                        title: 'Contact Details',
                        subtitle: 'Where potential clients and employers can reach you.',
                      ),
                      const SizedBox(height: 12),
                      PortfolioSetupTextField(
                        controller: _locationController,
                        label: 'Location',
                        hint: 'e.g. San Francisco, CA or Remote',
                        icon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 14),
                      PortfolioSetupTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: 'e.g. +1 555 123 4567',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 28),
                      const PortfolioSetupSectionHeader(
                        title: 'Professional & Social Links',
                        subtitle: 'All links are grouped in a modern interactive card.',
                      ),
                      const SizedBox(height: 12),
                      PortfolioSetupTextField(
                        controller: _websiteController,
                        label: 'Personal Website',
                        hint: 'https://yourwebsite.com',
                        icon: Icons.language_rounded,
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 14),
                      PortfolioSetupTextField(
                        controller: _linkedinController,
                        label: 'LinkedIn Profile',
                        hint: 'https://linkedin.com/in/username',
                        icon: Icons.business_center_outlined,
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 14),
                      PortfolioSetupTextField(
                        controller: _githubController,
                        label: 'GitHub Profile / Username',
                        hint: 'https://github.com/username or @username',
                        icon: Icons.code_rounded,
                      ),
                      const SizedBox(height: 14),
                      PortfolioSetupTextField(
                        controller: _portfolioController,
                        label: 'Portfolio Website',
                        hint: 'https://portfolio.dev',
                        icon: Icons.web_asset_rounded,
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 14),
                      PortfolioSetupTextField(
                        controller: _cvLinkController,
                        label: 'CV Link',
                        hint: 'https://drive.google.com/... or dropbox link',
                        icon: Icons.description_outlined,
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 28),
                      const PortfolioSetupSectionHeader(
                        title: 'Section Visibility',
                        subtitle: 'Toggle visibility of individual portfolio sections.',
                      ),
                      const SizedBox(height: 12),
                      PortfolioVisibilityCard(
                        visibility: _visibility,
                        onChanged: (newVisibility) {
                          setState(() => _visibility = newVisibility);
                        },
                      ),
                      const SizedBox(height: 32),
                      BlocBuilder<PortfolioCubit, PortfolioState>(
                        builder: (context, state) {
                          return SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.isDark ? const Color(0xFF121110) : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                elevation: 0,
                              ),
                              onPressed: state is PortfolioUpdating
                                  ? null
                                  : _saveProfile,
                              child: state is PortfolioUpdating
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.isDark ? const Color(0xFF121110) : Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Save Portfolio',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
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
        ),
      ),
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
          cvLink: _cvLinkController.text.trim(),
          socialLinks: socialLinks,
          profileSlug: _slugController.text.trim(),
          portfolioCompleted: true,
          sectionVisibility: _visibility,
        );
  }
}
