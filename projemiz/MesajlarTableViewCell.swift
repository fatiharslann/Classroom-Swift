//
//  MesajlarTableViewCell.swift
//  projemiz
//
//  Created by fatih on 13.05.2018.
//  Copyright © 2018 fatmadelenn. All rights reserved.
//



import UIKit
class MesajlarTableViewCell:UITableViewCell {
    
    @IBOutlet weak var kullaniciAdi: UILabel!
    @IBOutlet weak var mesajSayisi: UILabel!
    @IBOutlet weak var mail: UILabel!
    override func awakeFromNib() {
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
