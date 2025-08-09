import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';




void _editarMensagem(BuildContext context, Map<String, dynamic> mensagem) {
  // Mostrar dialog para editar texto da mensagem
  final TextEditingController editController =
      TextEditingController(text: mensagem['text']);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Editar mensagem'),
      content: TextField(
        controller: editController,
        maxLines: null,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            final novoTexto = editController.text.trim();
            if (novoTexto.isEmpty) return;

            Navigator.pop(context);

            // Atualizar no backend (criar mutation para editar mensagem)
            final client = GraphQLProvider.of(context).value;
            final options = MutationOptions(
              document: gql(r'''
                mutation AtualizarMensagem($id: Int!, $text: String!) {
                  update_mensagem_by_pk(pk_columns: {id: $id}, _set: {text: $text}) {
                    id
                    text
                  }
                }
              '''),
              variables: {'id': mensagem['id'], 'text': novoTexto},
            );

            final result = await client.mutate(options);

            if (result.hasException) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao editar mensagem')),
              );
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    ),
  );
}

void _eliminarMensagem(BuildContext context, Map<String, dynamic> mensagem) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmar exclusão'),
      content: const Text('Deseja realmente eliminar esta mensagem?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);

            // Deletar no backend (criar mutation para deletar mensagem)
            final client = GraphQLProvider.of(context).value;
            final options = MutationOptions(
              document: gql(r'''
                mutation DeletarMensagem($id: Int!) {
                  delete_mensagem_by_pk(id: $id) {
                    id
                  }
                }
              '''),
              variables: {'id': mensagem['id']},
            );

            final result = await client.mutate(options);

            if (result.hasException) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao eliminar mensagem')),
              );
            }
          },
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
}