
// Attaching gestures

view.rx.tapGesture()
    .when(.recognized)
    .subscribe(onNext: { _ in
        print("view tapped")
    })
    .disposed(by: disposeBag)

view.rx.anyGesture(.tap(), .longPress())
    .when(.recognized)
    .subscribe(onNext: { [weak view] gesture in
        if let tap = gesture as? UITapGestureRecognizer {
            print("view was tapped at \(tap.location(in: view!))")
        } else {
            print("view was long pressed")
        }
    })
    .disposed(by: disposeBag)

// Supported gestures

view.rx.screenEdgePanGesture(edges: [.top, .bottom])
    .when(.recognized)
    .subscribe(onNext: { recognizer in
        // gesture was recognized
    })
    .disposed(by: disposeBag)

let observable = view.rx.swipeGesture(.left, configuration: { recognizer in
    recognizer.allowedTouchTypes = [NSNumber(value: UITouchType.stylus.rawValue)]
})



// Current location

view.rx.tapGesture()
    .when(.recognized)
    .asLocation(in: .window)
    .subscribe(onNext: { location in
        // you now directly get the tap location in the window
    })
    .disposed(by: disposeBag)



// Pan gestures

view.rx.panGesture()
    .asTranslation(in: .superview)
    .subscribe(onNext: { translation, velocity in
        print("Translation=\(translation), velocity=\(velocity)")
    })
    .disposed(by: disposeBag)



// Rotation gestures

view.rx.rotationGesture()
    .asRotation()
    .subscribe(onNext: { rotation, velocity in
        print("Rotation=\(rotation), velocity=\(velocity)")
    })
    .disposed(by: disposeBag)



// Automated view transform

view.rx.transformGestures()
    .asTransform()
    .subscribe(onNext: { [unowned view] transform, velocity in
        view.transform = transform
    })
    .disposed(by: disposeBag)

view.rx.transformGestures(configuration: { (recognizers, delegate) in
    recognizers.pinchGesture.isEnabled = false
})



// Advanced usage

let panGesture = view.rx.panGesture()
    .share(replay: 1)

panGesture
    .when(.changed)
    .asTranslation()
    .subscribe(onNext: { [unowned view] translation, _ in
        view.transform = CGAffineTransform(translationX:
                                            translation.x,
                                           y: translation.y)
    })
    .disposed(by: disposeBag)

panGesture
    .when(.ended)
    .subscribe(onNext: { _ in
        print("Done panning")
    })
    .disposed(by: disposeBag)
