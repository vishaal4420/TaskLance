import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../auth/providers/auth_providers.dart';

class CreateProposalScreen extends ConsumerStatefulWidget {
  final String? projectId;

  const CreateProposalScreen({super.key, this.projectId});

  @override
  ConsumerState<CreateProposalScreen> createState() => _CreateProposalScreenState();
}

class _CreateProposalScreenState extends ConsumerState<CreateProposalScreen> {
  final _budgetCtrl = TextEditingController();
  final _scopeCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _budgetCtrl.dispose();
    _scopeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitProposal() async {
    if (widget.projectId == null) {
      AppSnackBar.error(context, 'No project specified');
      return;
    }

    final budget = double.tryParse(_budgetCtrl.text.trim());
    if (budget == null || budget <= 0) {
      AppSnackBar.error(context, 'Please enter a valid budget');
      return;
    }

    final scope = _scopeCtrl.text.trim();
    if (scope.isEmpty) {
      AppSnackBar.error(context, 'Please enter a scope of work');
      return;
    }

    setState(() => _loading = true);

    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) throw Exception('Not logged in');

      final projectDoc = await FirebaseFirestore.instance.collection('projects').doc(widget.projectId).get();
      if (!projectDoc.exists) throw Exception('Project not found');
      final clientUid = projectDoc.data()?['clientUid'] as String?;
      final clientName = projectDoc.data()?['clientName'] as String?;

      final proposalId = const Uuid().v4();
      final proposalData = {
        'id': proposalId,
        'projectId': widget.projectId,
        'freelancerUid': user.uid,
        'freelancerName': user.name,
        'freelancerAvatarUrl': user.avatarUrl,
        'clientUid': clientUid,
        'clientName': clientName,
        'bidAmount': budget,
        'coverLetter': scope,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('proposals').doc(proposalId).set(proposalData);

      if (!mounted) return;
      AppSnackBar.success(context, 'Proposal Sent!');
      context.pop();
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Failed to send proposal: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Proposal')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppTextField(
            label: 'Proposed Budget (\$)', 
            controller: _budgetCtrl,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.attach_money_rounded,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Scope of Work', 
            controller: _scopeCtrl,
            maxLines: 6, 
            hint: 'Describe what you will deliver...',
          ),
          const SizedBox(height: 32),
          AppButton(
            label: 'Send Proposal',
            onPressed: _submitProposal,
            isLoading: _loading,
            width: double.infinity,
            icon: Icons.send_rounded,
          ),
        ],
      ),
    );
  }
}
