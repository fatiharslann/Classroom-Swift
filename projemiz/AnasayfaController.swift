//
//  AnasayfaController.swift
//  projemiz
//
//  Created by fatmadelenn on 4.05.2018.
//  Copyright © 2018 fatmadelenn. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
class AnasayfaController: UIViewController, UITableViewDelegate,UITableViewDataSource,UITabBarControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource{
    @IBOutlet weak var adsoyad: UILabel!
    @IBOutlet weak var anasayfa: UINavigationBar!
    @IBOutlet weak var kullaniciAdi: UILabel!
    @IBOutlet weak var rutbe: UILabel!
    @IBOutlet weak var duyuruYaz: UITextView!
   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    var ref:DatabaseReference?
    var kullaniciId:String!
    var duyuruIdkey:String!
    var begeniKey:String!
    var temp = false
    var begeniTemp = false
    var begenenCount = 0
    var mesajCount = 0
    var grupCount = 0
    var begenme = 0
    var duyurular = [Duyuru]()
    var kullanicilar = [Kullanici]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        self.duyuruYaz!.layer.borderWidth = 1
        duyuruYaz!.layer.borderColor = UIColor.lightGray.cgColor
        ref = Database.database().reference()
        kullaniciGetir()
        duyurulariGetir()
        tumKullanicilariGetir()
        Database.database().reference().child("duyurular").observe(.value, with: {(snapshot) in
            let count = snapshot.childrenCount
             self.tabBarController?.tabBar.items?[0].badgeValue = String(count)
        })
        Database.database().reference().child("mesajlar").observe(.value, with: {(snapshot) in
            self.mesajCount = 0
            for gelenMesaj in snapshot.children.allObjects{
                let mesaj = gelenMesaj as? DataSnapshot
                let gMesaj = mesaj?.value as? NSDictionary
                let aliciM = gMesaj!["aliciId"] as? String
                if self.kullaniciId == aliciM{
                    self.mesajCount = self.mesajCount + 1
                }
            }
            self.tabBarController?.tabBar.items? [2].badgeValue = String(self.mesajCount)
        })
        Database.database().reference().child("gruplar").observe(.value, with: {(snapshot) in
            let grupchild = snapshot.childrenCount
            if grupchild == grupchild + 1 {
                self.grupCount = self.grupCount + 1
            }
        self.tabBarController?.tabBar.items? [1].badgeValue = String(self.begenenCount)
        })
        Database.database().reference().child("begeni").observe(.value, with: {(snapshot) in
           self.begenenCount = 0
            for gelen in snapshot.children.allObjects {
                let begen = gelen as? DataSnapshot
                let gelenbegeni = begen?.value as? NSDictionary
                let begenen = gelenbegeni!["kullaniciId"] as? String
                let duyurum = gelenbegeni!["duyuruId"] as? String
                Database.database().reference().child("duyurular").observe(.value, with: {(snapshot) in
                    for begeniGelen in snapshot.children.allObjects {
                        let duyuru = begeniGelen as? DataSnapshot
                        let gelenDuyuru = duyuru?.value as? NSDictionary
                        let key = duyuru?.key
                        let duyuruYapan = gelenDuyuru!["duyuruYazan"] as! String
                        print(duyuruYapan)
                        if self.kullaniciId == duyuruYapan && key == duyurum {
                            self.begenenCount = self.begenenCount + 1
                        }
                    }
                    self.tabBarController?.tabBar.items? [3].badgeValue = String(self.begenenCount)
                })
            }
        })
    }
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 0 || tabBarIndex == 1 || tabBarIndex == 2 || tabBarIndex == 3 {
            tabBarController.tabBar.items?[tabBarIndex].badgeValue = nil
        }
    }

    func kullaniciGetir(){
        kullaniciId = Auth.auth().currentUser?.uid
        ref?.child("kullanicilar/"+kullaniciId).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let adSoyad = value?["adSoyad"] as? String ?? ""
            let rutbeGetir = value?["rutbe"] as? String ?? ""
            self.adsoyad.text! = adSoyad
            self.rutbe.text! = rutbeGetir
            self.kullaniciAdi.text! = (Auth.auth().currentUser?.email)!
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    @IBAction func duyuruGonder(_ sender: Any) {
        if self.duyuruYaz.text! != ""{
            var duyuruId = ref?.child("duyurular/").childByAutoId()
            duyuruIdkey = duyuruId?.key
            self.ref?.child("duyurular/"+duyuruIdkey!+"/").setValue(["duyuru" : self.duyuruYaz.text!,
                                                                     "duyuruYazan" : kullaniciId,
                                                                     "zaman": [".sv": "timestamp"],
                                                                     "begeni": 0])
           
            self.hataMesaji(title: "Duyuru", message: "Duyurunuz Başarıyla eklenmiştir...")
        }
       
    }
    
    func duyurulariGetir() -> Void {
        ref=Database.database().reference()
        ref?.child("duyurular").observe(.value, with: {(snapshot) in
            self.duyurular.removeAll()
            for gelen in snapshot.children.allObjects {
                let duyuru = gelen as? DataSnapshot
                let gelenDuyuru = duyuru?.value as? NSDictionary
                let key = duyuru?.key
                let duyuruIcerik = gelenDuyuru!["duyuru"] as! String
                let duyuruYapan = gelenDuyuru!["duyuruYazan"] as! String
                let tarih = gelenDuyuru!["zaman"] as! Double
                let gelenDuyuruu = Duyuru(postKey:key!, duyuruIcerik: duyuruIcerik, duyuruYapan: duyuruYapan, tarih: tarih)
                self.duyurular.append(gelenDuyuruu)
            }
            self.duyurular.reverse()
            self.tableView.reloadData()
        })
    }
    func tumKullanicilariGetir(){
        ref=Database.database().reference()
        ref?.child("kullanicilar").observe(.value, with: {(snapshot) in
            self.kullanicilar.removeAll()
            for gelen in snapshot.children.allObjects {
                print(snapshot.childrenCount)
                let kullanici = gelen as? DataSnapshot
                let gelenKullanici = kullanici?.value as? NSDictionary
                let key = kullanici?.key
                let kullaniciAd = gelenKullanici!["adSoyad"] as! String
                let gelenKullanicii = Kullanici(id:key!, adSoyad: kullaniciAd, eMail: "")
                self.kullanicilar.append(gelenKullanicii)
            }
            self.kullanicilar.reverse()
            self.collectionView.reloadData()
        })
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*kaç satır*/
        return duyurular.count
    }
    /*tableviewin seçme özelliğini kapatmak için*/
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*satır satır alır*/
        let cell = tableView.dequeueReusableCell(withIdentifier: "DuyurularViewCell") as! DuyurularTableViewCell//cellin daha önce oluşturulup oluşturulmadığını kontrol eder
        ref = Database.database().reference()
        ref?.child("kullanicilar").child(duyurular[indexPath.row].duyuruYapan).observeSingleEvent(of: .value, with: {(snapshot) in
            let kullanici = snapshot.value as? NSDictionary
            cell.cellAdSoyad.text! = (kullanici!["adSoyad"] as? String)!
        })
        
        Database.database().reference().child("begeni").observe(.value, with:{(snapshot) in
            for gelenBegeni in snapshot.children.allObjects {
                let snapGelen = gelenBegeni as? DataSnapshot
                let NSbegeni = snapGelen?.value as? NSDictionary
                let duyuru = NSbegeni?["duyuruId"] as! String
                let begenenKisi = NSbegeni?["kullaniciId"] as! String
                if duyuru == self.duyurular[indexPath.row].postKey{
                    self.begenme = self.begenme + 1
                }
                
            }
            cell.cellBegeniSayisi.text = String(self.begenme)
            self.begenme = 0
        })
        cell.postKey = duyurular[indexPath.row].postKey
        cell.cellMetin.text! = duyurular[indexPath.row].duyuruIcerik
        cell.cellMetin.numberOfLines = 0
        let gelenTarih = timestampCevirme(serverTimestamp: duyurular[indexPath.row].tarih)
        cell.cellTarih.text! = gelenTarih
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return kullanicilar.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell2 = collectionView.dequeueReusableCell(withReuseIdentifier: "KullanicilarCollectionViewCell", for: indexPath) as! KullanicilarCollectionViewCell
        cell2.kullaniciAdi.text = kullanicilar[indexPath.row].adSoyad
        return cell2
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
