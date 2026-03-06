import Flutter
import UIKit

public class SsPreventerPlugin: NSObject, FlutterPlugin, FlutterSceneLifeCycleDelegate, FlutterStreamHandler {
    private let protectionManager = SsProtectionManager()

    private var isPreventEnabled = false
    private var isDetectionEnabled = false
    private var screenshotObserver: NSObjectProtocol?
    private var eventSink: FlutterEventSink?
    private weak var registrar: FlutterPluginRegistrar?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(
            name: "com.dl10yr.ss_preventer",
            binaryMessenger: registrar.messenger()
        )
        let eventChannel = FlutterEventChannel(
            name: "com.dl10yr.ss_preventer/events",
            binaryMessenger: registrar.messenger()
        )

        let instance = SsPreventerPlugin(registrar: registrar)
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)

        registrar.addApplicationDelegate(instance)
        registrar.addSceneDelegate(instance)
    }

    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        super.init()
    }

    deinit {
        removeScreenshotObserver()
        protectionManager.disableProtection()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if Thread.isMainThread {
            handleMethod(call, result: result)
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.handleMethod(call, result: result)
        }
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        if isDetectionEnabled {
            addScreenshotObserver()
        }
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        removeScreenshotObserver()
        return nil
    }

    // MARK: - Application / Scene lifecycle callbacks

    public func applicationDidBecomeActive(_ application: UIApplication) {
        applyProtectionIfNeeded()
    }

    public func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions?
    ) -> Bool {
        applyProtectionIfNeeded(scene: scene)
        return false
    }

    public func sceneWillEnterForeground(_ scene: UIScene) {
        applyProtectionIfNeeded(scene: scene)
    }

    public func sceneDidBecomeActive(_ scene: UIScene) {
        applyProtectionIfNeeded(scene: scene)
    }
}

private extension SsPreventerPlugin {
    func handleMethod(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "preventOn":
            isPreventEnabled = true
            applyProtectionIfNeeded()
            result(nil)
        case "preventOff":
            isPreventEnabled = false
            protectionManager.disableProtection()
            result(nil)
        case "setDetectionEnabled":
            let enabled = call.arguments as? Bool ?? false
            isDetectionEnabled = enabled
            if enabled {
                addScreenshotObserver()
            } else {
                removeScreenshotObserver()
            }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func addScreenshotObserver() {
        guard screenshotObserver == nil else { return }

        screenshotObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.eventSink?([
                "type": "screenshot",
                "detectedAt": Int(Date().timeIntervalSince1970 * 1000),
            ])
        }
    }

    func removeScreenshotObserver() {
        guard let screenshotObserver = screenshotObserver else { return }
        NotificationCenter.default.removeObserver(screenshotObserver)
        self.screenshotObserver = nil
    }

    func applyProtectionIfNeeded(scene: UIScene? = nil) {
        guard isPreventEnabled else { return }
        if let sceneWindow = window(from: scene) {
            protectionManager.enableProtection(for: sceneWindow)
            return
        }
        protectionManager.enableProtection(for: keyWindow())
    }

    func window(from scene: UIScene?) -> UIWindow? {
        guard let windowScene = scene as? UIWindowScene else { return nil }
        if let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return keyWindow
        }
        return windowScene.windows.first(where: { $0.windowLevel == .normal })
    }

    func keyWindow() -> UIWindow? {
        if let registrarWindow = registrar?.viewController?.view.window {
            return registrarWindow
        }

        if #available(iOS 13.0, *) {
            let scenes = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .filter {
                    $0.activationState == .foregroundActive ||
                    $0.activationState == .foregroundInactive
                }

            for scene in scenes {
                if let keyWindow = scene.windows.first(where: { $0.isKeyWindow }) {
                    return keyWindow
                }
                if let normalWindow = scene.windows.first(where: { $0.windowLevel == .normal }) {
                    return normalWindow
                }
            }
        }

        return UIApplication.shared.delegate?.window ?? nil
    }
}
