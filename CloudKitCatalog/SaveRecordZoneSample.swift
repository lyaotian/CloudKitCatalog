/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This sample shows how to save a record zone with a provided zone name.
*/

import CloudKit

class SaveRecordZoneSample: CodeSample {
    
    init() {
        super.init(
            title: "saveRecordZone",
            className: "CKDatabase",
            methodName: ".saveRecordZone()",
            descriptionKey: "Zones.SaveRecordZone",
            inputs: [
                TextInput(label: "zoneName", value: "", isRequired: true)
            ]
        )
    }
    
    override func run(completionHandler: @escaping (Results, Error?) -> Void) {
        
        if let zoneName = data["zoneName"] as? String {
            
            let container = CKContainer.default()
            let privateDB = container.privateCloudDatabase

            privateDB.save(CKRecordZone(zoneName: zoneName)) {
                
                (recordZone, nsError) in
                
                let results = Results()
                
                if let recordZone = recordZone {
                    results.items.append(recordZone)
                }
                
                completionHandler(results, nil)
            }
        }
        
    }
    
    
}
