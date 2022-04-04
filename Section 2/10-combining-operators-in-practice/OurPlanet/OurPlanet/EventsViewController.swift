import UIKit
import RxSwift
import RxCocoa

class EventsViewController: UIViewController, UITableViewDataSource {

  @IBOutlet var tableView: UITableView!
  @IBOutlet var slider: UISlider!
  @IBOutlet var daysLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 60
  }

  @IBAction func sliderAction(slider: UISlider) {
  }

  // MARK: UITableViewDataSource
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventCell
    return cell
  }

}
