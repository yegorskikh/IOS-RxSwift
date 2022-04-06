import UIKit
import RxSwift
import RxCocoa

class CategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet var tableView: UITableView!
  var activityIndicator: UIActivityIndicatorView!
  let download = DownloadView()
  
  let categories = BehaviorRelay<[EOCategory]>(value: [])
  let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupIndicator()
    activityIndicator.startAnimating()
    
    view.addSubview(download)
    view.layoutIfNeeded()
    
    categories
      .asObservable()
      .subscribe(onNext: { [weak self] _ in
        DispatchQueue.main.async {
          self?.tableView?.reloadData()
        }
      })
      .disposed(by: disposeBag)
    
    startDownload()
  }
  
  func startDownload() {
    download.progress.progress = 0.0
    download.label.text = "Download: 0%"
    
    let eoCategories = EONET.categories
    let downloadedEvents = eoCategories
      .flatMap { categories in
        return Observable.from(categories.map { category in
          EONET.events(forLast: 360, category: category)
        }) }
      .merge(maxConcurrent: 2)
    
    let updatedCategories = eoCategories.flatMap { categories in
      downloadedEvents.scan((0,categories)) { tuple, events in
        return (tuple.0 + 1, tuple.1.map { category in
          let eventsForCategory = EONET.filteredEvents(events: events, forCategory: category)
          if !eventsForCategory.isEmpty {
            var cat = category
            cat.events = cat.events + eventsForCategory
            return cat
          }
          return category
        })
      }
    }
      .do(onNext: { [weak self] tuple in
        DispatchQueue.main.async {
          let progress = Float(tuple.0) / Float(tuple.1.count)
          self?.download.progress.progress = progress
          let percent = Int(progress * 100.0)
          self?.download.label.text = "Download: \(percent)%"
        }
      })
        .do(onCompleted: { [weak self] in
          DispatchQueue.main.async {
            self?.activityIndicator.stopAnimating()
            self?.download.isHidden = true
          }
        })
        
          eoCategories
          .concat(updatedCategories.map(\.1))
          .bind(to: categories)
          .disposed(by: disposeBag)
          
  }
  
  private func setupIndicator() {
    activityIndicator = UIActivityIndicatorView()
    activityIndicator.color = .white
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
  }
  
  // MARK: UITableViewDataSource
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories.value.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")!
    let category = categories.value[indexPath.row]
    
    cell.detailTextLabel?.text = category.description
    cell.textLabel?.text = "\(category.name) (\(category.events.count))"
    cell.accessoryType = (category.events.count > 0) ? .disclosureIndicator : .none
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let category = categories.value[indexPath.row]
    tableView.deselectRow(at: indexPath, animated: true)
    
    guard !category.events.isEmpty else { return }
    let eventsController = storyboard!.instantiateViewController(withIdentifier: "events") as! EventsViewController
    eventsController.title = category.name
    eventsController.events.accept(category.events)
    
    navigationController!.pushViewController(eventsController, animated: true)
  }
  
}

