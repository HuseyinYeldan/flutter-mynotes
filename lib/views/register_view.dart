import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email = TextEditingController();
  late final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 61, 39, 10),
        foregroundColor: const Color.fromARGB(255, 255, 200, 70),
        titleTextStyle:
            const TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color:  Color.fromARGB(255, 255, 200, 70)),
        title: const Text('Kayıt Ol!'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'E-posta...'),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: 'Şifre...'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final email = _email.text;
                final password = _password.text;
                await AuthService.firebase().createUser(email: email, password: password);
                Navigator.of(context).pushNamed(verifyEmailRoute);
                AuthService.firebase().sendEmailVerification();
              } on WeakPasswordAuthException {
                await showErrorDialog(context, 'Şifre en az 6 karakter olmalı.');
              }
              on EmailAlreadyInUseAuthException {
                await showErrorDialog(context, 'Bu e-posta kullanılıyor.');
              }
              on InvalidEmailAuthException {
                await showErrorDialog(context, 'E-posta yanlış.');
              }
              on GenericAuthException {
                await showErrorDialog(context, 'Bir hata oluştu.');
              }
              catch(e){
                await showErrorDialog(context, e.toString());
              }
            },
            child: const Text('Kayıt Ol'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginRoute, (route) => false);
              },
              child: const Text('Hesabınız var mı? Giriş Yapın!'))
        ],
      ),
    );
  }
}
