/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A SubmenuTableViewController displays a second-level menu for those code sample groups that have 
                more than one code sample.
*/

import UIKit

class SubmenuTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var codeSamples = [CodeSample]()
    var groupTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let groupTitle = groupTitle {
            navigationItem.title = groupTitle
        }
        navigationItem.hidesBackButton = (navigationController!.viewControllers.first?.navigationItem.hidesBackButton)!
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return codeSamples.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let codeSample = codeSamples[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier:"SubmenuItem", for: indexPath) as! SubmenuTableViewCell
        cell.submenuLabel.text = codeSample.title
        return cell
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCodeSampleFromSubmenu" {
            let codeSampleViewController = segue.destination as! CodeSampleViewController
            if let selectedCell = sender as? SubmenuTableViewCell {
                let indexPath = tableView.indexPath(for: selectedCell)!
                codeSampleViewController.selectedCodeSample = codeSamples[indexPath.row]

            }
        }
    }


}
