//
//  GrupAyrintiViewController.swift
//  projemiz
//
//  Created by fatih on 12.05.2018.
//  Copyright © 2018 fatmadelenn. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
class GrupAyrintiViewController:UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    
    @IBOutlet weak var labelGrupAdi: UILabel!
    @IBOutlet weak var labelKullaniciAdi: UILabel!
    @IBOutlet weak var labelTarih: UILabel!
    
    @IBOutlet weak var paylasimTableView: UITableView!
    @IBOutlet weak var paylasimYap: UITextView!
    var grupID = ""
    var ref:DatabaseReference?
    var grupAdi = ""
    var kullaniciId = ""
    var paylasimlar = [Paylasim]()
    override func viewDidLoad() {
        super.viewDidLoad()
        paylasimTableView.delegate = self
        paylasimTableView.dataSource = self
        ref = Database.database().reference()
        ref?.child("gruplar").child(grupID).observe(.value, with: {(snapshot) in
            let gelenGrup = snapshot.value as? NSDictionary
            self.grupAdi = gelenGrup!["grupAdi"] as! String
            self.labelGrupAdi.text = self.grupAdi
            self.ref?.child("kullanicilar").child(gelenGrup!["grupOlusturanId"] as! String).observeSingleEvent(of: .value, with: {(snapshot) in
                let kullanici = snapshot.value as? NSDictionary
                self.labelKullaniciAdi.text! = (kullanici!["adSoyad"] as? String)!
            })
            self.labelTarih.text = self.timestampCevirme(serverTimestamp: gelenGrup!["zaman"] as! Double)
            self.paylasimYap!.layer.borderWidth = 1
            self.paylasimYap!.layer.borderColor = UIColor.lightGray.cgColor
        })
        paylasimlariGetir()
        self.kullaniciId = (Auth.auth().currentUser?.uid)!
        
    }
    @objc func geri(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paylasimlar.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaylasimViewCell") as! PaylasimTableViewCell
        ref?.child("kullanicilar").child(paylasimlar[indexPath.row].kullaniciId).observeSingleEvent(of: .value, with: {(snapshot) in
            let kullanici = snapshot.value as? NSDictionary
            cell.adSoyad.text! = (kullanici!["adSoyad"] as? String)!
        })
        cell.icerik.text = paylasimlar[indexPath.row].icerik
        cell.tarih.text = timestampCevirme(serverTimestamp: paylasimlar[indexPath.row].tarih)
        
        return cell
    }
    @IBAction func paylas(_ sender: Any) {
        if self.paylasimYap.text == ""{
            self.hataMesaji(title: "Hata!", message: "Boş Paylaşım")
        }else{
            let paylasimId = self.ref?.child("paylasimlar").childByAutoId().key
            self.ref?.child("paylasimlar").child(paylasimId!).setValue(["icerik":self.paylasimYap.text,
                                                                       "kullaniciId":self.kullaniciId,
                                                                       "grupId":self.grupID,
                                                                       "tarih" :[".sv": "timestamp"]])
        }
        
    }
    func paylasimlariGetir()  {
        ref?.child("paylasimlar").observe(.value, with: {(snapshot) in
            self.paylasimlar.removeAll()
            for gelen in snapshot.children.allObjects {
                let paylasim = gelen as? DataSnapshot
                let gelenPaylasim = paylasim?.value as? NSDictionary
                let key = paylasim?.key
                let paylasimIcerik = gelenPaylasim!["icerik"] as! String
                let paylasimYapanId = gelenPaylasim!["kullaniciId"] as! String
                let paylasimGrupId = gelenPaylasim!["grupId"] as! String
                let tarih = gelenPaylasim!["tarih"] as! Double
                if self.grupID == paylasimGrupId {
                    let gelenPaylasimm = Paylasim(id: key!, icerik: paylasimIcerik, tarih: tarih, kullaniciId: paylasimYapanId, grupId: self.grupID)
                    self.paylasimlar.append(gelenPaylasimm)
                    self.paylasimTableView.reloadData()
                }
                
                
            }
            
        })
    }
    /*Timestamp i tarihe çevirmek*/
    func timestampCevirme(serverTimestamp: Double) -> String {
        let x = serverTimestamp / 1000
        let date = NSDate(timeIntervalSince1970: x)
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        
        return formatter.string(from: date as Date)
    }
    /*üstteki saat olan kısım gizlendi*/
    override var prefersStatusBarHidden: Bool{
        return true
    }
    /*hata mesajları*/
    func hataMesaji(title:String,message:String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Tamam", style: .cancel, handler: nil)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
}
