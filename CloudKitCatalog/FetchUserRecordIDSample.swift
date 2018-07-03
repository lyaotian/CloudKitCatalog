/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This sample shows how to fetch the signed in user's user record ID.
*/

import CloudKit

class FetchUserRecordIDSample: CodeSample {
    
    init() {
        super.init(
            title: "fetchUserRecordIDWithCompletionHandler",
            className: "CKContainer",
            methodName: ".fetchUserRecordIDWithCompletionHandler()",
            descriptionKey: "Discoverability.FetchUserRecordID"
        )
    }
    
    override func run(completionHandler: @escaping (Results, Error?) -> Void) {
        
        let container = CKContainer.default()
        
        container.fetchUserRecordID {
            (recordID, nsError) in
            
            let results = Results()

            if let recordID = recordID {
                results.items.append(recordID)
            }
            
            completionHandler(results, nsError)
        }
        
    }
    
}
