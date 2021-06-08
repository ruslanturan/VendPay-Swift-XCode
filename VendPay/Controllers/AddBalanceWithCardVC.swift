//
//  BalanceViewController.swift
//  VendPay
//
//  Created by Ruslan Cahangirov on 9/18/20.
//  Copyright © 2020 Ruslan Cahangirov. All rights reserved.
//

import UIKit

class AddBalanceWithCardVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var logo: UIButton!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var lblLast: UILabel!
    @IBOutlet weak var lastView: UIView!
    @IBOutlet weak var cardIcon: UIImageView!
    @IBOutlet weak var lblendingWith: UILabel!
    @IBOutlet weak var btnBalance: UIButton!
    @IBOutlet weak var lblOr: UILabel!
    @IBOutlet weak var btnCard: UIButton!
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    var incAmount = ""
    var error = ""
    var tryagain = ""
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
        self.hideKeyboard()
        NotificationCenter.default.addObserver(self, selector: #selector(Keyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Keyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        let lang = UserDefaults.standard.string(forKey: "lang")
        if(lang != nil){
            changeLanguage(str: lang!)
        }
        let logoHeight = (self.screenHeight/5)
        logo.frame = CGRect(x: 0, y: 20, width: self.screenWidth, height: logoHeight)
        let image = UIImage(named: "logo.png")
        logo.setImage(image, for: .normal)
        logo.imageView?.contentMode = .scaleAspectFit
        scrollView.addSubview(logo)
        txtAmount.frame = CGRect(x: 30, y: logoHeight + 50, width: self.screenWidth - 60, height: 50)
        txtAmount.delegate = self
        scrollView.addSubview(txtAmount)
        lblLast.frame = CGRect(x: 40, y: logoHeight + 120, width: self.screenWidth - 60, height: 50)
        scrollView.addSubview(lblLast)
        lastView.frame = CGRect(x: 30, y: logoHeight + 160, width: self.screenWidth - 60, height: 50)
        lastView.layer.cornerRadius = 6
        scrollView.addSubview(lastView)
        cardIcon.frame = CGRect(x: 35, y: logoHeight + 170, width: 51, height: 32)
        scrollView.addSubview(cardIcon)
        lblendingWith.frame = CGRect(x: 100, y: logoHeight + 155, width: (self.screenWidth - 130), height: 60)
        scrollView.addSubview(lblendingWith)
        btnBalance.frame = CGRect(x: 20, y: logoHeight + 250, width: (self.screenWidth - 40), height: 55)
        btnBalance.layer.cornerRadius = 12
        btnBalance.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnBalance.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnBalance.layer.shadowOpacity = 1.0
        btnBalance.layer.shadowRadius = 0.0
        btnBalance.layer.masksToBounds = false
        scrollView.addSubview(btnBalance)
        lblOr.frame = CGRect(x: 0, y: logoHeight + 300, width: self.screenWidth, height: 50)
        scrollView.addSubview(lblOr)
        btnCard.frame = CGRect(x: 20, y: logoHeight + 350, width: (self.screenWidth - 40), height: 55)
        btnCard.layer.cornerRadius = 12
        btnCard.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnCard.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnCard.layer.shadowOpacity = 1.0
        btnCard.layer.shadowRadius = 0.0
        btnCard.layer.masksToBounds = false
        scrollView.addSubview(btnCard)
        scrollView.contentSize = CGSize(width: self.screenWidth, height: self.screenHeight)
        scrollView.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
        let logged = UserDefaults.standard.string(forKey: "logged")
        let loggedID = logged!.split(separator: ";").map(String.init)
        let ID = loggedID[1].split(separator: ":").map(String.init)
        let card = UserDefaults.standard.string(forKey: ID[1] + "card")
        let endIndex = card!.index(card!.startIndex, offsetBy: 18)
        let startIndex = card!.index(card!.startIndex, offsetBy: 14)
        let digits = card?.substring(to: endIndex)
        let lastDigits = digits?.substring(from: startIndex)
        let ending = lblendingWith.text!
        lblendingWith.text = ending + " " + lastDigits!
    }
    @IBAction func logoOnClick(_ sender: Any) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeVC
        self.navigationController?.setViewControllers([vc], animated:true)
    }
    @IBAction func btnBalanceOnClick(_ sender: Any) {
        let amount = txtAmount.text ?? "0"
        let decimalAmount = Decimal(string: amount) ?? 0
        if(amount.contains(".")) || self.txtAmount.text!.count < 1 || decimalAmount < 1{
            let alert = UIAlertController(title: error, message: incAmount, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            let amountDotCounts = amount.split(separator: ".")
            if(amountDotCounts.count > 2){
                let alert = UIAlertController(title: error, message: incAmount, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
        }
        let intAmount = NSDecimalNumber(decimal: (decimalAmount*100)).intValue
        DispatchQueue.main.async {
            [weak self] in
            self!.paymentRequest(url: "https://www.vendpay.ge/user/create_payment?amount=" + String(intAmount))
        }
    }
    @IBAction func btnCardOnClick(_ sender: Any) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "Card") as! AddBalanceVC
        self.navigationController!.pushViewController(vc, animated:true)
    }
    func paymentRequest(url: String){
        if let myURL = NSURL(string: url) {
            do {
                let myHTMLString = try NSString(contentsOf: myURL as URL, encoding: String.Encoding.utf8.rawValue)
                if (!myHTMLString.lowercased.contains("transaction")){
                    let alert = UIAlertController(title: error, message: tryagain, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                else{
                    let vc = storyBoard.instantiateViewController(withIdentifier: "Pay") as! PayVC
                    let res = myHTMLString as String
                    let result = res.split(separator: " ").map(String.init)
                    vc.id = result[1]
                    let logged = UserDefaults.standard.string(forKey: "logged")
                    let loggedID = logged!.split(separator: ";").map(String.init)
                    let ID = loggedID[1].split(separator: ":").map(String.init)
                    let card = UserDefaults.standard.string(forKey: ID[1] + "card")
                    let parts = card!.split(separator: ";").map(String.init)
                    let number = parts[0].split(separator: ":").map(String.init)
                    let month = parts[1].split(separator: ":").map(String.init)
                    let year = parts[2].split(separator: ":").map(String.init)
                    let cvv = parts[3].split(separator: ":").map(String.init)
                    vc.number = number[1]
                    vc.month = month[1]
                    vc.year = year[1]
                    vc.cvv = cvv[1]
                    vc.amount = txtAmount.text!
                    self.navigationController?.setViewControllers([vc], animated:true)
                }
            } catch {
                print(error)
            }
        }
    }
    func close (action: UIAlertAction){
        exit(-1)
    }
    @objc func Keyboard (notification: Notification){
        let userInfo = notification.userInfo!
        let keyboardScreeenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreeenEndFrame, from: view.window)
        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = UIEdgeInsets.zero
        }
        else{
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    func changeLanguage(str: String){
        self.error = "error".addLocalizableString(str: str)
        self.tryagain = "tryagain".addLocalizableString(str: str)
        self.incAmount = "incAmount".addLocalizableString(str: str)
        txtAmount.placeholder = "amount".addLocalizableString(str: str)
        lblLast.text = "last_card".addLocalizableString(str: str)
        lblendingWith.text = "ending".addLocalizableString(str: str)
        btnBalance.setTitle("addbalance".addLocalizableString(str: str), for: .normal)
        lblOr.text = "or".addLocalizableString(str: str)
        btnCard.setTitle("newCard".addLocalizableString(str: str), for: .normal)
    }
}
