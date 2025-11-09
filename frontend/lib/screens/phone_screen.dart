import 'package:flutter/material.dart';
import 'package:bootiehunter/screens/call_screen.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Recents'),
            Tab(text: 'Contacts'),
            Tab(text: 'Keypad'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RecentsTab(),
          _ContactsTab(),
          _KeypadTab(),
        ],
      ),
    );
  }
}

class _RecentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Load actual recents from backend
    final recents = [
      {'name': 'R.E.E.D.', 'type': 'reed', 'time': '2:30 PM', 'duration': '5:23'},
      {'name': 'R.E.E.D.', 'type': 'reed', 'time': 'Yesterday', 'duration': '12:45'},
    ];

    if (recents.isEmpty) {
      return const Center(
        child: Text('No recent calls'),
      );
    }

    return ListView.builder(
      itemCount: recents.length,
      itemBuilder: (context, index) {
        final call = recents[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(
              call['name']![0],
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(call['name'] as String),
          subtitle: Text('${call['time']} • ${call['duration']}'),
          trailing: const Icon(Icons.call),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CallScreen(
                  contactName: call['name'] as String,
                  contactType: call['type'] as String,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ContactsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Load actual contacts from backend
    final contacts = [
      {'name': 'R.E.E.D.', 'type': 'reed', 'subtitle': 'AI Assistant'},
    ];

    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(
              contact['name']![0],
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(contact['name'] as String),
          subtitle: Text(contact['subtitle'] as String),
          trailing: const Icon(Icons.call),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CallScreen(
                  contactName: contact['name'] as String,
                  contactType: contact['type'] as String,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _KeypadTab extends StatefulWidget {
  @override
  State<_KeypadTab> createState() => _KeypadTabState();
}

class _KeypadTabState extends State<_KeypadTab> {
  String _number = '';

  void _addDigit(String digit) {
    setState(() {
      _number += digit;
    });
  }

  void _deleteDigit() {
    if (_number.isNotEmpty) {
      setState(() {
        _number = _number.substring(0, _number.length - 1);
      });
    }
  }

  void _makeCall() {
    if (_number.toLowerCase() == 'reed' || _number.toLowerCase() == '7333') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CallScreen(
            contactName: 'R.E.E.D.',
            contactType: 'reed',
          ),
        ),
      );
      setState(() {
        _number = '';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only R.E.E.D. is available. Try "REED" or "7333"')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Text(
              _number.isEmpty ? 'Enter name or number' : _number,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w300),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: GridView.count(
            crossAxisCount: 3,
            padding: const EdgeInsets.all(16),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _DialButton('1', ''), _DialButton('2', 'ABC'), _DialButton('3', 'DEF'),
              _DialButton('4', 'GHI'), _DialButton('5', 'JKL'), _DialButton('6', 'MNO'),
              _DialButton('7', 'PQRS'), _DialButton('8', 'TUV'), _DialButton('9', 'WXYZ'),
              _DialButton('*', ''), _DialButton('0', '+'), _DialButton('#', ''),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.call, size: 32),
                color: Colors.green,
                onPressed: _makeCall,
              ),
              IconButton(
                icon: const Icon(Icons.backspace, size: 32),
                onPressed: _deleteDigit,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _DialButton(String digit, String letters) {
    return InkWell(
      onTap: () => _addDigit(digit),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              digit,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
            ),
            if (letters.isNotEmpty)
              Text(
                letters,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }
}

