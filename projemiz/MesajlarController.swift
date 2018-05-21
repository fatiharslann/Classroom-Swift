//
//  MesajlarController.swift
//  projemiz
//
//  Created by fatmadelenn on 4.05.2018.
//  Copyright © 2018 fatmadelenn. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class MesajlarController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var kisilerTableView: UITableView!
    var kullanicilar = [Kullanici]()
    var ref:DatabaseReference?
    var gonderilecekId = ""
    var gonderilecekAdi = ""
    var gonderilenMesaj = 0
    var mesaj = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.kisilerTableView.delegate = self
        self.kisilerTableView.dataSource = self
        self.kisilerTableView.separatorStyle = .none
        ref = Database.database().reference()
        kisileriGetir()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func kisileriGetir(){
        ref?.child("kullanicilar").observe(.value, with: {(snapshot) in
            self.kullanicilar.removeAll()
            for gelen in snapshot.children.allObjects {
                let kullanici = gelen as? DataSnapshot
                let gelenKullanici = kullanici?.value as? NSDictionary
                let key = kullanici?.key
                let gelenKullaniciAdi = gelenKullanici!["adSoyad"] as! String
                let gelenKullaniciMail = gelenKullanici!["eMail"] as! String
                let yeniKullanici = Kullanici(id: key!, adSoyad: gelenKullaniciAdi, eMail: gelenKullaniciMail)
                self.kullanicilar.append(yeniKullanici)
            }
            self.kullanicilar.reverse()
            self.kisilerTableView.reloadData()
        })
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kullanicilar.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mesajKisiTableViewCell") as! MesajlarTableViewCell
        cell.kullaniciAdi.text = kullanicilar[indexPath.row].adSoyad
        cell.mail.text = kullanicilar[indexPath.row].eMail
        Database.database().reference().child("mesajlar").observe(.value, with:{(snapshot) in
            for gelenmesaj in snapshot.children.allObjects {
                let snapGelen = gelenmesaj as? DataSnapshot
                let NSGelen = snapGelen?.value as? NSDictionary
                let alici = NSGelen?["aliciId"] as! String
                let gonderici = NSGelen?["gondericiId"] as! String
                if Auth.auth().currentUser?.uid == alici && gonderici == self.kullanicilar[indexPath.row].id{
                    self.gonderilenMesaj = self.gonderilenMesaj + 1
                }
                if self.gonderilenMesaj > 0{
                    self.mesaj = true
                }
            }
            if !self.mesaj{
                cell.mesajSayisi.alpha = 0.0
            }
            cell.mesajSayisi.text = String(self.gonderilenMesaj) + " mesajınız var"
            self.gonderilenMesaj = 0
        })
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.gonderilecekId = kullanicilar[indexPath.row].id
        self.gonderilecekAdi = kullanicilar[indexPath.row].adSoyad
        self.performSegue(withIdentifier: "mesajKisi", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mesajKisi" {
            let idGonder = segue.destination as! MesajAtViewController
            idGonder.aliciAdi = self.gonderilecekAdi
            idGonder.aliciId = self.gonderilecekId
        }
    }
    /*üstteki saat olan kısım gizlendi*/
    override var prefersStatusBarHidden: Bool{
        return true
    }
    


}
