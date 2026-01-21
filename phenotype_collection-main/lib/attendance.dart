import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'video_player_screen.dart';

const String _apiBaseUrl = 'http://61.155.111.202:18080/cprweb/pt/api';
const String _fileBaseUrl = 'http://61.155.111.202:18080';

Future<Map<String, String>> _buildHeaders({bool json = false}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final headers = <String, String>{'Accept': 'application/json'};
  if (token != null && token.isNotEmpty) {
    headers['Authorization'] = 'Token $token';
  }
  if (json) {
    headers['Content-Type'] = 'application/json';
  }
  return headers;
}

Future<List<dynamic>> _fetchAllResults(
  Uri uri,
  Map<String, String> headers,
) async {
  final results = <dynamic>[];
  Uri? next = uri;
  while (next != null) {
    final res = await http.get(next, headers: headers);
    if (res.statusCode != 200) break;
    final decoded = jsonDecode(utf8.decode(res.bodyBytes));
    if (decoded is List) {
      results.addAll(decoded);
      break;
    }
    final page = (decoded['results'] as List?) ?? const [];
    results.addAll(page);
    final nextUrl = decoded['next'];
    if (nextUrl is String && nextUrl.isNotEmpty) {
      next = Uri.parse(nextUrl);
    } else {
      next = null;
    }
  }
  return results;
}

String _experimentInfoText(Map<String, dynamic> exp) {
  final parts = <String>[];
  final location = exp['location']?.toString() ?? '';
  final expType = exp['experiment_type']?.toString() ?? '';
  final year = exp['year']?.toString() ?? '';
  final start =
      exp['start_date']?.toString() ?? exp['startDate']?.toString() ?? '';
  final end = exp['end_date']?.toString() ?? exp['endDate']?.toString() ?? '';
  if (location.isNotEmpty) parts.add(location);
  if (expType.isNotEmpty) parts.add(expType);
  if (year.isNotEmpty) parts.add(year);
  if (start.isNotEmpty || end.isNotEmpty) {
    final range = end.isNotEmpty ? '$start ~ $end' : start;
    if (range.isNotEmpty) parts.add(range);
  }
  return parts.join(' | ');
}

String _unitInfoText(Map<String, dynamic> unit) {
  final parts = <String>[];
  final expName = unit['experiment_name']?.toString() ?? '';
  final unitType = unit['unit_type_display']?.toString() ??
      unit['unit_type']?.toString() ??
      '';
  final status = unit['status']?.toString() ?? '';
  final locPrimary = unit['location_primary']?.toString() ?? '';
  final locSecondary = unit['location_secondary']?.toString() ?? '';
  if (expName.isNotEmpty) parts.add(expName);
  if (unitType.isNotEmpty) parts.add(unitType);
  final location = [locPrimary, locSecondary]
      .where((p) => p.isNotEmpty)
      .join(' ');
  if (location.isNotEmpty) parts.add(location);
  if (status.isNotEmpty) parts.add(status);
  return parts.join(' | ');
}

String? _resolveRemoteUrl(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
  return '$_fileBaseUrl$raw';
}

