import Foundation
import RxSwift
import RxRelay


example(of: "PublishSubject") {
    let subject = PublishSubject<String>()
    subject.on(.next("Is anyone listening?"))
    
    let subscriptionOne = subject
        .subscribe(onNext: {
            print($0)
        })
    
    subject.on(.next("1"))
    subject.onNext("2")
    
    let subscriptionTwo = subject
        .subscribe { event in
            print("2)", event.element ?? event)
        }
    
    subject.onNext("3")
    
    subscriptionOne.dispose()
    subject.onNext("4")
    
    subject.onCompleted()
    subject.onNext("5")
    
    subscriptionTwo.dispose()
    
    let disposeBag = DisposeBag()
    
    subject
        .subscribe {
            print("3)", $0.element ?? $0)
        }
        .disposed(by: disposeBag)
    
    subject.onNext("?")
}




enum MyError: Error {
    case anError
}

func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
    print(label, (event.element ?? event.error) ?? event)
}



example(of: "BehaviorSubject") {
    let subject = BehaviorSubject(value: "Initial value")
    let disposeBag = DisposeBag()
    
    subject
        .subscribe {
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    
    subject.onNext("X")
    
    subject.onError(MyError.anError)
    
    subject
        .subscribe {
            print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
}



example(of: "ReplaySubject") {
    
    let subject = ReplaySubject<String>.create(bufferSize: 2)
    let disposeBag = DisposeBag()
    
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    
    subject
        .subscribe {
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    
    subject
        .subscribe {
            print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
    
    subject.onNext("4")
    
    subject.dispose()
    
    subject
        .subscribe {
            print(label: "3)", event: $0)
        }
        .disposed(by: disposeBag)
    
    subject.onError(MyError.anError)
    
    
}

example(of: "PublishRelay") {
    
    let relay = PublishRelay<String>()
    let disposeBag = DisposeBag()
    
    relay
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    relay.accept("1")
    
}

example(of: "BehaviorRelay") {
    
    let relay = BehaviorRelay(value: "Initial value")
    let disposeBag = DisposeBag()
    
    relay.accept("New initial value")
    
    relay
        .subscribe {
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    
    
    relay.accept("1")
    
    relay
        .subscribe {
            print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
    
    relay.accept("2")
    
    print(relay.value) // 2
    
}

// MARK: - Challenge

example(of: "PublishSubject") {
    
    let disposeBag = DisposeBag()
    
    let dealtHand = PublishSubject<[(String, Int)]>()
    
    func deal(_ cardCount: UInt) {
        var deck = cards
        var cardsRemaining = deck.count
        var hand = [(String, Int)]()
        
        for _ in 0..<cardCount {
            let randomIndex = Int.random(in: 0..<cardsRemaining)
            hand.append(deck[randomIndex])
            deck.remove(at: randomIndex)
            cardsRemaining -= 1
        }
        
        // Add code to update dealtHand here
        let handPoints = points(for: hand)
        if handPoints > 21 {
            dealtHand.onError(HandError.busted(points: handPoints))
        } else {
            dealtHand.onNext(hand)
        }
    }
    
    // Add subscription to handSubject here
    dealtHand
        .subscribe(
            onNext: {
                print(cardString(for: $0), "for", points(for: $0), "points")
            },
            onError: {
                print(String(describing: $0).capitalized)
            })
        .disposed(by: disposeBag)
    
    deal(3)
}



example(of: "BehaviorRelay") {
    enum UserSession {
        case loggedIn, loggedOut
    }
    
    enum LoginError: Error {
        case invalidCredentials
    }
    
    let disposeBag = DisposeBag()
    
    // Create userSession BehaviorRelay of type UserSession with initial value of .loggedOut
    let userSession = BehaviorRelay(value: UserSession.loggedOut)
    
    // Subscribe to receive next events from userSession
    userSession
        .subscribe(onNext: {
            print("userSession changed:", $0)
        })
        .disposed(by: disposeBag)
    
    func logInWith(username: String, password: String, completion: (Error?) -> Void) {
        guard username == "johnny@appleseed.com",
              password == "appleseed" else {
                  completion(LoginError.invalidCredentials)
                  return
              }
        
        // Update userSession
        userSession.accept(.loggedIn)
    }
    
    func logOut() {
        // Update userSession
        userSession.accept(.loggedOut)
    }
    
    func performActionRequiringLoggedInUser(_ action: () -> Void) {
        // Ensure that userSession is loggedIn and then execute action()
        guard userSession.value == .loggedIn else {
            print("You can't do that!")
            return
        }
        
        action()
    }
    
    for i in 1...2 {
        let password = i % 2 == 0 ? "appleseed" : "password"
        
        logInWith(username: "johnny@appleseed.com", password: password) { error in
            guard error == nil else {
                print(error!)
                return
            }
            
            print("User logged in.")
        }
        
        performActionRequiringLoggedInUser {
            print("Successfully did something only a logged in user can do.")
        }
    }
}
