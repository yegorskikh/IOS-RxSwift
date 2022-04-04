import Foundation
import RxSwift
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

// MARK: - Prefixing and concatenating

example(of: "startWith") {
    
    let numbers = Observable.of(2, 3, 4)
    
    let observable = numbers.startWith(1)
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
    
    /*
     1
     2
     3
     4
     */
}

example(of: "Observable.concat") {
    
    let first = Observable.of(1, 2, 3)
    let second = Observable.of(4, 5, 6)
    
    let observable = Observable.concat([first, second])
    observable.subscribe(onNext: { value in
        print(value)
    })
    
    /*
     1
     2
     3
     4
     5
     6
     */
    
}

example(of: "concat") {
    let germanCities = Observable.of("Berlin", "Münich", "Frankfurt")
    let spanishCities = Observable.of("Madrid", "Barcelona", "Valencia")
    
    let observable = germanCities.concat(spanishCities)
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
    
    /*
     Berlin
     Münich
     Frankfurt
     Madrid
     Barcelona
     Valencia
     */
    
}

example(of: "concatMap") {
    
    let sequences = [
        "German cities": Observable.of("Berlin", "Münich", "Frankfurt"),
        "Spanish cities": Observable.of("Madrid", "Barcelona","Valencia")
    ]
    
    let observable = Observable.of("German cities", "Spanish cities")
        .concatMap { country in sequences[country] ?? .empty() }
    
    _ = observable.subscribe(onNext: { string in
        print(string)
    })
    
    /*
     Berlin
     Münich
     Frankfurt
     Madrid
     Barcelona
     Valencia
     */
    
}

// MARK: - Merging

example(of: "merge") {
    
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    let source = Observable.of(left.asObservable(), right.asObservable())
    
    let observable = source.merge()
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
    
    
    var leftValues = ["Berlin", "Munich", "Frankfurt"]
    var rightValues = ["Madrid", "Barcelona", "Valencia"]
    
    repeat {
        switch Bool.random() {
        case true where !leftValues.isEmpty:
            left.onNext("Left:  " + leftValues.removeFirst())
        case false where !rightValues.isEmpty:
            right.onNext("Right: " + rightValues.removeFirst())
        default:
            break
        }
    } while !leftValues.isEmpty || !rightValues.isEmpty
    
    
    left.onCompleted()
    right.onCompleted()
    
    /*
     Results will be different each time you run this code
     
     Left:  Berlin
     Right: Madrid
     Right: Barcelona
     Left:  Munich
     Right: Valencia
     Left:  Frankfurt
     */
}

// MARK: - Combining elements

example(of: "combineLatest") {
    
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    let observable = Observable.combineLatest(left, right) { lastLeft, lastRight in
        return "\(lastLeft) \(lastRight)"
    }
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
    
    print("> Sending a value to Left")
    left.onNext("Hello,")
    
    print("> Sending a value to Right")
    right.onNext("world")
    
    print("> Sending another value to Right")
    right.onNext("RxSwift")
    
    print("> Sending another value to Left")
    left.onNext("Have a good day,")
    
    left.onCompleted()
    right.onCompleted()
    
    /*
     > Sending a value to Left
     > Sending a value to Right
     Hello, world
     > Sending another value to Right
     Hello, RxSwift
     > Sending another value to Left
     Have a good day, RxSwift
     */
}

example(of: "combine user choice and value") {
    
    let choice: Observable<DateFormatter.Style> = Observable.of(.short, .long)
    let dates = Observable.of(Date())
    
    let observable = Observable.combineLatest(choice, dates) { format, when -> String in
        let formatter = DateFormatter()
        formatter.dateStyle = format
        return formatter.string(from: when)
    }
    
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
    
    /*
     4/3/22
     April 3, 2022
     */
    
}

