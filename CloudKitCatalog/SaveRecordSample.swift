/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This code sample demonstrates how to save a record of type Items to the private database.
*/

import CloudKit
import UIKit

class SaveRecordSample: CodeSample {
    
    init() {
        super.init(
            title: "saveRecord",
            className: "CKDatabase",
            methodName: ".saveRecord()",
            descriptionKey: "Records.SaveRecord",
            inputs: [
                TextInput(label: "recordName", value: ""),
                TextInput(label: "zoneName", value: CKRecordZoneDefaultName),
                TextInput(label: "name", value: ""),
                LocationInput(label: "location"),
                ImageInput(label: "asset")
            ]
        )
    }
    
    func processResult(record: CKRecord?, error: Error?, completionHandler: (Results, Error?) -> Void) {
        let results = Results()
        
        if let record = record {
            results.items.append(record)
        }
        
        completionHandler(results, error)
    }
    
    override func run(completionHandler: @escaping (Results, Error?) -> Void) {
        
        if let recordName = data["recordName"] as? String, let zoneName = data["zoneName"] as? String {
            
            let container = CKContainer.default()
            let privateDB = container.privateCloudDatabase
            
            let recordType = "Items"
            
            var record: CKRecord
            if zoneName.isEmpty {
                if recordName.isEmpty {
                    record = CKRecord(recordType: recordType)
                } else {
                    let recordID = CKRecordID(recordName: recordName)
                    record = CKRecord(recordType: recordType, recordID: recordID)
                }
            } else {
                let zoneID = CKRecordZoneID(zoneName: zoneName, ownerName: CKOwnerDefaultName)
                if recordName.isEmpty {
                    record = CKRecord(recordType: recordType, zoneID: zoneID)
                } else {
                    let recordID = CKRecordID(recordName: recordName, zoneID: zoneID)
                    record = CKRecord(recordType: recordType, recordID: recordID)
                }
            }
            if let name = data["name"] as? NSString {
                record["name"] = name
            }
            if let location = data["location"] as? CLLocation {
                record["location"] = location
            }
            if let imageURL = data["asset"] as? URL {
                let asset = CKAsset(fileURL: imageURL)
                record["asset"] = asset
            }
            privateDB.save(record) {
                (rec, nsError) in
                
                if let error = nsError { // && error.code == 14
                    // In this case we are trying to overwrite an existing record so let's fetch it and modify it.
                    privateDB.fetch(withRecordID: record.recordID) {
                        (rec, nsError) in
                        
                        if let rec = rec {
                            for key in record.allKeys() {
                                rec[key] = record[key]
                            }
                            
                            privateDB.save(rec) {
                                (rec, nsError) in
                                
                                self.processResult(record: rec, error: nsError, completionHandler: completionHandler)
                            }
                        }
                        
                    }
                } else {
                
                    self.processResult(record: rec, error: nsError, completionHandler: completionHandler)
                    
                }
            }
        }
        
    }
}
