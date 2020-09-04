import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/model/Conversa.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp/model/Usuario.dart';
import '../Routes.dart';

class AbaConversas extends StatefulWidget {
  @override
  _AbaConversasState createState() => _AbaConversasState();
}

class _AbaConversasState extends State<AbaConversas> {

  List<Conversa> _listaConversas = List();
  final _controleStream = StreamController<QuerySnapshot>.broadcast(); // controlador para um stream.
  Firestore db = Firestore.instance;
  SharedPreferences prefs;
  String _idUsuarioLogado;

  Stream<QuerySnapshot> _adicionarListnerConversas() {

    final stream = db.collection("conversas")
        .document(_idUsuarioLogado)
        .collection("ultima_conversa")
        .snapshots();

    // cria um listner para o nó "ultima_conversa"
    stream.listen((dados) {
      _controleStream.add(dados);
    });
  }

  _recuperaUsuarioLogado() async {

    prefs = await SharedPreferences.getInstance();
    _idUsuarioLogado = prefs.getString('idUsuario') ?? ''; //setado no Home
    print("usuario logado: " + _idUsuarioLogado);

    // inicializa o listner
    _adicionarListnerConversas();

  }

  @override
  void initState() {
    super.initState();
    _recuperaUsuarioLogado();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    /// _controleStream.close();
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: _controleStream.stream,
      builder: (context, snapshot){
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator()
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Center(
                child: Text("Erro ao carregar os dados!"),
              );
            } else {

              QuerySnapshot querySnapshot = snapshot.data;

              if( querySnapshot.documents.length == 0 ){
                return Center(
                  child: Text("Você não tem nenhuma conversa ainda :(")
                );
              }

              return ListView.builder(
                  itemCount: querySnapshot.documents.length, // _listaConversas.length,
                  itemBuilder: (context, indice){

                    List<DocumentSnapshot> conversas = querySnapshot.documents.toList();
                    DocumentSnapshot item = conversas[indice];

                    String urlImagem      = item["caminhoFoto"];
                    String tipo           = item["tipoMensagem"] ?? '0';
                    String mensagem       = item["mensagem"] ?? 'sem mensagem';
                    String nome           = item["nome"] ?? 'sem nome';
                    String idDestinatario = item["idDestinatario"];

                    // para iniciar a conversa com usuario
                    Usuario usuario = Usuario();
                    usuario.nome = nome;
                    usuario.urlImagem = urlImagem;
                    usuario.idUsuario = idDestinatario;

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
                        backgroundImage: urlImagem != null
                            ? NetworkImage( urlImagem )
                            : null,
                      ),
                      title: Text(
                        nome,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        ),
                      ),
                      subtitle: Text(
                          tipo == "0"
                              ? mensagem
                              : "Imagem...",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14
                          )
                      ),
                    );

                  }
              );

            }
        }
      },
    );
  }
}
