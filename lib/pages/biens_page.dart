import 'package:allo/UI/components/button.dart';
import 'package:allo/UI/pages/ajouter_biens.dart';
import 'package:allo/data/db/alloDB.dart';
import 'package:allo/data/models/objet.dart';
import 'package:allo/UI/pages/update_biens_page.dart';
import 'package:flutter/material.dart';
// biensPage.dart
class BiensPage extends StatefulWidget {
  BiensPage({super.key});

  @override
  State<BiensPage> createState() => _BiensPageState();
}

class _BiensPageState extends State<BiensPage> {
  late Future<List<Biens>> _biensList;

  @override
  void initState() {
    super.initState();
    _biensList = AllDB().biens();
  }

  void _updateBiensList() {
    setState(() {
      _biensList = AllDB().biens();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biens Brouillons'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Biens>>(
              future: _biensList,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Biens>> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (BuildContext context, int index) {
                      Biens biens = snapshot.data![index];
                      return ListTile(
                        title: Text(biens.libelle),
                        subtitle: Text(biens.description),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UpdateBiensPage(biens: biens),
                            ),
                          ).then((value) => setState(() {
                                _biensList = AllDB().biens();
                              }));
                        },
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Erreur: ${snapshot.error}');
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),
          ButtonSelect(
            text: 'Ajouter un bien',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BiensAddPage(),
                ),
              ).then((value) => _updateBiensList());
            },
            buttonColor: const Color(0xFFD9D9D9),
            textColor: const Color.fromARGB(255, 0, 0, 0),
            textStyle: "Jomhuria",
            tailleHeight: 60,
            tailleWidth: 130,
            fontSize: 20,
          )
        ],
      ),
    );
  }
}
