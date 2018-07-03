/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This extends CKSubscription to conform to the Result protocol.
*/

import CloudKit

extension CKSubscription: Result {
    var summaryField: String? {
        if subscriptionType == .recordZone {
            return "RecordZone(\(zoneID!.zoneName))"
        } else if subscriptionType == .query {
            var info = [String]()
            if let recordType = recordType {
                info.append(recordType)
            }
            if let predicate = predicate {
                info.append(predicate.predicateFormat)
            }
            let queryParams = info.joined(separator: ",")
            return "Query(\(queryParams))"
        } else {
            return subscriptionID
        }
    }
    
    var attributeList: [AttributeGroup] {
        var subscriptionType = ""
        var firesOnRecordCreation = "N"
        var firesOnRecordUpdate = "N"
        var firesOnRecordDeletion = "N"
        var firesOnce = "N"

        switch self.subscriptionType {
        case .recordZone:
            subscriptionType = "RecordZone"
        case .query:
            subscriptionType = "Query"
        default: break
        }
        
        if subscriptionOptions.contains(.firesOnRecordCreation) {
            firesOnRecordCreation = "Y"
        }
        if subscriptionOptions.contains(.firesOnRecordUpdate) {
            firesOnRecordUpdate = "Y"
        }
        if subscriptionOptions.contains(.firesOnRecordDeletion) {
            firesOnRecordDeletion = "Y"
        }
        if subscriptionOptions.contains(.firesOnce) {
            firesOnce = "Y"
        }
        
        var groups = [
            AttributeGroup(title: "", attributes: [
                Attribute(key: "subscriptionID", value: subscriptionID),
                Attribute(key: "subscriptionType", value: subscriptionType),
                Attribute(key: "predicate", value: predicate != nil ? predicate!.predicateFormat : "")
            ]),
            AttributeGroup(title: "Options", attributes: [
                Attribute(key: "FiresOnRecordCreation", value: firesOnRecordCreation),
                Attribute(key: "FiresOnRecordUpdate", value: firesOnRecordUpdate),
                Attribute(key: "FiresOnRecordDeletion", value: firesOnRecordDeletion),
                Attribute(key: "FiresOnce", value: firesOnce)
            ])
        ]
        if let zoneID = zoneID {
            groups[0].attributes += [
                Attribute(key: "zoneID"),
                Attribute(key: "zoneName", value: zoneID.zoneName, isNested: true),
                Attribute(key: "ownerName", value: zoneID.ownerName, isNested: true)
            ]
        }
        return groups
    }
}
