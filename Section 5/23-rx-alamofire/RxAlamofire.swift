// Basic requests

RxAlamofire.string(.get, stringURL)
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)

RxAlamofire.json(.get, stringURL)
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)

RxAlamofire.data(.get, stringURL)
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)



// Request customization

// get current weather in london
RxAlamofire.json(.get, "http://api.openweathermap.org/data/2.5/weather", parameters: ["q": "London", "APPID": "{APIKEY}"])
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)



// Response validation

let response = request(.get, stringURL)
    .validate(statusCode: 200 ..< 300)
    .validate(contentType: ["text/json"])
    .json()



// Downloading files

let destination: DownloadRequest.DownloadFileDestination = { _, response in
    let docsURL = FileManager.default.urls(for: .documentDirectory,
                                           in: .userDomainMask)[0]
    
    let filename = response.suggestedFilename ?? "image.png"
    let fileURL = docsURL.appendingPathComponent(filename)
    return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
}

RxAlamofire.download(URLRequest(url: someURL), to: destination)
    .subscribe(onCompleted: { print("Download complete") })
    .disposed(by: disposeBag)



// Upload tasks

RxAlamofire.upload(someData, to: URLRequest(url: someURL))
    .subscribe(onCompleted: { print("Upload complete") })
    .disposed(by: disposeBag)



// Tracking progress

RxAlamofire.upload(localFileURL,to: URLRequest(url: remoteURL))
    .validate() // check acceptable status codes
    .progress()
    .subscribe (
        onNext: { progress in
            let percent = Int(100.0 * progress.completed)
            print("Upload progress: \(percent)%")
        },
        onCompleted: { print("Upload complete") }
    )
    .disposed(by: disposeBag)
