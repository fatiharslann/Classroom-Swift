//
//  MesajAtViewController.swift
//  projemiz
//
//  Created by fatmadelenn on 7.05.2018.
//  Copyright © 2018 fatmadelenn. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
class MesajAtViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    

    
    @IBOutlet weak var mesajText: UITextView!
    @IBOutlet weak var mesajlarTableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    var aliciId = ""
    var aliciAdi = ""
    var gondericiId = ""
    var ref:DatabaseReference?
    var mesajlar = [Mesaj]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mesajlarTableView.dataSource = self
        self.mesajlarTableView.delegate = self
        self.navigationBar.topItem?.title = "ghjk"
        ref = Database.database().reference()
        gondericiId = (Auth.auth().currentUser?.uid)!
        mesajlarTableView.separatorStyle = .none
        self.mesajText!.layer.borderWidth = 1
        mesajText!.layer.borderColor = UIColor.lightGray.cgColor
        mesajlariGetir()
        
    }
    @IBAction func gonder(_ sender: UIButton) {
        if mesajText.text == ""{
            hataMesaji(title: "Hata!", message: "Boş mesaj...")
        }else{
            let mesajId = ref?.child("mesajlar").childByAutoId().key
            ref?.child("mesajlar").child(mesajId!).setValue(["aliciId":self.aliciId,
                                                             "gondericiId":self.gondericiId,
                                                             "mesaj":self.mesajText.text,
                                                             "zaman":[".sv": "timestamp"]])
            self.mesajText.text = ""
            
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mesajlar.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if self.gondericiId == mesajlar[indexPath.row].gondericiId {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "gidenMesaj") as! GidenMesajTableViewCell
            cell1.mesaj.text = mesajlar[indexPath.row].mesaj
            cell1.mesaj.numberOfLines = 0
            cell1.tarih.text = timestampCevirme(serverTimestamp: mesajlar[indexPath.row].zaman)
            return cell1
        }else{
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "gelenMesaj") as! GelenMesajTableViewCell
            cell2.mesaj.text = mesajlar[indexPath.row].mesaj
            cell2.mesaj.numberOfLines = 0
            cell2.tarih.text = timestampCevirme(serverTimestamp: mesajlar[indexPath.row].zaman)
            return cell2
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    func mesajlariGetir()  {
        ref?.child("mesajlar").observe(.value, with: {(snapshot) in
            self.mesajlar.removeAll()
            for gelen in snapshot.children.allObjects {
                let mesaj = gelen as? DataSnapshot
                let gelenMesaj = mesaj?.value as? NSDictionary
                let gelenAliciId = gelenMesaj!["aliciId"] as! String
                let gelenGondericiId = gelenMesaj!["gondericiId"] as! String
                let gelenmesaj = gelenMesaj!["mesaj"] as! String
                let tarih = gelenMesaj!["zaman"] as! Double
                if gelenAliciId == self.aliciId && gelenGondericiId == self.gondericiId {
                    let gelenMesajj = Mesaj(aliciId: self.aliciId, gondericiId: self.gondericiId, mesaj: gelenmesaj, zaman: tarih)
                    self.mesajlar.append(gelenMesajj)
                }else if gelenAliciId == self.gondericiId && gelenGondericiId == self.aliciId {
                    let gelenMesajjj = Mesaj(aliciId: self.gondericiId, gondericiId: self.aliciId, mesaj: gelenmesaj, zaman: tarih)
                    self.mesajlar.append(gelenMesajjj)
                }
                
                
              
            }
            self.mesajlarTableView.reloadData()
            //self.asagiIndir()
        })
    }
    /*üstteki saat olan kısım gizlendi*/
    override var prefersStatusBarHidden: Bool{
        return true
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
    func hataMesaji(title:String,message:String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Tamam", style: .cancel, handler: nil)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
//    func asagiIndir(){
//      DispatchQueue.main.async {
//         let indexPath = IndexPath(row: self.mesajlar.count-1, section: 0)
//      self.mesajlarTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//      }
//}

    

}
