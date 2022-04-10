// MARK: - Basic table view

@IBOutlet var tableView: UITableView!

func bindTableView() {
    let cities = Observable.of(["Lisbon", "Copenhagen", "London", "Madrid", "Vienna"])
    cities
        .bind(to: tableView.rx.items) { (tableView: UITableView, index: Int, element: String) in
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell.textLabel?.text = element
            return cell
        }
        .disposed(by: disposeBag)
}

/*
 • modelSelected(_:),modelDeselected(_:),itemSelected,itemDeselectedfire on item selection.
 • modelDeleted(_:) fires on item deletion (upon tableView:commitEditingStyle:forRowAtIndexPath:).
 • itemAccessoryButtonTapped fire on accessory button tap.
 • itemInserted, itemDeleted, itemMoved fire on event callbacks in table edit mode.
 • willDisplayCell, didEndDisplayingCell fire every time related
 UITableViewDelegate callbacks fire.
 */

tableView.rx
    .modelSelected(String.self)
    .subscribe(onNext: { model in
        print("\(model) was selected")
    })
    .disposed(by: disposeBag)


// MARK: - Multiple cell types

// To build a table

enum MyModel {
    case text(String)
    case pairOfImages(UIImage, UIImage)
}

let observable = Observable<[MyModel]>.just([
    .textEntry("Paris"),
    .pairOfImages(UIImage(named: "EiffelTower.jpg")!, UIImage(named: "LeLouvre.jpg")!),
    .textEntry("London"),
    .pairOfImages(UIImage(named: "BigBen.jpg")!, UIImage(named: "BuckinghamPalace.jpg")!)
])

// To bind it to the table

observable.bind(to: tableView.rx.items) { (tableView: UITableView, index: Int, element: MyModel) in
    let indexPath = IndexPath(item: index, section: 0)
    
    switch element {
    case .textEntry(let title):
        let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! TextCell
        cell.titleLabel.text = title
        return cell
    case let .pairOfImages(firstImage, secondImage):
        let cell = tableView.dequeueReusableCell(withIdentifier: "pairOfImagesCell", for: indexPath) as! ImagesCell
        cell.leftImage.image = firstImage
        cell.rightImage.image = secondImage
        return cell
    }
}
.disposed(by: disposeBag)
