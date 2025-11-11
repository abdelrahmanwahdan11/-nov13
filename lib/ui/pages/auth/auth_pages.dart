import 'package:flutter/material.dart';

import '../../../controllers/auth_controller.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../widgets/divider_text.dart';
import '../../widgets/genius_input.dart';
import '../../widgets/pill_buttons.dart';
import '../../widgets/social_pill_row.dart';
import '../../widgets/password_strength_meter.dart';
import '../../widgets/genius_scaffold.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key, required this.controller});

  final AuthController controller;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GeniusScaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.translate('signin'), style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 24),
              GeniusInput(
                controller: _email,
                hintText: l10n.translate('email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              GeniusInput(
                controller: _password,
                hintText: l10n.translate('password'),
                obscureText: _obscure,
                suffix: IconButton(
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscure = !_obscure;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/auth/forgot'),
                  child: Text(l10n.translate('forgot_password')),
                ),
              ),
              const SizedBox(height: 16),
              FilledPillButton(
                label: l10n.translate('signin'),
                onPressed: _loading
                    ? null
                    : () async {
                        setState(() {
                          _loading = true;
                        });
                        await widget.controller.signIn(_email.text, _password.text);
                        if (!mounted) return;
                        setState(() {
                          _loading = false;
                        });
                        Navigator.of(context).pushReplacementNamed('/home');
                      },
              ),
              const SizedBox(height: 16),
              OutlinedPillButton(
                label: l10n.translate('guest_continue'),
                onPressed: () async {
                  await widget.controller.continueAsGuest();
                  if (!mounted) return;
                  Navigator.of(context).pushReplacementNamed('/home');
                },
              ),
              const SizedBox(height: 24),
              DividerText(text: l10n.translate('or_signup_email')),
              const SizedBox(height: 24),
              const SocialPillRow(),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/auth/signup'),
                child: Text(l10n.translate('signup')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, required this.controller});

  final AuthController controller;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscure = true;
  int _score = 0;
  bool _agreed = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GeniusScaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.translate('signup'),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 40),
              ),
              const SizedBox(height: 24),
              const SocialPillRow(),
              const SizedBox(height: 24),
              DividerText(text: l10n.translate('or_signup_email')),
              const SizedBox(height: 24),
              GeniusInput(
                controller: _username,
                hintText: l10n.translate('username'),
              ),
              const SizedBox(height: 16),
              GeniusInput(
                controller: _email,
                hintText: l10n.translate('email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              GeniusInput(
                controller: _password,
                hintText: l10n.translate('password'),
                obscureText: _obscure,
                onChanged: (value) {
                  setState(() {
                    _score = computePasswordScore(value);
                  });
                },
                suffix: IconButton(
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              const SizedBox(height: 12),
              PasswordStrengthMeter(score: _score),
              const SizedBox(height: 8),
              Text(passwordLabel(_score)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Checkbox(
                    value: _agreed,
                    onChanged: (value) => setState(() => _agreed = value ?? false),
                  ),
                  Expanded(
                    child: Text(
                      l10n.translate('agree_tos'),
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledPillButton(
                label: l10n.translate('signup'),
                onPressed: !_agreed || _loading
                    ? null
                    : () async {
                        setState(() {
                          _loading = true;
                        });
                        await widget.controller.signUp(_email.text, _password.text, _username.text);
                        if (!mounted) return;
                        setState(() {
                          _loading = false;
                        });
                        Navigator.of(context).pushReplacementNamed('/home');
                      },
              ),
              const SizedBox(height: 16),
              OutlinedPillButton(
                label: l10n.translate('guest_continue'),
                onPressed: () async {
                  await widget.controller.continueAsGuest();
                  if (!mounted) return;
                  Navigator.of(context).pushReplacementNamed('/home');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _email = TextEditingController();
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GeniusScaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.translate('forgot_password'), style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            GeniusInput(
              controller: _email,
              hintText: l10n.translate('email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            FilledPillButton(
              label: _sent ? 'Sent!' : 'Send Link',
              onPressed: () {
                setState(() {
                  _sent = true;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
