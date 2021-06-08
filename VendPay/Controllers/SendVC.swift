//
//  SendViewController.swift
//  VendPay
//
//  Created by Ruslan Cahangirov on 8/12/20.
//  Copyright © 2020 Ruslan Cahangirov. All rights reserved.
//

import UIKit

class SendVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var logo: UIButton!
    @IBOutlet weak var lblID: UILabel!
    @IBOutlet weak var lblBalance: UILabel!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var txtReceiverId: UITextField!
    @IBOutlet weak var txtUnique: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnHelp: UIButton!
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    var loggedId = ""
    var unique = ""
    var error = ""
    var incRecID = ""
    var incAmount = ""
    var noWhitespace = ""
    var noMoney = ""
    var incUnique = ""
    var tryAgain = ""
    var notFound = ""
    var success = ""
    var completed = ""
    var help = ""
    var how = ""
    var complete = ""
    var req = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        if !Reachability.isConnectedToNetwork(){
            let alert = UIAlertController(title: "Connection Failed", message: "Please check the internet connection and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: close))
            self.present(alert, animated: true)
        }
        self.hideKeyboard()
        NotificationCenter.default.addObserver(self, selector: #selector(Keyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Keyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        let defaults = UserDefaults.standard
        let logged = defaults.string(forKey: "logged")
        let loggedID = logged!.split(separator: ";").map(String.init)
        lblID.text = loggedID[1].replacingOccurrences(of: " ", with: "")
        let id = loggedID[1].split(separator: ":").map(String.init)
        loggedId = id[1]
        lblBalance.text = loggedID[0].replacingOccurrences(of: " ", with: "") + " GEL"
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
        txtAmount.frame = CGRect(x: 30, y: logoHeight + 130, width: self.screenWidth - 60, height: 50)
        txtAmount.delegate = self
        scrollView.addSubview(txtAmount)
        txtReceiverId.frame = CGRect(x: 30, y: logoHeight + 200, width: self.screenWidth - 60, height: 50)
        txtReceiverId.delegate = self
        scrollView.addSubview(txtReceiverId)
        txtUnique.frame = CGRect(x: 30, y: logoHeight + 270, width: self.screenWidth - 120, height: 50)
        txtUnique.delegate = self
        txtUnique.isUserInteractionEnabled = false
        scrollView.addSubview(txtUnique)
        btnHelp.frame = CGRect(x: self.screenWidth - 75, y: logoHeight + 275, width: 40, height: 40)
        let image2 = UIImage(named: "warnicon.png")
        btnHelp.setImage(image2, for: .normal)
        btnHelp.imageView?.contentMode = .scaleAspectFit
        scrollView.addSubview(btnHelp)
        btnSend.frame = CGRect(x: 20, y: logoHeight + 350, width: self.screenWidth - 40, height: 55)
        btnSend.layer.cornerRadius = 12
        btnSend.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnSend.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnSend.layer.shadowOpacity = 1.0
        btnSend.layer.shadowRadius = 0.0
        btnSend.layer.masksToBounds = false
        scrollView.addSubview(btnSend)
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
    @IBAction func helpOnClick(_ sender: Any) {
        let alert = UIAlertController(title: how, message: help, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
        self.present(alert, animated: true)
        return
    }
    @IBAction func sendOnClick(_ sender: Any) {
        sendMoney()
    }
    func sendMoney(){
        let buttonTitle = btnSend.title(for: .normal)
        if buttonTitle == req {
            if self.txtReceiverId.text!.count != 6 {
                let alert = UIAlertController(title: error, message: incRecID, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            if self.txtReceiverId.text! == loggedId {
                let alert = UIAlertController(title: error, message: incRecID, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
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
            let balance = lblBalance.text!.split(separator: ":").map(String.init)
            let decimalBalance = Decimal(string: balance[1])
            if decimalAmount > decimalBalance!{
                let alert = UIAlertController(title: error, message: noMoney, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            DispatchQueue.main.async {
                [weak self] in
                let id = self!.loggedId
                let receiverId = self!.txtReceiverId.text!
                let amount = self!.txtAmount.text!
                self!.uniqueRequest(url: "https://www.vendpay.ge/user/create_unique?fromId=" + id + "&toId=" + receiverId + "&amount=" + amount)

            }
        }
        else{
            if(txtUnique.text!.contains(" ")){
                let alert = UIAlertController(title: error, message: noWhitespace, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            if(txtUnique.text!.uppercased() != unique){
                let alert = UIAlertController(title: error, message: incUnique, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            DispatchQueue.main.async {
                [weak self] in
                let id = self!.loggedId
                let amount = self!.txtAmount.text!
                let receiverId = self!.txtReceiverId.text!
                self!.balanceRequest(url: "https://www.vendpay.ge/user/transfer_money?userId=" + id + "&description=Sent%20to%20-%20&amount=" + amount + "&addressId=" + receiverId)
            }
        }
    }
    func uniqueRequest(url: String){
        if let myURL = NSURL(string: url) {
            do {
                let myHTMLString = try NSString(contentsOf: myURL as URL, encoding: String.Encoding.utf8.rawValue)
                if (myHTMLString.contains("Error: user")){
                    let alert = UIAlertController(title: error, message: notFound, preferredStyle: .alert)
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
                    let res = myHTMLString as String
                    let result = res.split(separator: ":").map(String.init)
                    unique = result[1]
                    self.txtAmount.isUserInteractionEnabled = false
                    self.txtReceiverId.isUserInteractionEnabled = false
                    self.txtUnique.isUserInteractionEnabled = true
                    btnSend.setTitle(complete, for: .normal)
                }
            } catch {
                print(error)
            }
        }
    }
    func balanceRequest(url: String){
        if let myURL = NSURL(string: url) {
            do {
                let myHTMLString = try NSString(contentsOf: myURL as URL, encoding: String.Encoding.utf8.rawValue)
                if (myHTMLString.contains("Error")){
                    let alert = UIAlertController(title: error, message: tryAgain, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                else{
                    DispatchQueue.main.async {
                        [weak self] in
                        self!.changeBalanceRequest(url: "https://www.vendpay.ge/user/change_balance?change=minus&userId=" + self!.loggedId + "&amount=" + self!.txtAmount.text!)
                        self!.changeBalanceRequest(url: "https://www.vendpay.ge/user/change_balance?change=plus&userId=" + self!.txtReceiverId.text! + "&amount=" + self!.txtAmount.text!)
                    }
                    let vcHome = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeVC
                    self.navigationController?.setViewControllers([vcHome], animated: true)
                    let alert = UIAlertController(title: success, message: completed, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            } catch {
                print(error)
            }
        }
    }
    func changeBalanceRequest(url: String){
        if let myURL = NSURL(string: url) {
            do {
                let myHTMLString = try NSString(contentsOf: myURL as URL, encoding: String.Encoding.utf8.rawValue)
                if (myHTMLString.contains("Error")){
                    let alert = UIAlertController(title: error, message: tryAgain, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                else{
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
    private func switchBasedNextTextField(_ textField: UITextField) {
        switch textField {
        case self.txtReceiverId:
            self.txtAmount.becomeFirstResponder()
        default:
            self.txtReceiverId.resignFirstResponder()
        }
    }    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField.returnKeyType == .go){
            sendMoney()
        }
        if(textField.returnKeyType == .done){
            self.view.endEditing(true)
        }
        else{
            self.switchBasedNextTextField(textField)
        }
        return true
    }
    func changeLanguage(str: String){
        btnSend.setTitle("reqCode".addLocalizableString(str: str), for: .normal)
        let balance = lblBalance.text!.split(separator: ":").map(String.init)
        lblBalance.text = "balance".addLocalizableString(str: str) + balance[1]
        txtAmount.placeholder = "amount".addLocalizableString(str: str)
        txtReceiverId.placeholder = "receiver".addLocalizableString(str: str)
        txtUnique.placeholder = "unique".addLocalizableString(str: str)
        self.how = "how".addLocalizableString(str: str)
        self.help = "send_receiver".addLocalizableString(str: str)
        self.incRecID = "recID".addLocalizableString(str: str)
        self.incAmount = "incAmount".addLocalizableString(str: str)
        self.noWhitespace = "whitespace".addLocalizableString(str: str)
        self.noMoney = "noMone".addLocalizableString(str: str)
        self.incUnique = "incUnique".addLocalizableString(str: str)
        self.error = "error".addLocalizableString(str: str)
        self.tryAgain = "tryagain".addLocalizableString(str: str)
        self.notFound = "notfound".addLocalizableString(str: str)
        self.success = "success".addLocalizableString(str: str)
        self.completed = "completed".addLocalizableString(str: str)
        self.complete = "complete".addLocalizableString(str: str)
        self.req = "reqCode".addLocalizableString(str: str)
    }
}
