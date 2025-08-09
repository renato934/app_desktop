// Pagina Principal
final String mensagensQuery = r'''
  subscription GetMensagens($userId: Int!) {
    grupo_membros(where: { id_user: { _eq: $userId } }) {
      grupo {
        id
        nome
        imagem
        mensagems(order_by: {created_at: desc}, limit: 1) {
          id
          created_at
        }
        grupo_membros {
          user {
            id
            nome
            imagem
            status
          }
        }
      }
    }
  }
''';

final String userQuery = r'''
  subscription getuser($userId: Int!) {
    users(where: {id: {_eq: $userId}}) {
      id
      nome
      imagem
      status
    }
  }
''';

final newGrupo = r'''
  mutation newGrupo($nome: String!) {
    insert_grupos_one(object: { nome: $nome }) {
      id
      nome
      imagem
    }
  }
''';

final newGrupoMembros = r'''
  mutation newGrupoMembros($id_grupo: Int!, $id_user: Int!) {
    insert_grupo_membros_one(object: { id_grupo: $id_grupo, id_user: $id_user }) {
      id
      id_grupo
      id_user
    }
  }
''';

// Pagina de Chat
final String mensagensUsersQuery = r'''
  subscription GetMensagens($idgrupo: Int!) {
    grupos(where: { id: { _eq: $idgrupo } }) {
      id
      nome
      imagem
      grupo_membros {
        user {
          id
          nome
          imagem
          status
        }
      }
      mensagems(order_by: { created_at: asc }) {
        id
        from_id_user
        text
        created_at
        mensagens_lidas {
          id_user
          lida
        }
      }
    }
  }
''';

final String insertMensagemMutation = r'''
  mutation InsertMensagem($text: String!, $fromId: Int!, $grupoId: Int!) {
    insert_mensagem_one(object: {
      text: $text,
      from_id_user: $fromId,
      id_grupo: $grupoId
    }) {
      id
      text
      created_at
    }
  }
''';

final updateLidaMutation = r'''
  mutation MarcarComoLidas($userId: Int!, $grupoId: Int!) {
    update_mensagens_lidas(
      where: {
        id_user: { _eq: $userId },
        lida: { _eq: false },
        mensagem: { id_grupo: { _eq: $grupoId } }
      },
      _set: { lida: true }
    ) {
      affected_rows
    }
  }
''';

//Página to-do
final String gettarefas = r'''
  subscription getTarefas($iduser: Int!) {
  todo_lists(where: {id_user: {_eq: $iduser}}) {
    id
    titulo
    id_user
    tarefas: tarefas {
      id
      tarefa
      completed
      created_at
    }
  }
}
''';



// Pagina de Amigos
  // Tambem usado na pagina principal
  final String friendsQuery = r'''
  subscription GetFriends($userId: Int!) {
    amigos(
      where: {
        _or: [
          {id_user1: {_eq: $userId}},
          {id_user2: {_eq: $userId}}
        ],
        status: {_eq: 1}
      }
    ) {
      user {
        id
        nome
        status
        tag
        imagem
      }
      userByIdUser2 {
        id
        nome
        status
        tag
        imagem
      }
    }
  }
  ''';