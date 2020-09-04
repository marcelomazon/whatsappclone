import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/model/Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp/Routes.dart';
import 'package:whatsapp/Cadastro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  String _msgErro = "";
  SharedPreferences prefs;

  void _logarUsuario(Usuario usuario) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    prefs = await SharedPreferences.getInstance(); // preferencias locais

    auth.signInWithEmailAndPassword(
      email: usuario.email,
      password: usuario.senha
    ).then((firebaseUser) async {
      Firestore db = Firestore.instance;
      DocumentSnapshot dados = await db.collection("usuarios").document(firebaseUser.uid).get();

      prefs = await SharedPreferences.getInstance();

      print("dados Usuario: " + dados.data.toString());

      await prefs.setString('idUsuario', firebaseUser.uid);
      await prefs.setString('nome', dados.data["nome"]);
      await prefs.setString('urlImagem', dados.data["urlImagem"]);

      Navigator.pushReplacementNamed(context, Routes.ROTA_HOME, arguments: firebaseUser);
        print("teste");
    }).catchError((onError) {
      _msgErro = "Falha no login: " + onError.toString();
    });
  }

  _validarCampos() {
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if (email.isEmpty) {
      setState(() {
        _msgErro = "Preencha um e-mail válido";
      });
    } else if (senha.isEmpty) {
      setState(() {
        _msgErro = "Preencha a senha com pelo menos 6 caracteres";
      });
    } else {
      Usuario usuario = Usuario();
      usuario.email = email;
      usuario.senha = senha;
      _logarUsuario(usuario);
    }
  }

  Future _verificaUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    //auth.signOut();

    FirebaseUser usuarioLogado = await auth.currentUser();
    if (usuarioLogado != null) {

      Navigator.pushReplacementNamed(context, Routes.ROTA_HOME);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _verificaUsuarioLogado();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Color(0xff075e54)),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                    padding: EdgeInsets.only(bottom: 32),
                    child: Image.asset("assets/images/logo.png", height: 150)),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: _controllerEmail,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "E-mail",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32))),
                  ),
                ),
                TextField(
                  controller: _controllerSenha,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Senha",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32))),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                    onPressed: () {
                      _validarCampos();
                    },
                    child: Text(
                      "Entrar",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    color: Colors.green,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                  ),
                ),
                Center(
                  child: GestureDetector(
                    child: Text(
                      "Não tem conta? Cadastre-se!",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Cadastro()));
                    },
                  ),
                ),
                Center(
                  child: Text(
                    _msgErro,
                    style: TextStyle(color: Colors.red, fontSize: 20),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
