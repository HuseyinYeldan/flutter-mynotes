import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
        title: const Text('Giriş Yap!'),
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
                await AuthService.firebase().logIn(email: email, password: password);
                final user = AuthService.firebase().currentUser;
                  if (user?.isEmailVerified?? false) {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(notesRoute, (route) => false);
                  } else {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        verifyEmailRoute, (route) => false);
                  }
              } 
              on UserNotFoundAuthException {
                await showErrorDialog(context, 'Kullanıcı Bulunamadı.');
              } 
              on WrongPasswordAuthException {
                await showErrorDialog(context, 'Giriş bilgileri yanlış.');
              } 
              on GenericAuthException {
                await showErrorDialog(context, 'Bir hata oluştu.');
              }
              catch (e) {
                await showErrorDialog(context, e.toString());
              }
            },
            child: const Text('Giriş Yap'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text('Hesabınız yok mu? Kayıt Ol!'))
        ],
      ),
    );
  }
}
