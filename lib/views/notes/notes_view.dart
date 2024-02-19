import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 15, 55, 1),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color.fromRGBO(0, 32, 114, 1),
        foregroundColor: const Color.fromARGB(255, 255, 200, 70),
        titleTextStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: Color.fromARGB(255, 255, 200, 70)),
        title: Column(
          children: [
            const Text(
              'Hoşgeldin',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color.fromARGB(255, 255, 200, 70),
              ),
            ),
            Text(
              AuthService.firebase().currentUser!.email.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 16,
                color: Color.fromARGB(255, 255, 200, 70),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(newNoteRoute);
              },
              icon: const Icon(Icons.add)),
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
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                  stream: _notesService.allNotes,
                  builder: ((context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        return const Center(
                            child: Text(
                          'Notlar bekleniyor...',
                          style: TextStyle(
                            color: Colors.amber,
                          ),
                        ));
                      default:
                        return const Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.amber,
                            color: Colors.white,
                          ),
                        );
                    }
                  }));
            default:
              return const Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.amber,
                  color: Colors.white,
                ),
              );
          }
        },
      ),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Çıkış Yap'),
          content: const Text('Çıkış yapmak istediğine emin misin?'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('İptal')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Çıkış'))
          ],
        );
      }).then((value) => value ?? false);
}
