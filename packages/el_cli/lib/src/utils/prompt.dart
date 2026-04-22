import 'dart:io';

import 'package:dart_console/dart_console.dart';
import 'package:equatable/equatable.dart';
import 'package:io/ansi.dart';
import 'package:meta/meta.dart';

typedef PromptValidate<T> = String? Function(T? value);

class Prompt<T> extends Console {
  Prompt(this.message, {this.defaultValue, this.required = false, this.validate});

  /// 交互标题内容
  final String message;

  /// 默认值
  final T? defaultValue;

  /// 是否必填
  final bool required;

  /// 自定义验证，返回值如果不为 null，则会显示错误消息
  final PromptValidate<T>? validate;

  /// 映射用户输入的值，注意：为了正确应用 [defaultValue]，对某些行为应明确将其置空，
  /// 例如：'' -> null
  @protected
  T? value;

  String? _errorMessage;

  /// 错误消息，如果不为 null，会在终端最下方显示此消息
  @protected
  String? get errorMessage => _errorMessage;

  /// 设置错误消息，此方法会自动更新终端错误消息内容
  @protected
  set errorMessage(String? v) {
    if (v != null) {
      writeLineAndHold(red.wrap(v)); // 在下一行写入错误消息，光标位置保持不变
    } else {
      if (_errorMessage != null) removeNextLineAndHold(); // 清除错误消息
    }
    _errorMessage = v;
  }

  /// 构建对话结果
  T build() {
    ask();
    startListen();
    if (handlerValidate()) {
      confirm();
      return value ?? defaultValue!;
    } else {
      print('Prompt build() Error, You must set a default value');
      exit(1);
    }
  }

  /// 1.开始询问，此方法一般在 [startListen] 前执行，告知用户需要做什么？
  @protected
  @mustCallSuper
  void ask() {
    stdout.write(blue.wrap('? '));
    stdout.write('$message ');
  }

  /// 2.开启键盘监听，此方法会创建一个同步阻塞循环，然后监听键盘输入，将按键操作映射到具体的实现方法，
  /// 例如：[handlerChar]、[handlerEnter]、[handlerExit]、[handlerBackspace]
  @protected
  void startListen() {
    while (true) {
      final key = readKey();

      if (key.isControl) {
        if (key.controlChar == ControlCharacter.enter) {
          if (handlerValidate()) {
            handlerEnter();
            break;
          }
        } else if (key.controlChar == ControlCharacter.backspace) {
          handlerBackspace();
          handlerValidate();
        } else if (key.controlChar == ControlCharacter.arrowUp ||
            key.controlChar == ControlCharacter.arrowDown ||
            key.controlChar == ControlCharacter.arrowLeft ||
            key.controlChar == ControlCharacter.arrowRight) {
          handlerDirection(key.controlChar);
        } else if (key.controlChar == ControlCharacter.ctrlC) {
          handlerExit();
        }
      } else {
        if (key.char == ' ') handlerSpace();
        handlerChar(key.char);
        handlerValidate();
      }
    }
  }

  /// 通过验证时，更新 [ask] 的状态
  @protected
  @mustCallSuper
  void confirm() {
    cursorPosition = Coordinate(cursorPosition!.row, 0);
    stdout.write(green.wrap('✔ '));
    stdout.write('$message ');
  }

  /// 处理 Ctrl + C 退出事件
  @protected
  @mustCallSuper
  void handlerExit() {
    exit(1);
  }

  /// 处理回车键
  @protected
  void handlerEnter() {}

  /// 处理删除键
  @protected
  void handlerBackspace() {}

  /// 处理空格键
  @protected
  void handlerSpace() {}

  /// 处理方向键
  @protected
  void handlerDirection(ControlCharacter controlChar) {}

  /// 处理符号键
  @protected
  void handlerChar(String char) {}

  /// 执行输入内容验证，如果验证通过，则返回 true
  @protected
  bool handlerValidate() {
    if (required) {
      if (value == null && defaultValue == null) {
        errorMessage = 'required';
        return false;
      }
    }
    if (validate != null) {
      errorMessage = validate!(value ?? defaultValue);
      return errorMessage == null;
    }
    return true;
  }

  /// 将光标保持在当前位置，在下一行写入数据
  void writeLineAndHold([Object? object = "", bool clean = true]) {
    final oldCol = cursorPosition!.col;
    stdout.writeln();
    stdout.write(object);
    if (clean) eraseCursorToEnd();
    cursorPosition = Coordinate(cursorPosition!.row - 1, oldCol);
  }

