//
//  PassordViewController.swift
//  VendPay
//
//  Created by Ruslan Cahangirov on 8/11/20.
//  Copyright © 2020 Ruslan Cahangirov. All rights reserved.
//

import UIKit
import Foundation

class ForgotPasswordVC: UIViewController , UITextFieldDelegate{

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var logo: UIButton!
    @IBOutlet weak var txtMail: UITextField!
    @IBOutlet weak var txtCode: UITextField!
    @IBOutlet weak var txtPass: UITextField!
    @IBOutlet weak var txtCPass: UITextField!
    @IBOutlet weak var btnChange: UIButton!
    @IBOutlet weak var btnHelp: UIButton!
    var screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var incMail = ""
    var noWhitespace = ""
    var tryAgain = ""
    var incUnique = ""
    var incPass = ""
    var notMatch = ""
    var success = ""
    var changed = ""
    var notFound = ""
    var how = ""
    var help = ""
    var req = ""
    var unique = ""
    var change = ""
    var error = ""
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
        txtMail.frame = CGRect(x: 30, y: logoHeight + 50, width: self.screenWidth - 60, height: 50)
        txtMail.delegate = self
        scrollView.addSubview(txtMail)
        txtCode.frame = CGRect(x: 30, y: logoHeight + 110, width: self.screenWidth - 120, height: 50)
        txtCode.delegate = self
        scrollView.addSubview(txtCode)
        btnHelp.frame = CGRect(x: self.screenWidth - 75, y: logoHeight + 115, width: 40, height: 40)
        let image2 = UIImage(named: "warnicon.png")
        btnHelp.setImage(image2, for: .normal)
        btnHelp.imageView?.contentMode = .scaleAspectFit
        scrollView.addSubview(btnHelp)
        txtPass.frame = CGRect(x: 30, y: logoHeight + 170, width: self.screenWidth - 60, height: 50)
        txtPass.delegate = self
        scrollView.addSubview(txtPass)
        txtCPass.frame = CGRect(x: 30, y: logoHeight + 230, width: self.screenWidth - 60, height: 50)
        txtCPass.delegate = self
        scrollView.addSubview(txtCPass)
        btnChange.frame = CGRect(x: 20, y: logoHeight + 330, width: self.screenWidth - 40, height: 55)
        btnChange.layer.cornerRadius = 12
        btnChange.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnChange.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnChange.layer.shadowOpacity = 1.0
        btnChange.layer.shadowRadius = 0.0
        btnChange.layer.masksToBounds = false
        btnChange.layer.cornerRadius = 12
        scrollView.addSubview(btnChange)
        scrollView.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
        scrollView.contentSize = CGSize(width: self.screenWidth, height: self.screenHeight)
        self.txtCode.isUserInteractionEnabled = false
        self.txtPass.isUserInteractionEnabled = false
        self.txtCPass.isUserInteractionEnabled = false
    }
    @IBAction func logoOnClick(_ sender: Any) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "First") as! FirstVC
        self.navigationController?.setViewControllers([vc], animated:true)
    }
    @IBAction func changeOnClick(_ sender: Any) {
        changePassword()
    }
    @IBAction func helpOnclick(_ sender: Any) {
        let alert = UIAlertController(title: how, message: help, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
        self.present(alert, animated: true)
        return
    }
    func changePassword(){
        let buttonTitle = btnChange.title(for: .normal)
        if buttonTitle == req {
            if !(self.txtMail.text!.contains("@")) || !(self.txtMail.text!.contains(".")) || self.txtMail.text!.count < 5 {
                let alert = UIAlertController(title: error, message: incMail, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            if (self.txtMail.text!.contains(" ")){
                let alert = UIAlertController(title: error, message: noWhitespace, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            DispatchQueue.main.async {
                [weak self] in
                self!.codeRequest(url: "https://www.vendpay.ge/user/check_user?email=" + self!.txtMail.text!)
            }
        }
        else{
            if self.txtPass.text!.contains(" ") || self.txtCPass.text!.contains(" ") || self.txtCode.text!.contains(" "){
                let alert = UIAlertController(title: error, message: noWhitespace, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            if self.txtCode.text!.count != 5 || self.txtCode.text!.uppercased() != unique{
                let alert = UIAlertController(title: error, message: incUnique, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            if self.txtPass.text!.count < 1 || self.txtCPass.text!.count < 1{
                let alert = UIAlertController(title: error, message: incPass, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            if self.txtPass.text! != self.txtCPass.text!{
                let alert = UIAlertController(title: error, message: notMatch, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            let pass = txtPass.text
            DispatchQueue.main.async {
                [weak self] in
                self!.passwordRequest(url: "https://www.vendpay.ge/user/change_password?unique=" + self!.unique + "&password=" + pass!)
            }
        }
    }
    func codeRequest(url: String){
        let myURL = URL(string: url)
        do {
            let myHTMLString = try NSString(contentsOf: myURL!, encoding: String.Encoding.utf8.rawValue)
            if (myHTMLString.contains("Error: User")){
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
                let code = String(myHTMLString).split(separator: ":").map(String.init)
                unique = code[1].uppercased()
                self.txtMail.isUserInteractionEnabled = false
                self.txtCode.isUserInteractionEnabled = true
                self.txtPass.isUserInteractionEnabled = true
                self.txtCPass.isUserInteractionEnabled = true
                btnChange.setTitle(change, for: .normal)
            }
        }catch {
            print(error)
        }
    }
    func passwordRequest(url: String){
        let myURL = URL(string: url)
        do {
            let myHTMLString = try NSString(contentsOf: myURL!, encoding: String.Encoding.utf8.rawValue)
            if (myHTMLString.contains("Error: User")){
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
                let vc = storyBoard.instantiateViewController(withIdentifier: "First") as! FirstVC
                self.navigationController?.setViewControllers([vc], animated: true)
                let alert = UIAlertController(title: success, message: changed, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }catch {
            print(error)
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
        case self.txtCode:
            self.txtPass.becomeFirstResponder()
        case self.txtPass:
            self.txtCPass.becomeFirstResponder()
        default:
            self.txtCode.resignFirstResponder()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField.returnKeyType == .go){
            changePassword()
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
        btnChange.setTitle("reqCode".addLocalizableString(str: str), for: .normal)
        txtCode.placeholder = "unique".addLocalizableString(str: str)
        txtMail.placeholder = "mail".addLocalizableString(str: str)
        txtCPass.placeholder = "confirmpass".addLocalizableString(str: str)
        txtPass.placeholder = "newpass".addLocalizableString(str: str)
        self.incMail = "incMail".addLocalizableString(str: str)
        self.incUnique = "incUnique".addLocalizableString(str: str)
        self.incPass = "incPass".addLocalizableString(str: str)
        self.notMatch = "notMatch".addLocalizableString(str: str)
        self.success = "success".addLocalizableString(str: str)
        self.changed = "changed".addLocalizableString(str: str)
        self.notFound = "notfound".addLocalizableString(str: str)
        self.how = "how".addLocalizableString(str: str)
        self.help = "send_mail".addLocalizableString(str: str)
        self.req = "reqCode".addLocalizableString(str: str)
        self.change = "change".addLocalizableString(str: str)
        self.error = "error".addLocalizableString(str: str)
        self.noWhitespace = "whitespace".addLocalizableString(str: str)
        self.tryAgain = "tryagain".addLocalizableString(str: str)
    }
}
