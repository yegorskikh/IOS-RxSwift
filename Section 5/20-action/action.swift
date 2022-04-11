// Connecting buttons

button.rx.action = buttonAction
button.rx.action = nil



// Composing behavior
let loginPasswordObservable =

Observable.combineLatest(loginField.rx.text, passwordField.rx.text) {
    ($0, $1)
}

loginButton.rx.tap
    .withLatestFrom(loginPasswordObservable)
    .bind(to: loginAction.inputs)
    .disposed(by: disposeBag)

loginAction
    .elements
    .filter { $0 } // only keep "true" values
    .take(1)       // just interested in first successful login
    .subscribe(onNext: {
        // login complete, push the next view controller
    })
    .disposed(by: disposeBag)

loginAction
    .errors
    .subscribe(onError: { error in
        guard
            case .underlyingError(let err) = error
        else {
            return
        }
        // update the UI to warn about the error
    } })
    .disposed(by: disposeBag)



// Passing work items to cells

observable.bind(to: tableView.rx.items) {
    (tableView: UITableView, index: Int, element: MyModel) in
    let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath)
    cell.button.rx.action = CocoaAction { [weak self] in
        // do something specific to this cell here
        return .empty()
    }
    return cell }
.disposed(by: disposeBag)



// Manual execution

loginAction
    .execute(("john", "12345"))
    .subscribe(onNext: {
        // handle return of action execution here
    })
    .disposed(by: disposeBag)
