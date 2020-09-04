import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import 'package:whatsapp/Routes.dart';

class Configuracoes extends StatefulWidget {
  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  TextEditingController _controllerNome = TextEditingController();
  PickedFile _imagem;
  String _idUsuarioLogado;
  bool _carregandoImagem = false;
  String _urlImagemRecuperada;

  Future _recuperarImagem(String origemImagem) async {
    PickedFile imagemSelecionada;
    ImagePicker image = ImagePicker();

    switch (origemImagem) {
      case "camera":
        imagemSelecionada = await image.getImage(source: ImageSource.camera);
        break;
      case "galeria":
        imagemSelecionada = await image.getImage(source: ImageSource.gallery);
        break;
    }

    setState(() {
      _imagem = imagemSelecionada;
      if (_imagem != null) {
        _carregandoImagem = true;
        _uploadImagem();
      }
    });
  }

  Future _uploadImagem() {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz
        .child(
            "perfil") // se não for informada a extesão, cria pasta, senão criar arquivo
        .child(_idUsuarioLogado + ".jpg");

    //arquivo.putFile(_imagem);
    StorageUploadTask task = arquivo.putFile(File(_imagem.path));
    task.events.listen((StorageTaskEvent event) {
      if (event.type == StorageTaskEventType.progress) {
        setState(() {
          _carregandoImagem = true;
        });
      } else if (event.type == StorageTaskEventType.success) {
        setState(() {
          _carregandoImagem = false;
        });
      }
    });

    task.onComplete.then((StorageTaskSnapshot snapshot) {
      _recuperarUrlImagem(snapshot);
    });
  }

  Future _recuperarUrlImagem(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    _atualizarUrlImagemFireStore(url);

    setState(() {
      _urlImagemRecuperada = url;
    });
  }

  _atualizarUrlImagemFireStore(String urlImagemPerfil) async {
    Firestore db = Firestore.instance;

    Map<String, dynamic> dadosAtualizar = {
      "urlImagem" : urlImagemPerfil
    };

    db.collection(("usuarios"))
        .document(_idUsuarioLogado)
        .updateData(dadosAtualizar);

  }

  _atualizarNomeFireStore() async {
    Firestore db = Firestore.instance;

    Map<String, dynamic> dadosAtualizar = {
      "nome" : _controllerNome.text
    };
    // atualiza dados no firebase
    db.collection(("usuarios"))
        .document(_idUsuarioLogado)
        .updateData(dadosAtualizar);

    Navigator.pushNamedAndRemoveUntil(context, Routes.ROTA_HOME, (_)=>false);
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;

    Firestore db = Firestore.instance;
    // recupera os dados do usuário logado
    DocumentSnapshot snapshot = await db.collection("usuarios")
      .document(_idUsuarioLogado)
      .get();

    Map<String, dynamic> dados = snapshot.data;
    _controllerNome.text = dados["nome"]; // recupera nome do usuario

    if (dados['urlImagem'] != null) { // se existe o atributo urlImagem
      setState(() {
        _urlImagemRecuperada = dados["urlImagem"];
      });
    }
  }

  // recuperar dados do usuario logado, para mostrar o nome do input
  // e utilizar o id pra renomear a imagem.
  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurações"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                //carregando
                _carregandoImagem // se estiver carregando a imagem exibe o spiner, senão exibe imagem carregada
                    ? CircularProgressIndicator()
                    : CircleAvatar(
                        radius: 100,
                        backgroundColor: Colors.grey,
                        backgroundImage:
                        _urlImagemRecuperada != null
                          ? NetworkImage(_urlImagemRecuperada)
                          : null
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                      child: Text("Camera"),
                      onPressed: () {
                        _recuperarImagem("camera");
                      },
                    ),
                    FlatButton(
                      child: Text("Galeria"),
                      onPressed: () {
                        _recuperarImagem("galeria");
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: _controllerNome,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "Nome",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                    onPressed: _atualizarNomeFireStore,
                    child: Text(
                      "Salvar",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    color: Colors.green,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
