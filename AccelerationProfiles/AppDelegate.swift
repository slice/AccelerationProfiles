import Cocoa

typealias Profile = [String: Double]

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    var rules: [String: Profile] = [:]
    
    var defaultAccelProfile: Profile? {
        return rules["*"]
    }
    
    var applicationSupport: URL {
        return FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
    }
    
    var configDir: URL {
        return self.applicationSupport / "AccelerationProfiles"
    }
    
    var configPath: URL {
        return self.configDir / "config.json"
    }
    
    func loadConfiguration() throws {
        let fm = FileManager.default

        // Create the configuration file if it doesn't exist, with a skeleton default.
        NSLog("Configuration file is located at: \(self.configPath.path)")
        if !fm.fileExists(atPath: self.configPath.path) {
            NSLog("Configuration file does not exist, creating automatically.")
            try fm.createDirectory(at: self.configDir, withIntermediateDirectories: true)
            try "{}".write(to: self.configPath, atomically: false, encoding: .utf8)
        }
        
        // Attempt to read the contents of the file and parse it as JSON.
        let fileContents = fm.contents(atPath: configPath.path)!
        let json = try JSONSerialization.jsonObject(with: fileContents)
        
        self.rules.removeAll(keepingCapacity: true)

        // Schema:
        // object(
        //   key: app (string, bundle id/app name),
        //   value: object(
        //     key: device (string, "mouse" | "trackpad"),
        //     value: acceleration (double)
        //   )
        // )
        let dict = json as! [String: Any]
        for (identifier, profile) in dict {
            let accel = profile as! Profile
            self.rules[identifier] = accel
        }
        
        NSLog("Loaded rules: \(self.rules)")
    }
    
    func addImageToButton() {
        let button = self.item.button!
        button.image = NSImage(named: "MenuBar")
    }
    
    func beginWatching() {
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(self.onFocusChanged),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )
    }
    
    @objc func onFocusChanged(notification: NSNotification) {
        let app = notification.userInfo![NSWorkspace.applicationUserInfoKey]! as! NSRunningApplication
        let bundle = app.bundleIdentifier ?? "<none>"
        let name = app.localizedName ?? "<none>"
        NSLog("Now focused. [bundle: \(bundle)] [name: \(name)]")
        self.applyProfileFromIdentifiers(withIdentifiers: [bundle, name])
    }
    
    func applyDefaultProfile() {
        guard let defaultProfile = self.defaultAccelProfile else {
            NSLog("No default profile was found.")
            return
        }
        
        self.applyProfile(defaultProfile)
    }

    func profileAlreadyApplied(_ profile: Profile) -> Bool {
        return !profile.map({
            (deviceName, accel) in
            PointerDevice(rawValue: deviceName)!.speed == accel
        }).contains(false)
    }
    
    func applyProfile(_ profile: Profile) {
        guard !self.profileAlreadyApplied(profile) else {
            NSLog("Profile already applied, skipping.")
            return
        }

        for (deviceName, accel) in profile {
            var device = PointerDevice(rawValue: deviceName)!
            NSLog("Tweaking \(deviceName): \(device.speed) -> \(accel)")
            device.speed = accel
        }
    }
    
    func applyProfileFromIdentifiers(withIdentifiers identifiers: [String]) {
        NSLog("Attempting to apply profile for identifiers: \(identifiers)")

        guard let (_, profile) = self.rules.first(where: { (ident, _) in identifiers.contains(ident) }) else {
            NSLog("Applying default profile because no specific profile was found for these identifiers.")
            self.applyDefaultProfile()
            return
        }
        
        self.applyProfile(profile)
    }
    
    func constructMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(
            title: "AccelerationProfiles by slice",
            action: nil,
            keyEquivalent: ""
        ))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(
            title: "Open Configuration",
            action: #selector(self.openConfiguration),
            keyEquivalent: "o"
        ))
        menu.addItem(NSMenuItem(
            title: "Reload Configuration",
            action: #selector(self.reloadConfiguration),
            keyEquivalent: "r"
        ))
        menu.addItem(NSMenuItem(
            title: "Quit",
            action: #selector(self.quit),
            keyEquivalent: "q"
        ))
        self.item.menu = menu
    }
    
    @objc func quit() {
        NSRunningApplication.current.terminate()
    }

    @objc func openConfiguration() {
        NSLog("Opening configuration.")
        NSWorkspace.shared.openFile(self.configPath.path)
    }
    
    @objc func reloadConfiguration() {
        NSLog("Reloading configuration.")
        do {
            try self.loadConfiguration()
        } catch {
            NSLog("Error loading configuration: \(error)")

            let alert = NSAlert()
            alert.messageText = "Configuration Error"
            alert.informativeText = error.localizedDescription
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.reloadConfiguration()
        self.addImageToButton()
        self.constructMenu()
        self.beginWatching()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
}
