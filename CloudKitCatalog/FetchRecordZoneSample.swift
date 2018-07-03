/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This sample shows how to fetch a record zone with the given name.
*/

import CloudKit

class FetchRecordZoneSample: CodeSample {
    
    init() {
        super.init(
            title: "fetchRecordZoneWithID",
            className: "CKDatabase",
            methodName: ".fetchRecordZoneWithID()",
            descriptionKey: "Zones.FetchRecordZone",
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
            
            privateDB.fetch(withRecordZoneID: zoneID) {
                
                (zone, nsError) in
                
                let results = Results()
                
                if let zone = zone {
                    results.items.append(zone)
                }
                
                completionHandler(results, nsError)
            }

        }
        
    }
}
