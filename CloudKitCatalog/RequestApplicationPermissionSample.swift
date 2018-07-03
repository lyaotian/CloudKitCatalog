/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This sample shows how to request a user's permission to make them discoverable to other users
                of the app.
*/

import CloudKit

class PermissionStatus: Result {
    let summaryField: String? = nil
    let attribute: Attribute
    
    init(status: CKApplicationPermissionStatus) {
        let attribute = Attribute(key: "CKApplicationPermissionStatus")
        if status == .granted {
            attribute.value = "Granted"
        } else {
            attribute.value = "Denied"
        }
        self.attribute = attribute
    }
    
    var attributeList: [AttributeGroup] {
        return [
            AttributeGroup(title: "Discoverability Status:", attributes: [ attribute ])
        ]
    }
    
}

class RequestApplicationPermissionSample: CodeSample {
    
    init() {
        super.init(
            title: "requestApplicationPermission",
            className: "CKContainer",
            methodName: ".requestApplicationPermission()",
            descriptionKey: "Discoverability.RequestApplicationPermission"
        )
    }
    
    override func run(completionHandler: @escaping (Results, Error?) -> Void) {
        
        let container = CKContainer.default()
        
        container.requestApplicationPermission(CKApplicationPermissions.userDiscoverability) {
            
            (applicationPermissionStatus, nsError) in
            
            let results = Results()
            
            results.items = [ PermissionStatus(status: applicationPermissionStatus) ]

            completionHandler(results,nsError)
        }
        
    }
}
