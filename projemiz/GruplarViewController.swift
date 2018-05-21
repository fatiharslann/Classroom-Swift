//
//  GruplarViewController.swift
//  projemiz
//
//  Created by fatih on 11.05.2018.
//  Copyright © 2018 fatmadelenn. All rights reserved.
//
import UIKit
import Firebase
import FirebaseAuth
class GruplarViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{
    
    
    
    
    @IBOutlet weak var grupTableView: UITableView!
    var ref:DatabaseReference?
    var kullaniciId:String!
    var grupKey:String!
    var grupID:String!
    var gruplar = [Grup]()
    var temp = 0
    var takip = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        grupTableView.delegate = self
        grupTableView.dataSource = self
        grupTableView.rowHeight = UITableViewAutomaticDimension
        ref = Database.database().reference()
        kullaniciId = Auth.auth().currentUser?.uid
        tumGruplariGetir()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gruplar.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "grupTableCell") as! GrupTableViewCell
        cell.grupAdi.text = gruplar[indexPath.row].grupAdi
        ref?.child("kullanicilar").child(gruplar[indexPath.row].olusturan).observeSingleEvent(of: .value, with: {(snapshot) in
            let kullanici = snapshot.value as? NSDictionary
            cell.kullaniciAdi.text! = (kullanici!["adSoyad"] as? String)!
        })
        cell.tarih.text = timestampCevirme(serverTimestamp: gruplar[indexPath.row].zaman)
        cell.grupId = gruplar[indexPath.row].id
        if self.temp == 0 {
            /*ref?.child("grupTakip").observe(.value, with: {(snapshot) in
                for gelen in snapshot.children.allObjects {
                    let takip = gelen as? DataSnapshot
                    let gelenTakip = takip?.value as? NSDictionary
                    let gelenGrupId = gelenTakip!["grupId"] as! String
                    let gelenKullaniciId = gelenTakip!["kullaniciId"] as! String
                    if self.gruplar[indexPath.row].id == gelenGrupId && self.kullaniciId == gelenKullaniciId {
                        cell.btnTakipEt.isHidden = true
                    }
                }
                
            })*/
            cell.btnTakipEt.isHidden = false
        }else{
            cell.btnTakipEt.isHidden = true
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.grupID = gruplar[indexPath.row].id
        self.performSegue(withIdentifier: "grupAyrinti", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "grupAyrinti" {
            let idGonder = segue.destination as! GrupAyrintiViewController
            idGonder.grupID = self.grupID
        }
    }
    
    @IBAction func segmentControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            tumGruplariGetir()
            self.temp = 0
            break
        case 1:
            self.temp = 1
            takipEttiklerimiGetir()
            break
        default:
            break
        }
    }
    func tumGruplariGetir()  {
        self.ref?.child("gruplar").observe(.value, with: {(snapshot) in
            self.gruplar.removeAll()
            for gelen in snapshot.children.allObjects{
                let grup = gelen as? DataSnapshot
                let grupId = grup?.key as! String
                let gelenGrup = grup?.value as? NSDictionary
                let grupAdi = gelenGrup!["grupAdi"] as! String
                let grupKuran = gelenGrup!["grupOlusturanId"] as! String
                let tarih = gelenGrup!["zaman"] as! Double
                
                Database.database().reference().child("grupTakip").observe(.value, with: {(snapshot) in
                    self.takip = false
                    for gelenTakip in snapshot.children.allObjects{
                        let grupTakip = gelenTakip as? DataSnapshot
                        let gelenGrupTakip = grupTakip?.value as? NSDictionary
                        let grupIdTakip = gelenGrupTakip!["grupId"] as! String
                        let kullaniciIdTakip = gelenGrupTakip!["kullaniciId"] as! String
                        if self.kullaniciId == kullaniciIdTakip && grupId == grupIdTakip{
                            self.takip = true
                            break
                        }
                        
                    }
                    print(self.takip)
                    if !self.takip{
                        let yeniGrup = Grup(id: grupId, grupAdi: grupAdi, olusturan: grupKuran, zaman: tarih)
                        self.gruplar.append(yeniGrup)
                        self.grupTableView.reloadData()
                    }
                })
                
                
                
            }
            
            self.grupTableView.reloadData()
        })
    }
    /*func tumGruplariGetir()  {
        self.ref?.child("gruplar").observe(.value, with: {(snapshot) in
            self.gruplar.removeAll()
            for gelen in snapshot.children.allObjects{
                let grup = gelen as? DataSnapshot
                let grupId = grup?.key as! String
                let gelenGrup = grup?.value as? NSDictionary
                let grupAdi = gelenGrup!["grupAdi"] as! String
                let grupKuran = gelenGrup!["grupOlusturanId"] as! String
                let tarih = gelenGrup!["zaman"] as! Double
                let yeniGrup = Grup(id: grupId, grupAdi: grupAdi, olusturan: grupKuran, zaman: tarih)
                self.gruplar.append(yeniGrup)
            }
            
            self.grupTableView.reloadData()
        })
    }*/
    func takipEttiklerimiGetir()  {
        self.gruplar.removeAll()
        self.grupTableView.reloadData()
        ref?.child("grupTakip").observe(.value, with: {(snapshot) in
            self.gruplar.removeAll()
            for gelen in snapshot.children.allObjects {
                let takip = gelen as? DataSnapshot
                let gelenTakip = takip?.value as? NSDictionary
                let gelenGrupId = gelenTakip!["grupId"] as! String
                let gelenKullaniciId = gelenTakip!["kullaniciId"] as! String
                if self.kullaniciId == gelenKullaniciId {
                    self.ref?.child("gruplar").child(gelenGrupId).observe(.value, with: {(snapshot) in
                            let gelenGrup = snapshot.value as? NSDictionary
                            let grupAdi = gelenGrup!["grupAdi"] as! String
                            let grupKuran = gelenGrup!["grupOlusturanId"] as! String
                            let tarih = gelenGrup!["zaman"] as! Double
                            let yeniGrup = Grup(id: gelenGrupId, grupAdi: grupAdi, olusturan: grupKuran, zaman: tarih)
                            self.gruplar.append(yeniGrup)
                            self.grupTableView.reloadData()
                    })
                }
                
            }
            
        })
    }
    @IBAction func grupEkle(_ sender: Any) {
        let alert = UIAlertController(title: "Grup oluştur",
                                      message: "",
                                      preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Ekle", style: .default, handler: { (action) -> Void in
            let textField = alert.textFields![0]
            if textField.text! != ""{
                self.grupKey = self.ref?.child("gruplar").childByAutoId().key
                self.ref?.child("gruplar").child(self.grupKey).setValue(["grupAdi": textField.text!,                                                                            "grupOlusturanId": self.kullaniciId,"zaman" : [".sv": "timestamp"]])
                self.hataMesaji(title: "Başarılı!", message: "Oluşturduğunuz Grup Başarıyla eklenmiştir...")
            }
        })
        let cancel = UIAlertAction(title: "İptal", style: .destructive, handler: { (action) -> Void in })
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "Grup adını yazınız..."
            textField.clearButtonMode = .whileEditing
        }
        // Add action buttons and present the Alert
        alert.addAction(submitAction)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
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
    func hataMesaji(title:String,message:String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Tamam", style: .default, handler: { (action) -> Void in
            self.tumGruplariGetir()
            
        })
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }

    
    
}

