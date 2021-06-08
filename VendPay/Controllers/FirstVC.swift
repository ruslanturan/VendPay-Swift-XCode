//
//  FirstViewController.swift
//  VendPay
//
//  Created by Ruslan Cahangirov on 8/11/20.
//  Copyright © 2020 Ruslan Cahangirov. All rights reserved.
//

import UIKit
import Foundation
import FacebookLogin
import FBSDKLoginKit
import AuthenticationServices

class FirstVC: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var lblOr: UILabel!
    @IBOutlet weak var btnFB: UIButton!
    @IBOutlet weak var btnApple: UIButton!
    @IBOutlet weak var btnContact: UIButton!
    @IBOutlet weak var lblHelp: UILabel!
    var screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var error = ""
    var tryAgain = ""
    var alreadyMail = ""
    var passwordChanged = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        let backBtn = UIBarButtonItem()
        backBtn.title = ""
        navigationItem.backBarButtonItem = backBtn
        let lang = UserDefaults.standard.string(forKey: "lang")
        if(lang != nil){
            changeLanguage(str: lang!)
        }
        if !(Reachability.isConnectedToNetwork()){
            let alert = UIAlertController(title: "Connection Failed", message: "Please check the internet connection and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: close))
            self.present(alert, animated: true)
        }
        let logoHeight = (self.screenHeight/5)
        let bounds = self.navigationController!.navigationBar.bounds
        logo.frame = CGRect(x: 0, y: bounds.height + 20, width: self.screenWidth, height: logoHeight)
        scrollView.addSubview(logo)
        btnLogin.frame = CGRect(x: 20, y: logoHeight + 110, width: self.screenWidth - 40, height: 55)
        btnLogin.layer.cornerRadius = 12
        btnLogin.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnLogin.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnLogin.layer.shadowOpacity = 1.0
        btnLogin.layer.shadowRadius = 0.0
        btnLogin.layer.masksToBounds = false
        scrollView.addSubview(btnLogin)
        btnRegister.frame = CGRect(x: 20, y: logoHeight + 185, width: self.screenWidth - 40, height: 55)
        btnRegister.layer.cornerRadius = 12
        btnRegister.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnRegister.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnRegister.layer.shadowOpacity = 1.0
        btnRegister.layer.shadowRadius = 0.0
        btnRegister.layer.masksToBounds = false
        scrollView.addSubview(btnRegister)
        lblOr.frame = CGRect(x: 30, y: logoHeight + 240, width: self.screenWidth - 60, height: 50)
        scrollView.addSubview(lblOr)
        btnFB.frame = CGRect(x: 20, y: logoHeight + 290, width: self.screenWidth - 40, height: 55)
        btnFB.layer.cornerRadius = 12
        btnFB.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnFB.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnFB.layer.shadowOpacity = 1.0
        btnFB.layer.shadowRadius = 0.0
        btnFB.layer.masksToBounds = false
        scrollView.addSubview(btnFB)
        btnApple.frame = CGRect(x: 20, y: logoHeight + 370, width: self.screenWidth - 40, height: 55)
        btnApple.layer.cornerRadius = 12
        btnApple.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnApple.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnApple.layer.shadowOpacity = 1.0
        btnApple.layer.shadowRadius = 0.0
        btnApple.layer.masksToBounds = false
        scrollView.addSubview(btnApple)
        lblHelp.frame = CGRect(x: 0, y: logoHeight + 440, width: self.screenWidth, height: 40)
        scrollView.addSubview(lblHelp)
        btnContact.frame = CGRect(x: 0, y: logoHeight + 470, width: self.screenWidth, height: 40)
        scrollView.addSubview(btnContact)
        scrollView.contentSize = CGSize(width: self.screenWidth, height: self.screenHeight + 80)
        scrollView.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
    }
    @IBAction func registerOnClick(_ sender: Any) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "Register") as! RegisterVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func loginOnClick(_ sender: Any) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "Login") as! LoginVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func fbOnClick(_ sender: Any) {
        fbLogin()
    }
    @IBAction func appleOnClick(_ sender: Any) {
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()
        } else {
        }
    }

    @IBAction func contactOnClick(_ sender: Any) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "ContactFirst") as! ContactFirstVC
        self.navigationController!.pushViewController(vc, animated: true)
    }
    func fbLogin(){
        let loginManager = LoginManager()
        loginManager.logOut()
        loginManager.logIn(permissions:[.publicProfile, .email],viewController: self) {
            loginResult in
            switch loginResult {
            case .failed(let error):
                print (error)
            case .success(_, _, _):
                self.getFbUserData()
            case .cancelled:
                print("canceled")
            }
        }
    }
    func getFbUserData(){
        if((AccessToken.current) != nil){
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).start(completionHandler: {(connection, result, error) -> Void in
                if(error == nil){
                    let dict = result as! [String : AnyObject]
                    print(dict)
                    let pictureDict = dict as NSDictionary
                    var name = pictureDict.object(forKey: "name") as! String
                    name = name.replacingOccurrences(of: " ", with: "")
                    var email = ""
                    if let mail = pictureDict.object(forKey: "email"){
                        email = mail as! String
                    }
                    else {
                        var usrName = name
                        usrName = usrName.replacingOccurrences(of: " ", with: "")
                        email = usrName + "@facebook.com"
                    }
                    DispatchQueue.main.async{
                        [weak self] in
                        self!.userRequest(url: "https://www.vendpay.ge/user/getuser?mail=" + email + "&password=facebook", url2: "https://www.vendpay.ge/user/addUser?username=" + name + "&email=" + email + "&number=0&password=facebook")
                    }
                }
            })
        }
    }
    func userRequest(url: String, url2: String){
        if let myURL = NSURL(string: url) {
            do {
                let myHTMLString = try NSString(contentsOf: myURL as URL, encoding: String.Encoding.utf8.rawValue)
                if (myHTMLString.contains("Error: User not")){
                    DispatchQueue.main.async{
                        [weak self] in
                        self!.userAddRequest(url: url2)
                        return
                    }
                }
                if (myHTMLString.contains("Error: Password")){
                    let alert = UIAlertController(title: error, message: passwordChanged, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: close))
                    self.present(alert, animated: true)
                    return
                }
                if (!myHTMLString.contains("Error: User not") && myHTMLString.contains("Error")){
                    let alert = UIAlertController(title: error, message: tryAgain, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: close))
                    self.present(alert, animated: true)
                    return
                }
                else{
                    UserDefaults.standard.set(myHTMLString, forKey: "logged")
                    let vc = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeVC
                    self.navigationController?.setViewControllers([vc], animated:true)
                }
            } catch {
                print(error)
            }
        }
    }
    func userAddRequest(url: String){
        let myURL = URL(string: url)
        do {
            let myHTMLString = try NSString(contentsOf: myURL!, encoding: String.Encoding.utf8.rawValue)
            if (myHTMLString.contains("Error: Password")){
                let alert = UIAlertController(title: error, message: alreadyMail, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: close))
                self.present(alert, animated: true)
                return
            }
            if (myHTMLString.contains("Error")){
                let alert = UIAlertController(title: error, message: tryAgain, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: close))
                self.present(alert, animated: true)
                return
            }
            else{
                UserDefaults.standard.set("Balane:0.00;" + (myHTMLString as String), forKey: "logged")
                let vc = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeVC
                self.navigationController?.setViewControllers([vc], animated:true)
            }
        }catch {
            print(error)
        }
    }
    func close (action: UIAlertAction){
        exit(-1)
    }
    func changeLanguage(str: String){
        btnLogin.setTitle("login".addLocalizableString(str: str), for: .normal)
        btnRegister.setTitle("register".addLocalizableString(str: str), for: .normal)
        lblOr.text = "or".addLocalizableString(str: str)
        lblHelp.text = "need".addLocalizableString(str: str)
        btnContact.setTitle("contact".addLocalizableString(str: str), for: .normal)
        btnFB.setTitle("continune_fb".addLocalizableString(str: str), for: .normal)
        btnApple.setTitle("continune_apple".addLocalizableString(str: str), for: .normal)
        self.error = "error".addLocalizableString(str: str)
        self.tryAgain = "tryagain".addLocalizableString(str: str)
        self.alreadyMail = "readyMail".addLocalizableString(str: str)
        self.passwordChanged = "tryLogin".addLocalizableString(str: str)

    }
}

extension FirstVC: ASAuthorizationControllerDelegate {
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            let userName = appleIDCredential.fullName?.givenName
            let email = appleIDCredential.email ?? "test"
            print("__" + userName!)
            DispatchQueue.main.async{
                [weak self] in
                self!.userRequest(url: "https://www.vendpay.ge/user/getuser?mail=" + email + "&password=apple", url2: "https://www.vendpay.ge/user/addUser?username=" + userName! + "&email=" + email + "&number=0&password=apple")
            }
        }
    }
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }
}