String _remoteKey(String? url) {
  final resolved = _resolveRemoteUrl(url);
  return resolved ?? '';
}

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final List<Map<String, dynamic>> _experiments = [];
  final List<Map<String, dynamic>> _units = [];
  final Set<String> _expandedExperiments = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchExperiments();
  }

  Future<void> _fetchExperiments() async {
    setState(() => _loading = true);
    try {
      final headers = await _buildHeaders();
      final res = await http.get(
        Uri.parse('$_apiBaseUrl/experiments/'),
        headers: headers,
      );
      if (res.statusCode != 200) {
        setState(() {
          _experiments.clear();
          _units.clear();
        });
        return;
      }
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      final List results = data is Map && data['results'] is List
          ? data['results'] as List
          : (data is List ? data : const []);
      final mapped = <Map<String, dynamic>>[];
      for (final raw in results) {
        if (raw is Map<String, dynamic>) {
          mapped.add({
            'id': raw['id'],
            'name': raw['name'],
            'status': raw['status'],
            'start_date': raw['start_date'] ?? raw['startDate'],
            'end_date': raw['end_date'] ?? raw['endDate'],
            'year': raw['year'],
            'experiment_type': raw['experiment_type'],
            'location': raw['location'],
          });
        }
      }
      final unitsRaw = await _fetchAllResults(
        Uri.parse('$_apiBaseUrl/experimental_units/'),
        headers,
      );
      final mappedUnits = <Map<String, dynamic>>[];
      for (final raw in unitsRaw) {
        if (raw is Map) {
          mappedUnits.add({
            'id': raw['id'],
            'unit_code': raw['unit_code'] ?? raw['id'],
            'experiment': raw['experiment'],
            'experiment_name': raw['experiment_name'],
            'unit_type_display': raw['unit_type_display'],
            'unit_type': raw['unit_type'],
            'status': raw['status'],
            'location_primary': raw['location_primary'],
            'location_secondary': raw['location_secondary'],
          });
        }
      }
      setState(() {
        _experiments
          ..clear()
          ..addAll(mapped);
        _units
          ..clear()
          ..addAll(mappedUnits);
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalUnits = _units.length;
    final collectedUnits = _units.where(_isCollectedUnit).length;
    final pendingUnits = totalUnits - collectedUnits;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F5),
      appBar: AppBar(
        title: const Text('智能上传'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchExperiments,
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _buildProgressCard(totalUnits, collectedUnits, pendingUnits),
                const SizedBox(height: 18),
                _buildExperimentSection(),
              ],
            ),
    );
  }

  Widget _buildProgressCard(int total, int finished, int ongoing) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Text(
            '实验进度',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _stat('总单元数', total, Colors.teal),
              _stat('已采集', finished, Colors.green),
              _stat('待采集', ongoing, Colors.orange),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildExperimentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F3F2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '实验列表',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (_experiments.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('暂无实验'),
              ),
            )
          else
            ..._experiments.map(_buildExperimentItem),
        ],
      ),
    );
  }

  Widget _stat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }

  String _experimentKey(Map<String, dynamic> exp) {
    final id = exp['id']?.toString();
    if (id != null && id.isNotEmpty) return id;
    return exp['name']?.toString() ?? '';
  }

  List<Map<String, dynamic>> _unitsForExperiment(Map<String, dynamic> exp) {
    final expId = exp['id']?.toString();
    final expName = exp['name']?.toString();
    return _units.where((unit) {
      final unitExp = unit['experiment']?.toString();
      final unitName = unit['experiment_name']?.toString();
      final matchId =
          expId != null && expId.isNotEmpty && unitExp == expId;
      final matchName =
          expName != null && expName.isNotEmpty && unitName == expName;
      if (expId == null || expId.isEmpty) {
        return expName == null || expName.isEmpty || matchName;
      }
      return matchId || matchName;
    }).toList();
  }

  bool _isCollectedUnit(Map<String, dynamic> unit) {
    final status = unit['status']?.toString() ?? '';
    return status == 'finished' || status == 'collected' || status == 'done';
  }

  void _toggleExpanded(String key) {
    setState(() {
      if (_expandedExperiments.contains(key)) {
        _expandedExperiments.remove(key);
      } else {
        _expandedExperiments.add(key);
      }
    });
  }

  Widget _buildExperimentItem(Map<String, dynamic> exp) {
    final bool ongoing = exp['status'] != 'finished';
    final infoText = _experimentInfoText(exp);
    final key = _experimentKey(exp);
    final units = _unitsForExperiment(exp);
    final collectedCount = units.where(_isCollectedUnit).length;
    final pendingCount = units.length - collectedCount;
    final isExpanded = _expandedExperiments.contains(key);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          InkWell(
            onTap: () => _toggleExpanded(key),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.science, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exp['name'] ?? '',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        const Text('实验信息：'),
                        Text(infoText),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _countBadge('已采集', collectedCount, Colors.green),
                            const SizedBox(width: 8),
                            _countBadge('未采集', pendingCount, Colors.orange),
                          ],
                        ),
                      ]),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: ongoing
                            ? const Color(0xFFD7F0EC)
                            : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        ongoing ? '进行中' : '已完成',
                        style: TextStyle(
                          color: ongoing ? Colors.teal : Colors.green.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      isExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: Colors.grey.shade700,
                    ),
                  ],
                )
              ],
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 12),
            if (units.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('暂无实验单元'),
              )
            else
              ...units.map((unit) => _buildUnitPreview(exp, unit)),
          ],
        ],
      ),
    );
  }

  Widget _countBadge(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label $value',
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildUnitPreview(
      Map<String, dynamic> exp, Map<String, dynamic> unit) {
    final collected = _isCollectedUnit(unit);
    final infoText = _unitInfoText(unit);
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UnitMediaPage(experiment: exp, unit: unit),
          ),
        );
        if (!mounted) return;
        setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: collected ? Colors.green : Colors.teal,
              child: Icon(
                collected ? Icons.check : Icons.camera_alt,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(unit['unit_code']?.toString() ?? '',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(
                    infoText,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: const Color(0xFFF1F6F5),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}

class ExperimentUnitsPage extends StatefulWidget {
  final Map<String, dynamic> experiment;

  const ExperimentUnitsPage({super.key, required this.experiment});

  @override
  State<ExperimentUnitsPage> createState() => _ExperimentUnitsPageState();
}

class _ExperimentUnitsPageState extends State<ExperimentUnitsPage> {
  final List<Map<String, dynamic>> _units = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchUnits();
  }

  Future<void> _fetchUnits() async {
    setState(() => _loading = true);
    try {
      final headers = await _buildHeaders();
      final experimentId = widget.experiment['id']?.toString();
      final experimentName = widget.experiment['name']?.toString();
      final baseUri = Uri.parse('$_apiBaseUrl/experimental_units/');
      List<dynamic> results = [];

      if (experimentId != null && experimentId.isNotEmpty) {
        final uri =
            baseUri.replace(queryParameters: {'experiment': experimentId});
        results = await _fetchAllResults(uri, headers);
      }

      if (results.isEmpty) {
        final all = await _fetchAllResults(baseUri, headers);
        final filtered = all.where((raw) {
          if (raw is! Map) return false;
          final rawExperiment = raw['experiment']?.toString();
          final rawName = raw['experiment_name']?.toString();
          final matchId = experimentId != null &&
              experimentId.isNotEmpty &&
              rawExperiment == experimentId;
          final matchName = experimentName != null &&
              experimentName.isNotEmpty &&
              rawName == experimentName;
          if (experimentId == null || experimentId.isEmpty) {
            return experimentName == null || experimentName.isEmpty || matchName;
          }
          return matchId || matchName;
        }).toList();

        results = filtered.isEmpty ? all : filtered;
      }

      final mapped = <Map<String, dynamic>>[];
      for (final raw in results) {
        if (raw is Map) {
          mapped.add({
            'id': raw['id'],
            'unit_code': raw['unit_code'] ?? raw['id'],
            'experiment': raw['experiment'],
            'experiment_name': raw['experiment_name'],
            'unit_type_display': raw['unit_type_display'],
            'unit_type': raw['unit_type'],
            'status': raw['status'],
            'location_primary': raw['location_primary'],
            'location_secondary': raw['location_secondary'],
          });
        }
      }

      setState(() {
        _units
          ..clear()
          ..addAll(mapped);
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _units.length;
    final collected =
        _units.where((u) => u['status'] == 'finished').length;
    final pending = total - collected;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F5),
      appBar: AppBar(
        title: Text(widget.experiment['name']),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _buildInfoCard(total, collected, pending),
                const SizedBox(height: 16),
                _buildUnitSection(),
              ],
            ),
    );
  }

  Widget _buildInfoCard(int total, int collected, int pending) {
    final infoText = _experimentInfoText(widget.experiment);
    final startDate = widget.experiment['start_date']?.toString() ??
        widget.experiment['startDate']?.toString() ??
        '';
    final endDate = widget.experiment['end_date']?.toString() ??
        widget.experiment['endDate']?.toString() ??
        '';
    final dateText = endDate.isNotEmpty ? '$startDate ~ $endDate' : startDate;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '实验信息',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text('实验信息：$infoText'),
          const SizedBox(height: 6),
          Text('开始日期：$dateText'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem('$total', '总单元数', Colors.teal),
              _StatItem('$collected', '已采集', Colors.green),
              _StatItem('$pending', '待采集', Colors.orange),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildUnitSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F3F2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '实验单元',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (_units.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('暂无实验单元'),
              ),
            )
          else
            ..._units.map(_buildUnitItem),
        ],
      ),
    );
  }

  Widget _buildUnitItem(Map<String, dynamic> unit) {
    final status = unit['status']?.toString() ?? '';
    final collected = status == 'finished' ||
        status == 'collected' ||
        status == 'done';
    final infoText = _unitInfoText(unit);

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                UnitMediaPage(experiment: widget.experiment, unit: unit),
          ),
        );
        if (!mounted) return;
        setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: collected ? Colors.green : Colors.teal,
              child: Icon(
                collected ? Icons.check : Icons.camera_alt,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(unit['unit_code']?.toString() ?? '',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('单元信息：$infoText'),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: collected
                        ? const Color(0xFFD8F1D7)
                        : const Color(0xFFFBE2B5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    collected ? '已采集' : '未采集',
                    style: TextStyle(
                      color: collected ? Colors.green.shade700 : Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.bold, color: color)),
      const SizedBox(height: 4),
      Text(label),
    ]);
  }
}

