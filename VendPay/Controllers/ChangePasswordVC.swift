//
//  ChangePasswordVC.swift
//  VendPay
//
//  Created by Ruslan Cahangirov on 3/5/21.
//  Copyright © 2021 Ruslan Cahangirov. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var logo: UIButton!
    @IBOutlet weak var txtPass: UITextField!
    @IBOutlet weak var txtCPass: UITextField!
    @IBOutlet weak var btnConfirm: UIButton!
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    var error = ""
    var success = ""
    var changed = ""
    var tryAgain = ""
    var incPass = ""
    var noWhitespace = ""
    var notMatch = ""
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
        txtPass.frame = CGRect(x: 30, y: logoHeight + 100, width: self.screenWidth - 60, height: 50)
        txtPass.delegate = self
        scrollView.addSubview(txtPass)
        txtCPass.frame = CGRect(x: 30, y: logoHeight + 170, width: self.screenWidth - 60, height: 50)
        txtCPass.delegate = self
        scrollView.addSubview(txtCPass)
        btnConfirm.frame = CGRect(x: 20, y: logoHeight + 300, width: self.screenWidth - 40, height: 55)
        btnConfirm.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnConfirm.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnConfirm.layer.shadowOpacity = 1.0
        btnConfirm.layer.shadowRadius = 0.0
        btnConfirm.layer.masksToBounds = false
        btnConfirm.layer.cornerRadius = 12
        scrollView.addSubview(btnConfirm)
        scrollView.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
        self.view.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: self.screenWidth, height: self.screenHeight)
    }
    @IBAction func logoOnClick(_ sender: Any) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeVC
        self.navigationController?.setViewControllers([vc], animated:true)
    }
    @IBAction func confirmOnClick(_ sender: Any) {
        changePassword()
    }
    func changePassword(){
        if self.txtPass.text!.contains(" ") || self.txtCPass.text!.contains(" "){
            let alert = UIAlertController(title: error, message: noWhitespace, preferredStyle: .alert)
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
        if self.txtPass.text! != self.txtCPass.text!{
            let alert = UIAlertController(title: error, message: notMatch, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        let logged = UserDefaults.standard.string(forKey: "logged")
        let loggedID = logged!.split(separator: ";").map(String.init)
        let ID = loggedID[1].split(separator: ":").map(String.init)
        DispatchQueue.main.async {
            [weak self] in
            self!.passwordRequest(url: "https://www.vendpay.ge/user/editPassword?id=" + ID[1] + "&password=" + self!.txtPass.text!)
        }
    }
    func passwordRequest(url: String){
        if let myURL = NSURL(string: url) {
            do {
                let myHTMLString = try NSString(contentsOf: myURL as URL, encoding: String.Encoding.utf8.rawValue)
                if (myHTMLString.lowercased.contains("error")){
                    let alert = UIAlertController(title: error, message: tryAgain, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                else{
                    let vc = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeVC
                    self.navigationController?.setViewControllers([vc], animated: true)
                    let alert = UIAlertController(title: success, message: changed, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
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
        case self.txtPass:
            self.txtCPass.becomeFirstResponder()
        default:
            self.txtPass.resignFirstResponder()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField.returnKeyType == .go){
            changePassword()
        }
        else{
            self.switchBasedNextTextField(textField)
        }
        return true
    }
    func changeLanguage(str: String){
        txtPass.placeholder = "newpass".addLocalizableString(str: str)
        txtCPass.placeholder = "confirmpass".addLocalizableString(str: str)
        btnConfirm.setTitle("confirm".addLocalizableString(str: str), for: .normal)
        self.error = "error".addLocalizableString(str: str)
        self.incPass = "incPass".addLocalizableString(str: str)
        self.changed = "changed".addLocalizableString(str: str)
        self.noWhitespace = "whitespace".addLocalizableString(str: str)
        self.success = "success".addLocalizableString(str: str)
        self.tryAgain = "tryagain".addLocalizableString(str: str)
        self.notMatch = "notMatch".addLocalizableString(str: str)
    }
}
