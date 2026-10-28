import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:connecthub/features/portfolio_import/data/models/cv_portfolio_model.dart';
import 'package:connecthub/features/portfolio_import/data/repos/portfolio_import_firestore_service.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/preview/cv_preview_ai_badge.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/preview/cv_preview_section.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/preview/cv_preview_identity_section.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/preview/cv_preview_skills_editor.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/preview/cv_preview_experience_card.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/preview/cv_preview_project_card.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/preview/cv_preview_education_card.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/preview/cv_preview_certificate_card.dart';

/// Beautiful editable preview of the AI-parsed portfolio.
/// The user can review, edit, remove items, then press "Import Portfolio".
class CvPreviewView extends StatefulWidget {
  final CvPortfolioModel portfolio;
  final String userId;
  final VoidCallback? onImportComplete;

  const CvPreviewView({
    super.key,
    required this.portfolio,
    required this.userId,
    this.onImportComplete,
  });

  @override
  State<CvPreviewView> createState() => _CvPreviewViewState();
}

class _CvPreviewViewState extends State<CvPreviewView> {
  late CvPortfolioModel _portfolio;
  bool _isSaving = false;

  // Controllers for identity fields
  late TextEditingController _headlineCtrl;
  late TextEditingController _summaryCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _websiteCtrl;
  late TextEditingController _githubCtrl;
  late TextEditingController _linkedinCtrl;

  @override
  void initState() {
    super.initState();
    _portfolio = widget.portfolio;
    _headlineCtrl = TextEditingController(text: _portfolio.headline);
    _summaryCtrl = TextEditingController(text: _portfolio.summary);
    _locationCtrl = TextEditingController(text: _portfolio.location);
    _phoneCtrl = TextEditingController(text: _portfolio.phone);
    _websiteCtrl = TextEditingController(text: _portfolio.website);
    _githubCtrl = TextEditingController(text: _portfolio.github);
    _linkedinCtrl = TextEditingController(text: _portfolio.linkedin);
  }

  @override
  void dispose() {
    _headlineCtrl.dispose();
    _summaryCtrl.dispose();
    _locationCtrl.dispose();
    _phoneCtrl.dispose();
    _websiteCtrl.dispose();
    _githubCtrl.dispose();
    _linkedinCtrl.dispose();
    super.dispose();
  }

  // ── Save snapshot from controllers ────────────────────────────────────────

  void _syncIdentityFromControllers() {
    _portfolio = _portfolio.copyWith(
      headline: _headlineCtrl.text.trim(),
      summary: _summaryCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      website: _websiteCtrl.text.trim(),
      github: _githubCtrl.text.trim(),
      linkedin: _linkedinCtrl.text.trim(),
    );
  }

  // ── Import ────────────────────────────────────────────────────────────────

