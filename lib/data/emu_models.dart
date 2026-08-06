/// 动车组车型数据库
///
/// 数据来源：路路通"高速列车车型信息"公开页面
/// (http://wap.lltskb.com/shfw/lcxh/index.html)
/// 定员为常见参考值，不同批次/配置可能有差异，以实际为准。
library;

/// 一个动车组车型
class EmuModel {
  /// 型号名，如 CR400BF
  final String name;

  /// 编组数（辆），如 8、16、17
  final String formation;

  /// 餐车位置，如 "5车"
  final String diningCar;

  /// 有无餐座描述
  final String dining;

  /// 参考定员（人），null 表示未知
  final int? capacity;

  /// 备注，如 高寒型、智能动车、软卧车
  final String note;

  const EmuModel({
    required this.name,
    required this.formation,
    required this.diningCar,
    required this.dining,
    this.capacity,
    this.note = '',
  });

  /// 展示名：如 "CR400BF（8辆编组）"
  String get displayName => note.isEmpty ? name : '$name（$note）';
}

/// 全部车型库
const List<EmuModel> kEmuModels = [
  // ========== 动力集中动车组 ==========
  EmuModel(name: 'CR200J', formation: '8', diningCar: '4车或5车', dining: '有(无)餐座', note: '动力集中', capacity: 720),

  // ========== CRH 系列 ==========
  EmuModel(name: 'CRH1A', formation: '8', diningCar: '4车或5车', dining: '有餐座', capacity: 611),
  EmuModel(name: 'CRH1A-A', formation: '8', diningCar: '5车', dining: '无餐座', capacity: 613),
  EmuModel(name: 'CRH1B', formation: '16', diningCar: '9车', dining: '有餐座', capacity: 1299),
  EmuModel(name: 'CRH1E', formation: '16', diningCar: '9车', dining: '有(旧型)无(统型)', note: '软卧车', capacity: 618),
  EmuModel(name: 'CRH2A', formation: '8', diningCar: '5车', dining: '有(旧型)无(统型)', capacity: 613),
  EmuModel(name: 'CRH2B', formation: '16', diningCar: '8车', dining: '有餐座', capacity: 1230),
  EmuModel(name: 'CRH2C', formation: '8', diningCar: '5车', dining: '有餐座', capacity: 610),
  EmuModel(name: 'CRH2E', formation: '16', diningCar: '8车或9车', dining: '有餐座', note: '软卧车', capacity: 630),
  EmuModel(name: 'CRH2G', formation: '8', diningCar: '5车', dining: '无餐座', note: '高寒车', capacity: 613),
  EmuModel(name: 'CRH3A', formation: '8', diningCar: '5车', dining: '无餐座', capacity: 613),
  EmuModel(name: 'CRH3C', formation: '8', diningCar: '4车', dining: '有餐座', capacity: 556),
  EmuModel(name: 'CRH5A', formation: '8', diningCar: '6车', dining: '无餐座', capacity: 622),
  EmuModel(name: 'CRH5G', formation: '8', diningCar: '5车', dining: '无餐座', note: '高寒车', capacity: 622),
  EmuModel(name: 'CRH6A', formation: '8', diningCar: '5车', dining: '无餐座', note: '市域', capacity: 557),
  EmuModel(name: 'CRH6F', formation: '8', diningCar: '5车', dining: '无餐座', note: '市域', capacity: 1322),

  // ========== CRH380 系列 ==========
  EmuModel(name: 'CRH380A', formation: '8', diningCar: '5车', dining: '有(旧型)无(统型)', capacity: 556),
  EmuModel(name: 'CRH380AL', formation: '16', diningCar: '9车', dining: '有餐座', capacity: 1061),
  EmuModel(name: 'CRH380AN', formation: '8', diningCar: '5车', dining: '无餐座', capacity: 556),
  EmuModel(name: 'CRH380B', formation: '8', diningCar: '5车', dining: '无餐座', capacity: 556),
  EmuModel(name: 'CRH380BG', formation: '8', diningCar: '5车', dining: '无餐座', note: '高寒型', capacity: 556),
  EmuModel(name: 'CRH380BL', formation: '16', diningCar: '9车', dining: '有餐座', capacity: 1053),
  EmuModel(name: 'CRH380CL', formation: '16', diningCar: '9车', dining: '有餐座', capacity: 1053),
  EmuModel(name: 'CRH380D', formation: '8', diningCar: '5车', dining: '有(旧型)无(新型)', capacity: 495),

  // ========== CR300 系列 ==========
  EmuModel(name: 'CR300AF', formation: '8', diningCar: '5车', dining: '无餐座', capacity: 613),
  EmuModel(name: 'CR300BF', formation: '8', diningCar: '5车', dining: '无餐座', capacity: 613),

  // ========== CR400 复兴号系列 ==========
  EmuModel(name: 'CR400AF', formation: '8', diningCar: '5车', dining: '无餐座', capacity: 576),
  EmuModel(name: 'CR400AF-A', formation: '16', diningCar: '9车', dining: '无餐座', capacity: 1193),
  EmuModel(name: 'CR400AF-AE', formation: '16', diningCar: '8车', dining: '无餐座', note: '软卧车', capacity: 630),
  EmuModel(name: 'CR400AF-B', formation: '17', diningCar: '9车', dining: '无餐座', capacity: 1283),
  EmuModel(name: 'CR400AF-BS', formation: '17', diningCar: '9车', dining: '无餐座', capacity: 1283),
  EmuModel(name: 'CR400AF-C', formation: '8', diningCar: '5车', dining: '无餐座', capacity: 576),
  EmuModel(name: 'CR400AF-G', formation: '8', diningCar: '5车', dining: '无餐座', note: '高寒型', capacity: 576),
  EmuModel(name: 'CR400AF-S', formation: '8', diningCar: '5车', dining: '无餐座', capacity: 576),
  EmuModel(name: 'CR400AF-Z', formation: '8', diningCar: '5车', dining: '无餐座', note: '智能动车', capacity: 576),
  EmuModel(name: 'CR400BF', formation: '8', diningCar: '5车', dining: '无餐座', capacity: 576),
  EmuModel(name: 'CR400BF-A', formation: '16', diningCar: '9车', dining: '无餐座', capacity: 1193),
  EmuModel(name: 'CR400BF-AS', formation: '16', diningCar: '9车', dining: '无餐座', capacity: 1193),
  EmuModel(name: 'CR400BF-AZ', formation: '16', diningCar: '9车', dining: '无餐座', note: '智能动车', capacity: 1193),
  EmuModel(name: 'CR400BF-B', formation: '17', diningCar: '9车', dining: '无餐座', capacity: 1283),
  EmuModel(name: 'CR400BF-BS', formation: '17', diningCar: '9车', dining: '无餐座', note: '智能动车', capacity: 1283),
  EmuModel(name: 'CR400BF-BZ', formation: '17', diningCar: '9车', dining: '无餐座', note: '智能动车', capacity: 1283),
  EmuModel(name: 'CR400BF-C', formation: '8', diningCar: '5车', dining: '无餐座', note: '复兴号动车组', capacity: 576),
  EmuModel(name: 'CR400BF-G', formation: '8', diningCar: '5车', dining: '无餐座', note: '高寒型', capacity: 576),
  EmuModel(name: 'CR400BF-GS', formation: '8', diningCar: '5车', dining: '无餐座', capacity: 576),
  EmuModel(name: 'CR400BF-GZ', formation: '8', diningCar: '5车', dining: '无餐座', note: '智能动车', capacity: 576),
  EmuModel(name: 'CR400BF-S', formation: '8', diningCar: '5车', dining: '无餐座', capacity: 576),
  EmuModel(name: 'CR400BF-Z', formation: '8', diningCar: '5车', dining: '无餐座', note: '智能动车', capacity: 576),
];

/// 根据型号名查找车型（不区分大小写、忽略空格）
EmuModel? findEmuModel(String name) {
  final key = name.toUpperCase().replaceAll(' ', '');
  for (final m in kEmuModels) {
    if (m.name.toUpperCase() == key) return m;
  }
  return null;
}
