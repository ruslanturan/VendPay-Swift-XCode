//
//  MenuViewController.swift
//  VendPay
//
//  Created by Ruslan Cahangirov on 9/17/20.
//  Copyright © 2020 Ruslan Cahangirov. All rights reserved.
//

import UIKit

class MenuVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var logo: UIButton!
    @IBOutlet weak var btnAccount: UIButton!
    @IBOutlet weak var btnBalance: UIButton!
    @IBOutlet weak var btnTransfer: UIButton!
    @IBOutlet weak var btnTransaction: UIButton!
    @IBOutlet weak var btnLang: UIButton!
    @IBOutlet weak var btnContact: UIButton!
    @IBOutlet weak var btnLogout: UIButton!
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    override func viewDidLoad() {
        super.viewDidLoad()
        if !Reachability.isConnectedToNetwork(){
            let alert = UIAlertController(title: "Connection Failed", message: "Please check the internet connection and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: close))
            self.present(alert, animated: true)
        }
        let backBtn = UIBarButtonItem()
        backBtn.title = ""
        navigationItem.backBarButtonItem = backBtn
        let logoHeight = (self.screenHeight/5)
        logo.frame = CGRect(x: 0, y: 20, width: self.screenWidth, height: logoHeight)
        let image = UIImage(named: "logo.png")
        logo.setImage(image, for: .normal)
        logo.imageView?.contentMode = .scaleAspectFit
        scrollView.addSubview(logo)
        btnAccount.frame = CGRect(x: 20, y: logoHeight + 20, width: self.screenWidth - 40, height: 55)
        btnAccount.layer.cornerRadius = 12
        btnAccount.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnAccount.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnAccount.layer.shadowOpacity = 1.0
        btnAccount.layer.shadowRadius = 0.0
        btnAccount.layer.masksToBounds = false
        scrollView.addSubview(btnAccount)
        btnBalance.frame = CGRect(x: 20, y: logoHeight + 90, width: self.screenWidth - 40, height: 55)
        btnBalance.layer.cornerRadius = 12
        btnBalance.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnBalance.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnBalance.layer.shadowOpacity = 1.0
        btnBalance.layer.shadowRadius = 0.0
        btnBalance.layer.masksToBounds = false
        scrollView.addSubview(btnBalance)
        btnTransfer.frame = CGRect(x: 20, y: logoHeight + 160, width: self.screenWidth - 40, height: 55)
        btnTransfer.layer.cornerRadius = 12
        btnTransfer.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnTransfer.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnTransfer.layer.shadowOpacity = 1.0
        btnTransfer.layer.shadowRadius = 0.0
        btnTransfer.layer.masksToBounds = false
        scrollView.addSubview(btnTransfer)
        btnTransaction.frame = CGRect(x: 20, y: logoHeight + 230, width: self.screenWidth - 40, height: 55)
        btnTransaction.layer.cornerRadius = 12
        btnTransaction.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnTransaction.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnTransaction.layer.shadowOpacity = 1.0
        btnTransaction.layer.shadowRadius = 0.0
        btnTransaction.layer.masksToBounds = false
        scrollView.addSubview(btnTransaction)
        btnLang.frame = CGRect(x: 20, y: logoHeight + 300, width: self.screenWidth - 40, height: 55)
        btnLang.layer.cornerRadius = 12
        btnLang.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnLang.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnLang.layer.shadowOpacity = 1.0
        btnLang.layer.shadowRadius = 0.0
        btnLang.layer.masksToBounds = false
        scrollView.addSubview(btnLang)
        btnContact.frame = CGRect(x: 20, y: logoHeight + 370, width: self.screenWidth - 40, height: 55)
        btnContact.layer.cornerRadius = 12
        btnContact.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnContact.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnContact.layer.shadowOpacity = 1.0
        btnContact.layer.shadowRadius = 0.0
        btnContact.layer.masksToBounds = false
        scrollView.addSubview(btnContact)
        btnLogout.frame = CGRect(x: 20, y: logoHeight + 440, width: self.screenWidth - 40, height: 55)
        btnLogout.layer.cornerRadius = 12
        btnLogout.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnLogout.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnLogout.layer.shadowOpacity = 1.0
        btnLogout.layer.shadowRadius = 0.0
        btnLogout.layer.masksToBounds = false
        scrollView.addSubview(btnLogout)
        scrollView.contentSize = CGSize(width: self.screenWidth, height: self.screenHeight + 60)
        scrollView.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
        let lang = UserDefaults.standard.string(forKey: "lang")
        if(lang != nil){
            changeLanguage(str: lang!)
        }
    }
    @IBAction func logoOnClick(_ sender: Any) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeVC
        self.navigationController?.setViewControllers([vc], animated:true)
    }
    @IBAction func accountOnClick(_ sender: Any) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "Account") as! AccountVC
        self.navigationController!.pushViewController(vc, animated:true)
    }
    @IBAction func balanceOnclick(_ sender: Any) {
        let logged = UserDefaults.standard.string(forKey: "logged")
        let loggedID = logged!.split(separator: ";").map(String.init)
        let ID = loggedID[1].split(separator: ":").map(String.init)
        let card = UserDefaults.standard.string(forKey: ID[1] + "card") ?? ""
        if card.contains("n"){
            let vc = storyBoard.instantiateViewController(withIdentifier: "Balance") as! AddBalanceWithCardVC
            self.navigationController!.pushViewController(vc, animated:true)
        }
        else{
            let vc = storyBoard.instantiateViewController(withIdentifier: "Card") as! AddBalanceVC
            self.navigationController!.pushViewController(vc, animated:true)
        }
    }
    @IBAction func transferOnClick(_ sender: Any) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "Transfer") as! TransferVC
        self.navigationController!.pushViewController(vc, animated:true)
    }
    @IBAction func transactionOnClick(_ sender: Any) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "Transaction") as! TransactionVC
        self.navigationController!.pushViewController(vc, animated:true)
    }
    @IBAction func langOnClick(_ sender: Any) {
        let lang = btnLang.titleLabel?.text
        if (lang?.contains("hange"))!{
            UserDefaults.standard.set("ka", forKey: "lang")
        }
        else{
            UserDefaults.standard.set("en", forKey: "lang")
        }
        let vc = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeVC
        self.navigationController?.setViewControllers([vc], animated:true)
    }
    @IBAction func contactOnClick(_ sender: Any) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "ContactHome") as! ContactHomeVC
        self.navigationController!.pushViewController(vc, animated: true)
    }
    @IBAction func logoutOnClick(_ sender: Any) {
        UserDefaults.standard.set("", forKey: "logged")
        let vc = storyBoard.instantiateViewController(withIdentifier: "Language") as! LanguageVC
        self.navigationController?.setViewControllers([vc], animated:true)
    }
    func close (action: UIAlertAction){
        exit(-1)
    }
    func changeLanguage(str: String){
        btnAccount.setTitle("account".addLocalizableString(str: str), for: .normal)
        btnBalance.setTitle("addbalance".addLocalizableString(str: str), for: .normal)
        btnTransfer.setTitle("transfer".addLocalizableString(str: str), for: .normal)
        btnTransaction.setTitle("transaction".addLocalizableString(str: str), for: .normal)
        btnLang.setTitle("lang".addLocalizableString(str: str), for: .normal)
        btnContact.setTitle("contact".addLocalizableString(str: str), for: .normal)
        btnLogout.setTitle("logout".addLocalizableString(str: str), for: .normal)
    }
}
extension String{
    func addLocalizableString(str: String) -> String{
        let path = Bundle.main.path(forResource: str, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value:"", comment: "")
    }
}
