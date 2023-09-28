import 'package:flutter/material.dart';

class RecentFiles extends StatefulWidget {
  String title;
  int increase;
  RecentFiles({super.key, required this.increase, required this.title});
  @override
  State<RecentFiles> createState() => _RecentFilesState();
}

class _RecentFilesState extends State<RecentFiles> {
  @override
  Widget build(BuildContext context) {

    List<String> items = [];
    setState(() {
      items.add(widget.title);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Recently Created Files", style: TextStyle(fontFamily: "Times New Roman"),),
      ),
      body: ListView.builder(itemBuilder: (context, index){
        return ListTile(
          title: Text(widget.title),
        );
      }, itemCount: widget.increase),
    );
  }
}
