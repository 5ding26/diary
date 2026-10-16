import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

const weatherApiKey = 'REPLACE_WITH_YOUR_OPENWEATHERMAP_API_KEY';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key, this.entryId, this.initialEntry});

  final String? entryId;
  final Map<String, dynamic>? initialEntry;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  final ImagePicker _picker = ImagePicker();
  final Box _entriesBox = Hive.box('entries');

  DateTime _selectedDateTime = DateTime.now();
  String? _imagePath;
  Map<String, dynamic>? _weather;

  bool get _isEditMode => widget.initialEntry != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialEntry?['title'] as String? ?? '',
    );
    _contentController = TextEditingController(
      text: widget.initialEntry?['content'] as String? ?? '',
    );
    _selectedDateTime = DateTime.tryParse(
          widget.initialEntry?['datetime'] as String? ?? DateTime.now().toIso8601String(),
        ) ??
        DateTime.now();
    _imagePath = widget.initialEntry?['imagePath'] as String?;
    _weather = (widget.initialEntry?['weather'] as Map?)?.cast<String, dynamic>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;

    setState(() {
      _imagePath = picked.path;
    });
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _fetchWeather() async {
    if (weatherApiKey == 'REPLACE_WITH_YOUR_OPENWEATHERMAP_API_KEY') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先在 editor.dart 中填入 OpenWeatherMap API Key')),
      );
      return;
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请打开定位服务')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('天气需要位置权限')),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      final uri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$weatherApiKey&units=metric&lang=zh_cn',
      );

      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw Exception('天气请求失败');
      }

      final json = jsonDecode(response.body);
      final weatherMain = json['weather'][0]['main'] as String? ?? 'Clear';
      final weatherDescription = json['weather'][0]['description'] as String? ?? '晴';
      final temp = (json['main']['temp'] as num?)?.round() ?? 0;

      setState(() {
        _weather = {
          'icon': _weatherIcon(weatherMain),
          'temp': temp,
          'desc': weatherDescription,
        };
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('天气已更新：$weatherDescription ${temp}°C')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('获取天气失败：$e')),
      );
    }
  }

  String _weatherIcon(String weatherMain) {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return '☀';
      case 'clouds':
        return '⛅';
      case 'rain':
        return '🌧';
      case 'snow':
        return '❄';
      case 'mist':
        return '🌫';
      default:
        return '☁';
    }
  }

  Future<void> _saveEntry() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('标题和内容至少写一个吧~')),
      );
      return;
    }

    final now = DateTime.now();
    final entry = {
      'title': title.isEmpty ? '无标题' : title,
      'content': content,
      'imagePath': _imagePath ?? '',
      'time': DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime),
      'datetime': _selectedDateTime.toIso8601String(),
      'weather': _weather ?? {},
      'updatedAt': now.toIso8601String(),
    };

    if (_isEditMode && widget.entryId != null) {
      await _entriesBox.put(widget.entryId, entry);
    } else {
      await _entriesBox.put(DateTime.now().millisecondsSinceEpoch.toString(), entry);
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final weatherText = _weather == null
        ? '未获取天气'
        : '${_weather!['icon']} ${_weather!['temp']}°C';

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '编辑日记' : '写日记'),
        actions: [
          IconButton(
            onPressed: _saveEntry,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '标题',
                border: InputBorder.none,
              ),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                InkWell(
                  onTap: _pickDateTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F3F2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _fetchWeather,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F3F2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(weatherText),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('相册'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('拍照'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_imagePath != null && _imagePath!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(_imagePath!),
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 18),
            TextField(
              controller: _contentController,
              minLines: 12,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: '写下今天的点滴...',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 17, height: 1.7),
            ),
          ],
        ),
      ),
    );
  }
}
