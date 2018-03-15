//
//  FirebaseHandler.swift
//  DeviceManager
//
//  Created by Chandimal, Sameera on 3/14/18.
//  Copyright © 2018 Pearson. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FirebaseHandler {
    
    static func findDeviceExist(name: String, completion: @escaping (_ isExist: Bool, _ type: String, _ model: String) -> Void) {
        let ref: DatabaseReference = Database.database().reference()
        
        ref.child("Devices/iOS").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(name) {
                completion(true, "Devices", "iOS")
            } else {
                ref.child("Devices/Android").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.hasChild(name) {
                        completion(true, "Devices", "Android")
                    } else {
                        ref.child("Cables/iOSCables").observeSingleEvent(of: .value, with: { (snapshot) in
                            if snapshot.hasChild(name) {
                                completion(true, "Cables", "iOSCables")
                            } else {
                                ref.child("Cables/AndroidCables").observeSingleEvent(of: .value, with: { (snapshot) in
                                    if snapshot.hasChild(name) {
                                        completion(true, "Cables", "AndroidCables")
                                    } else {
                                        completion(false, "", "")
                                    }
                                })
                            }
                        })
                    }
                })
            }
        })
    }

    static func updateBorrower(type: String, model: String, name: String, borrower: String) {
        let ref: DatabaseReference = Database.database().reference()
        ref.child("\(type)/\(model)/\(name)/borrower").setValue(borrower)
    }
    
    static func getOwner(type: String, model: String, name: String, completion: @escaping (_ borrower: String) -> Void) {
        let ref: DatabaseReference = Database.database().reference()
        ref.child("\(type)/\(model)").child(name).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let borrower = value?["borrower"] as? String ?? ""
            completion(borrower)
        })
    }
    
    static func addItem(type: String, model: String, name: String) {
        let ref: DatabaseReference = Database.database().reference()
        ref.child("\(type)/\(model)").child(name).setValue([
            "borrower": "Locker"
        ])
    }
    
    static func getPassCode(completion: @escaping (_ borrower: Int) -> Void) {
        let ref: DatabaseReference = Database.database().reference()
        ref.child("Admin/Passcode").observeSingleEvent(of: .value, with: { (snapshot) in
            if let passcode = snapshot.value as? Int {
                completion(passcode)
            }
        })
    }
}