class UnitMediaPage extends StatefulWidget {
  final Map<String, dynamic> experiment;
  final Map<String, dynamic> unit;

  const UnitMediaPage({super.key, required this.experiment, required this.unit});

  @override
  State<UnitMediaPage> createState() => _UnitMediaPageState();
}

class _UnitMediaPageState extends State<UnitMediaPage> {
  final ImagePicker _picker = ImagePicker();
  final List<Map<String, String>> _media = [];
  final TextEditingController _traitController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  final List<Map<String, String>> _traits = [];
  final List<Map<String, String>> _remarks = [];
  bool _savingStatus = false;

  String? get _unitId => widget.unit['id']?.toString();

  @override
  void initState() {
    super.initState();
    _loadMedia();
    _fetchUnitDetail();
    _fetchRemoteMedia();
  }

  Future<void> _loadMedia() async {
    final unitId = _unitId;
    if (unitId == null || unitId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('unit_media_$unitId');
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final items = <Map<String, String>>[];
        for (final item in decoded) {
          if (item is Map) {
            final path = item['path']?.toString() ?? '';
            final remoteUrl = item['remote_url']?.toString() ?? '';
            final type = item['type']?.toString() ?? '';
            final time = item['time']?.toString() ?? '';
            if (path.isEmpty && remoteUrl.isEmpty) continue;
            if (path.isNotEmpty) {
              final file = File(path);
              if (await file.exists()) {
                items.add({
                  'type': type,
                  'path': path,
                  'time': time,
                  if (remoteUrl.isNotEmpty) 'remote_url': remoteUrl,
                });
                continue;
              }
            }
            if (remoteUrl.isNotEmpty) {
              items.add({
                'type': type,
                'path': path,
                'time': time,
                'remote_url': remoteUrl,
              });
            }
          }
        }
        setState(() {
          _media
            ..clear()
            ..addAll(items);
        });
      }
    } catch (_) {}
  }

  Future<void> _saveMedia() async {
    final unitId = _unitId;
    if (unitId == null || unitId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('unit_media_$unitId', jsonEncode(_media));
  }

  Future<void> _fetchRemoteMedia() async {
    final unitId = _unitId;
    if (unitId == null || unitId.isEmpty) return;
    final headers = await _buildHeaders();
    final baseUri = Uri.parse('$_apiBaseUrl/pfiles/');
    List<dynamic> results = await _fetchAllResults(
      baseUri.replace(queryParameters: {'experimental_unit_id': unitId}),
      headers,
    );
    if (results.isEmpty) {
      results = await _fetchAllResults(
        baseUri.replace(queryParameters: {'experimental_unit': unitId}),
        headers,
      );
    }
    if (results.isEmpty) {
      results = await _fetchAllResults(
        baseUri.replace(queryParameters: {'unit_id': unitId}),
        headers,
      );
    }
    if (results.isEmpty) return;

    final existing = <String, Map<String, String>>{};
    for (final item in _media) {
      final key = _remoteKey(item['remote_url']);
      if (key.isNotEmpty) {
        existing[key] = item;
      }
    }

    var changed = false;
    for (final raw in results) {
      if (raw is! Map) continue;
      final rawUrl = raw['file_url']?.toString() ??
          raw['file_altnative']?.toString() ??
          '';
      if (rawUrl.isEmpty) continue;
      final key = _remoteKey(rawUrl);
      if (key.isEmpty) continue;
      final rawType = raw['file_type']?.toString() ?? '';
      final type = rawType == 'video' ? 'video' : 'image';
      final time = raw['created_at']?.toString() ??
          raw['updated_at']?.toString() ??
          '';
      final existingItem = existing[key];
      if (existingItem != null) {
        var updated = false;
        if ((existingItem['type'] ?? '').isEmpty) {
          existingItem['type'] = type;
          updated = true;
        }
        if ((existingItem['time'] ?? '').isEmpty && time.isNotEmpty) {
          existingItem['time'] = time;
          updated = true;
        }
        if (updated) changed = true;
        continue;
      }
      _media.add({
        'type': type,
        'path': '',
        'time': time,
        'remote_url': rawUrl,
      });
      existing[key] = _media.last;
      changed = true;
    }

    if (changed) {
      if (mounted) {
        setState(() {});
      }
      await _saveMedia();
    }
  }

  bool _isCollectedStatus(String? status) {
    final value = status ?? '';
    return value == 'finished' || value == 'collected' || value == 'done';
  }

  bool get _isCollected =>
      _isCollectedStatus(widget.unit['status']?.toString());

  Future<void> _fetchUnitDetail() async {
    final unitId = _unitId;
    if (unitId == null || unitId.isEmpty) return;
    final headers = await _buildHeaders();
    final res = await http.get(
      Uri.parse('$_apiBaseUrl/experimental_units/$unitId/'),
      headers: headers,
    );
    if (res.statusCode != 200) return;
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (data is! Map) return;
    final time = _safeTime(data['updated_at'] ?? data['created_at']);
    final remarks = _decodeRecordList(data['comment'], time);
    final traits = _decodeRecordList(data['description'], time);
    if (!mounted) return;
    setState(() {
      _remarks
        ..clear()
        ..addAll(remarks);
      _traits
        ..clear()
        ..addAll(traits);
      if (data['status'] != null) {
        widget.unit['status'] = data['status'];
      }
      if (data['comment'] != null) {
        widget.unit['comment'] = data['comment'];
      }
      if (data['description'] != null) {
        widget.unit['description'] = data['description'];
      }
    });
  }

  Future<bool> _patchUnit(Map<String, dynamic> payload) async {
    final unitId = _unitId;
    if (unitId == null || unitId.isEmpty) return false;
    final headers = await _buildHeaders(json: true);
    final res = await http.patch(
      Uri.parse('$_apiBaseUrl/experimental_units/$unitId/'),
      headers: headers,
      body: jsonEncode(payload),
    );
    return res.statusCode == 200;
  }

  String _encodeRecordList(List<Map<String, String>> records) {
    return jsonEncode(records);
  }

  List<Map<String, String>> _decodeRecordList(dynamic raw, String time) {
    if (raw == null) return [];
    final text = raw.toString();
    if (text.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(text);
      if (decoded is List) {
        final items = <Map<String, String>>[];
        for (final item in decoded) {
          if (item is Map) {
            final desc = item['desc']?.toString() ?? '';
            final itemTime = item['time']?.toString() ?? time;
            if (desc.isEmpty) continue;
            items.add({'desc': desc, 'time': itemTime});
          } else if (item != null) {
            items.add({'desc': item.toString(), 'time': time});
          }
        }
        return items;
      }
    } catch (_) {}
    return [
      {'desc': text, 'time': time},
    ];
  }

  String _safeTime(dynamic raw) {
    return raw?.toString() ?? '';
  }

  Future<void> _addTrait() async {
    final text = _traitController.text.trim();
    if (text.isEmpty) return;
    final now = DateTime.now().toString().substring(0, 19);
    final updated = [
      ..._traits,
      {'desc': text, 'time': now},
    ];
    final wasCollected = _isCollected;
    final payload = {
      'description': _encodeRecordList(updated),
      if (!wasCollected) 'status': 'finished',
    };
    final ok = await _patchUnit(payload);
    if (!ok || !mounted) return;
    setState(() {
      _traits
        ..clear()
        ..addAll(updated);
      _traitController.clear();
      if (!wasCollected) {
        widget.unit['status'] = 'finished';
      }
    });
  }

  Future<void> _addRemark() async {
    final text = _remarkController.text.trim();
    if (text.isEmpty) return;
    final now = DateTime.now().toString().substring(0, 19);
    final updated = [
      ..._remarks,
      {'desc': text, 'time': now},
    ];
    final wasCollected = _isCollected;
    final payload = {
      'comment': _encodeRecordList(updated),
      if (!wasCollected) 'status': 'finished',
    };
    final ok = await _patchUnit(payload);
    if (!ok || !mounted) return;
    setState(() {
      _remarks
        ..clear()
        ..addAll(updated);
      _remarkController.clear();
      if (!wasCollected) {
        widget.unit['status'] = 'finished';
      }
    });
  }

  Future<void> _setCollected(bool collected) async {
    if (_savingStatus) return;
    final unitId = _unitId;
    if (unitId == null || unitId.isEmpty) return;
    final previous = widget.unit['status']?.toString() ?? '';
    final next = collected ? 'finished' : 'active';
    if (previous == next) return;
    setState(() {
      _savingStatus = true;
      widget.unit['status'] = next;
    });
    final ok = await _patchUnit({'status': next});
    if (!ok && mounted) {
      setState(() {
        widget.unit['status'] = previous;
      });
    }
    if (mounted) {
      setState(() {
        _savingStatus = false;
      });
    }
  }

  Future<bool> _requestPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
    ].request();
    return statuses[Permission.camera]?.isGranted ?? false;
  }

  Future<void> _takePhoto() async {
    if (!await _requestPermissions()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('需要相机权限才能拍照')),
      );
      return;
    }
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (photo == null) return;
    final saved = await _persistFile(photo, 'image');
    if (saved == null) return;
    await _addMedia(saved, 'image');
  }

  Future<void> _takeVideo() async {
    if (!await _requestPermissions()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('需要相机权限才能录像')),
      );
      return;
    }
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    if (video == null) return;
    final saved = await _persistFile(video, 'video');
    if (saved == null) return;
    await _addMedia(saved, 'video');
  }

  Future<File?> _persistFile(XFile picked, String type) async {
    final unitId = _unitId ?? 'unknown';
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/unit_media/$unitId/$type');
    await dir.create(recursive: true);
    final ext = picked.path.split('.').last;
    final filename = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final saved = await File(picked.path).copy('${dir.path}/$filename');
    return saved;
  }

  Future<void> _addMedia(File file, String type) async {
    final record = {
      'type': type,
      'path': file.path,
      'time': DateTime.now().toString().substring(0, 19),
    };
    setState(() {
      _media.add(record);
    });
    await _saveMedia();
    final response = await _uploadFile(file, type);
    final fileUrl = response?['file_url']?.toString();
    if (fileUrl != null && fileUrl.isNotEmpty) {
      record['remote_url'] = fileUrl;
      await _saveMedia();
      if (!_isCollected) {
        await _setCollected(true);
      }
    }
  }

  Future<Map<String, dynamic>?> _uploadFile(File file, String fileType) async {
    final unitId = _unitId;
    if (unitId == null || unitId.isEmpty) return null;
    final headers = await _buildHeaders();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_apiBaseUrl/pfiles/upload/'),
    );
    request.headers.addAll(headers);
    request.fields['file_type'] = fileType;
    request.fields['experimental_unit_id'] = unitId.trim();
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    try {
      final response = await request.send();
      final body = await response.stream.bytesToString();
      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  String _extensionFromUrl(String url, String type) {
    final path = Uri.parse(url).path;
    final dot = path.lastIndexOf('.');
    if (dot != -1 && dot > path.lastIndexOf('/')) {
      return path.substring(dot);
    }
    return type == 'video' ? '.mp4' : '.jpg';
  }

  Future<File?> _downloadMedia(Map<String, String> item) async {
    final url = _resolveRemoteUrl(item['remote_url']);
    if (url == null) return null;
    final unitId = _unitId ?? 'unknown';
    final type = item['type'] ?? 'file';
    try {
      final headers = await _buildHeaders();
      final res = await http.get(Uri.parse(url), headers: headers);
      if (res.statusCode != 200) return null;
      final base = await getApplicationDocumentsDirectory();
      final dir = Directory('${base.path}/unit_media/$unitId/$type');
      await dir.create(recursive: true);
      final ext = _extensionFromUrl(url, type);
      final filename = 'remote_${DateTime.now().millisecondsSinceEpoch}$ext';
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(res.bodyBytes);
      item['path'] = file.path;
      await _saveMedia();
      if (mounted) {
        setState(() {});
      }
      return file;
    } catch (_) {
      return null;
    }
  }

  Future<void> _openMedia(Map<String, String> item) async {
    File? file;
    final path = item['path'] ?? '';
    if (path.isNotEmpty) {
      final local = File(path);
      if (await local.exists()) {
        file = local;
      }
    }
    file ??= await _downloadMedia(item);
    if (file == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to load media')),
        );
      }
      return;
    }
    if (item['type'] == 'video') {
      _playVideo(file);
    } else {
      _viewPhoto(file);
    }
  }

  void _viewPhoto(File file) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PhotoPreviewPage(photoFile: file)),
    );
  }

  void _playVideo(File file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(videoFile: file),
      ),
    );
  }

  Future<void> _deleteMedia(int index) async {
    final item = _media.removeAt(index);
    final path = item['path'];
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
    setState(() {});
    await _saveMedia();
  }

  List<Map<String, String>> get _photos =>
      _media.where((m) => m['type'] == 'image').toList();

  List<Map<String, String>> get _videos =>
      _media.where((m) => m['type'] == 'video').toList();

  @override
  void dispose() {
    _traitController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unitInfo = _unitInfoText(widget.unit);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.unit['unit_code']?.toString() ?? '实验单元'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _infoCard(unitInfo),
          _mediaCard(),
          _photoList(),
          _videoList(),
          _remarkInput(),
          _remarkList(),
          _traitInput(),
          _traitList(),
        ],
      ),
    );
  }

  Widget _infoCard(String infoText) {
    final collected = _isCollected;
    final statusLabel = collected ? '已采集' : '未采集';
    final statusColor = collected ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('实验：${widget.experiment['name']}'),
        Text('单元编号：${widget.unit['unit_code']}'),
        Text('单元信息：$infoText'),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Status:'),
            const SizedBox(width: 8),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _savingStatus ? null : () => _setCollected(!collected),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (_savingStatus) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
      ]),
    );
  }

  Widget _mediaCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _mediaSummary(
                  Icons.photo,
                  '查看照片',
                  _photos.length,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _mediaSummary(
                  Icons.videocam,
                  '查看录像',
                  _videos.length,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _fetchRemoteMedia,
              icon: const Icon(Icons.refresh, color: Colors.teal),
              label: const Text(
                '刷新',
                style: TextStyle(color: Colors.teal),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mediaSummary(IconData icon, String label, int count) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            '$label ($count)',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoList() { {
    if (_photos.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('照片', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _photos.length,
              itemBuilder: (context, index) {
                final item = _photos[index];
                final path = item['path'] ?? '';
                final hasLocal =
                    path.isNotEmpty && File(path).existsSync();
                final canDownload =
                    !hasLocal && _resolveRemoteUrl(item['remote_url']) != null;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _openMedia(item),
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: hasLocal
                                ? Image.file(File(path), fit: BoxFit.cover)
                                : Container(
                                    color: Colors.grey[200],
                                    alignment: Alignment.center,
                                    child: Icon(
                                      canDownload
                                          ? Icons.cloud_download
                                          : Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      if (canDownload)
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.download,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => _deleteMedia(_media.indexOf(item)),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoList() {
    if (_videos.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('视频', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _videos.length,
              itemBuilder: (context, index) {
                final item = _videos[index];
                final path = item['path'] ?? '';
                final hasLocal =
                    path.isNotEmpty && File(path).existsSync();
                final canDownload =
                    !hasLocal && _resolveRemoteUrl(item['remote_url']) != null;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _openMedia(item),
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          child: Icon(
                            hasLocal
                                ? Icons.play_circle_fill
                                : (canDownload
                                    ? Icons.cloud_download
                                    : Icons.videocam_off),
                            size: 40,
                            color: hasLocal ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ),
                      if (canDownload)
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.download,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => _deleteMedia(_media.indexOf(item)),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _remarkInput() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '备注采集',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _remarkController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: '备注描述',
              prefixIcon: Icon(Icons.edit),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              minimumSize: const Size(200, 44),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: _addRemark,
            child: const Text('添加备忘记录'),
          )
        ],
      ),
    );
  }

  Widget _remarkList() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F3F2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '备忘记录 (${_remarks.length}条)',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _remarks.isEmpty
              ? const Center(child: Text('暂无备注记录'))
              : Column(
                  children: _remarks
                      .map((t) => _recordItem(
                            icon: Icons.sticky_note_2_outlined,
                            color: Colors.teal,
                           desc: t['desc']!,
                           time: t['time']!,
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _traitInput() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '性状采集',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _traitController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: '性状描述',
              prefixIcon: Icon(Icons.edit),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              minimumSize: const Size(200, 44),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: _addTrait,
            child: const Text('添加性状记录'),
          )
        ],
      ),
    );
  }

  Widget _traitList() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F3F2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '性状记录 (${_traits.length})条',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _traits.isEmpty
              ? const Center(child: Text('暂无性状记录'))
              : Column(
                  children: _traits
                      .map((t) => _recordItem(
                            icon: Icons.eco_outlined,
                            color: Colors.green,
                            desc: t['desc']!,
                            time: t['time']!,
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _recordItem({
    required IconData icon,
    required Color color,
    required String desc,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(desc,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(time,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PhotoPreviewPage extends StatelessWidget {
  final File photoFile;

  const PhotoPreviewPage({super.key, required this.photoFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('照片预览', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(photoFile),
        ),
      ),
    );
  }
}
