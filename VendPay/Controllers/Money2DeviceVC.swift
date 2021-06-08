//
//  MoneyViewController.swift
//  VendPay
//
//  Created by Ruslan Cahangirov on 2/8/21.
//  Copyright © 2021 Ruslan Cahangirov. All rights reserved.
//

import UIKit

class Money2DeviceVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var logo: UIButton!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    var vendName: String = ""
    var loggedId: String = ""
    var amount: String = ""
    var minimumAmount: String = ""
    var amountForDevice = 0
    var error: String = ""
    var noMoney: String = ""
    var warning: String = ""
    var sending: String = ""
    var confirm: String = ""
    var incAmount: String = ""
    var success: String = ""
    var completed: String = ""
    var tryAgain: String = ""
    var wrongQR: String = ""
    var busyMachine: String = ""
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
        let lang = UserDefaults.standard.string(forKey: "lang")
        if(lang != nil){
            changeLanguage(str: lang!)
        }
        self.hideKeyboard()
        NotificationCenter.default.addObserver(self, selector: #selector(Keyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Keyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        let logoHeight = (self.screenHeight/5)
        logo.frame = CGRect(x: 0, y: 20, width: self.screenWidth, height: logoHeight)
        let image = UIImage(named: "logo.png")
        logo.setImage(image, for: .normal)
        logo.imageView?.contentMode = .scaleAspectFit
        scrollView.addSubview(logo)
        txtAmount.frame = CGRect(x: 30, y: logoHeight + 100, width: self.screenWidth - 60, height: 50)
        scrollView.addSubview(txtAmount)
        btnSend.frame = CGRect(x: 20, y: logoHeight + 220, width: self.screenWidth - 40, height: 55)
        btnSend.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnSend.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnSend.layer.shadowOpacity = 1.0
        btnSend.layer.shadowRadius = 0.0
        btnSend.layer.masksToBounds = false
        btnSend.layer.cornerRadius = 12
        scrollView.addSubview(btnSend)
        scrollView.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
        self.view.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: self.screenWidth, height: self.screenHeight)
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(image: UIImage(named: "back"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(goBack))
        self.navigationItem.leftBarButtonItem = newBackButton
        self.navigationItem.leftBarButtonItem!.imageInsets = UIEdgeInsets(top: 0, left: -130, bottom: 0, right: 0)
    }
    @IBAction func logoOnClick(_ sender: Any) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeVC
        self.navigationController?.setViewControllers([vc], animated:true)
    }
    @IBAction func sendOnClick(_ sender: Any) {
        amount = txtAmount.text!
        if(amount != ""){
            let defaults = UserDefaults.standard
            let logged = defaults.string(forKey: "logged")!.split(separator: ";").map(String.init)
            let ID = logged[1].replacingOccurrences(of: " ", with: "").split(separator: ":").map(String.init)
            loggedId = ID[1]
            let b = logged[0].replacingOccurrences(of: " ", with: "").split(separator: ":").map(String.init)
            let balance = Decimal(string: b[1])
            let amountDecimal = Decimal(string: amount)
            if(amountDecimal! < 0.50){
                let alert = UIAlertController(title: error, message: minimumAmount, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            if(amountDecimal! > balance!){
                let alert = UIAlertController(title: error, message: noMoney, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            else{
                self.amountForDevice = Int(amount)! * 100
                self.machineRequest(url: "https://vendpay.ge/machine/setbalance?name=" + self.vendName + "&amount=" + String(self.amountForDevice) + "&userId=" + self.loggedId)
                let alert = UIAlertController(title: success, message: completed, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: goHome))
                self.present(alert, animated: true)
                return
            }
        }
        else{
            let alert = UIAlertController(title: error, message: incAmount, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
    }

    func goHome (action: UIAlertAction){
        let vcHome = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeVC
        self.navigationController?.setViewControllers([vcHome], animated:true)
    }
    @objc func goBack (action: UIAlertAction){
        let vcHome = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeVC
        self.navigationController?.setViewControllers([vcHome], animated:true)
    }
    func machineRequest(url: String){
        if let myURL = NSURL(string: url) {
            do {
                let myHTMLString = try NSString(contentsOf: myURL as URL, encoding: String.Encoding.utf8.rawValue)
                if (myHTMLString.contains("Error: Machine not ")){
                    let alert = UIAlertController(title: error, message: wrongQR, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                if (myHTMLString.contains("Error: Machine is busy")){
                    let alert = UIAlertController(title: error, message: busyMachine, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                if (myHTMLString.contains("Error")){
                    let alert = UIAlertController(title: error, message: tryAgain, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                else{
                    self.request(url: "https://vendpay.ge/user/change_balance?change=minus&userId=" + self.loggedId + "&amount=" + self.amount)
                    self.request(url: "https://vendpay.ge/user/transfer_money?userId=" + self.loggedId + "&description=Paid%20to%20-%20" + self.vendName + "&amount=" + self.amount + "&addressId=0")
                    self.request(url: "https://vendpay.ge/user/transaction?userId=" + self.loggedId + "&machinename=" + self.vendName + "&amount=" + self.amount)
                }
            } catch {
                print(error)
            }
        }
    }
    func request(url: String){
        if let myURL = NSURL(string: url) {
            do {
                let myHTMLString = try NSString(contentsOf: myURL as URL, encoding: String.Encoding.utf8.rawValue)
                if (myHTMLString.contains("Error")){
                    let alert = UIAlertController(title: error, message: tryAgain, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
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
        txtAmount.placeholder = "amount".addLocalizableString(str: str)
        btnSend.setTitle("send".addLocalizableString(str: str), for: .normal)
        self.error = "error".addLocalizableString(str: str)
        self.noMoney = "noMone".addLocalizableString(str: str)
        self.warning = "warning".addLocalizableString(str: str)
        self.sending = "sending".addLocalizableString(str: str)
        self.confirm = "conf".addLocalizableString(str: str)
        self.incAmount = "incAmount".addLocalizableString(str: str)
        self.minimumAmount = "minimumAmount".addLocalizableString(str: str)
        self.success = "success".addLocalizableString(str: str)
        self.completed = "successfully".addLocalizableString(str: str)
        self.tryAgain = "tryagain".addLocalizableString(str: str)
        self.wrongQR = "wrongQR".addLocalizableString(str: str)
        self.busyMachine = "busyMachine".addLocalizableString(str: str)
    }
}