  Future<void> _import() async {
    _syncIdentityFromControllers();
    setState(() => _isSaving = true);
    try {
      await PortfolioImportFirestoreService().importPortfolio(
        uid: widget.userId,
        portfolio: _portfolio,
      );
      if (mounted) {
        // Pop FIRST so CvPreviewView is removed and the HomeView/PortfolioView
        // tree is fully restored before we trigger any state refresh.
        Navigator.of(context).pop();

        // Show the snack on the underlying scaffold after the pop.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✨ Portfolio imported successfully!'),
            backgroundColor: const Color(0xFF22C55E),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        // Refresh the portfolio cubit AFTER the frame so PortfolioView's
        // MultiBlocProvider is fully live before we emit PortfolioLoading.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onImportComplete?.call();
        });
      }
    } on FirebaseException catch (e, st) {
      // ignore: avoid_print
      print('================================================================');
      // ignore: avoid_print
      print('[CvPreviewView] FirebaseException caught during import:');
      // ignore: avoid_print
      print('Plugin: ${e.plugin} | Code: ${e.code} | Message: ${e.message}');
      // ignore: avoid_print
      print('Stack Trace:\n$st');
      // ignore: avoid_print
      print('================================================================');
      if (mounted) {
        setState(() => _isSaving = false);
        _showError(
          'Failed to save portfolio to Firebase [${e.code}]: ${e.message ?? "Network or permission error"}',
          canRetry: true,
        );
      }
    } catch (e, st) {
      // ignore: avoid_print
      print('================================================================');
      // ignore: avoid_print
      print('[CvPreviewView] General exception caught during import: $e\n$st');
      // ignore: avoid_print
      print('================================================================');
      if (mounted) {
        setState(() => _isSaving = false);
        _showError('Failed to save portfolio: ${e.toString()}', canRetry: true);
      }
    }
  }

  void _showError(String msg, {bool canRetry = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 8),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: canRetry
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: _import,
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Preview & Edit',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          if (!_isSaving)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton.icon(
                icon: Icon(
                  Icons.download_rounded,
                  size: 18,
                  color: isDark ? const Color(0xFF141210) : Colors.white,
                ),
                label: Text(
                  'Import',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF141210) : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: _confirmImport,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: theme.colorScheme.primary),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── AI badge ─────────────────────────────────────────────────────
            CvPreviewAiBadge(
              projectCount: _portfolio.projects.length,
              experienceCount: _portfolio.experience.length,
              skillCount: _portfolio.skills.length,
            ),
            const SizedBox(height: 20),

            // ── Identity ─────────────────────────────────────────────────────
            CvPreviewIdentitySection(
              headlineCtrl: _headlineCtrl,
              summaryCtrl: _summaryCtrl,
              locationCtrl: _locationCtrl,
              phoneCtrl: _phoneCtrl,
              websiteCtrl: _websiteCtrl,
              githubCtrl: _githubCtrl,
              linkedinCtrl: _linkedinCtrl,
            ),
            const SizedBox(height: 16),

            // ── Skills ────────────────────────────────────────────────────────
            CvPreviewSection(
              title: 'Skills (${_portfolio.skills.length})',
              icon: Icons.psychology_outlined,
              child: CvPreviewSkillsEditor(
                skills: _portfolio.skills,
                onChanged: (skills) =>
                    setState(() => _portfolio = _portfolio.copyWith(skills: skills)),
              ),
            ),
            const SizedBox(height: 16),

            // ── Experience ────────────────────────────────────────────────────
            CvPreviewSection(
              title: 'Experience (${_portfolio.experience.length})',
              icon: Icons.work_outline_rounded,
              child: _portfolio.experience.isEmpty
                  ? const CvPreviewEmptyHint(label: 'No experience extracted')
                  : Column(
                      children: _portfolio.experience.asMap().entries.map((e) {
                        return CvPreviewExperienceCard(
                          exp: e.value,
                          onEdit: (updated) => setState(() {
                            final list = [..._portfolio.experience];
                            list[e.key] = updated;
                            _portfolio = _portfolio.copyWith(experience: list);
                          }),
                          onDelete: () => setState(() {
                            final list = [..._portfolio.experience];
                            list.removeAt(e.key);
                            _portfolio = _portfolio.copyWith(experience: list);
                          }),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 16),

            // ── Projects ─────────────────────────────────────────────────────
            CvPreviewSection(
              title: 'Projects (${_portfolio.projects.length})',
              icon: Icons.folder_special_outlined,
              child: _portfolio.projects.isEmpty
                  ? const CvPreviewEmptyHint(label: 'No projects extracted')
                  : Column(
                      children: _portfolio.projects.asMap().entries.map((e) {
                        return CvPreviewProjectCard(
                          project: e.value,
                          onEdit: (updated) => setState(() {
                            final list = [..._portfolio.projects];
                            list[e.key] = updated;
                            _portfolio = _portfolio.copyWith(projects: list);
                          }),
                          onDelete: () => setState(() {
                            final list = [..._portfolio.projects];
                            list.removeAt(e.key);
                            _portfolio = _portfolio.copyWith(projects: list);
                          }),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 16),

            // ── Education ─────────────────────────────────────────────────────
            CvPreviewSection(
              title: 'Education (${_portfolio.education.length})',
              icon: Icons.school_outlined,
              child: _portfolio.education.isEmpty
                  ? const CvPreviewEmptyHint(label: 'No education extracted')
                  : Column(
                      children: _portfolio.education.asMap().entries.map((e) {
                        return CvPreviewEducationCard(
                          edu: e.value,
                          onEdit: (updated) => setState(() {
                            final list = [..._portfolio.education];
                            list[e.key] = updated;
                            _portfolio = _portfolio.copyWith(education: list);
                          }),
                          onDelete: () => setState(() {
                            final list = [..._portfolio.education];
                            list.removeAt(e.key);
                            _portfolio = _portfolio.copyWith(education: list);
                          }),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 16),

            // ── Certificates ──────────────────────────────────────────────────
            CvPreviewSection(
              title: 'Certificates (${_portfolio.certificates.length})',
              icon: Icons.workspace_premium_outlined,
              child: _portfolio.certificates.isEmpty
                  ? const CvPreviewEmptyHint(label: 'No certificates extracted')
                  : Column(
                      children:
                          _portfolio.certificates.asMap().entries.map((e) {
                        return CvPreviewCertificateCard(
                          cert: e.value,
                          onEdit: (updated) => setState(() {
                            final list = [..._portfolio.certificates];
                            list[e.key] = updated;
                            _portfolio =
                                _portfolio.copyWith(certificates: list);
                          }),
                          onDelete: () => setState(() {
                            final list = [..._portfolio.certificates];
                            list.removeAt(e.key);
                            _portfolio =
                                _portfolio.copyWith(certificates: list);
                          }),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 32),

            // ── Import CTA ───────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.download_rounded, size: 20),
                label: const Text(
                  'Import Portfolio',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.isDark ? const Color(0xFF141210) : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isSaving ? null : _confirmImport,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmImport() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1B18) : const Color(0xFFFFFFFF),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Import Portfolio?',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This will save all the displayed sections to your portfolio. '
          'Existing data in experience, projects, education, and certificates will be replaced.',
          style: TextStyle(
            color: isDark ? const Color(0xFFC7BFB5) : const Color(0xFF4B453F),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? const Color(0xFF888076) : const Color(0xFF6B645C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Import',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) await _import();
  }
}
