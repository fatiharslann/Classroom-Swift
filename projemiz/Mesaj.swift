//
//  Mesaj.swift
//  projemiz
//
//  Created by fatih on 13.05.2018.
//  Copyright © 2018 fatmadelenn. All rights reserved.
//

class Mesaj {
    var aliciId:String
    var gondericiId:String
    var mesaj:String
    var zaman:Double
    init(aliciId:String,gondericiId:String,mesaj:String,zaman:Double) {
        self.aliciId = aliciId
        self.gondericiId = gondericiId
        self.mesaj = mesaj
        self.zaman = zaman
    }
}
