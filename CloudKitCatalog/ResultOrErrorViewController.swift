/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This controller displays a result or an error and provides a common Done/Back action.
*/

import UIKit

class ResultOrErrorViewController: UIViewController {

    var isDrilldown = false
    
    var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Error"
        
        doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(ResultOrErrorViewController.backToCodeSample))
        
        if !isDrilldown {
            navigationItem.hidesBackButton = true
            navigationItem.rightBarButtonItem = doneButton
        }
    }

    @objc func backToCodeSample() {
        dismiss(animated: true, completion: nil)
    }
    

}
