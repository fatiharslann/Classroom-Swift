//
//  UyeOlController.swift
//  projemiz
//
//  Created by fatmadelenn on 4.05.2018.
//  Copyright © 2018 fatmadelenn. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
class UyeOlController: UIViewController {
    @IBOutlet weak var degisken: UITextField!
    @IBOutlet weak var rutbe: UISegmentedControl!
    @IBOutlet weak var sifreTekrar: UITextField!
    @IBOutlet weak var sifre: UITextField!
    @IBOutlet weak var kullaniciAdi: UITextField!
    @IBOutlet weak var adSoyad: UITextField!
    
    var ref:DatabaseReference?
    var rutbeAdi = "Öğrenci"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "uyeBackground")!)
        ref=Database.database().reference()
        self.sifre.isSecureTextEntry = true
        self.sifreTekrar.isSecureTextEntry  = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func uyeOl(_ sender: Any) {
        
        if self.adSoyad.text! != "" || self.kullaniciAdi.text! != "" || self.sifre.text! != "" || self.sifreTekrar.text! != "" {
             if self.sifre.text!==self.sifreTekrar.text!{
                Auth.auth().createUser(withEmail: self.kullaniciAdi.text!, password: self.sifre.text!) { (user, error) in
                    if error == nil {

                                self.ref=self.ref?.child("kullanicilar/"+(user?.uid)!+"/")
                        
                        let user = [ "adSoyad" : self.adSoyad.text!, "rutbe":self.rutbeAdi, "degisken":self.degisken.text!, "eMail":self.kullaniciAdi.text!]
                                self.ref?.setValue(user)
                                self.hataMesaji2(title: "Başarılı", message: "Kaydınız tamamlandı.")
                    }else{
                        self.hataMesaji1(title: "Hata", message: "Kayıt başarısız")
                    }
                    
                    
                    
                    
                }
            }else{
                self.hataMesaji1(title: "Hata", message: "Şifreler uyumsuz!")
            }
        }else{
            self.hataMesaji1(title: "Hata", message: "Boş alan bırakmayınız!")
        }
    }
    @IBAction func segmentControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:do {
            self.degisken.attributedPlaceholder=NSAttributedString(string: "Sınıf",                                                       attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
            self.rutbeAdi = "Öğrenci"
            break
            
            }
        case 1:do {
            self.degisken.attributedPlaceholder=NSAttributedString(string: "Kadro Ünvanı",attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
            self.rutbeAdi = "Akademisyen"
            break
            
            }
        default:
            break
        }
        
    }
    func hataMesaji1(title:String,message:String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Tamam", style: .cancel, handler: nil)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
    func hataMesaji2(title:String,message:String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Tamam", style: .cancel, handler: { (action) -> Void in
            self.performSegue(withIdentifier: "uyeGiris", sender: nil)
        })
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }

}
