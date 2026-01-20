import 'package:flutter/material.dart';
import 'package:expense_tracker/models/record.dart';
import 'package:expense_tracker/utils/database_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  double _totalIncome = 0;
  double _totalExpense = 0;
  Map<Category, double> _expenseByCategory = {};
  Map<Category, double> _incomeByCategory = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 计算总收入和支出
    double income = await _dbHelper.getTotalAmountByType(RecordType.income, _startDate, _endDate);
    double expense = await _dbHelper.getTotalAmountByType(RecordType.expense, _startDate, _endDate);

    // 按分类统计
    Map<Category, double> expenseByCategory = await _dbHelper.getAmountByCategory(RecordType.expense, _startDate, _endDate);
    Map<Category, double> incomeByCategory = await _dbHelper.getAmountByCategory(RecordType.income, _startDate, _endDate);

    setState(() {
      _totalIncome = income;
      _totalExpense = expense;
      _expenseByCategory = expenseByCategory;
      _incomeByCategory = incomeByCategory;
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadData();
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

  List<PieChartSectionData> _getExpensePieSections() {
    List<PieChartSectionData> sections = [];
    List<Color> colors = [
      Colors.red, Colors.blue, Colors.green, Colors.yellow,
      Colors.purple, Colors.orange, Colors.teal, Colors.pink
    ];

    int colorIndex = 0;
    _expenseByCategory.forEach((category, amount) {
      double percentage = (_totalExpense > 0) ? (amount / _totalExpense) * 100 : 0;
      sections.add(
        PieChartSectionData(
          value: amount,
          title: '${_getCategoryName(category)}\n${percentage.toStringAsFixed(1)}%',
          color: colors[colorIndex % colors.length],
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return sections;
  }

  List<PieChartSectionData> _getIncomePieSections() {
    List<PieChartSectionData> sections = [];
    List<Color> colors = [
      Colors.green, Colors.blue, Colors.purple, Colors.teal,
      Colors.orange, Colors.red, Colors.yellow, Colors.pink
    ];

    int colorIndex = 0;
    _incomeByCategory.forEach((category, amount) {
      double percentage = (_totalIncome > 0) ? (amount / _totalIncome) * 100 : 0;
      sections.add(
        PieChartSectionData(
          value: amount,
          title: '${_getCategoryName(category)}\n${percentage.toStringAsFixed(1)}%',
          color: colors[colorIndex % colors.length],
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('统计分析'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDateRange(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 日期范围
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('统计期间:'),
                      Text(
                        '${DateFormat('yyyy-MM-dd').format(_startDate)} 至 ${DateFormat('yyyy-MM-dd').format(_endDate)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              // 收支概览
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '收支概览',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('收入'),
                              Text(
                                '¥${_totalIncome.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('支出'),
                              Text(
                                '¥${_totalExpense.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 20,
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
                          const Text('结余'),
                          Text(
                            '¥${(_totalIncome - _totalExpense).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: (_totalIncome - _totalExpense) >= 0 ? Colors.blue : Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 支出分类饼图
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '支出分类',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: PieChart(
                          PieChartData(
                            sections: _getExpensePieSections(),
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                // 触摸事件处理
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 收入分类饼图
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '收入分类',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: PieChart(
                          PieChartData(
                            sections: _getIncomePieSections(),
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                // 触摸事件处理
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}