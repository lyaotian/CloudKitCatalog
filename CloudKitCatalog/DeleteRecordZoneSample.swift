/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This sample demonstrates how to delete a record zone with the given name.
*/

import CloudKit

class DeleteRecordZoneSample: CodeSample {
    
    init() {
        super.init(
            title: "deleteRecordZoneWithID",
            className: "CKDatabase",
            methodName: ".deleteRecordZoneWithID()",
            descriptionKey: "Zones.DeleteRecordZone",
            inputs: [
                TextInput(label: "zoneName", value: "", isRequired: true)
            ]
        )
    }
    
    override func run(completionHandler: @escaping (Results, Error?) -> Void) {
        
        if let zoneName = data["zoneName"] as? String {
            
            let container = CKContainer.default()
            let privateDB = container.privateCloudDatabase
            
            let zoneID = CKRecordZoneID(zoneName: zoneName, ownerName: CKOwnerDefaultName)
            
            privateDB.delete(withRecordZoneID: zoneID) {
                (zoneID, nsError) in
                
                let results = Results()
                
                if let zoneID = zoneID {
                    results.items.append(zoneID)
                }
                
                completionHandler(results, nsError)
            }
        }
        
    }
}
