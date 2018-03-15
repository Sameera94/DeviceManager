//
//  ItemCell.swift
//  DeviceManager
//
//  Created by Chandimal, Sameera on 3/14/18.
//  Copyright © 2018 Pearson. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {

    @IBOutlet weak var deviecName: UILabel!
    @IBOutlet weak var borrower: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setData(item: String, borrower: String) {
        self.deviecName.text = item
        self.borrower.text = borrower
    }
    
}

class Item {
    var name = ""
    var borrower = ""
    
    init(name: String, borrower: String) {
        self.name = name
        self.borrower = borrower
    }
}
