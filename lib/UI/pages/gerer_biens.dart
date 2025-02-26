// gererBiens.dart
import 'package:allo/data/db/supabase.dart';
import 'package:allo/data/models/annonce.dart';
import 'package:allo/provider/biens_rendu_provider.dart';
import 'package:allo/provider/user_provider.dart';
import 'package:allo/service/notif_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GererBiens extends StatefulWidget {
  final Map<int, List<Annonce>> annonceArendre;
  const GererBiens({Key? key, required this.annonceArendre}) : super(key: key);

  @override
  State<GererBiens> createState() => _GererBiensState();
}

class _GererBiensState extends State<GererBiens> {
  List<int> biensRendus = [];
  Map<int, List<Annonce>> annonceArendre = {};

  @override
  void initState() {
    super.initState();
    annonceArendre = Map.from(widget.annonceArendre);
  }

  @override
  Widget build(BuildContext context) {
    var biensRendusModel = Provider.of<BiensRendusModel>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les biens'),
      ),
      body: ListView.builder(
        itemCount: annonceArendre.entries.length,
        itemBuilder: (context, index) {
          final entry = annonceArendre.entries.elementAt(index);
          final int userId = entry.key;
          final List<Annonce> annonceList = entry.value;
          print("Annonce a rendre: $annonceList");
          return annonceList
                  .any((annonce) => annonce.idU == userProvider.user['idU'])
              ? ExpansionTile(
                  title: Text('Utilisateur $userId'),
                  children: annonceList.map((annonce) {
                    return ListTile(
                      title: Text(annonce.libelle,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      trailing: biensRendusModel.estRendu(annonce.id)
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.check_circle_outline),
                      onTap: () {
                        if (biensRendusModel.estRendu(annonce.id)) {
                          biensRendusModel.removeBienRendu(annonce.id);
                          SupabaseDB.updatePreter(
                              annonce: annonce,
                              etatPret: true,
                              etat: "en cours");
                        } else {
                          biensRendusModel.addBienRendu(annonce.id);
                          SupabaseDB.updatePreter(
                              annonce: annonce, etatPret: false, etat: "rendu");
                              
                          NotificationService()
                              .showNotification(
                                  title: 'Bien rendu',
                                  body:
                                      'Le bien ${annonce.libelle} a été rendu')
                              .then((_) => Future.delayed(
                                  Duration(seconds: 2),
                                  () => NotificationService().showNotification(
                                      title: 'Annonce a cloturée',
                                      body:
                                          'Allez cloturer l\'annonce ${annonce.libelle}')));
                          setState(() {
                            annonceArendre[userId] = annonceList
                                .where((a) => a.id != annonce.id)
                                .toList();
                          });
                        }
                      },
                    );
                  }).toList(),
                )
              : Container();
        },
      ),
    );
  }
}
