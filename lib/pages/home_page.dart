import 'package:flutter/material.dart';
import 'package:expense_tracker/pages/add_record_page.dart';
import 'package:expense_tracker/pages/history_page.dart';
import 'package:expense_tracker/pages/statistics_page.dart';
import 'package:expense_tracker/utils/database_helper.dart';
import 'package:expense_tracker/models/record.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _totalIncome = 0;
  double _totalExpense = 0;
  List<Record> _recentRecords = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 获取当月的开始和结束日期
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    // 修正：传时间戳（毫秒数），而非字符串
  double income = await _dbHelper.getTotalAmountByType(
    RecordType.income,
    startOfMonth,
    endOfMonth,
  );
  double expense = await _dbHelper.getTotalAmountByType(
    RecordType.expense,
    startOfMonth,
    endOfMonth,
  );

    // 获取最近的5条记录
    List<Record> records = await _dbHelper.queryAllRecords();
    List<Record> recentRecords = records.length > 5 ? records.sublist(0, 5) : records;

    setState(() {
      _totalIncome = income;
      _totalExpense = expense;
      _recentRecords = recentRecords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记账App'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 收支概览
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '本月收支',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '收入',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '¥${_totalIncome.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '支出',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '¥${_totalExpense.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '结余',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '¥${(_totalIncome - _totalExpense).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: (_totalIncome - _totalExpense) >= 0 ? Colors.blue : Colors.red,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 快速操作
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddRecordPage(
                            onRecordAdded: _loadData,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('记一笔'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(150, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const StatisticsPage()),
                      );
                    },
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('统计'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(150, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 最近记录
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '最近记录',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HistoryPage()),
                      );
                    },
                    child: const Text('查看全部'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              if (_recentRecords.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('暂无记录'),
                  ),
                )
              else
                Column(
                  children: _recentRecords.map((record) => _buildRecordCard(record)).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordCard(Record record) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getCategoryName(record.category),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  record.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(record.date),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
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
      ),
    );
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
}