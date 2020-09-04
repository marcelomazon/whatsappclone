import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/model/Usuario.dart';
import 'package:whatsapp/telas/AbaContatos.dart';
import 'package:whatsapp/telas/AbaConversas.dart';
import 'package:whatsapp/Routes.dart';
import 'dart:io';

import 'Login.dart';

class Home extends StatefulWidget {
  var usuarioLogado;

  Home(this.usuarioLogado);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController _tabController;
  String _emailUsuario = "";
  List<String> itensMenu = ["Configurações", "Sair"];
  SharedPreferences prefs;
  Usuario usuario;

  Future _verificaUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    if (usuarioLogado == null) {
      Navigator.pushReplacementNamed(context, Routes.ROTA_LOGIN);
    }
  }

  @override
  void initState() {
    _verificaUsuarioLogado();
    //_recuperarUsuario();
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _deslogarUsuario() async {
      FirebaseAuth auth = FirebaseAuth.instance;
      print("desologar");
      await auth.signOut();
      Navigator.pushReplacementNamed(context, Routes.ROTA_LOGIN);
    }

    _escolhaMenuItem(String item) {
      switch (item) {
        case "Configurações":
          print("menu: " + item);
          Navigator.pushNamed(context, Routes.ROTA_CONFIGURACOES);
          break;
        case "Sair":
          print("menu: " + item);
          _deslogarUsuario();
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Whatsapp"),
        bottom: TabBar(
          indicatorWeight: 4,
          labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [Tab(text: "Conversas"), Tab(text: "Contatos")],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _escolhaMenuItem,
            //onCanceled: ,
            itemBuilder: (context) {
              return itensMenu.map((String item) {
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList();
            },
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [AbaConversas(), AbaContatos()],
      ),
    );
  }
}
