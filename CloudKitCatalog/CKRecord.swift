/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This extends CKRecord to conform to the Result protocol.
*/

import UIKit
import CloudKit

extension CKRecord: Result {
    var summaryField: String? {
        if let name = object(forKey: "name") as? String {
            return name
        }
        if let name = object(forKey: "Name") as? String {
            return name
        }
        for key in allKeys() {
            if let string = object(forKey: key) as? String {
                return string
            }
        }
        return recordID.recordName
    }
    var attributeList: [AttributeGroup] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        var metadata = [Attribute]()
        var fields = [Attribute]()
        metadata += [
            Attribute(key: "recordType", value: recordType),
            Attribute(key: "recordID"),
            Attribute(key: "recordName", value: recordID.recordName, isNested: true),
            Attribute(key: "zoneID.zoneName", value: recordID.zoneID.zoneName, isNested: true),
            Attribute(key: "zoneID.ownerName", value: recordID.zoneID.ownerName, isNested: true),
            Attribute(key: "recordChangeTag", value: recordChangeTag ?? "")
        ]
        if let modificationDate = modificationDate {
            metadata.append(Attribute(key: "modificationDate", value: dateFormatter.string(from: modificationDate)))
        }
        if let creationDate = creationDate {
            metadata.append(Attribute(key: "creationDate", value: dateFormatter.string(from: creationDate)))
        }
        for key in allKeys() {
            let value = object(forKey: key)
            if let value = value as? String {
                fields.append(
                    Attribute(key: key, value: value)
                )
            } else if let value = value as? CLLocation {
                let coordinate = value.coordinate
                fields += [
                    Attribute(key: key),
                    Attribute(key: "coordinate.latitude", value: String(coordinate.latitude), isNested: true),
                    Attribute(key: "coordinate.longitude", value: String(coordinate.longitude), isNested: true)
                ]
            } else if let value = value as? CKAsset, let path = value.fileURL.path as? String {
                fields += [
                    Attribute(key: key),
                    Attribute(key: "fileURL.path", value: path, image: UIImage(contentsOfFile: path)!)
                ]
            }
        }
        var attributeGroups = [ AttributeGroup(title: "Metadata:", attributes: metadata) ]
        
        if fields.count > 0 {
            attributeGroups.append(AttributeGroup(title: "Fields:", attributes: fields))
        }
        
        return attributeGroups
    }
}
