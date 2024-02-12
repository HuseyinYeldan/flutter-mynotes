import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/main.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

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
        titleTextStyle:
            const TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color:  Color.fromARGB(255, 255, 200, 70)),
        title: const Text('E-Posta Onay'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await FirebaseAuth.instance.signOut();
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
                    FirebaseAuth.instance.currentUser?.sendEmailVerification();
                  } on FirebaseAuthException catch (e) {
                    await showErrorDialog(context, e.message.toString());
                  }
                },
                child: const Text('Tekrar Onay Linki Yolla'))
          ],
        ),
      ),
    );
  }
}
