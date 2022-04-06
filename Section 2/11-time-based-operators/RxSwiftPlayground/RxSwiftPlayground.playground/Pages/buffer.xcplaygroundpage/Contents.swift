import UIKit
import RxSwift
import RxCocoa

// Start coding here


// Support code 
class TimelineView<E>: TimelineViewBase, ObserverType where E: CustomStringConvertible {
    
    static func make() -> TimelineView<E> {
        let view = TimelineView(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
        view.setup()
        return view
    }
    
    public func on(_ event: Event<E>) {
        switch event {
        case .next(let value):
            add(.next(String(describing: value)))
        case .completed:
            add(.completed())
        case .error(_):
            add(.error())
        }
    }
    
}

