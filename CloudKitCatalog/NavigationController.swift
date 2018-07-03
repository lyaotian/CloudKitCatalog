/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This navigation controller overrides prepareForSegue to run a code sample and show the results or an error.
*/

import UIKit

class NavigationController: UINavigationController {

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowLoadingView", let selectedCodeSample = sender as? CodeSample {
            selectedCodeSample.run {
                (results,error) in
                if let navigationController = segue.destination as? UINavigationController, let loadingViewController = navigationController.topViewController as? LoadingViewController {
                    var segueIdenfier = "ShowResult"
                    if error != nil {
                        loadingViewController.error = error
                        segueIdenfier = "ShowError"
                    } else {
                        loadingViewController.results = results
                        loadingViewController.codeSample = selectedCodeSample
                    }
                    DispatchQueue.main.async() {
                        loadingViewController.performSegue(withIdentifier: segueIdenfier, sender: loadingViewController)
                    }
                }
            }
        }
    }

}
