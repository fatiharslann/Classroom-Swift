//
//  Kullanici.swift
//  projemiz
//
//  Created by fatmadelenn on 11.05.2018.
//  Copyright © 2018 fatmadelenn. All rights reserved.
//

import Foundation
class Kullanici{
    var id:String
    var adSoyad:String
    var eMail:String
    init(id:String,adSoyad:String,eMail:String) {
        self.adSoyad = adSoyad
        self.eMail = eMail
        self.id = id
    }
}
