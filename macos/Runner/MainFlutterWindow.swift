import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    // 창을 화면 중앙에 배치
    self.center()
    
    // 창 크기 설정
    let windowSize = NSSize(width: 800, height: 600)
    self.setContentSize(windowSize)
    
    // 최소 크기 설정
    self.minSize = NSSize(width: 400, height: 300)
    
    // 창 제목 설정
    self.title = "스터디메이트"

    super.awakeFromNib()
  }
}
