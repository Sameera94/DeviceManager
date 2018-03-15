//
//  iOSDevice.swift
//  DeviceManager
//
//  Created by Chandimal, Sameera on 3/14/18.
//  Copyright © 2018 Pearson. All rights reserved.
//

import UIKit
import FirebaseDatabase

class iOSDevice: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var ref: DatabaseReference!
    var hanbler: DatabaseHandle!
    
    var items: [Item] = []
    var passCode = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "ItemCell")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        ref = Database.database().reference()
        
        FirebaseHandler.getPassCode { (passcode) in
            self.passCode = passcode
        }

        ref.child("Devices/iOS").observe(.childAdded, with: { (snapshot) in
            if let item = snapshot.value as? [String: String] {
                if let borrower = item["borrower"] {
                    self.items.append(Item(name: snapshot.key, borrower: borrower))
                }
            }
            self.tableView.reloadData()
        })
        
        ref.child("Devices/iOS").observe(.childChanged, with: { (snapshot) in
            if let item = snapshot.value as? [String: String] {
                if let borrower = item["borrower"] {
                    if let changedItem = self.items.filter({$0.name == snapshot.key}).first {
                        changedItem.borrower = borrower
                    }
                }
            }
            self.tableView.reloadData()
        })
        
        for barButton in self.navigationItem.rightBarButtonItems! {
            barButton.isEnabled = false
            barButton.tintColor = UIColor.gray
        }
    }
    
    @IBAction func onClickAdd(_ sender: Any) {
        let alert = UIAlertController(title: "Add new device", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Add", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            if let name = textField.text {
                if name.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                    FirebaseHandler.addItem(type: "Devices", model: "iOS", name: name.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Device name"
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        self.present(alert, animated:true, completion: nil)
    }

    @IBAction func onClickScanButton(_ sender: UIBarButtonItem) {
        self.showLockAlert()
    }
    
    func showLockAlert() {
        let alert = UIAlertController(title: "Locked", message: "Please enter passcode to unlock", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Verify", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            if let number = textField.text {
                if Int(number) != 0 && Int(number) == self.passCode {
                    self.performSegue(withIdentifier: "scanSegue", sender: self)
                } else {
                    self.showLockAlert()
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Passcode"
            textField.keyboardType = .numberPad
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        self.present(alert, animated:true, completion: nil)
    }
}

extension iOSDevice: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? ItemCell {
            cell.setData(item: self.items[indexPath.row].name, borrower: self.items[indexPath.row].borrower)
            if self.items[indexPath.row].borrower != "Locker" {
                cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
                cell.borrower.textColor = UIColor.black
            } else {
                cell.backgroundColor = UIColor.white
            }
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}
