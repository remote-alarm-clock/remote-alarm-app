import 'device_class.dart';

/// Enum which carries the supported device types
enum DeviceType {
  unknown,
  clock,
  lack;

  @override
  String toString() {
    return name.toString();
  }

  /// Try to create DeviceType from String.
  static DeviceType fromString(String devType) {
    return DeviceType.values.firstWhere(
        (element) => element.toString() == devType,
        orElse: () => unknown);
  }
}

// Cool type of extensions on values (instead of creating methods on the enum).
extension DeviceTypeClass on DeviceType {
  DeviceClass get deviceClass {
    switch (this) {
      case DeviceType.unknown:
      default:
        return const NotImplementedDevice();
    }
  }
}
