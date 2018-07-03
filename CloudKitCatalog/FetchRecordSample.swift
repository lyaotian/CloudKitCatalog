/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This sample demonstrates how to fetch a record by ID.
*/

import CloudKit

class FetchRecordSample: CodeSample {
    
    init() {
        super.init(
            title: "fetchRecordWithID",
            className: "CKDatabase",
            methodName: ".fetchRecordWithID()",
            descriptionKey: "Records.FetchRecord",
            inputs: [
                TextInput(label: "recordName", value: "", isRequired: true),
                TextInput(label: "zoneName", value: CKRecordZoneDefaultName, isRequired: true)
            ]
        )
    }
    
    override func run(completionHandler: @escaping (Results, Error?) -> Void) {
        
        if let zoneName = data["zoneName"] as? String, let recordName = data["recordName"] as? String {
            
            let container = CKContainer.default()
            let privateDB = container.privateCloudDatabase
            
            let zoneID = CKRecordZoneID(zoneName: zoneName, ownerName: CKOwnerDefaultName)
            let recordID = CKRecordID(recordName: recordName, zoneID: zoneID)
            
            privateDB.fetch(withRecordID: recordID) {
                (record, nsError) in
                
                let results = Results()
                
                if let record = record {
                    results.items.append(record)
                }
                
                completionHandler(results, nsError)
            }
        }
        
    }
}
