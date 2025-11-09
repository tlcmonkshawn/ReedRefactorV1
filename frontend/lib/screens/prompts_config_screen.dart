import 'package:flutter/material.dart';
import 'package:bootiehunter/models/prompt.dart';
import 'package:bootiehunter/services/prompt_service.dart';
import 'package:bootiehunter/services/api_service.dart';
import 'package:bootiehunter/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class PromptsConfigScreen extends StatefulWidget {
  const PromptsConfigScreen({super.key});

  @override
  State<PromptsConfigScreen> createState() => _PromptsConfigScreenState();
}

class _PromptsConfigScreenState extends State<PromptsConfigScreen> {
  late final PromptService _promptService;
  
  @override
  void initState() {
    super.initState();
    // Get PromptService from context
    _promptService = Provider.of<PromptService>(context, listen: false);
    _loadPrompts();
  }
  List<Prompt> _prompts = [];
  bool _isLoading = true;
  String? _error;
  String? _selectedCategory;

  final List<String> _categories = [
    'system_instructions',
    'image_processing',
    'research',
    'chat',
    'game_modes',
    'tool_functions',
  ];


  Future<void> _loadPrompts({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.currentUser!.canFinalize) {
        setState(() {
          _error = 'Only Bootie Bosses and Admins can manage prompts';
          _isLoading = false;
        });
        return;
      }

      // Load from cache (will check for updates automatically)
      final prompts = await _promptService.getPrompts(
        category: _selectedCategory,
        forceRefresh: forceRefresh,
      );
      setState(() {
        _prompts = prompts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

      Future<void> _deletePrompt(Prompt prompt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Prompt'),
        content: Text('Are you sure you want to delete "${prompt.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _promptService.deletePrompt(prompt.id);
        // Force refresh after delete
        _loadPrompts(forceRefresh: true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Prompt deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting prompt: $e')),
          );
        }
      }
    }
  }

  void _navigateToEdit(Prompt? prompt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PromptEditScreen(
          prompt: prompt,
          promptService: _promptService,
          onSaved: () {
            Navigator.pop(context);
            _loadPrompts(forceRefresh: true);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (!authProvider.currentUser!.canFinalize) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('AI Prompts Config'),
        ),
        body: const Center(
          child: Text('Only Bootie Bosses and Admins can manage prompts'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Prompts Config'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToEdit(null),
            tooltip: 'Create New Prompt',
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Category: '),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    hint: const Text('All Categories'),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ..._categories.map((category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category.replaceAll('_', ' ').toUpperCase()),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                      _loadPrompts();
                    },
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error: $_error'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadPrompts,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _prompts.isEmpty
                        ? const Center(child: Text('No prompts found'))
                        : ListView.builder(
                            itemCount: _prompts.length,
                            itemBuilder: (context, index) {
                              final prompt = _prompts[index];
                              return _PromptListItem(
                                prompt: prompt,
                                onEdit: () => _navigateToEdit(prompt),
                                onDelete: () => _deletePrompt(prompt),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _PromptListItem extends StatelessWidget {
  final Prompt prompt;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PromptListItem({
    required this.prompt,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(prompt.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${prompt.category}'),
            Text('Model: ${prompt.model}'),
            if (prompt.description != null)
              Text(
                prompt.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!prompt.active)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.visibility_off, color: Colors.grey),
              ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
              tooltip: 'Delete',
              color: Colors.red,
            ),
          ],
        ),
        onTap: onEdit,
      ),
    );
  }
}

class PromptEditScreen extends StatefulWidget {
  final Prompt? prompt;
  final PromptService promptService;
  final VoidCallback onSaved;

  const PromptEditScreen({
    super.key,
    this.prompt,
    required this.promptService,
    required this.onSaved,
  });

  @override
  State<PromptEditScreen> createState() => _PromptEditScreenState();
}

class _PromptEditScreenState extends State<PromptEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _category;
  late String _name;
  late String _model;
  late String _promptText;
  String? _description;
  String? _useCase;
  String? _promptType;
  int _sortOrder = 0;
  bool _active = true;

  final List<String> _categories = [
    'system_instructions',
    'image_processing',
    'research',
    'chat',
    'game_modes',
    'tool_functions',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.prompt != null) {
      final p = widget.prompt!;
      _category = p.category;
      _name = p.name;
      _model = p.model;
      _promptText = p.promptText;
      _description = p.description;
      _useCase = p.useCase;
      _promptType = p.promptType;
      _sortOrder = p.sortOrder;
      _active = p.active;
    } else {
      _category = _categories.first;
      _name = '';
      _model = '';
      _promptText = '';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final prompt = Prompt(
        id: widget.prompt?.id ?? 0,
        category: _category,
        name: _name,
        model: _model,
        promptText: _promptText,
        description: _description?.isEmpty ?? true ? null : _description,
        useCase: _useCase?.isEmpty ?? true ? null : _useCase,
        promptType: _promptType?.isEmpty ?? true ? null : _promptType,
        sortOrder: _sortOrder,
        active: _active,
        version: widget.prompt?.version ?? 1,
        metadata: null,
        createdAt: widget.prompt?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.prompt == null) {
        await widget.promptService.createPrompt(prompt);
      } else {
        await widget.promptService.updatePrompt(prompt);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.prompt == null
                ? 'Prompt created successfully'
                : 'Prompt updated successfully'),
          ),
        );
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.prompt == null ? 'New Prompt' : 'Edit Prompt'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories.map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat.replaceAll('_', ' ').toUpperCase()),
              )).toList(),
              onChanged: (value) => setState(() => _category = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _name,
              decoration: const InputDecoration(labelText: 'Name *'),
              onSaved: (value) => _name = value!,
              validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _model,
              decoration: const InputDecoration(labelText: 'Model *'),
              onSaved: (value) => _model = value!,
              validator: (value) => value?.isEmpty ?? true ? 'Model is required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _promptType,
              decoration: const InputDecoration(labelText: 'Prompt Type'),
              items: const [
                DropdownMenuItem(value: null, child: Text('None')),
                DropdownMenuItem(value: 'system_instruction', child: Text('System Instruction')),
                DropdownMenuItem(value: 'prompt_template', child: Text('Prompt Template')),
                DropdownMenuItem(value: 'tool_function', child: Text('Tool Function')),
              ],
              onChanged: (value) => setState(() => _promptType = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _description,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              onSaved: (value) => _description = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _useCase,
              decoration: const InputDecoration(labelText: 'Use Case'),
              maxLines: 2,
              onSaved: (value) => _useCase = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _promptText,
              decoration: const InputDecoration(labelText: 'Prompt Text *'),
              maxLines: 10,
              onSaved: (value) => _promptText = value!,
              validator: (value) => value?.isEmpty ?? true ? 'Prompt text is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _sortOrder.toString(),
              decoration: const InputDecoration(labelText: 'Sort Order'),
              keyboardType: TextInputType.number,
              onSaved: (value) => _sortOrder = int.tryParse(value ?? '0') ?? 0,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Active'),
              value: _active,
              onChanged: (value) => setState(() => _active = value ?? true),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

