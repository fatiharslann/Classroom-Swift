//
//  Grup.swift
//  projemiz
//
//  Created by fatih on 11.05.2018.
//  Copyright © 2018 fatmadelenn. All rights reserved.
//

import Foundation
class Grup {
    var id:String
    var grupAdi:String
    var olusturan:String
    var zaman:Double
    init(id:String,grupAdi:String,olusturan:String,zaman:Double) {
        self.id = id
        self.grupAdi = grupAdi
        self.olusturan = olusturan
        self.zaman = zaman
    }
}
