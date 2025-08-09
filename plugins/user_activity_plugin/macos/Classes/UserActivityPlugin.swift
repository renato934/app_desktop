import Cocoa
import FlutterMacOS

public class UserActivityPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "user_activity_plugin", binaryMessenger: registrar.messenger)
    let instance = UserActivityPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "isUserIdle" {
      let args = call.arguments as? [String: Any]
      let thresholdSeconds = args?["thresholdSeconds"] as? Int ?? 10

      let idleTime = getIdleTime()
      let isIdle = idleTime >= thresholdSeconds
      result(isIdle)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }

  private func getIdleTime() -> Int {
    var iterator: io_iterator_t = 0
    var entry: io_registry_entry_t = 0
    var idleTime: Int = 0

    let service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOHIDSystem"))
    if service != 0 {
      var dict: Unmanaged<CFMutableDictionary>?
      let kr = IORegistryEntryCreateCFProperties(service, &dict, kCFAllocatorDefault, 0)
      if kr == KERN_SUCCESS, let dict = dict?.takeRetainedValue() as NSDictionary? {
        let obj = dict["HIDIdleTime"] as? NSNumber
        if let obj = obj {
          idleTime = Int(truncating: obj) / 1000000000 // nanosegundos para segundos
        }
      }
      IOObjectRelease(service)
    }

    return idleTime
  }
}
