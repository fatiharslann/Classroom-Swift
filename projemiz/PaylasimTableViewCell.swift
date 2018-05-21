//
//  PaylasimTableViewCell.swift
//  projemiz
//
//  Created by fatih on 13.05.2018.
//  Copyright © 2018 fatmadelenn. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
class PaylasimTableViewCell:UITableViewCell {
    
    @IBOutlet weak var tarih: UILabel!
    @IBOutlet weak var adSoyad: UILabel!
    @IBOutlet weak var icerik: UILabel!
    override func awakeFromNib() {
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
