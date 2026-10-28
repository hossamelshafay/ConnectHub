import 'package:flutter/material.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/preview/cv_preview_section.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/preview/cv_preview_dark_field.dart';

class CvPreviewIdentitySection extends StatelessWidget {
  final TextEditingController headlineCtrl;
  final TextEditingController summaryCtrl;
  final TextEditingController locationCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController websiteCtrl;
  final TextEditingController githubCtrl;
  final TextEditingController linkedinCtrl;

  const CvPreviewIdentitySection({
    super.key,
    required this.headlineCtrl,
    required this.summaryCtrl,
    required this.locationCtrl,
    required this.phoneCtrl,
    required this.websiteCtrl,
    required this.githubCtrl,
    required this.linkedinCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return CvPreviewSection(
      title: 'Professional Identity',
      icon: Icons.person_rounded,
      child: Column(
        children: [
          CvPreviewDarkField(
            ctrl: headlineCtrl,
            label: 'Headline',
            hint: 'Your professional tagline',
          ),
          const SizedBox(height: 12),
          CvPreviewDarkField(
            ctrl: summaryCtrl,
            label: 'About',
            hint: 'Your professional summary',
            maxLines: 4,
          ),
          const SizedBox(height: 12),
          CvPreviewDarkField(
            ctrl: locationCtrl,
            label: 'Location',
            hint: 'City, Country',
          ),
          const SizedBox(height: 12),
          CvPreviewDarkField(
            ctrl: phoneCtrl,
            label: 'Phone',
            hint: '+1 555 123 4567',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          CvPreviewDarkField(
            ctrl: websiteCtrl,
            label: 'Website',
            hint: 'https://yoursite.com',
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 12),
          CvPreviewDarkField(
            ctrl: githubCtrl,
            label: 'GitHub',
            hint: 'https://github.com/username',
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 12),
          CvPreviewDarkField(
            ctrl: linkedinCtrl,
            label: 'LinkedIn',
            hint: 'https://linkedin.com/in/username',
            keyboardType: TextInputType.url,
          ),
        ],
      ),
    );
  }
}
