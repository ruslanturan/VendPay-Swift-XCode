//
//  RegisterViewController.swift
//  VendPay
//
//  Created by Ruslan Cahangirov on 8/6/20.
//  Copyright © 2020 Ruslan Cahangirov. All rights reserved.
//

import UIKit
import Foundation

class RegisterVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var logo: UIButton!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtMail: UITextField!
    @IBOutlet weak var txtPass: UITextField!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var txtConfirmPass: UITextField!
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    var error = ""
    var pleaseUser = ""
    var pleaseMail = ""
    var pleasePass = ""
    var noWhitespace = ""
    var tryAgain = ""
    var alreadyMail = ""
    var notMatch = ""

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
        txtUsername.frame = CGRect(x: 30, y: logoHeight + 40, width: self.screenWidth - 60, height: 50)
        txtUsername.delegate = self
        scrollView.addSubview(txtUsername)
        txtMail.frame = CGRect(x: 30, y: logoHeight + 110, width: self.screenWidth - 60, height: 50)
        txtMail.delegate = self
        scrollView.addSubview(txtMail)
        txtPass.frame = CGRect(x: 30, y: logoHeight + 180, width: self.screenWidth - 60, height: 50)
        txtPass.delegate = self
        scrollView.addSubview(txtPass)
        txtConfirmPass.frame = CGRect(x: 30, y: logoHeight + 250, width: self.screenWidth - 60, height: 50)
        txtConfirmPass.delegate = self
        scrollView.addSubview(txtConfirmPass)
        btnRegister.frame = CGRect(x: 20, y: logoHeight + 350, width: self.screenWidth - 40, height: 55)
        btnRegister.layer.cornerRadius = 12
        btnRegister.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnRegister.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnRegister.layer.shadowOpacity = 1.0
        btnRegister.layer.shadowRadius = 0.0
        btnRegister.layer.masksToBounds = false
        scrollView.addSubview(btnRegister)
        scrollView.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
        scrollView.contentSize = CGSize(width: self.screenWidth, height: self.screenHeight)
    }
    @IBAction func logoOnClick(_ sender: Any) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "First") as! FirstVC
        self.navigationController?.setViewControllers([vc], animated:true)
    }
    @IBAction func registerOnClick(_ sender: Any) {
        register()
    }
    func register(){
        if self.txtUsername.text!.count < 1 {
            let alert = UIAlertController(title: error, message: pleaseUser, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        if !(self.txtMail.text!.contains("@")) || !(self.txtMail.text!.contains(".")) || self.txtMail.text!.count < 5 {
            let alert = UIAlertController(title: error, message: pleaseMail, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        if self.txtPass.text!.count < 1 {
            let alert = UIAlertController(title: error, message: pleasePass, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        if self.txtPass.text! != self.txtConfirmPass.text!{
            let alert = UIAlertController(title: error, message: notMatch, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        if self.txtUsername.text!.contains(" ") || (self.txtMail.text!.contains(" ")) || self.txtPass.text!.contains(" "){
            let alert = UIAlertController(title: error, message: noWhitespace, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        let name = txtUsername.text!
        let mail = txtMail.text!
        let pass = txtPass.text!
        self.userAddRequest(url: "https://www.vendpay.ge/user/addUser?username=" + name + "&email=" + mail + "&number=0&password=" + pass)
    }
    func userAddRequest(url: String){
        let myURL = URL(string: url)
        do {
            let myHTMLString = try NSString(contentsOf: myURL!, encoding: String.Encoding.utf8.rawValue)
            if (myHTMLString.contains("Error: E-mail")){
                let alert = UIAlertController(title: error, message: alreadyMail, preferredStyle: .alert)
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
                UserDefaults.standard.set("Balance:0.00;" + (myHTMLString as String), forKey: "logged")
                let vcHome = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeVC
                self.navigationController?.setViewControllers([vcHome], animated:true)
            }
        }
        catch {
            print(error)
        }
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
        case self.txtUsername:
            self.txtMail.becomeFirstResponder()
        case self.txtMail:
            self.txtPass.becomeFirstResponder()
        case self.txtPass:
            self.txtConfirmPass.becomeFirstResponder()
        default:
            self.txtUsername.resignFirstResponder()
        }
    }
    func close (action: UIAlertAction){
        exit(-1)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField.returnKeyType == .go){
            register()
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
        btnRegister.setTitle("register".addLocalizableString(str: str), for: .normal)
        txtUsername.placeholder = "username".addLocalizableString(str: str)
        txtMail.placeholder = "mail".addLocalizableString(str: str)
        txtPass.placeholder = "pass".addLocalizableString(str: str)
        txtConfirmPass.placeholder = "confirmpass".addLocalizableString(str: str)
        self.pleaseUser = "pleaseUser".addLocalizableString(str: str)
        self.pleaseMail = "pleaseMail".addLocalizableString(str: str)
        self.pleasePass = "pleasePass".addLocalizableString(str: str)
        self.noWhitespace = "whitespace".addLocalizableString(str: str)
        self.error = "error".addLocalizableString(str: str)
        self.tryAgain = "tryagain".addLocalizableString(str: str)
        self.alreadyMail = "readyMail".addLocalizableString(str: str)
        self.notMatch = "notMatch".addLocalizableString(str: str)
    }
}
