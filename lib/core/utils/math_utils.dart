import 'dart:math';

class MathUtils {
  static double sigmoid(double x) {
    return 1.0 / (1.0 + exp(-x));
  }
}
