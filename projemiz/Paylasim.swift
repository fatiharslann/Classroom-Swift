//
//  Paylasim.swift
//  projemiz
//
//  Created by fatih on 13.05.2018.
//  Copyright © 2018 fatmadelenn. All rights reserved.
//

class  Paylasim {
    var id:String
    var icerik:String
    var tarih:Double
    var kullaniciId:String
    var grupId:String
    init(id:String,icerik:String,tarih:Double,kullaniciId:String,grupId:String) {
        self.id = id
        self.icerik = icerik
        self.grupId = grupId
        self.kullaniciId = kullaniciId
        self.tarih = tarih
    }
}