  /// 移除相对光标位置的一行数据：
  /// * 当 row == 0 时，会删除当前行；
  /// * 当 row < 0 时，会删除上面行；
  /// * 当 row > 0 时，会删除下面行。
  void removeLine([int row = 0]) {
    cursorPosition = Coordinate(cursorPosition!.row + row, 0);
    eraseLine();
  }

  /// 将光标保持在当前位置，删除下面所有内容
  void removeNextLineAndHold() {
    final currentRow = cursorPosition!.row;
    final currentCol = cursorPosition!.col;

    for (int row = currentRow + 1; row < windowHeight; row++) {
      cursorPosition = Coordinate(row, 0);
      eraseLine();
    }

    cursorPosition = Coordinate(currentRow, currentCol);
  }
}

/// 键盘输入默认值的混入实现，当用户没有输入时，会在终端渲染设置的默认值
mixin InputDefaultValuePromptMixin<T> on Prompt<T> {
  /// 访问 [value] 的字符串版本
  String getValue(T? v);

  /// 将用户输入的字符串设置到 [value] 中
  void setValue(String v);

  @override
  void ask() {
    super.ask();
    writeDefaultValue();
  }

  @override
  void confirm() {
    super.confirm();
    stdout.writeln(cyan.wrap(getValue(value ?? defaultValue)));
  }

  @override
  void handlerBackspace() {
    if (getValue(value) != '') {
      removeChar();
      if (getValue(value) == '') writeDefaultValue();
    } else {
      writeDefaultValue();
    }
  }

  @override
  void handlerChar(String char) {
    // 当前值若为空，并且存在默认值时，首次键入需要清除终端上的默认值
    if (value == null && defaultValue != null) eraseCursorToEnd();
    setValue(getValue(value) + char);
    stdout.write(char);
  }

  /// 向终端写入默认值，显示默认值不影响光标输入位置
  void writeDefaultValue() {
    if (defaultValue != null) {
      final oldCol = cursorPosition!.col;
      stdout.write(lightGray.wrap(getValue(defaultValue)));
      cursorPosition = Coordinate(cursorPosition!.row, oldCol);
    }
  }

  /// 删除一个字符
  void removeChar() {
    final v = getValue(value);
    if (v.isEmpty) return;

    final row = cursorPosition!.row;
    setValue(v.substring(0, v.length - 1));
    cursorPosition = Coordinate(row, cursorPosition!.col - 1);
    eraseCursorToEnd();
  }
}

class Input extends Prompt<String> with InputDefaultValuePromptMixin<String> {
  /// 构建输入字符对话框，返回一个 String 字符串
  Input(super.message, {super.defaultValue, super.validate}) : super(required: true);

  @override
  String getValue(String? v) => v ?? '';

  @override
  void setValue(String v) {
    if (v.trim() == '') {
      value = null;
    } else {
      value = v;
    }
  }
}

class Confirm extends Prompt<bool> with InputDefaultValuePromptMixin<bool> {
  /// 构建确认对话框，返回一个 bool 值
  Confirm(super.message, {super.defaultValue}) : assert(defaultValue != null);

  @override
  bool get defaultValue => super.defaultValue ?? false;

  @override
  String getValue(bool? v) {
    if (v == null) return '';
    return v ? 'y' : 'n';
  }

  @override
  void setValue(String v) {
    if (v == 'y') {
      value = true;
    } else if (v == 'n') {
      value = false;
    } else {
      value = null;
    }
  }

  @override
  void handlerChar(String char) {
    if (value == null && (char == 'y' || char == 'n')) {
      eraseCursorToEnd();
      setValue(char);
      stdout.write(char);
    }
  }
}

class Password extends Prompt<String> {
  /// 构建密码输入对话框，它会将用户输入的字符转成 *
  Password(super.message, {super.validate}) : super(required: true);

  @override
  void confirm() {
    super.confirm();
    stdout.writeln(cyan.wrap('*' * value!.length));
  }

  @override
  void handlerBackspace() {
    if (value == null) return;

    if (value!.length == 1) {
      value = null;
    } else {
      value = value!.substring(0, value!.length - 1);
    }

    final row = cursorPosition!.row;
    cursorPosition = Coordinate(row, cursorPosition!.col - 1);
    eraseCursorToEnd();
  }

