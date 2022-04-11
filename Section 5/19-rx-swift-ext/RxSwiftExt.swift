
// distinct

_ = Observable.of("a", "b", "a", "c", "b", "a", "d")
    .distinct()
    .toArray()
    .subscribe(onNext: { print($0) })


/*
 ["a","b","c","d"]
 */



// mapAt

struct Person {
    let name: String
}

Observable
    .of(Person(name: "Bart"),
        Person(name: "Lisa"),
        Person(name: "Maggie"))
    .mapAt(\.name)

/*
 The mapAt(_:) operator takes advantage of keypaths to let you extract data from a larger object
 */



// retry and repeatWithBehavior

// try request up to 5 times
// multiply the delay by 3.0 at each attemps
// so retry after 1, 3, 9, 27 and 81 seconds before giving up
let request = URLRequest(url: url)
let tryHard = URLSession.shared.rx.response(request: request)
    .map { response in
        // process response here
    }
    .retry(.exponendialDelayed(maxCount: 3, inital: 1.0, multiplier: 3.0))



// catchErrorJustComplete

let neverErrors = someObservable.catchErrorJustComplete()



// pausable and pausableBuffered

let pausableSequence = source.pausable(pauser.startWith(true))



// withUnretained

var anObject: SomeClass! = SomeClass()
_ = Observable
    .of(1, 2, 3, 5, 8, 13, 18, 21, 23)
    .withUnretained(anObject)
    .debug("Combined Object with Emitted Events")
    .do(onNext: { _, value in
        if value == 13 {
            // When anObject becomes nil, the next value of the
            source
        }
        
        // sequence will try to retain it and fail.
        // As soon as it fails, the sequence will complete.
        anObject = nil
    })
    .subscribe()

message
// guard let self = self
    .withUnretained(self) { vc, message in
        vc.showMessage(message)
    }



// partition

let (evens, odds) = Observable
    .of(1, 2, 3, 5, 6, 7, 8)
    .partition { $0 % 2 == 0 }

_ = evens.debug("evens").subscribe() // Emits 2, 6, 8
_ = odds.debug("odds").subscribe() // Emits 1, 3, 5, 7



// mapMany

_ = Observable.of(
    [1, 3, 5],
    [2, 4] )
.mapMany { pow(2, $0) }
.debug("powers of 2")
.subscribe() // Emits [2, 8, 32] and [4, 16]
