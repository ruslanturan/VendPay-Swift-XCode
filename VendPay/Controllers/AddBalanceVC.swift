//
//  CardViewController.swift
//  VendPay
//
//  Created by Ruslan Cahangirov on 9/18/20.
//  Copyright © 2020 Ruslan Cahangirov. All rights reserved.
//

import UIKit

class AddBalanceVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var logo: UIButton!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var txtNumber: UITextField!
    @IBOutlet weak var txtMonth: UITextField!
    @IBOutlet weak var txtYear: UITextField!
    @IBOutlet weak var txtCVV: UITextField!
    @IBOutlet weak var btnAdd: UIButton!
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    var incCardNum = ""
    var incAmount = ""
    var incMonth = ""
    var incYear = ""
    var incCvv = ""
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
        let logoHeight = (self.screenHeight/5)
        logo.frame = CGRect(x: 0, y: 20, width: self.screenWidth, height: logoHeight)
        let image = UIImage(named: "logo.png")
        logo.setImage(image, for: .normal)
        logo.imageView?.contentMode = .scaleAspectFit
        scrollView.addSubview(logo)
        txtAmount.frame = CGRect(x: 30, y: logoHeight + 50, width: self.screenWidth - 60, height: 50)
        txtAmount.delegate = self
        scrollView.addSubview(txtAmount)
        txtNumber.frame = CGRect(x: 30, y: logoHeight + 120, width: self.screenWidth - 60, height: 50)
        txtNumber.delegate = self
        scrollView.addSubview(txtNumber)
        txtMonth.frame = CGRect(x: 40, y: logoHeight + 190, width: (self.screenWidth - 100)/2, height: 50)
        txtMonth.delegate = self
        scrollView.addSubview(txtNumber)
        txtYear.frame = CGRect(x: (self.screenWidth + 20)/2, y: logoHeight + 190, width: (self.screenWidth - 100)/2, height: 50)
        txtYear.delegate = self
        scrollView.addSubview(txtYear)
        txtCVV.frame = CGRect(x: (self.screenWidth - (self.screenWidth - 100)/2)/2, y: logoHeight + 260, width: (self.screenWidth - 100)/2, height: 50)
        txtCVV.delegate = self
        scrollView.addSubview(txtYear)
        btnAdd.frame = CGRect(x: 20, y: logoHeight + 330, width: self.screenWidth - 40, height: 55)
        btnAdd.layer.cornerRadius = 12
        btnAdd.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnAdd.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnAdd.layer.shadowOpacity = 1.0
        btnAdd.layer.shadowRadius = 0.0
        btnAdd.layer.masksToBounds = false
        scrollView.addSubview(btnAdd)
        scrollView.contentSize = CGSize(width: self.screenWidth, height: self.screenHeight)
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
    @IBAction func addOnClick(_ sender: Any) {
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
        if self.txtNumber.text!.count != 16 {
            let alert = UIAlertController(title: error, message: incCardNum, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        let intMonth = Int(txtMonth.text ?? "0")
        if self.txtMonth.text!.count < 0 || intMonth! > 12{
            let alert = UIAlertController(title: error, message: incMonth, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        if(!self.txtMonth.text!.starts(with: "0") && intMonth! < 10){
            self.txtMonth.text = "0" + self.txtMonth.text!
        }
        if self.txtYear.text!.count != 2 {
            let alert = UIAlertController(title: error, message: incYear, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        let year = Calendar.current.component(.year, from: Date())
        let intYear = Int("20" + txtYear.text!)
        if year > intYear! {
            let alert = UIAlertController(title: error, message: incYear, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        if self.txtCVV.text!.count != 3 {
            let alert = UIAlertController(title: error, message: incCvv, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        let intAmount = NSDecimalNumber(decimal: (decimalAmount*100)).intValue
        DispatchQueue.main.async{
            [weak self] in
            self!.payRequest(url: "https://www.vendpay.ge/user/create_payment?amount=" + String(intAmount))
        }
    }
    func payRequest(url: String){
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
                    vc.number = txtNumber.text!
                    vc.month = txtMonth.text!
                    vc.year = txtYear.text!
                    vc.cvv = txtCVV.text!
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
        btnAdd.setTitle("addbalance".addLocalizableString(str: str), for: .normal)
        txtAmount.placeholder = "amount".addLocalizableString(str: str)
        txtNumber.placeholder = "card_number".addLocalizableString(str: str)
        txtMonth.placeholder = "month".addLocalizableString(str: str)
        txtYear.placeholder = "year".addLocalizableString(str: str)
        txtCVV.placeholder = "cvv".addLocalizableString(str: str)
        self.incAmount = "incAmount".addLocalizableString(str: str)
        self.incCardNum = "pleaseCard".addLocalizableString(str: str)
        self.incMonth = "pleaseMonth".addLocalizableString(str: str)
        self.incYear = "pleaseYear".addLocalizableString(str: str)
        self.incCvv = "pleaseCVV".addLocalizableString(str: str)
        self.error = "error".addLocalizableString(str: str)
        self.tryagain = "tryagain".addLocalizableString(str: str)
    }
}
