//
//  AccountVC.swift
//  VendPay
//
//  Created by Ruslan Cahangirov on 3/4/21.
//  Copyright © 2021 Ruslan Cahangirov. All rights reserved.
//

import UIKit

class AccountVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var logo: UIButton!
    @IBOutlet weak var lblID: UILabel!
    @IBOutlet weak var lblBalance: UILabel!
    @IBOutlet weak var lblMail: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblPayment: UILabel!
    @IBOutlet weak var btnMail: UIButton!
    @IBOutlet weak var btnPhone: UIButton!
    @IBOutlet weak var btnPayment: UIButton!
    @IBOutlet weak var btnPassword: UIButton!
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    var username = ""
    var email = ""
    var phone = ""
    var payMethod = ""
    var ending = ""
    var noCard = ""
    var error = ""
    var tryAgain = ""
    var warning = ""
    var increase = ""
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
        lblID.frame = CGRect(x: 0, y: logoHeight + 30, width: self.screenWidth, height: 30)
        scrollView.addSubview(lblID)
        lblBalance.frame = CGRect(x: 0, y: logoHeight + 70, width: self.screenWidth, height: 30)
        scrollView.addSubview(lblBalance)
        lblMail.frame = CGRect(x: 15, y: logoHeight + 120, width: self.screenWidth - 80, height: 50)
        lblMail.numberOfLines = 0
        scrollView.addSubview(lblMail)
        btnMail.frame = CGRect(x: self.screenWidth - 65, y: logoHeight + 120, width: 45, height: 45)
        let image2 = UIImage(named: "edit.png")
        btnMail.setImage(image2, for: .normal)
        btnMail.imageView?.contentMode = .scaleAspectFit
        btnMail.layer.cornerRadius = 12
        btnMail.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnMail.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnMail.layer.shadowOpacity = 1.0
        btnMail.layer.shadowRadius = 0.0
        btnMail.layer.masksToBounds = false
        scrollView.addSubview(btnMail)
        lblNumber.frame = CGRect(x: 15, y: logoHeight + 200, width: self.screenWidth - 80, height: 50)
        lblNumber.numberOfLines = 0
        scrollView.addSubview(lblNumber)
        btnPhone.frame = CGRect(x: self.screenWidth - 65, y: logoHeight + 200, width: 45, height: 45)
        btnPhone.setImage(image2, for: .normal)
        btnPhone.imageView?.contentMode = .scaleAspectFit
        btnPhone.layer.cornerRadius = 12
        btnPhone.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnPhone.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnPhone.layer.shadowOpacity = 1.0
        btnPhone.layer.shadowRadius = 0.0
        btnPhone.layer.masksToBounds = false
        scrollView.addSubview(btnPhone)
        lblPayment.frame = CGRect(x: 15, y: logoHeight + 280, width: self.screenWidth - 80, height: 50)
        lblPayment.numberOfLines = 0
        scrollView.addSubview(lblPayment)
        btnPayment.frame = CGRect(x: self.screenWidth - 65, y: logoHeight + 280, width: 45, height: 45)
        btnPayment.setImage(image2, for: .normal)
        btnPayment.imageView?.contentMode = .scaleAspectFit
        btnPayment.layer.cornerRadius = 12
        btnPayment.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnPayment.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnPayment.layer.shadowOpacity = 1.0
        btnPayment.layer.shadowRadius = 0.0
        btnPayment.layer.masksToBounds = false
        scrollView.addSubview(btnPayment)
        btnPassword.frame = CGRect(x: 20, y: logoHeight + 360, width: self.screenWidth - 40, height: 55)
        btnPassword.layer.cornerRadius = 12
        btnPassword.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnPassword.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnPassword.layer.shadowOpacity = 1.0
        btnPassword.layer.shadowRadius = 0.0
        btnPassword.layer.masksToBounds = false
        scrollView.addSubview(btnPassword)
        scrollView.contentSize = CGSize(width: self.screenWidth, height: self.screenHeight)
        scrollView.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
        let lang = UserDefaults.standard.string(forKey: "lang")
        if(lang != nil){
            changeLanguage(str: lang!)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let logged = UserDefaults.standard.string(forKey: "logged")
        let loggedID = logged!.split(separator: ";").map(String.init)
        lblID.text = loggedID[1].replacingOccurrences(of: " ", with: "")
        let ID = loggedID[1].split(separator: ":").map(String.init)
        DispatchQueue.main.async {
            [weak self] in
            self!.webRequest(url: "https://www.vendpay.ge/user/account?id=" + ID[1])
        }
        let lang = UserDefaults.standard.string(forKey: "lang")
        if(lang != nil){
            changeLanguage(str: lang!)
        }
    }
    @IBAction func logoOnClick(_ sender: Any) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeVC
        self.navigationController?.setViewControllers([vc], animated:true)
    }
    @IBAction func mailOnClick(_ sender: Any) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "EditMail") as! EditMailVC
        self.navigationController!.pushViewController(vc, animated:true)
    }
    @IBAction func numberOnClick(_ sender: Any) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "EditPhone") as! EditPhoneVC
        vc.comesFrom = "account"
        self.navigationController!.pushViewController(vc, animated:true)
    }
    @IBAction func paymentOnClick(_ sender: Any) {
        let alert = UIAlertController(title: warning, message: increase, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Add Balance", style: .default, handler: goToAddBalance))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    @IBAction func passwordOnClick(_ sender: Any) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "ChangePassword") as! ChangePasswordVC
        self.navigationController!.pushViewController(vc, animated:true)
    }
    func goToAddBalance(action: UIAlertAction){
        let vc = storyBoard.instantiateViewController(withIdentifier: "Card") as! AddBalanceVC
        self.navigationController!.pushViewController(vc, animated:true)
    }
    func webRequest(url: String){
        if let myURL = NSURL(string: url) {
            do {
                let myHTMLString = try NSString(contentsOf: myURL as URL, encoding: String.Encoding.utf8.rawValue)
                if (myHTMLString.lowercased.contains("error")){
                    let vc = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeVC
                    self.navigationController?.setViewControllers([vc], animated: true)

                    let alert = UIAlertController(title: error, message: tryAgain, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                else{
                    let result = String(myHTMLString).split(separator: ";").map(String.init)
                    let name = result[1].split(separator: ":").map(String.init)
                    lblBalance.text = username + ":" + name[1]
                    let mail = result[2].split(separator: ":").map(String.init)
                    lblMail.text = email + ": " + mail[1]
                    let num = result[3].split(separator: ":").map(String.init)
                    lblNumber.text = phone + ": +995" + num[1]
                    let logged = UserDefaults.standard.string(forKey: "logged")
                    let loggedID = logged!.split(separator: ";").map(String.init)
                    let ID = loggedID[1].split(separator: ":").map(String.init)
                    let card = UserDefaults.standard.string(forKey: ID[1] + "card") ?? ""
                    if card.contains("n"){
                        let endIndex = card.index(card.startIndex, offsetBy: 18)
                        let startIndex = card.index(card.startIndex, offsetBy: 14)
                        let digits = card.substring(to: endIndex)
                        let lastDigits = digits.substring(from: startIndex)
                        lblPayment.text = payMethod + ending + " " + lastDigits
                    }
                    else{
                        lblPayment.text = payMethod + noCard
                    }
                    
                }
            } catch {
                print(error)
            }
        }
    }
    func close (action: UIAlertAction){
        exit(-1)
    }
    func changeLanguage(str: String){
        btnPassword.setTitle("change".addLocalizableString(str: str), for: .normal)
        self.username = "username".addLocalizableString(str: str)
        self.email = "mail".addLocalizableString(str: str)
        self.phone = "number".addLocalizableString(str: str)
        self.payMethod = "paymethod".addLocalizableString(str: str)
        self.ending = "ending".addLocalizableString(str: str)
        self.noCard = "nocard".addLocalizableString(str: str)
        self.error = "error".addLocalizableString(str: str)
        self.tryAgain = "tryagain".addLocalizableString(str: str)
        self.warning = "warning".addLocalizableString(str: str)
        self.increase = "increase".addLocalizableString(str: str)
    }
}
