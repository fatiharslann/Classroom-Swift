//
//  GrupTableViewCell.swift
//  projemiz
//
//  Created by fatih on 11.05.2018.
//  Copyright © 2018 fatmadelenn. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
class GrupTableViewCell:UITableViewCell {
    
    @IBOutlet weak var grupAdi: UILabel!
    @IBOutlet weak var btnTakipEt: UIButton!
    
    @IBOutlet weak var tarih: UILabel!
    @IBOutlet weak var kullaniciAdi: UILabel!
    var grupId = ""
    var kullaniciId:String = ""
    var ref:DatabaseReference?
    @IBAction func takipEt(_ sender: Any) {
        kullaniciId = (Auth.auth().currentUser?.uid)!
        ref = Database.database().reference()
        let iliskiId = ref?.child("grupTakip").childByAutoId().key
        ref?.child("grupTakip").child(iliskiId!).setValue(["grupId":grupId, "kullaniciId":kullaniciId])
        self.btnTakipEt.isHidden = true
    }
    override func awakeFromNib() {
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
