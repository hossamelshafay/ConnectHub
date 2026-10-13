import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:connecthub/features/portfolio_import/data/models/cv_portfolio_model.dart';
import 'package:connecthub/features/portfolio_import/data/repos/portfolio_import_firestore_service.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Preview & Edit',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          if (!_isSaving)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton.icon(
                icon: const Icon(Icons.download_rounded,
                    size: 18, color: Color(0xFF0F172A)),
                label: const Text(
                  'Import',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: _confirmImport,
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFF38BDF8)),
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
            _AiBadge(
              projectCount: _portfolio.projects.length,
              experienceCount: _portfolio.experience.length,
              skillCount: _portfolio.skills.length,
            ),
            const SizedBox(height: 20),

            // ── Identity ─────────────────────────────────────────────────────
            _PreviewSection(
              title: 'Professional Identity',
              icon: Icons.person_rounded,
              child: Column(
                children: [
                  _DarkField(
                      ctrl: _headlineCtrl,
                      label: 'Headline',
                      hint: 'Your professional tagline'),
                  const SizedBox(height: 12),
                  _DarkField(
                      ctrl: _summaryCtrl,
                      label: 'About',
                      hint: 'Your professional summary',
                      maxLines: 4),
                  const SizedBox(height: 12),
                  _DarkField(
                      ctrl: _locationCtrl,
                      label: 'Location',
                      hint: 'City, Country'),
                  const SizedBox(height: 12),
                  _DarkField(
                      ctrl: _phoneCtrl,
                      label: 'Phone',
                      hint: '+1 555 123 4567',
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  _DarkField(
                      ctrl: _websiteCtrl,
                      label: 'Website',
                      hint: 'https://yoursite.com',
                      keyboardType: TextInputType.url),
                  const SizedBox(height: 12),
                  _DarkField(
                      ctrl: _githubCtrl,
                      label: 'GitHub',
                      hint: 'https://github.com/username',
                      keyboardType: TextInputType.url),
                  const SizedBox(height: 12),
                  _DarkField(
                      ctrl: _linkedinCtrl,
                      label: 'LinkedIn',
                      hint: 'https://linkedin.com/in/username',
                      keyboardType: TextInputType.url),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Skills ────────────────────────────────────────────────────────
            _PreviewSection(
              title: 'Skills (${_portfolio.skills.length})',
              icon: Icons.psychology_outlined,
              child: _SkillsEditor(
                skills: _portfolio.skills,
                onChanged: (skills) =>
                    setState(() => _portfolio = _portfolio.copyWith(skills: skills)),
              ),
            ),
            const SizedBox(height: 16),

            // ── Experience ────────────────────────────────────────────────────
            _PreviewSection(
              title: 'Experience (${_portfolio.experience.length})',
              icon: Icons.work_outline_rounded,
              child: _portfolio.experience.isEmpty
                  ? _EmptyHint(label: 'No experience extracted')
                  : Column(
                      children: _portfolio.experience.asMap().entries.map((e) {
                        return _ExperienceCard(
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
            _PreviewSection(
              title: 'Projects (${_portfolio.projects.length})',
              icon: Icons.folder_special_outlined,
              child: _portfolio.projects.isEmpty
                  ? _EmptyHint(label: 'No projects extracted')
                  : Column(
                      children: _portfolio.projects.asMap().entries.map((e) {
                        return _ProjectCard(
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
            _PreviewSection(
              title: 'Education (${_portfolio.education.length})',
              icon: Icons.school_outlined,
              child: _portfolio.education.isEmpty
                  ? _EmptyHint(label: 'No education extracted')
                  : Column(
                      children: _portfolio.education.asMap().entries.map((e) {
                        return _EducationCard(
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
            _PreviewSection(
              title: 'Certificates (${_portfolio.certificates.length})',
              icon: Icons.workspace_premium_outlined,
              child: _portfolio.certificates.isEmpty
                  ? _EmptyHint(label: 'No certificates extracted')
                  : Column(
                      children:
                          _portfolio.certificates.asMap().entries.map((e) {
                        return _CertificateCard(
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
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: const Color(0xFF0F172A),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Import Portfolio?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'This will save all the displayed sections to your portfolio. '
          'Existing data in experience, projects, education, and certificates will be replaced.',
          style: TextStyle(color: Color(0xFF94A3B8), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Import',
                style: TextStyle(
                    color: Color(0xFF38BDF8), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true) await _import();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AI Badge
// ─────────────────────────────────────────────────────────────────────────────

class _AiBadge extends StatelessWidget {
  final int projectCount;
  final int experienceCount;
  final int skillCount;

  const _AiBadge({
    required this.projectCount,
    required this.experienceCount,
    required this.skillCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF38BDF8).withValues(alpha: 0.15),
            const Color(0xFF818CF8).withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded,
              color: Color(0xFF38BDF8), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Parsed by Gemini AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$experienceCount experience · $projectCount projects · $skillCount skills extracted',
                  style: const TextStyle(
                      color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'REVIEW',
              style: TextStyle(
                color: Color(0xFF38BDF8),
                fontWeight: FontWeight.w800,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Preview Section Card
// ─────────────────────────────────────────────────────────────────────────────

class _PreviewSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _PreviewSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF38BDF8), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFF334155), height: 1),
          ),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dark text field
// ─────────────────────────────────────────────────────────────────────────────

class _DarkField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;

  const _DarkField({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5)),
        const SizedBox(height: 4),
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: Color(0xFF475569), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF0F172A),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF334155)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF334155)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Skills Editor
// ─────────────────────────────────────────────────────────────────────────────

class _SkillsEditor extends StatefulWidget {
  final List<String> skills;
  final ValueChanged<List<String>> onChanged;

  const _SkillsEditor({required this.skills, required this.onChanged});

  @override
  State<_SkillsEditor> createState() => _SkillsEditorState();
}

class _SkillsEditorState extends State<_SkillsEditor> {
  late List<String> _skills;
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _skills = List.from(widget.skills);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _add() {
    final v = _ctrl.text.trim();
    if (v.isEmpty || _skills.contains(v)) return;
    setState(() => _skills.add(v));
    _ctrl.clear();
    widget.onChanged(_skills);
  }

  void _remove(int i) {
    setState(() => _skills.removeAt(i));
    widget.onChanged(_skills);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _skills.asMap().entries.map((e) {
            return Chip(
              label: Text(e.value,
                  style: const TextStyle(
                      color: Color(0xFF38BDF8), fontSize: 12)),
              backgroundColor:
                  const Color(0xFF38BDF8).withValues(alpha: 0.12),
              side: const BorderSide(
                  color: Color(0xFF38BDF8), width: 0.5),
              deleteIcon: const Icon(Icons.close, size: 14,
                  color: Color(0xFF64748B)),
              onDeleted: () => _remove(e.key),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _ctrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Add skill…',
                  hintStyle: const TextStyle(
                      color: Color(0xFF475569), fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFF334155)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFF334155)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color(0xFF38BDF8), width: 1.5),
                  ),
                ),
                onFieldSubmitted: (_) => _add(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _add,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add,
                    color: Color(0xFF0F172A), size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Experience Card (inline edit)
// ─────────────────────────────────────────────────────────────────────────────

class _ExperienceCard extends StatelessWidget {
  final CvExperienceModel exp;
  final ValueChanged<CvExperienceModel> onEdit;
  final VoidCallback onDelete;

  const _ExperienceCard({
    required this.exp,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return _ItemCard(
      title: exp.position.isNotEmpty ? exp.position : 'Untitled Role',
      subtitle: exp.company,
      meta:
          [exp.startDate, exp.endDate].where((s) => s.isNotEmpty).join(' – '),
      body: exp.description,
      onEdit: () => _openEditSheet(context),
      onDelete: onDelete,
    );
  }

  void _openEditSheet(BuildContext context) {
    final compCtrl = TextEditingController(text: exp.company);
    final posCtrl = TextEditingController(text: exp.position);
    final startCtrl = TextEditingController(text: exp.startDate);
    final endCtrl = TextEditingController(text: exp.endDate);
    final descCtrl = TextEditingController(text: exp.description);

    _showEditSheet(
      context: context,
      title: 'Edit Experience',
      fields: [
        _SheetField(ctrl: compCtrl, label: 'Company'),
        _SheetField(ctrl: posCtrl, label: 'Position'),
        _SheetField(ctrl: startCtrl, label: 'Start Date'),
        _SheetField(ctrl: endCtrl, label: 'End Date (or "Present")'),
        _SheetField(ctrl: descCtrl, label: 'Description', maxLines: 3),
      ],
      onSave: () => onEdit(exp.copyWith(
        company: compCtrl.text.trim(),
        position: posCtrl.text.trim(),
        startDate: startCtrl.text.trim(),
        endDate: endCtrl.text.trim(),
        description: descCtrl.text.trim(),
      )),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Project Card
// ─────────────────────────────────────────────────────────────────────────────

class _ProjectCard extends StatelessWidget {
  final CvProjectModel project;
  final ValueChanged<CvProjectModel> onEdit;
  final VoidCallback onDelete;

  const _ProjectCard({
    required this.project,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return _ItemCard(
      title: project.title.isNotEmpty ? project.title : 'Untitled Project',
      subtitle:
          project.techStack.isNotEmpty ? project.techStack.join(', ') : '',
      meta: project.github.isNotEmpty ? project.github : project.liveDemo,
      body: project.description,
      onEdit: () => _openEditSheet(context),
      onDelete: onDelete,
    );
  }

  void _openEditSheet(BuildContext context) {
    final titleCtrl = TextEditingController(text: project.title);
    final descCtrl = TextEditingController(text: project.description);
    final techCtrl = TextEditingController(text: project.techStack.join(', '));
    final githubCtrl = TextEditingController(text: project.github);
    final demoCtrl = TextEditingController(text: project.liveDemo);

    _showEditSheet(
      context: context,
      title: 'Edit Project',
      fields: [
        _SheetField(ctrl: titleCtrl, label: 'Title'),
        _SheetField(ctrl: descCtrl, label: 'Description', maxLines: 3),
        _SheetField(
            ctrl: techCtrl,
            label: 'Tech Stack (comma-separated)'),
        _SheetField(ctrl: githubCtrl, label: 'GitHub URL'),
        _SheetField(ctrl: demoCtrl, label: 'Live Demo URL'),
      ],
      onSave: () => onEdit(project.copyWith(
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        techStack: techCtrl.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        github: githubCtrl.text.trim(),
        liveDemo: demoCtrl.text.trim(),
      )),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Education Card
// ─────────────────────────────────────────────────────────────────────────────

class _EducationCard extends StatelessWidget {
  final CvEducationModel edu;
  final ValueChanged<CvEducationModel> onEdit;
  final VoidCallback onDelete;

  const _EducationCard({
    required this.edu,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return _ItemCard(
      title: edu.institution.isNotEmpty ? edu.institution : 'Institution',
      subtitle: edu.degree,
      meta: edu.field.isNotEmpty ? edu.field : '',
      body: [edu.startDate, edu.endDate].where((s) => s.isNotEmpty).join(' – '),
      onEdit: () => _openEditSheet(context),
      onDelete: onDelete,
    );
  }

  void _openEditSheet(BuildContext context) {
    final instCtrl = TextEditingController(text: edu.institution);
    final degCtrl = TextEditingController(text: edu.degree);
    final fieldCtrl = TextEditingController(text: edu.field);
    final startCtrl = TextEditingController(text: edu.startDate);
    final endCtrl = TextEditingController(text: edu.endDate);

    _showEditSheet(
      context: context,
      title: 'Edit Education',
      fields: [
        _SheetField(ctrl: instCtrl, label: 'Institution'),
        _SheetField(ctrl: degCtrl, label: 'Degree'),
        _SheetField(ctrl: fieldCtrl, label: 'Field of Study'),
        _SheetField(ctrl: startCtrl, label: 'Start Date'),
        _SheetField(ctrl: endCtrl, label: 'End Date'),
      ],
      onSave: () => onEdit(edu.copyWith(
        institution: instCtrl.text.trim(),
        degree: degCtrl.text.trim(),
        field: fieldCtrl.text.trim(),
        startDate: startCtrl.text.trim(),
        endDate: endCtrl.text.trim(),
      )),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Certificate Card
// ─────────────────────────────────────────────────────────────────────────────

class _CertificateCard extends StatelessWidget {
  final CvCertificateModel cert;
  final ValueChanged<CvCertificateModel> onEdit;
  final VoidCallback onDelete;

  const _CertificateCard({
    required this.cert,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return _ItemCard(
      title: cert.title.isNotEmpty ? cert.title : 'Certificate',
      subtitle: cert.issuer,
      meta: cert.date,
      body: cert.url.isNotEmpty ? cert.url : '',
      onEdit: () => _openEditSheet(context),
      onDelete: onDelete,
    );
  }

  void _openEditSheet(BuildContext context) {
    final titleCtrl = TextEditingController(text: cert.title);
    final issuerCtrl = TextEditingController(text: cert.issuer);
    final dateCtrl = TextEditingController(text: cert.date);
    final urlCtrl = TextEditingController(text: cert.url);

    _showEditSheet(
      context: context,
      title: 'Edit Certificate',
      fields: [
        _SheetField(ctrl: titleCtrl, label: 'Title'),
        _SheetField(ctrl: issuerCtrl, label: 'Issuing Organization'),
        _SheetField(ctrl: dateCtrl, label: 'Date'),
        _SheetField(ctrl: urlCtrl, label: 'Credential URL'),
      ],
      onSave: () => onEdit(cert.copyWith(
        title: titleCtrl.text.trim(),
        issuer: issuerCtrl.text.trim(),
        date: dateCtrl.text.trim(),
        url: urlCtrl.text.trim(),
      )),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable Item Card (delete + edit)
// ─────────────────────────────────────────────────────────────────────────────

class _ItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String meta;
  final String body;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ItemCard({
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.body,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(subtitle,
                          style: const TextStyle(
                              color: Color(0xFF38BDF8), fontSize: 12)),
                    if (meta.isNotEmpty)
                      Text(meta,
                          style: const TextStyle(
                              color: Color(0xFF64748B), fontSize: 11)),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined,
                    size: 16, color: Color(0xFF94A3B8)),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 16, color: Color(0xFFEF4444)),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              body,
              style: const TextStyle(
                  color: Color(0xFF94A3B8), fontSize: 12, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty hint
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyHint extends StatelessWidget {
  final String label;
  const _EmptyHint({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: Color(0xFF475569), size: 16),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit bottom sheet helper
// ─────────────────────────────────────────────────────────────────────────────

class _SheetField {
  final TextEditingController ctrl;
  final String label;
  final int maxLines;

  const _SheetField({
    required this.ctrl,
    required this.label,
    this.maxLines = 1,
  });
}

void _showEditSheet({
  required BuildContext context,
  required String title,
  required List<_SheetField> fields,
  required VoidCallback onSave,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1E293B),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: ListView(
          controller: scrollCtrl,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF475569),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            ...fields.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.label,
                          style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: f.ctrl,
                        maxLines: f.maxLines,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Color(0xFF334155)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Color(0xFF334155)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFF38BDF8), width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () {
                  onSave();
                  Navigator.pop(context);
                },
                child: const Text('Save Changes',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
