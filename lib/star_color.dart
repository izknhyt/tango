enum StarColor { red, yellow, blue }

extension StarColorExt on StarColor {
  String get label {
    switch (this) {
      case StarColor.red:
        return '赤';
      case StarColor.yellow:
        return '黄';
      case StarColor.blue:
        return '青';
    }
  }
}
