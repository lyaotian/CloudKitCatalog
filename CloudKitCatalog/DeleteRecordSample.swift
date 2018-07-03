/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This code sample shows how to delete a record by ID.
*/

import CloudKit

class DeleteRecordSample: CodeSample {
    
    init() {
        super.init(
            title: "deleteRecordWithID",
            className: "CKDatabase",
            methodName: ".deleteRecordWithID()",
            descriptionKey: "Records.DeleteRecord",
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
            
            privateDB.delete(withRecordID: recordID) {
                (recordID, nsError) in
                
                let results = Results()
                
                if let recordID = recordID {
                    results.items.append(recordID)
                }
                
                completionHandler(results, nsError)
            }
        }
        
    }
}

