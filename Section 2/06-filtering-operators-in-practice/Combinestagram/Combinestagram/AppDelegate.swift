import UIKit
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    
    _ = numbers
      .subscribe(
        onNext: { el in
          print("element [\(el)]")
        },
        onCompleted: {
          print("-------------")
        })
    
    _ = numbers
      .subscribe(
        onNext: { el in
          print("element [\(el)]")
        },
        onCompleted: {
          print("-------------")
        })
    
    return true
  }
  
  lazy var numbers = Observable<Int>.create { observer in
    let start = self.getStartNumber()
    observer.onNext(start)
    observer.onNext(start+1)
    observer.onNext(start+2)
    observer.onCompleted()
    return Disposables.create()
  }
  
  var start = 0
  private func getStartNumber() -> Int {
    start += 1
    return start
  }
  
  
  
}
