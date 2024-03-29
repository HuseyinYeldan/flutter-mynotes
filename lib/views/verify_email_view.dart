import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';
import 'package:mynotes/views/notes/notes_view.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 61, 39, 10),
        foregroundColor: const Color.fromARGB(255, 255, 200, 70),
        titleTextStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 26,
            color: Color.fromARGB(255, 255, 200, 70)),
        title: const Text('E-Posta Onay'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (_) => false);
                  }
                  break;
                default:
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Çıkış Yap'),
                ),
              ];
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const Text('Lütfen devam etmek için e-postanızı onaylayın.'),
            TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                },
                child: const Text('Giriş Yap')),
            const Text(
                'E-postanıza onay linki gelemdi mi? Aşşağıdaki butona tıklayarak yollayabilirsiniz. (Spam kutusuna bakmayı unutmayın.)'),
            TextButton(
                onPressed: () async {
                  try {
                    await AuthService.firebase().sendEmailVerification();
                  } on GenericAuthException {
                    await showErrorDialog(context, 'Bir hata oluştu.');
                  }
                },
                child: const Text('Tekrar Onay Linki Yolla'))
          ],
        ),
      ),
    );
  }
}
