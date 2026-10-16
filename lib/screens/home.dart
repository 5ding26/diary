import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'editor.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Box entriesBox = Hive.box('entries');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日记'),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('这是一个轻量日记启动版。')),
              );
            },
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: entriesBox.listenable(),
        builder: (context, Box box, _) {
          final entries = box.keys.toList().reversed.toList();

          if (entries.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.book_rounded, size: 64, color: Color(0xFFB9CFC8)),
                  SizedBox(height: 16),
                  Text(
                    '还没有日记，开始写下今天的点滴吧',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final key = entries[index];
              final entry = Map<String, dynamic>.from(box.get(key) as Map);
              final dateText = entry['time'] as String? ?? '今天';
              final title = entry['title'] as String? ?? '无标题';
              final content = entry['content'] as String? ?? '';
              final imagePath = entry['imagePath'] as String? ?? '';
              final weather = entry['weather'] as Map? ?? {};

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EditorScreen(
                          entryId: key.toString(),
                          initialEntry: entry,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              dateText,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            if (weather.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F7F6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${weather['icon'] ?? '☀'} ${weather['temp'] ?? ''}°',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF56706C),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (imagePath.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(imagePath),
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Text(
                          content,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Color(0xFF2B2B2B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const EditorScreen()),
          );
        },
        backgroundColor: const Color(0xFF7FA9A2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
