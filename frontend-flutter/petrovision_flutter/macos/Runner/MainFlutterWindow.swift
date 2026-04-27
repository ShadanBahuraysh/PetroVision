import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // Set minimum window size so the admin dashboard never clips
    self.minSize = NSSize(width: 1100, height: 700)

    // Set a sensible default size on launch
    if windowFrame.width < 1100 || windowFrame.height < 700 {
      let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
      let newWidth: CGFloat = min(1280, screen.width)
      let newHeight: CGFloat = min(800, screen.height)
      let newX = screen.origin.x + (screen.width - newWidth) / 2
      let newY = screen.origin.y + (screen.height - newHeight) / 2
      self.setFrame(NSRect(x: newX, y: newY, width: newWidth, height: newHeight), display: true)
    }

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}