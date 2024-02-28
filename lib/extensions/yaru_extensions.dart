import 'package:yaru/yaru.dart';

extension YaruStringVariantExtensions on String {
  YaruVariant toYaruVariant() {
    switch (this) {
      case 'bark':
        return YaruVariant.bark;
      case 'blue':
        return YaruVariant.blue;
      case 'kubuntuBlue':
        return YaruVariant.kubuntuBlue;
      case 'lubuntuBlue':
        return YaruVariant.lubuntuBlue;
      case 'magenta':
        return YaruVariant.magenta;
      case 'olive':
        return YaruVariant.olive;
      case 'orange':
        return YaruVariant.orange;
      case 'prussianGreen':
        return YaruVariant.prussianGreen;
      case 'purple':
        return YaruVariant.purple;
      case 'red':
        return YaruVariant.red;
      case 'sage':
        return YaruVariant.sage;
      case 'ubuntuBudgieBlue':
        return YaruVariant.ubuntuBudgieBlue;
      case 'ubuntuButterflyPink':
        return YaruVariant.ubuntuButterflyPink;
      case 'ubuntuCinnamonBrown':
        return YaruVariant.ubuntuCinnamonBrown;
      case 'ubuntuMateGreen':
        return YaruVariant.ubuntuMateGreen;
      case 'ubuntuStudioBlue':
        return YaruVariant.ubuntuStudioBlue;
      case 'ubuntuUnityPurple':
        return YaruVariant.ubuntuUnityPurple;
      case 'viridian':
        return YaruVariant.viridian;
      case 'xubuntuBlue':
      default:
        return YaruVariant.xubuntuBlue;
    }
  }
}

extension YaruVariantExtensions on YaruVariant {
  String toYaruString() {
    switch (this) {
      case YaruVariant.bark:
        return 'bark';
      case YaruVariant.blue:
        return 'blue';
      case YaruVariant.kubuntuBlue:
        return 'kubuntuBlue';
      case YaruVariant.lubuntuBlue:
        return 'lubuntuBlue';
      case YaruVariant.magenta:
        return 'magenta';
      case YaruVariant.olive:
        return 'olive';
      case YaruVariant.orange:
        return 'orange';
      case YaruVariant.prussianGreen:
        return 'prussianGreen';
      case YaruVariant.purple:
        return 'purple';
      case YaruVariant.red:
        return 'red';
      case YaruVariant.sage:
        return 'sage';
      case YaruVariant.ubuntuBudgieBlue:
        return 'ubuntuBudgieBlue';
      case YaruVariant.ubuntuButterflyPink:
        return 'ubuntuButterflyPink';
      case YaruVariant.ubuntuCinnamonBrown:
        return 'ubuntuCinnamonBrown';
      case YaruVariant.ubuntuMateGreen:
        return 'ubuntuMateGreen';
      case YaruVariant.ubuntuStudioBlue:
        return 'ubuntuStudioBlue';
      case YaruVariant.ubuntuUnityPurple:
        return 'ubuntuUnityPurple';
      case YaruVariant.viridian:
        return 'viridian';
      case YaruVariant.xubuntuBlue:
      default:
        return 'xubuntuBlue';
    }
  }
}