example(of: "zip") {
    
    enum Weather {
        case cloudy
        case sunny
    }
    
    let left: Observable<Weather> = Observable.of(.sunny, .cloudy, .cloudy, .sunny)
    let right = Observable.of("Lisbon", "Copenhagen", "London", "Madrid", "Vienna")
    
    let observable = Observable.zip(left, right) { weather, city in
        return "It's \(weather) in \(city)"
    }
    
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
    
    /*
     It's sunny in Lisbon
     It's cloudy in Copenhagen
     It's cloudy in London
     It's sunny in Madrid
     */
    
}

// MARK: - Triggers

example(of: "withLatestFrom") {
    
    let button = PublishSubject<Void>()
    let textField = PublishSubject<String>()
    
    let observable = button.withLatestFrom(textField)
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
    
    textField.onNext("Par")
    textField.onNext("Pari")
    textField.onNext("Paris")
    button.onNext(())
    button.onNext(())
    
    /*
     Paris
     Paris
     */
    
}

example(of: "sample") {
    
    let button = PublishSubject<Void>()
    let textField = PublishSubject<String>()
    
    let observable = textField.sample(button)
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
    
    textField.onNext("Par")
    textField.onNext("Pari")
    textField.onNext("Paris")
    button.onNext(())
    button.onNext(())
    
    /*
     Paris
     */
    
}

// MARK: - Switches

example(of: "amb") {
    
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    let observable = left.amb(right)
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
    
    left.onNext("Lisbon")
    right.onNext("Copenhagen")
    left.onNext("London")
    left.onNext("Madrid")
    right.onNext("Vienna")
    
    left.onCompleted()
    right.onCompleted()
    
    /*
     Lisbon
     London
     Madrid
     */
}

example(of: "switchLatest") {
    
    let one = PublishSubject<String>()
    let two = PublishSubject<String>()
    let three = PublishSubject<String>()
    
    let source = PublishSubject<Observable<String>>()
    
    let observable = source.switchLatest()
    let disposable = observable.subscribe(onNext: { value in
        print(value)
    })
    
    source.onNext(one)
    one.onNext("Some text from sequence one")
    two.onNext("Some text from sequence two")
    source.onNext(two)
    two.onNext("More text from sequence two")
    one.onNext("and also from sequence one")
    
    source.onNext(three)
    two.onNext("Why don't you see me?")
    one.onNext("I'm alone, help me")
    three.onNext("Hey it's three. I win.")
    source.onNext(one)
    one.onNext("Nope. It's me, one!")
    
    disposable.dispose()
    
    /*
     Some text from sequence one
     More text from sequence two
     Hey it's three. I win.
     Nope. It's me, one!
     */
    
}

// MARK: - Combining elements within a sequence

example(of: "reduce") {
    
    let source = Observable.of(1, 3, 5, 7, 9)
    
    let observable = source.reduce(0, accumulator: +)
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
    
    /*
     25
     */
    
}

example(of: "scan") {
    
    let source = Observable.of(1, 3, 5, 7, 9)
    
    let observable = source.scan(0, accumulator: +)
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
    
    /*
     1
     4
     9
     16
     25
     */
    
}

// MARK: - Challenge

example(of: "The zip case") {
    
    let source = Observable.of(1, 3, 5, 7, 9)
    
    let scanObservable = source.scan(0, accumulator: +)
    let observable = Observable.zip(source, scanObservable)
    
    _ = observable.subscribe(onNext: { tuple in
        print("Source -", tuple.0, "Running total -", tuple.1)
    })
    
    /*
     Source - 1 Running total - 1
     Source - 3 Running total - 4
     Source - 5 Running total - 9
     Source - 7 Running total - 16
     Source - 9 Running total - 25
     */
    
}

example(of: "Superior scan") {
    
    let source = Observable.of(1, 3, 5, 7, 9)
    
    let scanObservable = source.scan((0, 0)) { acc, current in
        return (current, acc.1 + current)
    }
    
    _ = scanObservable.subscribe(onNext: { tuple in
        print("Source -", tuple.0, "Running total -", tuple.1)
    })
    
    /*
     Source - 1 Running total - 1
     Source - 3 Running total - 4
     Source - 5 Running total - 9
     Source - 7 Running total - 16
     Source - 9 Running total - 25
     */
    
}
