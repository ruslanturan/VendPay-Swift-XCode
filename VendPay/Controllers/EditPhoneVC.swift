//
//  EditPhoneVC.swift
//  VendPay
//
//  Created by Ruslan Cahangirov on 3/5/21.
//  Copyright © 2021 Ruslan Cahangirov. All rights reserved.
//

import UIKit

class EditPhoneVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var logo: UIButton!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtCode: UITextField!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var btnHelp: UIButton!
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    var comesFrom = ""
    var error = ""
    var incPhone = ""
    var incCode = ""
    var success = ""
    var changed = ""
    var tryAgain = ""
    var alreadyPhone = ""
    var noWhitespace = ""
    var how = ""
    var help = ""
    var req = ""
    var code = ""
    var confirm = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        if !Reachability.isConnectedToNetwork(){
            let alert = UIAlertController(title: "Connection Failed", message: "Please check the internet connection and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: close))
            self.present(alert, animated: true)
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(self.backAction(sender:)))
        self.navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: -130, bottom: 0, right: 0);
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
        txtPhone.frame = CGRect(x: 30, y: logoHeight + 100, width: self.screenWidth - 60, height: 50)
        txtPhone.delegate = self
        scrollView.addSubview(txtPhone)
        txtCode.frame = CGRect(x: 30, y: logoHeight + 170, width: self.screenWidth - 120, height: 50)
        txtCode.delegate = self
        txtCode.isUserInteractionEnabled = false
        scrollView.addSubview(txtCode)
        btnHelp.frame = CGRect(x: self.screenWidth - 75, y: logoHeight + 175, width: 40, height: 40)
        let image2 = UIImage(named: "warnicon.png")
        btnHelp.setImage(image2, for: .normal)
        btnHelp.imageView?.contentMode = .scaleAspectFit
        scrollView.addSubview(btnHelp)
        btnConfirm.frame = CGRect(x: 20, y: logoHeight + 270, width: self.screenWidth - 40, height: 55)
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
        if(self.comesFrom.contains("home")){
            let vc = storyBoard.instantiateViewController(withIdentifier: "First") as! FirstVC
            self.navigationController?.setViewControllers([vc], animated:true)
        }
        else{
            let vc = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeVC
            self.navigationController?.setViewControllers([vc], animated:true)
        }
    }
    @IBAction func helpOnClick(_ sender: Any) {
        let alert = UIAlertController(title: how, message: help, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
        self.present(alert, animated: true)
        return
    }
    @IBAction func confirmOnClick(_ sender: Any) {
        setNumber()
    }
    func setNumber(){
        let buttonTitle = btnConfirm.title(for: .normal)
        if buttonTitle == req {
            if self.txtPhone.text!.count != 9  || !self.txtPhone.text!.starts(with: "5"){
                let alert = UIAlertController(title: error, message: incPhone, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            DispatchQueue.main.async {
                [weak self] in
                self!.code = self!.randomString(length: 4)
                self!.codeRequest(url: "https://www.vendpay.ge/user/verifyphone?Id=1&phone=" + self!.txtPhone.text! + "&code=" + self!.code)
            }
        }
        else{
            if self.txtCode.text!.lowercased() != code.lowercased(){
                let alert = UIAlertController(title: error, message: incCode, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            let logged = UserDefaults.standard.string(forKey: "logged")
            let loggedID = logged!.split(separator: ";").map(String.init)
            let ID = loggedID[1].split(separator: ":").map(String.init)
            DispatchQueue.main.async {
                [weak self] in
                self!.phoneRequest(url: "https://www.vendpay.ge/user/editPhone?id=" + ID[1] + "&phone=" + self!.txtPhone.text!)
            }
        }
    }
    func codeRequest(url: String){
        if let myURL = NSURL(string: url) {
            do {
                let myHTMLString = try NSString(contentsOf: myURL as URL, encoding: String.Encoding.utf8.rawValue)
                if (myHTMLString.lowercased.contains("error: phone")){
                    let alert = UIAlertController(title: error, message: alreadyPhone, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                if (myHTMLString.lowercased.contains("error")){
                    let alert = UIAlertController(title: error, message: tryAgain, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                else{
                    txtCode.isUserInteractionEnabled = true
                    txtPhone.isUserInteractionEnabled = false
                    btnConfirm.setTitle(confirm, for: .normal)
                }
            } catch {
                print(error)
            }
        }
    }
    func phoneRequest(url: String){
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
    func randomString(length: Int) -> String {

        let letters : NSString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)

        var randomString = ""

        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }

        return randomString
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField.returnKeyType == .go){
            setNumber()
        }
        return true
    }
    @objc func backAction(sender: AnyObject) {
        if(self.comesFrom.contains("home")){
            let vc = storyBoard.instantiateViewController(withIdentifier: "First") as! FirstVC
            self.navigationController?.setViewControllers([vc], animated:true)
        }
        else{
            let vc = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeVC
            self.navigationController?.setViewControllers([vc], animated:true)
        }
    }
    
    func changeLanguage(str: String){
        txtPhone.placeholder = "newPhone".addLocalizableString(str: str)
        btnConfirm.setTitle("reqCode".addLocalizableString(str: str), for: .normal)
        self.error = "error".addLocalizableString(str: str)
        self.incPhone = "incPhone".addLocalizableString(str: str)
        self.changed = "phoneChanged".addLocalizableString(str: str)
        self.alreadyPhone = "readyPhone".addLocalizableString(str: str)
        self.noWhitespace = "whitespace".addLocalizableString(str: str)
        self.success = "success".addLocalizableString(str: str)
        self.tryAgain = "tryagain".addLocalizableString(str: str)
        self.how = "how".addLocalizableString(str: str)
        self.help = "send_sms".addLocalizableString(str: str)
        self.req = "reqCode".addLocalizableString(str: str)
        self.confirm = "confirm".addLocalizableString(str: str)
        self.incCode = "incUnique".addLocalizableString(str: str)

    }
}
