import 'package:flutter/material.dart';
import 'package:expense_tracker/models/record.dart';
import 'package:expense_tracker/utils/database_helper.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Record> _records = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    List<Record> records;
    if (_startDate != null && _endDate != null) {
      records = await _dbHelper.queryRecordsByDateRange(_startDate!, _endDate!);
    } else {
      records = await _dbHelper.queryAllRecords();
    }
    setState(() {
      _records = records;
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    final DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: _startDate ?? firstDayOfMonth,
        end: _endDate ?? lastDayOfMonth,
      ),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadRecords();
    }
  }

  String _getCategoryName(Category category) {
    switch (category) {
      case Category.food: return '餐饮';
      case Category.shopping: return '购物';
      case Category.transport: return '交通';
      case Category.entertainment: return '娱乐';
      case Category.medical: return '医疗';
      case Category.education: return '教育';
      case Category.housing: return '住房';
      case Category.other: return '其他';
      case Category.salary: return '工资';
      case Category.bonus: return '奖金';
      case Category.investment: return '投资';
      case Category.partTime: return '兼职';
      case Category.gift: return '礼金';
      case Category.otherIncome: return '其他收入';
      // default: return '未知';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDateRange(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _startDate = null;
                _endDate = null;
              });
              _loadRecords();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRecords,
        child: _records.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('暂无记录'),
                ),
              )
            : ListView.builder(
                itemCount: _records.length,
                itemBuilder: (context, index) {
                  Record record = _records[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _getCategoryName(record.category),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${record.type == RecordType.income ? '+' : '-' }¥${record.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: record.type == RecordType.income ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          if (record.description.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                record.description,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                DateFormat('yyyy-MM-dd HH:mm').format(record.date),
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}