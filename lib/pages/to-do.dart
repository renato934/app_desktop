import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: TodoPage()));
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  // Simulando utilizador atual com ID 1
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

  void _addTodoList() {
    final title = _titleController.text.trim();
    final rawTasks = _textareaController.text.trim();

    if (title.isEmpty || rawTasks.isEmpty) return;

    final tasks = rawTasks
        .split('\n')
        .map((line) => TodoTask(line.trim()))
        .where((task) => task.description.isNotEmpty)
        .toList();

    setState(() {
      _todoLists.add(
        TodoListItem(
          title: title,
          tasks: tasks,
          shared: false,
          ownerId: currentUserId,
        ),
      );
      _titleController.clear();
      _textareaController.clear();
    });
  }

  void _editTodoList(int index) {
    final item = _todoLists[index];
    _editTitleController.text = item.title;
    _editTasksController.text = item.tasks.map((t) => t.description).join('\n');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 300, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Editar Lista',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _editTitleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF2C2C2E),
                    labelText: 'Título',
                    labelStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _editTasksController,
                  maxLines: 8,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF2C2C2E),
                    labelText: 'Tarefas',
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
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        final newTitle = _editTitleController.text.trim();
                        final rawTasks = _editTasksController.text.trim();

                        if (newTitle.isNotEmpty && rawTasks.isNotEmpty) {
                          final newTasks = rawTasks
                              .split('\n')
                              .map((line) => TodoTask(line.trim()))
                              .where((task) => task.description.isNotEmpty)
                              .toList();

                          setState(() {
                            _todoLists[index].title = newTitle;
                            _todoLists[index].tasks = newTasks;
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _removeTodoList(int index) {
    setState(() {
      _todoLists.removeAt(index);
    });
  }

  void _mostrarDialogoPartilhar(BuildContext context, int index) {
    final Set<String> selecionados = {};
    const double alturaItem = 70;

    showDialog(
      context: context,
      builder: (context) {
        final width = MediaQuery.of(context).size.width;
        final alturaCalculada = contatos.length * alturaItem;

        return Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Dialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: width * 0.5,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selecionar Amigos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// 🔧 Limita altura da lista ao necessário ou até 500px
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: alturaCalculada.clamp(0, 500),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: contatos.length,
                        itemBuilder: (context, i) {
                          final contato = contatos[i];
                          final id = contato['id']!;
                          final nome = contato['nome']!;
                          final status = contato['status']!;
                          final tag = contato['tag']!;
                          final imagem = contato['imagem']!;

                          return CheckboxListTile(
                            value: selecionados.contains(id),
                            onChanged: (bool? value) {
                              if (value == true) {
                                selecionados.add(id);
                              } else {
                                selecionados.remove(id);
                              }
                              (context as Element).markNeedsBuild();
                            },
                            activeColor: Colors.blue,
                            title: Text(
                              nome,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(tag, style: TextStyle(fontSize: 13)),
                            secondary: Stack(
                              children: [
                                imagem.isNotEmpty
                                    ? CircleAvatar(
                                        radius: 19,
                                        backgroundColor: Colors.grey[800],
                                        backgroundImage: AssetImage(imagem),
                                        onBackgroundImageError: (_, __) {},
                                      )
                                    : CircleAvatar(
                                        radius: 19,
                                        backgroundColor: Colors.grey[800],
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 19,
                                        ),
                                      ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: status == 'online'
                                          ? Colors.green
                                          : Colors.grey,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors
                                            .black, // borda para destacar o círculo no avatar
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            checkboxShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// Botões de ação
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
                          child: const Text('Confirmar Partilha'),
                          onPressed: () {
                            if (selecionados.length > 0) {
                              _toggleShared(index);
                              Navigator.pop(context);
                            }
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

  void _toggleShared(int index) {
    setState(() {
      _todoLists[index].shared = true ;
    });
  }

  void _toggleTaskDone(TodoListItem listItem, int taskIndex) {
    setState(() {
      listItem.tasks[taskIndex].done = !listItem.tasks[taskIndex].done;
    });
  }

  Widget _buildMyListsTab() {
    final myLists = _todoLists
        .where((e) => e.ownerId == currentUserId)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Título da lista',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: TextField(
              controller: _textareaController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                labelText: 'Tarefas (uma por linha)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              textAlignVertical: TextAlignVertical.top,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addTodoList,
              child: const Text('Adicionar Lista'),
            ),
          ),
          const SizedBox(height: 16),
          if (myLists.isEmpty)
            const Center(child: Text('Nenhuma lista ainda!'))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myLists.length,
              itemBuilder: (context, index) {
                final item = myLists[index];
                return _buildTodoCard(item, editable: true);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSharedListsTab() {
    final sharedFromOthers = _todoLists
        .where((e) => e.shared && e.ownerId != currentUserId)
        .toList();

    if (sharedFromOthers.isEmpty) {
      return const Center(child: Text('Nenhuma lista partilhada por outros.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sharedFromOthers.length,
      itemBuilder: (context, index) {
        return _buildTodoCard(sharedFromOthers[index], editable: false);
      },
    );
  }

  Widget _buildTodoCard(TodoListItem item, {bool editable = true}) {
    final index = _todoLists.indexOf(item);

    return Card(
      color: const Color.fromRGBO(18, 18, 20, 1),

      margin: const EdgeInsets.symmetric(vertical: 8),
      clipBehavior: Clip.antiAlias, // importante para ripple correto
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Row(
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              if (item.shared)
                Text("• "),
                Text(
                  "Partilhada",
                  style: TextStyle(color: Colors.blue, fontSize: 14),
                ),
            ],
          ),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            ...item.tasks.asMap().entries.map(
              (entry) => CheckboxListTile(
                title: Text(
                  entry.value.description,
                  style: const TextStyle(color: Colors.white70),
                ),
                value: entry.value.done,
                onChanged: editable
                    ? (_) => _toggleTaskDone(item, entry.key)
                    : null,
              ),
            ),
            if (editable)
              ButtonBar(
                children: [
                  IconButton(
                    icon: Icon(
                      item.shared ? Icons.share : Icons.share_outlined,
                      color: item.shared ? Colors.blue : Colors.white,
                    ),
                    onPressed: () => _mostrarDialogoPartilhar(context, index),
                    tooltip: 'Partilhar',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () => _editTodoList(index),
                    tooltip: 'Editar',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeTodoList(index),
                    tooltip: 'Apagar',
                  ),
                ],
              ),
          ],
        ),
      ),
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
        body: TabBarView(
          children: [_buildMyListsTab(), _buildSharedListsTab()],
        ),
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

  TodoTask(this.description, {this.done = false});
}
