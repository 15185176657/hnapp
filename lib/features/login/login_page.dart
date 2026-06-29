import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/section_card.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _accountController = TextEditingController();
  final _codeController = TextEditingController();
  bool _codeSent = false;
  bool _isSubmitting = false;
  String? _message;

  @override
  void dispose() {
    _accountController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    FocusScope.of(context).unfocus();
    final account = _accountController.text.trim();
    if (account.isEmpty) {
      setState(() => _message = 'Enter phone number or email first.');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _message = null;
    });
    await AppScope.of(context).authApi.sendOtp(account: account);
    if (!mounted) {
      return;
    }
    setState(() {
      _codeSent = true;
      _isSubmitting = false;
      _message = 'Demo code sent. Use any 6 digits to continue.';
    });
  }

  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();
    final account = _accountController.text.trim();
    final code = _codeController.text.trim();
    if (account.isEmpty || code.length < 4) {
      setState(() => _message = 'Enter account and verification code.');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _message = null;
    });
    final token = await AppScope.of(
      context,
    ).authApi.verifyOtp(account: account, code: code);
    if (!mounted) {
      return;
    }
    AppScope.of(context).authSession.signInWithToken(token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
          children: [
            const Icon(
              Icons.solar_power_rounded,
              size: 52,
              color: AppColors.solar,
            ),
            const SizedBox(height: 18),
            Text(
              'Sign in',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Use phone or email OTP to access your solar station.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _accountController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Phone or email',
                      prefixIcon: Icon(Icons.alternate_email_rounded),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _isSubmitting ? null : _sendCode,
                    icon: const Icon(Icons.sms_rounded),
                    label: const Text('Send code'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _codeController,
                    enabled: _codeSent,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Verification code',
                      prefixIcon: Icon(Icons.pin_rounded),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _isSubmitting ? null : _signIn(),
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _message!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _isSubmitting ? null : _signIn,
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Sign in'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
