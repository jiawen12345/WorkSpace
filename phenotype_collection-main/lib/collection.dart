import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _apiBaseUrl = 'http://61.155.111.202:18080/cprweb/pt/api';

Future<Map<String, String>> _buildHeaders({bool json = false}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final headers = <String, String>{
    'Accept': 'application/json',
  };
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

String? _experimentRange(Map<String, dynamic> exp) {
  final range = exp['range'] ?? exp['unit_range'] ?? exp['plot_range'];
  if (range != null && range.toString().isNotEmpty) {
    return range.toString();
  }
  final start = exp['range_start'] ?? exp['unit_start'] ?? exp['unit_code_start'];
  final end = exp['range_end'] ?? exp['unit_end'] ?? exp['unit_code_end'];
  if (start != null && end != null) {
    return '${start.toString()} ~ ${end.toString()}';
  }
  return null;
}

String? _experimentProgress(Map<String, dynamic> exp) {
  final progress = exp['progress'];
  if (progress != null && progress.toString().isNotEmpty) {
    return progress.toString();
  }
  final current = exp['collected_count'] ??
      exp['completed_count'] ??
      exp['current'] ??
      exp['progress_current'];
  final total =
      exp['total_count'] ?? exp['total'] ?? exp['progress_total'] ?? exp['unit_total'];
  if (current != null && total != null) {
    return '${current.toString()}/${total.toString()}';
  }
  return null;
}

String _experimentInfoText(Map<String, dynamic> exp) {
  final parts = <String>[];
  final location = exp['location']?.toString() ?? '';
  final expType = exp['experiment_type']?.toString() ?? '';
  final year = exp['year']?.toString() ?? '';
  final start = exp['start_date']?.toString() ?? exp['startDate']?.toString() ?? '';
  final end = exp['end_date']?.toString() ?? exp['endDate']?.toString() ?? '';
  if (location.isNotEmpty) parts.add(location);
  if (expType.isNotEmpty) parts.add(expType);
  if (year.isNotEmpty) parts.add(year);
  if (start.isNotEmpty || end.isNotEmpty) {
    final range = end.isNotEmpty ? '$start ~ $end' : start;
    if (range.isNotEmpty) parts.add(range);
  }
  final fallbackRange = _experimentRange(exp);
  if (parts.isEmpty && fallbackRange != null && fallbackRange.isNotEmpty) {
    parts.add(fallbackRange);
  }
  return parts.join(' | ');
}

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final List<Map<String, dynamic>> _experimentList = [];
  bool _loading = false;

  double _progressValue(String progress) {
    final parts = progress.split('/');
    if (parts.length != 2) return 0;
    final current = int.tryParse(parts[0].trim());
    final total = int.tryParse(parts[1].trim());
    if (current == null || total == null || total == 0) return 0;
    return current / total;
  }

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
        setState(() => _experimentList.clear());
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
            'range': _experimentRange(raw),
            'progress': _experimentProgress(raw),
            'status': raw['status'],
            'start_date': raw['start_date'] ?? raw['startDate'],
            'end_date': raw['end_date'] ?? raw['endDate'],
            'year': raw['year'],
            'experiment_type': raw['experiment_type'],
            'location': raw['location'],
          });
        }
      }

      setState(() {
        _experimentList
          ..clear()
          ..addAll(mapped);
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _experimentList.length;
    final finished =
        _experimentList.where((e) => e['status'] == 'finished').length;
    final ongoing = total - finished;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F5),
      appBar: AppBar(
        title: const Text('数据采集'),
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
                _buildProgressCard(total, finished, ongoing),
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
              _stat('总实验数', total, Colors.teal),
              _stat('已完成', finished, Colors.green),
              _stat('进行中', ongoing, Colors.orange),
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
          if (_experimentList.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('暂无实验'),
              ),
            )
          else
            ..._experimentList.map(_buildExperimentItem),
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

  Widget _buildExperimentItem(Map<String, dynamic> exp) {
    final bool ongoing = exp['status'] != 'finished';
    final progressText = exp['progress']?.toString() ?? '0/0';
    final progressValue = _progressValue(progressText);
    final infoText = _experimentInfoText(exp);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExperimentPlotsPage(experiment: exp),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
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
                    const SizedBox(height: 6),
                    Text('进度：$progressText'),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: progressValue,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.teal,
                    ),
                  ]),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                const Icon(Icons.chevron_right),
              ],
            )
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

class ExperimentPlotsPage extends StatefulWidget {
  final Map<String, dynamic> experiment;

  const ExperimentPlotsPage({super.key, required this.experiment});

  @override
  State<ExperimentPlotsPage> createState() => _ExperimentPlotsPageState();
}

class _ExperimentPlotsPageState extends State<ExperimentPlotsPage> {
  final List<Map<String, dynamic>> _plots = [];
  PlotFilter _filter = PlotFilter.all;

