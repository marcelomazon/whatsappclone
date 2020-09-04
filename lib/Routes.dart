import 'package:flutter/material.dart';
import 'package:whatsapp/Cadastro.dart';
import 'package:whatsapp/Chat.dart';
import 'package:whatsapp/Configuracoes.dart';
import 'package:whatsapp/Home.dart';
import 'package:whatsapp/Mensagens.dart';

import 'Login.dart';
import 'model/Usuario.dart';

class Routes {
  static const ROTA_HOME = "/home";
  static const ROTA_LOGIN = "/login";
  static const ROTA_CADASTRO = "/cadastro";
  static const ROTA_CONFIGURACOES = "/configuracoes";
  static const ROTA_MENSAGENS = "/mensagens";
  static const ROTA_CHAT = "/chat";

  static Route<dynamic> generator(RouteSettings rota) {
    final args = rota.arguments;

    switch (rota.name) {
      case "/":
        return MaterialPageRoute(builder: (context) => Login());
        break;
      case ROTA_LOGIN:
        return MaterialPageRoute(builder: (context) => Login());
        break;
      case ROTA_CADASTRO:
        return MaterialPageRoute(builder: (context) => Cadastro());
        break;
      case ROTA_HOME:
        return MaterialPageRoute(builder: (context) => Home(args));
        break;
      case ROTA_CONFIGURACOES:
        return MaterialPageRoute(builder: (context) => Configuracoes());
        break;
      case ROTA_MENSAGENS:
        return MaterialPageRoute(builder: (context) => Mensagens(args));
        break;
      case ROTA_CHAT:
        Usuario usuario = args;
        return MaterialPageRoute(
            builder: (context) => Chat(
                peerId: usuario.idUsuario,
                peerAvatar: usuario.urlImagem,
                contato: usuario
            )
        );
        break;
      default:
        _erroRota();
    }
  }

  static Route<dynamic> _erroRota() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Destino não encontrado"),
        ),
        body: Center(
          child: Text("O recurso destinado não foi encontrado!"),
        ),
      );
    });
  }
}
