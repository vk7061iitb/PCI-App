import 'package:flutter/material.dart';

class DebugMessagesPage extends StatefulWidget {
  const DebugMessagesPage({super.key});

  @override
  DebugMessagesPageState createState() => DebugMessagesPageState();
}

class DebugMessagesPageState extends State<DebugMessagesPage> {
  List<String> debugMessages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Messages'),
      ),
      body: ListView.builder(
        itemCount: debugMessages.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(debugMessages[index]),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Listen to debug output
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      setState(() {
        debugMessages.add(details.exceptionAsString());
      });
    };
    // Capture print output
    debugPrint = (String? message, {int? wrapWidth}) {
      setState(() {
        debugMessages.add(message ?? "");
      });
    };
  }
}
