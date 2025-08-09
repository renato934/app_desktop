import 'package:app_desktop/basedados/querys.dart';
import 'package:app_desktop/pages/paginaprincipal.dart';
import 'package:app_desktop/widget/widget_selecionarAmigos.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final int currentUserId = 1;

  final List<Map<String, String>> contatos = [
    {
      'id': '1',
      'nome': 'Ana',
      'status': 'online',
      'tag': 'aB3kL9dX',
      "imagem": "assets/splash.png",
    },
    {
      'id': '2',
      'nome': 'Bruno',
      'status': 'offline',
      'tag': 'Pq8ZrRt2',
      "imagem": "",
    },
    {
      'id': '3',
      'nome': 'Carla',
      'status': 'online',
      'tag': 'Xy12ABcd',
      "imagem": "assets/splash.png",
    },
  ];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textareaController = TextEditingController();
  final TextEditingController _editTitleController = TextEditingController();
  final TextEditingController _editTasksController = TextEditingController();

  final List<TodoListItem> _todoLists = [];

  Widget _buildTodoCard(
    TodoListItem item,
    List<Map<String, dynamic>> friendsList,
  ) {
    final previewTasks = item.tasks.take(6).toList();
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setStateCard) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setStateCard(() => isHovered = true),
          onExit: (_) => setStateCard(() => isHovered = false),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TodoDetailsPage(
                    listItem: item,
                    editable: item.ownerId == currentUserId,
                    onTaskToggle: (taskIndex) =>
                        _toggleTaskDone(item, taskIndex),
                  ),
                ),
              );
            },
            child: Card(
              color: const Color.fromRGBO(18, 18, 20, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    ...previewTasks.map(
                      (task) => Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: task.done
                                    ? Colors.grey
                                    : Colors.blue, // cinza se done, azul se não
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              task.description,
                              style: TextStyle(
                                color: task.done
                                    ? Colors.grey[500]
                                    : Colors.white70,
                                fontSize: 15,
                                decoration: task.done
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (item.tasks.length > previewTasks.length)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "+${item.tasks.length - previewTasks.length} mais...",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const Spacer(),
                    if (item.ownerId == currentUserId && isHovered)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              item.shared ? Icons.share : Icons.share_outlined,
                              color: item.shared ? Colors.blue : Colors.white,
                            ),
                            onPressed: () async {
                              final Map<String, dynamic>? selecionados =
                                  await selecionarAmigos(context, friendsList);
                              if (selecionados != null &&
                                  selecionados.isNotEmpty) {
                                final Set<int> ids = selecionados['ids'];
                                final List<String> nomes =
                                    selecionados['nomes'];
                              }
                            },
                            tooltip: 'Partilhar',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {},
                            tooltip: 'Apagar',
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _toggleTaskDone(TodoListItem listItem, int taskIndex) {
    setState(() {
      listItem.tasks[taskIndex].done = !listItem.tasks[taskIndex].done;
    });
  }

  Widget _buildMyListsTab(List<Map<String, dynamic>> friendsList) {
    return Subscription(
      options: SubscriptionOptions(
        document: gql(gettarefas),
        variables: {'iduser': currentUserId},
      ),
      builder: (result) {
        if (result.isLoading) return CircularProgressIndicator();

        if (result.hasException || result.data == null) {
          return const Center(
            child: Text('Sem tarefas', style: TextStyle(color: Colors.white)),
          );
        }

        final todos_list = result.data!['todo_lists'] as List<dynamic>;

        if (todos_list.isEmpty) {
          return const Center(
            child: Text('Sem tarefas', style: TextStyle(color: Colors.white)),
          );
        }

        Map<int, TodoListItem> todoListsMap = {};

        for (var todo in todos_list) {
          final todoListId = todo['id'] as int;

          if (!todoListsMap.containsKey(todoListId)) {
            todoListsMap[todoListId] = TodoListItem(
              title: todo['titulo'] ?? '',
              ownerId: todo['id_user'],
              shared: false, // ajuste conforme seu dado
              tasks: [],
            );
          }

          final todo_tarefas = todo['tarefas'];

          for (var todo_tar in todo_tarefas) {
            // Adiciona a tarefa à lista de tarefas do TodoListItem
            todoListsMap[todoListId]!.tasks.add(
              TodoTask(
                description: todo_tar['tarefa'],
                done: todo_tar['completed'] ?? false,
              ),
            );
          }
        }

        final myLists = todoListsMap.values.toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisExtent: 250,
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: myLists.length,
            itemBuilder: (context, index) {
              return _buildTodoCard(myLists[index], friendsList);
            },
          ),
        );
      },
    );
  }

  Widget _buildSharedListsTab(List<Map<String, dynamic>> friendsList) {
    final sharedFromOthers = _todoLists
        .where((e) => e.shared && e.ownerId != currentUserId)
        .toList();

    if (sharedFromOthers.isEmpty) {
      return const Center(child: Text('Nenhuma lista partilhada por outros.'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        itemCount: sharedFromOthers.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          return _buildTodoCard(sharedFromOthers[index], friendsList);
        },
      ),
    );
  }

  void _mostrarDialogoAdicionarLista() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            width: 550, // largura fixa menor
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Adicionar Lista',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF2C2C2E),
                        labelText: 'Título da lista',
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _textareaController,
                      maxLines: 6, // menos linhas para ficar menor
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF2C2C2E),
                        labelText: 'Tarefas (uma por linha)',
                        labelStyle: const TextStyle(color: Colors.white70),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          child: const Text('Adicionar'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textareaController.dispose();
    _editTitleController.dispose();
    _editTasksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: TabBar(
          tabs: [
            Tab(text: 'Minhas Tarefas'),
            Tab(text: 'Tarefas Partilhadas'),
          ],
        ),
        body: Subscription(
          options: SubscriptionOptions(
            document: gql(friendsQuery),
            variables: {'userId': currentUserId},
          ),
          builder: (result) {
            if (result.isLoading) return CircularProgressIndicator();

            final rawFriends = (result.data!['amigos'] ?? []) as List<dynamic>;

            final friendsList = rawFriends
                .map(
                  (f) =>
                      extractFriend(f as Map<String, dynamic>, currentUserId),
                )
                .toList();

            return TabBarView(
              children: [
                _buildMyListsTab(friendsList),
                _buildSharedListsTab(friendsList),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _mostrarDialogoAdicionarLista,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class TodoDetailsPage extends StatelessWidget {
  final TodoListItem listItem;
  final bool editable;
  final Function(int) onTaskToggle;

  const TodoDetailsPage({
    Key? key,
    required this.listItem,
    required this.editable,
    required this.onTaskToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(listItem.title),
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: listItem.tasks.length,
        itemBuilder: (context, index) {
          final task = listItem.tasks[index];
          return CheckboxListTile(
            value: task.done,
            onChanged: editable ? (_) => onTaskToggle(index) : null,
            title: Text(
              task.description,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}

class TodoListItem {
  String title;
  List<TodoTask> tasks;
  bool shared;
  int ownerId;

  TodoListItem({
    required this.title,
    required this.tasks,
    this.shared = false,
    required this.ownerId,
  });
}

class TodoTask {
  String description;
  bool done;

  TodoTask({required this.description, this.done = false});
}