  @override
  void initState() {
    super.initState();
    _fetchPlots();
  }

  Future<void> _fetchPlots() async {
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
        mapped.add(_mapPlot(Map<String, dynamic>.from(raw)));
      }
    }
    if (!mounted) return;
    setState(() {
      _plots
        ..clear()
        ..addAll(mapped);
    });
  }

  Map<String, dynamic> _mapPlot(Map<String, dynamic> unit) {
    final status = unit['status']?.toString() ?? '';
    final hasComment = (unit['comment']?.toString() ?? '').isNotEmpty;
    final hasDescription =
        (unit['description']?.toString() ?? '').isNotEmpty;
    final collected =
        status == 'finished' ||
            status == 'collected' ||
            status == 'done' ||
            hasComment ||
            hasDescription;
    final unitId = unit['id'];
    final unitCode = unit['unit_code']?.toString() ?? unitId?.toString() ?? '';
    final time = unit['updated_at']?.toString() ??
        unit['created_at']?.toString() ??
        '';
    return {
      'unitId': unitId,
      'plotId': unitCode,
      'variety': _resolveVariety(unit),
      'experimentName': unit['experiment_name']?.toString() ?? '',
      'unitTypeDisplay': unit['unit_type_display']?.toString() ??
          unit['unit_type']?.toString() ??
          '',
      'locationPrimary': unit['location_primary']?.toString() ?? '',
      'locationSecondary': unit['location_secondary']?.toString() ?? '',
      'collected': collected,
      'time': time,
      'status': status,
    };
  }

  String _resolveVariety(Map<String, dynamic> unit) {
    final mutantSnapshot = unit['mutant_snapshot'];
    if (mutantSnapshot is Map && mutantSnapshot['cultivar'] != null) {
      return mutantSnapshot['cultivar'].toString();
    }
    final mutantInfo = unit['mutant_info'];
    if (mutantInfo is Map && mutantInfo['cultivar'] != null) {
      return mutantInfo['cultivar'].toString();
    }
    return '';
  }

  String _plotInfoText(Map<String, dynamic> plot) {
    final parts = <String>[];
    final experimentName = plot['experimentName']?.toString() ?? '';
    final variety = plot['variety']?.toString() ?? '';
    final unitType = plot['unitTypeDisplay']?.toString() ?? '';
    final status = plot['status']?.toString() ?? '';
    final locPrimary = plot['locationPrimary']?.toString() ?? '';
    final locSecondary = plot['locationSecondary']?.toString() ?? '';
    if (experimentName.isNotEmpty) parts.add(experimentName);
    if (variety.isNotEmpty) parts.add(variety);
    if (unitType.isNotEmpty && unitType != variety) parts.add(unitType);
    final location = [locPrimary, locSecondary]
        .where((p) => p.isNotEmpty)
        .join(' ');
    if (location.isNotEmpty) parts.add(location);
    if (status.isNotEmpty) parts.add(status);
    return parts.join(' | ');
  }

  Future<void> _toggleCollected(Map<String, dynamic> plot) async {
    final wasCollected = plot['collected'] == true;
    final isCollected = !wasCollected;
    final now = DateTime.now().toString().substring(0, 19);
    setState(() {
      plot['collected'] = isCollected;
      if (isCollected) {
        final hasTime = (plot['time']?.toString() ?? '').isNotEmpty;
        plot['time'] = hasTime ? plot['time'] : now;
      } else {
        plot['time'] = '';
      }
    });
    final unitId = plot['unitId']?.toString();
    if (unitId == null || unitId.isEmpty) return;
    final status = isCollected ? 'finished' : 'active';
    final ok = await _patchUnitStatus(unitId, status);
    if (!ok && mounted) {
      setState(() {
        plot['collected'] = wasCollected;
        if (!wasCollected) {
          plot['time'] = '';
        }
      });
    }
  }

  Future<bool> _patchUnitStatus(String unitId, String status) async {
    final headers = await _buildHeaders(json: true);
    final res = await http.patch(
      Uri.parse('$_apiBaseUrl/experimental_units/$unitId/'),
      headers: headers,
      body: jsonEncode({'status': status}),
    );
    return res.statusCode == 200;
  }

  int get _totalCount => _plots.length;

  int get _collectedCount =>
      _plots.where((p) => p['collected'] == true).length;

  int get _pendingCount => _totalCount - _collectedCount;

  List<Map<String, dynamic>> get _filteredPlots {
    if (_filter == PlotFilter.all) return _plots;
    final wantCollected = _filter == PlotFilter.collected;
    return _plots.where((p) => p['collected'] == wantCollected).toList();
  }

  void _deletePlot(Map<String, dynamic> plot) {
    setState(() {
      _plots.remove(plot);
    });
  }

  String _nextPlotId() {
    var maxNum = 0;
    for (final p in _plots) {
      final id = p['plotId']?.toString() ?? '';
      final num = int.tryParse(id.replaceAll(RegExp(r'[^0-9]'), ''));
      if (num != null && num > maxNum) maxNum = num;
    }
    final next = maxNum + 1;
    return '25KY${next.toString().padLeft(5, '0')}';
  }

  void _addPlot() {
    final plot = {
      'plotId': _nextPlotId(),
      'variety': '',
      'collected': false,
      'time': '',
    };
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PlotCollectionPage(experiment: widget.experiment, plot: plot),
      ),
    );
  }

  String _filterLabel(PlotFilter filter) {
    switch (filter) {
      case PlotFilter.collected:
        return '已采集';
      case PlotFilter.pending:
        return '未采集';
      case PlotFilter.all:
      default:
        return '全部';
    }
  }

  void _showFilterDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('筛选'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _filterOption(ctx, PlotFilter.pending, '未采集'),
              _filterOption(ctx, PlotFilter.collected, '已采集'),
              _filterOption(ctx, PlotFilter.all, '全部'),
            ],
          ),
        );
      },
    );
  }

  Widget _filterOption(BuildContext ctx, PlotFilter value, String label) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          setState(() => _filter = value);
          Navigator.pop(ctx);
        },
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F5),
      appBar: AppBar(
        title: Text(widget.experiment['name']),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _infoCard(),
          const SizedBox(height: 16),
          _plotSection(context, _filteredPlots),
        ],
      ),
    );
  }

  Widget _infoCard() {
    final infoText = _experimentInfoText(widget.experiment);
    final startDate = widget.experiment['start_date']?.toString() ??
        widget.experiment['startDate']?.toString() ??
        '';
    final endDate =
        widget.experiment['end_date']?.toString() ??
            widget.experiment['endDate']?.toString() ??
            '';
    final dateText =
        endDate.isNotEmpty ? '$startDate ~ $endDate' : startDate;

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
              _StatItem('$_totalCount', '总实验数', Colors.teal),
              _StatItem('$_collectedCount', '已采集', Colors.green),
              _StatItem('$_pendingCount', '待采集', Colors.orange),
            ],
          )
        ],
      ),
    );
  }

  Widget _plotSection(BuildContext context, List<Map<String, dynamic>> plots) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F3F2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '实验单元',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _showFilterDialog,
                    icon: const Icon(Icons.filter_alt_outlined, size: 18),
                    label: Text('筛选: ${_filterLabel(_filter)}'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      side: const BorderSide(color: Colors.teal),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _addPlot,
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10AFA2), Color(0xFF0E8F88)],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.add_circle_outline,
                              size: 18, color: Colors.white),
                          SizedBox(width: 6),
                          Text('新增',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...plots.map((plot) => _plotItem(context, plot)),
        ],
      ),
    );
  }

  Widget _plotItem(BuildContext context, Map<String, dynamic> p) {
    final collected = p['collected'] as bool;
    final infoText = _plotInfoText(p);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PlotCollectionPage(experiment: widget.experiment, plot: p),
          ),
        );
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
                  Text(p['plotId'],
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('单元信息：$infoText'),
                  if (collected) Text("采集时间：${p['time']}")
                ],
              ),
            ),
            Column(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _toggleCollected(p),
                  child: Container(
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
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _deletePlot(p),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE2E2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      '删除',
                      style: TextStyle(
                        color: Color(0xFFB71C1C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
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

class PlotCollectionPage extends StatefulWidget {
  final Map<String, dynamic> experiment;
  final Map<String, dynamic> plot;

  const PlotCollectionPage(
      {super.key, required this.experiment, required this.plot});

  @override
  State<PlotCollectionPage> createState() => _PlotCollectionPageState();
}

class _PlotCollectionPageState extends State<PlotCollectionPage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  final List<File> _photos = [];
  final List<File> _videos = [];
  final List<Map<String, String>> _traits = [];
  final List<Map<String, String>> _remarks = [];

  String? get _unitId => widget.plot['unitId']?.toString();

  @override
  void initState() {
    super.initState();
    _fetchPlotDetail();
  }

  Future<void> _takePhoto() async {
    final x = await _picker.pickImage(source: ImageSource.camera);
    if (x == null) return;
    final file = File(x.path);
    final ok = await _uploadFile(file, 'image');
    if (!ok || !mounted) return;
    final now = DateTime.now().toString().substring(0, 19);
    setState(() {
      _photos.add(file);
      widget.plot['collected'] = true;
      final hasTime = (widget.plot['time']?.toString() ?? '').isNotEmpty;
      widget.plot['time'] = hasTime ? widget.plot['time'] : now;
    });
  }

  Future<void> _takeVideo() async {
    final x = await _picker.pickVideo(source: ImageSource.camera);
    if (x == null) return;
    final file = File(x.path);
    final ok = await _uploadFile(file, 'video');
    if (!ok || !mounted) return;
    final now = DateTime.now().toString().substring(0, 19);
    setState(() {
      _videos.add(file);
      widget.plot['collected'] = true;
      final hasTime = (widget.plot['time']?.toString() ?? '').isNotEmpty;
      widget.plot['time'] = hasTime ? widget.plot['time'] : now;
    });
  }

  Future<void> _addTrait() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final now = DateTime.now().toString().substring(0, 19);
    final updated = [
      ..._traits,
      {'desc': text, 'time': now},
    ];
    final ok = await _patchUnit({'description': _encodeRecordList(updated)});
    if (!ok || !mounted) return;
    setState(() {
      _traits
        ..clear()
        ..addAll(updated);
      _controller.clear();
      widget.plot['collected'] = true;
      final hasTime = (widget.plot['time']?.toString() ?? '').isNotEmpty;
      widget.plot['time'] = hasTime ? widget.plot['time'] : now;
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
    final ok = await _patchUnit({'comment': _encodeRecordList(updated)});
    if (!ok || !mounted) return;
    setState(() {
      _remarks
        ..clear()
        ..addAll(updated);
      _remarkController.clear();
      widget.plot['collected'] = true;
      final hasTime = (widget.plot['time']?.toString() ?? '').isNotEmpty;
      widget.plot['time'] = hasTime ? widget.plot['time'] : now;
    });
  }

  Future<void> _fetchPlotDetail() async {
    final unitId = _unitId;
    if (unitId == null || unitId.isEmpty) return;
    final headers = await _buildHeaders();
    final res = await http.get(
      Uri.parse('$_apiBaseUrl/experimental_units/$unitId/'),
      headers: headers,
    );
    if (res.statusCode != 200) return;
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (data is! Map<String, dynamic>) return;
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
      if (time.isNotEmpty && (remarks.isNotEmpty || traits.isNotEmpty)) {
        widget.plot['collected'] = true;
        widget.plot['time'] = time;
      }
    });
  }

  Future<bool> _uploadFile(File file, String fileType) async {
    final unitId = _unitId;
    if (unitId == null || unitId.isEmpty) {
      debugPrint('upload skipped: missing unitId');
      return false;
    }
    final headers = await _buildHeaders();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_apiBaseUrl/pfiles/upload/'),
    );
    request.headers.addAll(headers);
    request.fields['file_type'] = fileType;
    request.fields['experimental_unit_id'] = unitId;
    request.fields['experimental_unit_id'] = unitId.trim();
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    debugPrint('upload start: type=$fileType unitId=$unitId path=${file.path}');
    try {
      final response = await request.send();
      final body = await response.stream.bytesToString();
      debugPrint('upload response: ${response.statusCode} body=$body');
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint('upload error: $e');
      return false;
    }
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

  @override
  void dispose() {
    _controller.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plot['plotId']),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: Text('提交')),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _infoCard(),
          _mediaCard(),
          _remarkInput(),
          _remarkList(),
          _traitInput(),
          _traitList(),
        ],
      ),
    );
  }

  String _plotDetailText(Map<String, dynamic> plot) {
    final parts = <String>[];
    final variety = plot['variety']?.toString() ?? '';
    final unitType = plot['unitTypeDisplay']?.toString() ?? '';
    final locPrimary = plot['locationPrimary']?.toString() ?? '';
    final locSecondary = plot['locationSecondary']?.toString() ?? '';
    if (variety.isNotEmpty) parts.add(variety);
    if (unitType.isNotEmpty && unitType != variety) parts.add(unitType);
    final location = [locPrimary, locSecondary]
        .where((p) => p.isNotEmpty)
        .join(' ');
    if (location.isNotEmpty) parts.add(location);
    return parts.join(' | ');
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('实验：${widget.experiment['name']}'),
        Text('实验编号：${widget.plot['plotId']}'),
        Text('单元信息：${_plotDetailText(widget.plot)}'),
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
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: _takePhoto,
              icon: const Icon(Icons.camera_alt),
              label: Text('拍照 (${_photos.length})'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: _takeVideo,
              icon: const Icon(Icons.videocam),
              label: Text('录像 (${_videos.length})'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _traitInput() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '性状采集',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
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
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: _addTrait,
            child: const Text('添加性状记录'),
          )
        ],
      ),
    );
  }

  Widget _remarkInput() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
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
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: _addRemark,
            child: const Text('添加备注记录'),
          )
        ],
      ),
    );
  }

  Widget _remarkList() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F3F2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '备注记录 (${_remarks.length}条)',
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

  Widget _traitList() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F3F2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '性状记录 (${_traits.length}条)',
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

enum PlotFilter { all, collected, pending }


