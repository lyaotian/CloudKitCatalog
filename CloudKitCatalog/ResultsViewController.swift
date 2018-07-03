/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A ResultsViewController displays a Results object in a table.
*/

import UIKit

class ResultsViewController: ResultOrErrorViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    // MARK: - Properties
    
    @IBOutlet weak var tableView: TableView!
    @IBOutlet weak var toolbarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolbar: UIToolbar!
    
    var results: Results = Results()
    var codeSample: CodeSample?
    
    var selectedAttributeValue: String?
    
    var activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if results.items.count == 1 {
            let result = results.items[0]
            navigationItem.title = result.summaryField ?? "Result"
        } else {
            navigationItem.title = "Result"
        }
        
        activityIndicator.hidesWhenStopped = true
        
        toggleToolbar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let codeSample = codeSample as? MarkNotificationsReadSample {
            codeSample.cache.markAsRead()
        }
    }
    
    func toggleToolbar() {
        if toolbarHeightConstraint != nil {
            if results.moreComing {
                toolbar.isHidden = false
                toolbarHeightConstraint.constant = 44
            } else {
                toolbarHeightConstraint.constant = 0
                toolbar.isHidden = true
            }
        }
    }


    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        if results.items.count > 0 && !results.showAsList {
            return results.items[0].attributeList.count
        }
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if results.items.count > 0 && !results.showAsList {
            return results.items[0].attributeList[section].attributes.count
        } else {
            return results.items.count
        }
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if results.showAsList {
            let cell = tableView.dequeueReusableCell(withIdentifier:"ResultCell", for: indexPath) as! ResultTableViewCell
            let result = results.items[indexPath.row]
            cell.resultLabel.text = result.summaryField ?? ""
            cell.changeLabelWidthConstraint.constant = 15
            if results.added.contains(indexPath.row) {
                cell.changeLabel.text = "A"
            } else if results.deleted.contains(indexPath.row) {
                cell.changeLabel.text = "D"
            } else if results.modified.contains(indexPath.row) {
                cell.changeLabel.text = "M"
            } else {
                cell.changeLabelWidthConstraint.constant = 0
            }
            return cell
        }
        
        let attribute = results.items[0].attributeList[indexPath.section].attributes[indexPath.row]
        
        guard let value = attribute.value else {
            let cell = tableView.dequeueReusableCell(withIdentifier:"AttributeKeyCell", for: indexPath) as! AttributeKeyTableViewCell
            cell.attributeKey.text = attribute.key
            return cell
        }
        
        
        if attribute.image != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier:"ImageCell", for: indexPath) as! ImageTableViewCell
            cell.attributeKey.text = attribute.key
            cell.attributeValue.text = value.isEmpty ? "-" : value
            cell.assetImage.image = attribute.image
            return cell
        }
        
        let cellIdentifier = attribute.isNested ? "NestedAttributeCell" : "AttributeCell"

        let cell = tableView.dequeueReusableCell(withIdentifier:cellIdentifier, for: indexPath) as! AttributeTableViewCell

        cell.attributeKey.text = attribute.key
        cell.attributeValue.text = value.isEmpty ? "-" : value
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let codeSample = codeSample else { return "" }
        if results.showAsList {
            return codeSample.listHeading
        } else {
            let result = results.items[0]
            return result.attributeList[section].title
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if results.items.count > 0 && !results.showAsList {
            let attribute = results.items[0].attributeList[indexPath.section].attributes[indexPath.row]
            if attribute.image != nil {
                return 200.0
            }
        }
        return tableView.rowHeight
    }
    
    
    // Mark: - Responder
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(ResultsViewController.copyAttributeToClipboard)
    }
    
    // MARK: - Actions

    
    @IBAction func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            let point = sender.location(in: tableView)
            let indexPath = tableView.indexPathForRow(at: point)!
            if let attributeCell = tableView.cellForRow(at: indexPath) as? AttributeTableViewCell, let attributeValue = attributeCell.attributeValue {
                self.becomeFirstResponder()
                self.selectedAttributeValue = attributeValue.text ?? ""
                let menuController = UIMenuController.shared
                menuController.setTargetRect(attributeValue.frame, in: attributeCell)
                menuController.menuItems = [UIMenuItem(title: "Copy attribute value", action: #selector(ResultsViewController.copyAttributeToClipboard))]
                menuController.setMenuVisible(true, animated: true)
            }
        }
    }
    
    @objc func copyAttributeToClipboard() {
        if let selectedAttributeValue = selectedAttributeValue {
            let pasteBoard = UIPasteboard.general
            pasteBoard.string = selectedAttributeValue
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DrillDown", let resultsViewController = segue.destination as? ResultsViewController, let indexPath = tableView.indexPathForSelectedRow {
            let result = results.items[indexPath.row]
            resultsViewController.results = Results(items: [result])
            resultsViewController.codeSample = codeSample
            resultsViewController.isDrilldown = true
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    @IBAction func loadMoreResults(sender: UIBarButtonItem) {
        sender.isEnabled = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        activityIndicator.startAnimating()
        
        if let codeSample = codeSample {
            codeSample.run {
                (results, nsError) in
                
                self.results = results
                DispatchQueue.main.async {
                    var indexPaths = [IndexPath]()
                    for index in results.added.sorted() {
                        indexPaths.append(IndexPath(row: index, section: 0))
                    }
                    if indexPaths.count > 0 {
                        self.tableView.insertRows(at: indexPaths, with: .automatic)
                    }
                    indexPaths = []
                    for index in results.deleted.union(results.modified).sorted() {
                        indexPaths.append(IndexPath(row: index, section: 0))
                    }
                    if indexPaths.count > 0 {
                        self.tableView.reloadRows(at: indexPaths, with: .automatic)
                    }
                    self.navigationItem.rightBarButtonItem = self.doneButton
                    self.activityIndicator.stopAnimating()
                    if results.moreComing {
                        sender.isEnabled = true
                    } else {
                        
                        UIView.animate(withDuration: 0.4, animations: {
                            self.toggleToolbar()
                            self.view.layoutIfNeeded()
                        })
                        
                    }
                }
            }
        }
    }
    

}
