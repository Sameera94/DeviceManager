//
//  DBViewController.swift
//  DeviceManager
//
//  Created by Chandimal, Sameera on 3/14/18.
//  Copyright © 2018 Pearson. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class DBViewController: UIViewController {

    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func insertIten(_ sender: UIButton) {
        ref = Database.database().reference()
        
        
//        self.ref.child("Devices").child("iOS").setValue([
//            "name": "iPhone 6+",
//            "borrower": "Locker"
//        ])
        
        self.ref.child("Devices/iOS").childByAutoId().setValue([
            "name": "iPhone 6+",
            "borrower": "Locker"
        ])
    }
}
