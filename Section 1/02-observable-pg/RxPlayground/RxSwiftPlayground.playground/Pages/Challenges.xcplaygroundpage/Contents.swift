import Foundation
import RxSwift

// 1

example(of: "never") {
    
    let disposeBag =  DisposeBag()
    let observable = Observable<Any>.never()
    
        observable
            .do(onSubscribed: {
                print("do")
            }).subscribe(
                onNext: { element in
                    print(element)
                },
                onCompleted: {
                    print("Completed")
                },
                onDisposed: {
                    print("Disposed")
                })
                .disposed(by: disposeBag)
                
            /*
             do
             Disposed
             */
    
}

// 2

example(of: "never 2") {
    
  let observable = Observable<Any>.never()
  let disposeBag = DisposeBag()
    
    observable
        .debug("debug")
        .subscribe(
          onNext: { element in
              print(element)
          },
          onCompleted: {
            print("Completed")
          },
          onDisposed: {
            print("Disposed")
          }
        )
        .disposed(by: disposeBag)
    
    /*
     2022-03-14 21:56:57.414: debug -> subscribed
     2022-03-14 21:56:57.429: debug -> isDisposed
     Disposed
     */
}
