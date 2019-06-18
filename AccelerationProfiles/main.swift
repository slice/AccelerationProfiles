import Cocoa

// Launch the application manually to avoid having a MainMenu.xib file.
NSApplication.shared.delegate = AppDelegate()
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
