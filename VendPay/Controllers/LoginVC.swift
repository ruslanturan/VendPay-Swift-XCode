//
//  LoginViewController.swift
//  VendPay
//
//  Created by Ruslan Cahangirov on 8/6/20.
//  Copyright © 2020 Ruslan Cahangirov. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration

extension UIViewController{
    func hideKeyboard() {
        let Tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(Tap)
        
    }
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    public class Reachability {
        class func isConnectedToNetwork() -> Bool {
            var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
            zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
            zeroAddress.sin_family = sa_family_t(AF_INET)
            let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                    SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
                }
            }
            var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
            if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
                return false
            }
            // Working for Cellular and WIFI
            let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
            let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
            let ret = (isReachable && !needsConnection)
            return ret
        }
    }
}

class LoginVC: UIViewController, UITextFieldDelegate{
    @IBOutlet weak var txtPass: UITextField!
    @IBOutlet weak var txtMail: UITextField!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var btnForgot: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var logo: UIButton!
    @IBOutlet weak var checbox: UISwitch!
    @IBOutlet weak var rememberMe: UILabel!
    var screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var incMail = ""
    var error = ""
    var incPass = ""
    var tryAgain = ""
    var notfound = ""
    var noWhitespace = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        let backBtn = UIBarButtonItem()
        backBtn.title = ""
        navigationItem.backBarButtonItem = backBtn
        let lang = UserDefaults.standard.string(forKey: "lang")
        if(lang != nil){
            changeLanguage(str: lang!)
        }
        self.hideKeyboard()
        txtMail.delegate = self
        txtPass.delegate = self
        if !Reachability.isConnectedToNetwork(){
            let alert = UIAlertController(title: "Connection Failed", message: "Please check the internet connection and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: close))
            self.present(alert, animated: true)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(Keyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Keyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        let logoHeight = (self.screenHeight/5)
        logo.frame = CGRect(x: 0, y: 20, width: self.screenWidth, height: logoHeight)
        let image = UIImage(named: "logo.png")
        logo.setImage(image, for: .normal)
        logo.imageView?.contentMode = .scaleAspectFit
        scrollView.addSubview(logo)
        txtMail.frame = CGRect(x: 30, y: logoHeight + 50, width: self.screenWidth - 60, height: 50)
        scrollView.addSubview(txtMail)
        txtPass.frame = CGRect(x: 30, y: logoHeight + 130, width: self.screenWidth - 60, height: 50)
        scrollView.addSubview(txtPass)
        checbox.frame = CGRect(x: 50, y: logoHeight + 190, width: 60, height: 50)
        scrollView.addSubview(checbox)
        rememberMe.frame = CGRect(x: 120, y: logoHeight + 180, width: self.screenWidth - 120, height: 50)
        scrollView.addSubview(rememberMe)
        btnLogin.frame = CGRect(x: 20, y: logoHeight + 250, width: self.screenWidth - 40, height: 55)
        btnLogin.layer.cornerRadius = 12
        btnLogin.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnLogin.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnLogin.layer.shadowOpacity = 1.0
        btnLogin.layer.shadowRadius = 0.0
        btnLogin.layer.masksToBounds = false
        scrollView.addSubview(btnLogin)
        btnForgot.frame = CGRect(x: 60, y: logoHeight + 310, width: self.screenWidth - 120, height: 30)
        scrollView.addSubview(btnForgot)
        scrollView.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
        scrollView.contentSize = CGSize(width: self.screenWidth, height: self.screenHeight)
        let credentials = UserDefaults.standard.string(forKey: "credentials") ?? ""
        if(credentials.contains(";")){
            let credentialsArr = credentials.components(separatedBy: ";")
            txtMail.text = credentialsArr[0]
            txtPass.text = credentialsArr[1]
        }else{
            txtMail.text = ""
            txtPass.text = ""
        }
    }
    @IBAction func logoOnClick(_ sender: Any) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "First") as! FirstVC
        self.navigationController?.setViewControllers([vc], animated:true)
    }
    @IBAction func loginOnClick(_ sender: Any) {
        login()
    }
    @IBAction func forgotOnClick(_ sender: Any) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "ForgotPassword") as! ForgotPasswordVC
        self.navigationController!.pushViewController(vc, animated: true)
    }
    func login(){
        if !(self.txtMail.text!.contains("@")) || !(self.txtMail.text!.contains(".")) || self.txtMail.text!.count < 5 {
            let alert = UIAlertController(title: error, message: incMail, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        if self.txtPass.text!.count < 1 {
            let alert = UIAlertController(title: error, message: incPass, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        if self.txtPass.text!.contains(" ") || (self.txtMail.text!.contains(" ")) {
            let alert = UIAlertController(title: error, message: noWhitespace, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        let mail = txtMail.text
        let pass = txtPass.text
        DispatchQueue.main.async {
            [weak self] in
            self!.userRequest(url: "https://www.vendpay.ge/user/getuser?mail=" + mail! + "&password=" + pass!)
        }
    }
    func userRequest(url: String){
        if let myURL = NSURL(string: url) {
            do {
                let myHTMLString = try NSString(contentsOf: myURL as URL, encoding: String.Encoding.utf8.rawValue)
                if (myHTMLString.contains("Error: User")){
                    let alert = UIAlertController(title: error, message: notfound, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                if (myHTMLString.contains("Error: Password")){
                    let alert = UIAlertController(title: error, message: incPass, preferredStyle: .alert)
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
                if (myHTMLString.contains("Balance")){
                    UserDefaults.standard.set(myHTMLString, forKey: "logged")
                    if(checbox.isOn){
                        UserDefaults.standard.set(txtMail.text! + ";" + txtPass.text!, forKey: "credentials")
                    }
                    else{
                        UserDefaults.standard.set("", forKey: "credentials")
                    }
                    let vc = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeVC
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
    private func switchBasedNextTextField(_ textField: UITextField) {
        switch textField {
        case self.txtMail:
            self.txtPass.becomeFirstResponder()
        default:
            self.txtMail.resignFirstResponder()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField.returnKeyType == .go){
            login()
        }
        else{
            self.switchBasedNextTextField(textField)
        }
        return true
    }
    func changeLanguage(str: String){
        btnLogin.setTitle("login".addLocalizableString(str: str), for: .normal)
        btnForgot.setTitle("forgot".addLocalizableString(str: str), for: .normal)
        txtMail.placeholder = "mail".addLocalizableString(str: str)
        txtPass.placeholder = "pass".addLocalizableString(str: str)
        rememberMe.text = "remember".addLocalizableString(str: str)
        self.incMail = "incMail".addLocalizableString(str: str)
        self.incPass = "incPass".addLocalizableString(str: str)
        self.tryAgain = "tryagain".addLocalizableString(str: str)
        self.notfound = "notfound".addLocalizableString(str: str)
        self.error = "error".addLocalizableString(str: str)
        self.noWhitespace = "whitespace".addLocalizableString(str: str)
    }
}
