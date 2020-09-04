import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/Mensagem.dart';
import 'package:whatsapp/model/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Mensagens extends StatefulWidget {
  Usuario contato;

  Mensagens(this.contato);

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  String _idUsuarioLogado;
  String _idUsuarioDestino;
  Firestore db = Firestore.instance;
  TextEditingController _controllerMensagem = TextEditingController();
  final _controleStream = StreamController<QuerySnapshot>.broadcast(); // controlador para um stream.
  Stream<QuerySnapshot> conversa;
  ScrollController _scrollController = ScrollController();

  void _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();

    _idUsuarioLogado = usuarioLogado.uid;
    _idUsuarioDestino = widget.contato.idUsuario;

    _adicionarListnerMensagens();

  }

  Stream<QuerySnapshot> _recuperarMensagem() {
    return db.collection("mensagens").document(_idUsuarioLogado).collection(_idUsuarioDestino).snapshots();
  }

  void _salvarMensagem(String idRemetente, String idDestinatario, Mensagem mensagem) async {
    await db.collection("mensagens")
        .document(idRemetente)
        .collection(idDestinatario)
        .add(mensagem.toMap());
    _controllerMensagem.clear();
  }

  void _enviarMensagem() {
    String textoMensagem = _controllerMensagem.text;
    if (textoMensagem.isNotEmpty) {
      Mensagem msg = Mensagem();
      msg.idUsuario = _idUsuarioLogado;
      msg.mensagem = textoMensagem;
      msg.urlImagem = "";
      msg.data = Timestamp.now().toString();
      msg.tipo = "texto";

      _salvarMensagem(_idUsuarioLogado, _idUsuarioDestino, msg);
      _salvarMensagem(_idUsuarioDestino, _idUsuarioLogado, msg);
    }
  }

  Stream<QuerySnapshot> _adicionarListnerMensagens() {

    final stream = db.collection("mensagens")
        .document(_idUsuarioLogado)
        .collection(_idUsuarioDestino)
        .orderBy("data", descending: false)
        .snapshots();

    // cria um listner para o nó "ultima_conversa"
    stream.listen((dados) {
      _controleStream.add(dados);
      Timer(Duration(seconds: 1), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent); // envia p final da lista
      });
    });
  }

  void _enviarFoto() {}

  Widget caixaMensagem() {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: TextField(
                controller: _controllerMensagem,
                autofocus: true,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(24, 8, 24, 8),
                    hintText: "Digite uma mensagem",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: _enviarFoto,
                    )),
              ),
            ),
          ),
          FloatingActionButton(
            backgroundColor: Color(0xff075E54),
            child: Icon(Icons.send, color: Colors.white),
            mini: true,
            onPressed: _enviarMensagem,
          )
        ],
      ),
    );
  }

  Widget streamConversa() {
    return StreamBuilder(
      stream: _controleStream.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(), // carregando mensagens
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            QuerySnapshot querySnapshot = snapshot.data;

            if (snapshot.hasError) {
              return Expanded(child: Text("Falha ao carregar mensagem"));
            } else {
              return Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: querySnapshot.documents.length,
                  itemBuilder: (context, indice) {
                    //recupera mensagem
                    List<DocumentSnapshot> mensagens = querySnapshot.documents.toList();

                    // mensagem específica
                    DocumentSnapshot item = mensagens[indice];
                    print("conversa $indice:" + item["mensagem"]);

                    //double largura = MediaQuery.of(context).size.width * 0.8;
                    Alignment alinhamento = Alignment.centerRight;
                    Color cor = Color(0xffc2ffa5);

                    if (item["idUsuario"] != _idUsuarioLogado) {
                      alinhamento = Alignment.centerLeft;
                      cor = Color(0xfff7f7f7);
                    }

                    return Align(
                      alignment: alinhamento,
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Container(
                          //width: largura,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.all(Radius.circular(8))),
                          child: Text(
                            item["mensagem"],
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }

            break;
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
    //conversa = _recuperarMensagem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey,
              backgroundImage: widget.contato.urlImagem != null ? NetworkImage(widget.contato.urlImagem) : null),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(widget.contato.nome),
            )
          ]
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/bg.png"), fit: BoxFit.cover)),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [streamConversa(), caixaMensagem()],
            ),
          ),
        ),
      ),
    );
  }
}
