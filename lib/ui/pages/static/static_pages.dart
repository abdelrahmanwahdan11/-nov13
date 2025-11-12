import 'package:flutter/material.dart';

import '../../widgets/genius_scaffold.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _StaticTemplate(title: 'Help Center', body: 'Frequently asked questions and tutorials.');
  }
}

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _StaticTemplate(title: 'Terms of Service', body: 'All the legal things you agree to.');
  }
}

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _StaticTemplate(title: 'Report Content', body: 'Describe the issue you encountered.');
  }
}

class _StaticTemplate extends StatelessWidget {
  const _StaticTemplate({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return GeniusScaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(body),
      ),
    );
  }
}
