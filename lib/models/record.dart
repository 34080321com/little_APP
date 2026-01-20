enum RecordType { income, expense }

enum Category {
  // 支出分类
  food,        // 餐饮
  shopping,    // 购物
  transport,   // 交通
  entertainment, // 娱乐
  medical,     // 医疗
  education,   // 教育
  housing,     // 住房
  other,       // 其他
  
  // 收入分类
  salary,      // 工资
  bonus,       // 奖金
  investment,  // 投资
  partTime,    // 兼职
  gift,        // 礼金
  otherIncome  // 其他收入
}

class Record {
  int? id;
  double amount;
  RecordType type;
  Category category;
  String description;
  DateTime date;

  Record({
    this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type.index,
      'category': category.index,
      'description': description,
      'date': date.millisecondsSinceEpoch,
    };
  }

  static Record fromMap(Map<String, dynamic> map) {
    return Record(
      id: map['id'],
      amount: map['amount'],
      type: RecordType.values[map['type']],
      category: Category.values[map['category']],
      description: map['description'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
    );
  }
}