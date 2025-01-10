import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ManualScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manual'),
      ),
      body: FutureBuilder(
        future: DefaultAssetBundle.of(context).loadString('assets/MANUAL.md'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Markdown(data: snapshot.data ?? '');
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}