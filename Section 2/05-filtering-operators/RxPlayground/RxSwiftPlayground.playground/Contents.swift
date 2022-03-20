import Foundation
import RxSwift

// MARK: - Ignoring operators

example(of: "ignoreElements") {
    
    let strikes = PublishSubject<String>()
    let disposeBag = DisposeBag()
    
    strikes
        .ignoreElements()
        .subscribe {
            print($0, "You're out!")
        }
        .disposed(by: disposeBag)
    
    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onNext("X")
    
    strikes.onCompleted()
    
    /*
     You're out!
     */
}

example(of: "elementAt") {
    
    let strikes = PublishSubject<String>()
    let disposeBag = DisposeBag()
    
    strikes
        .elementAt(2)
        .subscribe(onNext: {
            print($0, "You're out!")
        })
        .disposed(by: disposeBag)
    
    strikes.onNext("1")
    strikes.onNext("2")
    strikes.onNext("3")
    
    /*
     3
     You're out!
     */
}

example(of: "filter") {
    let disposeBag = DisposeBag()
    
    Observable.of(1, 2, 3, 4, 5, 6)
        .filter { $0.isMultiple(of: 2) }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    /*
     2
     4
     6
     */
}

// MARK: - Skipping operators

example(of: "skip") {
    let disposeBag = DisposeBag()
    
    Observable.of("A", "B", "C", "D", "E", "F")
        .skip(3)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    /*
     D
     E
     F
     */
}

example(of: "skipWhile") {
    let disposeBag = DisposeBag()
    
    Observable.of(2, 2, 3, 4, 4)
        .skipWhile { $0.isMultiple(of: 2) }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    /*
     3
     4
     4
     */
}

example(of: "skipUntil") {
    let disposeBag = DisposeBag()
    
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()
    
    subject
        .skipUntil(trigger)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    subject.onNext("A")
    subject.onNext("B")
    trigger.onNext("X")
    subject.onNext("C")
    
    /*
     C
     */
}

// MARK: - Taking operators

example(of: "take") {
    let disposeBag = DisposeBag()
    
    Observable.of(1, 2, 3, 4, 5, 6)
        .take(3)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    /*
     1
     2
     3
     */
}

example(of: "takeWhile") {
    let disposeBag = DisposeBag()
    
    Observable.of(2, 2, 4, 4, 6, 6)
        .enumerated()
        .takeWhile { index, integer in
            integer.isMultiple(of: 2) && index < 3
        }
        .map(\.element)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    /*
     2
     2
     4
     */
}

example(of: "takeUntil") {
    let disposeBag = DisposeBag()
    
    Observable.of(1, 2, 3, 4, 5)
        .takeUntil(.inclusive) { $0.isMultiple(of: 4) }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    /*
     1
     2
     3
     4
     */
}

example(of: "takeUntil trigger") {
    let disposeBag = DisposeBag()
    
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()
    
    subject
        .takeUntil(trigger)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    subject.onNext("1")
    subject.onNext("2")
    trigger.onNext("X")
    subject.onNext("3")
    
    /*
     1
     2
     */
}

// MARK: - Distinct operators

example(of: "distinctUntilChanged") {
    
    let disposeBag = DisposeBag()
    
    Observable.of("A", "A", "B", "B", "A")
        .distinctUntilChanged()
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    /*
     A
     B
     A
     */
    
}

example(of: "distinctUntilChanged(_:)") {
    let disposeBag = DisposeBag()
    
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    
    Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
        .distinctUntilChanged { a, b in
            guard
                let aWords = formatter
                    .string(from: a)?
                    .components(separatedBy: " "),
                let bWords = formatter
                    .string(from: b)?
                    .components(separatedBy: " ")
            else {
                return false
            }
            var containsMatch = false
            
            for aWord in aWords where bWords.contains(aWord) {
                containsMatch = true
                break
            }
            return containsMatch
        }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

// MARK: - Challenge

example(of: "Challenge") {
    let disposeBag = DisposeBag()
    
    let contacts = [
        "603-555-1212": "Florent",
        "212-555-1212": "Shai",
        "408-555-1212": "Marin",
        "617-555-1212": "Scott"
    ]
    
    func phoneNumber(from inputs: [Int]) -> String {
        var phone = inputs.map(String.init).joined()
        
        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 3)
        )
        
        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 7)
        )
        
        return phone
    }
    
    let input = PublishSubject<Int>()
    
    // Add your code here
    input
        .filter { $0 < 10 }
        .skipWhile { $0 == 0 }
        .take(10)
        .toArray()
        .subscribe(onSuccess: { arr in
            let phone = phoneNumber(from: arr)
            
            if let contact = contacts[phone] {
                print("Dialing \(contact) (\(phone))...")
            } else {
                print("Contact not found - \(phone)")
            }
        })
        .disposed(by: disposeBag)
    
    input.onNext(0)
    input.onNext(603)
    input.onNext(2)
    input.onNext(1)
    input.onNext(2)
    
    "5551212".forEach {
        if let number = (Int("\($0)")) {
            input.onNext(number)
        }
    }
    
    input.onNext(9)
}