  @override
  void handlerChar(String char) {
    value = (value ?? '') + char;
    stdout.write('*');
  }
}

class Choice extends Equatable {
  const Choice({required this.name, this.desc});

  /// 选择项名字
  final String name;

  /// 描述信息
  final String? desc;

  @override
  List<Object?> get props => [name];
}

/// 支持键盘导航选择列表
abstract class ListPrompt<T> extends Prompt<T> {
  ListPrompt(super.message, {required this.children, super.defaultValue, super.required, super.validate}) {
    if (children.isEmpty) {
      print('Select children not null');
      exit(1);
    }
  }

  final List<Choice> children;

  int _index = 0;

  /// 当前导航索引
  int get index => _index;

  set index(int v) {
    _index = v;
    if (index < 0) {
      _index = children.length - 1;
    }
    if (index >= children.length) {
      _index = 0;
    }
  }

  /// 帮助描述
  String get help;

  /// 记录绘制的全部行
  int line = 0;

  /// 清空当前绘制的所有内容，包括：标题 + 列表项 + 空格 + 帮助
  void cleanListLine() {
    removeLine();
    for (int i = 0; i < line - 1; i++) {
      removeLine(-1);
    }
  }

  /// 构建未选中列表项样式
  String buildListItem(Choice v) => '  ${v.name}';

  /// 构建选中列表项样式
  String buildSelectedListItem(Choice v) => blue.wrap('> ${v.name}') ?? '> ${v.name}';

  /// 重写 ask，除了询问标题外还会渲染整个列表项，每次调用 ask 都相当于刷新界面
  @override
  void ask() {
    // 每次调用都先清空旧数据，然后重新绘制
    if (line > 0) cleanListLine();

    line = children.length + 3; // 标题 + 列表项 + 空格 + 帮助
    super.ask();

    stdout.writeln();
    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      final result = i == index ? buildSelectedListItem(child) : buildListItem(child);
      stdout.writeln(result);
    }
    stdout.writeln();

    final desc = children[index].desc;
    if (desc != null) {
      stdout.writeln(cyan.wrap(desc));
      line++;
    }
    stdout.write(help);
  }

  @override
  void handlerExit() {
    showCursor();
    super.handlerExit();
  }

  @override
  void handlerDirection(ControlCharacter controlChar) {
    switch (controlChar) {
      case ControlCharacter.arrowUp:
        index--;
      case ControlCharacter.arrowDown:
        index++;
      case ControlCharacter.arrowLeft:
        index = 0;
      case ControlCharacter.arrowRight:
        index = children.length - 1;
      default:
    }
    ask(); // 刷新渲染
  }

  @override
  T build() {
    hideCursor();
    final result = super.build();
    showCursor();
    return result;
  }
}

class Select extends ListPrompt<Choice> {
  /// 构建选择器对话框，通过上下键导航选择一个选项
  Select(super.message, {required super.children}) {
    value = children[index];
  }

  @override
  Choice get value => super.value!;

  @override
  String get help => '↑↓ navigate • ⏎ submit';

  @override
  set index(int v) {
    super.index = v;
    value = children[index];
  }

  @override
  void confirm() {
    cleanListLine();
    super.confirm();
    stdout.writeln(cyan.wrap(value.name));
  }
}

class Checkbox extends ListPrompt<List<Choice>> {
  /// 构建多选对话框，通过上下键导航 + Space 选择一个选项
  Checkbox(super.message, {required super.children, super.validate, super.defaultValue}) {
    value = defaultValue ?? [];
  }

  @override
  List<Choice> get value => super.value!;

  @override
  String get help => '↑↓ navigate • space select • ⏎ submit';

  @override
  String buildListItem(Choice v) {
    final has = value.contains(v);
    return '  (${has ? '_' : ' '}) ${v.name}';
  }

  @override
  String buildSelectedListItem(Choice v) {
    final has = value.contains(v);
    final result = '> (${has ? '_' : ' '}) ${v.name}';
    return blue.wrap(result) ?? result;
  }

  @override
  void handlerSpace() {
    final v = children[index];
    if (value.contains(v)) {
      value.remove(v);
    } else {
      value.add(v);
    }

    ask();
  }

  @override
  void confirm() {
    cleanListLine();
    super.confirm();
    stdout.writeln(cyan.wrap(value.map((e) => e.name).join(',')));
  }
}
