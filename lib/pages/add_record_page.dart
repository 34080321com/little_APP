import 'package:flutter/material.dart';
import 'package:expense_tracker/models/record.dart';
import 'package:expense_tracker/utils/database_helper.dart';
import 'package:intl/intl.dart';
// 导入Flutter核心包（必须有）

class AddRecordPage extends StatefulWidget {
  final Function? onRecordAdded;

  const AddRecordPage({super.key, this.onRecordAdded});

  @override
  _AddRecordPageState createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  RecordType _selectedType = RecordType.expense;
  Category _selectedCategory = Category.food;
  DateTime _selectedDate = DateTime.now();

  // final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  List<Category> _getCategoriesByType(RecordType type) {
    if (type == RecordType.expense) {
      return [
        Category.food,
        Category.shopping,
        Category.transport,
        Category.entertainment,
        Category.medical,
        Category.education,
        Category.housing,
        Category.other,
      ];
    } else {
      return [
        Category.salary,
        Category.bonus,
        Category.investment,
        Category.partTime,
        Category.gift,
        Category.otherIncome,
      ];
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

  void _submitForm() async {
  debugPrint('点击保存，表单验证状态：${_formKey.currentState!.validate()}');
  if (!_formKey.currentState!.validate()) return;

  // 打印要保存的数据，确认变量正确
  debugPrint('金额：${_amountController.text}，分类：${_selectedCategory}，类型：${_selectedType}');
  
  double amount = double.parse(_amountController.text);
  Record record = Record(
    amount: amount,
    type: _selectedType,
    category: _selectedCategory,
    date: _selectedDate,
    description: _descriptionController.text,
  );

  try {
  int id = await DatabaseHelper.instance.insert(record);
  // 优化成功日志，增加上下文信息
  debugPrint('【记账记录】保存成功，记录ID：$id'); 
  // 调用回调刷新首页
  if (widget.onRecordAdded != null) {
    widget.onRecordAdded!();
  }
  // 提示+清空表单
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('保存成功！')),
  );
} catch (e, stackTrace) { // 增加stackTrace捕获异常堆栈
  // 1. 打印详细错误信息到终端（核心修改）
  debugPrint('【记账记录】保存失败 ===== START =====');
  debugPrint('错误类型：${e.runtimeType}'); // 打印错误类型
  debugPrint('错误详情：$e'); // 打印错误内容
  debugPrint('异常堆栈：$stackTrace'); // 打印完整堆栈，定位代码位置
  debugPrint('【记账记录】保存失败 ===== END =====');
  
  // 2. 给用户的提示简化（避免展示复杂堆栈）
  String userErrorMsg = '保存失败：${e.toString().split(':').first}';
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(userErrorMsg),
      backgroundColor: Colors.red, // 错误提示用红色更醒目
    ),
  );
}
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加记录'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 收支类型选择
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<RecordType>(
                      title: const Text('支出'),
                      value: RecordType.expense,
                      groupValue: _selectedType,
                      onChanged: (RecordType? value) {
                        setState(() {
                          _selectedType = value!;
                          _selectedCategory = _getCategoriesByType(value).first;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<RecordType>(
                      title: const Text('收入'),
                      value: RecordType.income,
                      groupValue: _selectedType,
                      onChanged: (RecordType? value) {
                        setState(() {
                          _selectedType = value!;
                          _selectedCategory = _getCategoriesByType(value).first;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 金额输入
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: '金额',
                  prefixText: '¥',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入金额';
                  }
                  double? amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return '请输入有效的金额';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // 分类选择
              Text(
                '分类',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _getCategoriesByType(_selectedType).map((category) {
                  return ChoiceChip(
                    label: Text(_getCategoryName(category)),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // 日期选择
              ListTile(
                title: Text(
                  '日期: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),

              const SizedBox(height: 16),

              // 备注输入
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: '备注',
                  border: const OutlineInputBorder(),
                  hintText: '请输入备注信息',
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              // 提交按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('保存'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: const TextStyle(fontSize: 16),
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