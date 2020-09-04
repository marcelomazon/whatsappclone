import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp/model/Usuario.dart';

import '../Routes.dart';

class AbaContatos extends StatefulWidget {
  @override
  _AbaContatosState createState() => _AbaContatosState();
}

class _AbaContatosState extends State<AbaContatos> {
  String _idUsuarioLogado;
  String _emailUsuarioLogado;

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;
    _emailUsuarioLogado = usuarioLogado.email;
  }

  Future<List<Usuario>> _recuperarContatos() async {
    Firestore db = Firestore.instance;

    QuerySnapshot querySnapshot = await db.collection("usuarios").getDocuments();

    List<Usuario> listaUsuarios = List();
    for (DocumentSnapshot item in querySnapshot.documents) {
      var dados = item.data;

      // ignora item onde o usuario é o mesmo do contato logado
      if (dados["email"] == _emailUsuarioLogado) continue;

      Usuario usuario = Usuario();

      usuario.idUsuario = item.documentID;
      usuario.nome = dados["nome"];
      usuario.email = dados["email"];
      usuario.urlImagem = dados["urlImagem"];

      listaUsuarios.add(usuario);
    }

    return listaUsuarios;
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Usuario>>(
      future: _recuperarContatos(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, indice) {
                  List<Usuario> listaItens = snapshot.data;
                  Usuario usuario = listaItens[indice];
                  return ListTile(
                    onTap: () {
                      //interessante: parametro usuario selecionado
                      //Navigator.pushNamed(context, Routes.ROTA_MENSAGENS, arguments: usuario);
                      Navigator.pushNamed(context, Routes.ROTA_CHAT, arguments: usuario);
                    },
                    contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    leading: CircleAvatar(
                        maxRadius: 30,
                        backgroundColor: Colors.grey,
                        backgroundImage: usuario.urlImagem != null ? NetworkImage(usuario.urlImagem) : null),
                    title: Text(
                      usuario.nome,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  );
                });
            break;
        }
      },
    );
  }
}
