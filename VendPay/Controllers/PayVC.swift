//
//  CodeViewController.swift
//  VendPay
//
//  Created by Ruslan Cahangirov on 9/18/20.
//  Copyright © 2020 Ruslan Cahangirov. All rights reserved.
//

import UIKit
import WebKit

class PayVC: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    var id: String = ""
    var amount: String = ""
    var number: String = ""
    var month: String = ""
    var year: String = ""
    var cvv: String = ""
    var error = ""
    var tryagain = ""
    var success = ""
    var successfully = ""
    var warning = ""
    var saveCard = ""
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
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
        view.backgroundColor = UIColor.white
        let url = URL(string: "https://ecommerce.ufc.ge/ecomm2/ClientHandler?trans_id=" + id)!
        webView.load(URLRequest(url: url))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let lang = UserDefaults.standard.string(forKey: "lang")
        if(lang != nil){
            changeLanguage(str: lang!)
        }
    }
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, cred)
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let urlStr = navigationAction.request.url?.absoluteString {
            if urlStr.lowercased().contains("ecommerce.ufc.ge") || urlStr.lowercased().contains("vendpay"){
                self.webView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                self.view.backgroundColor = UIColor.white
            }
            if urlStr.lowercased().contains("tbc/success"){
                DispatchQueue.main.async{
                    [weak self] in
                    self!.resultRequest(url:"https://www.vendpay.ge/user/payment_result?trans_id=" + self!.id)
                }
            }
            if urlStr.lowercased().contains("tbc/fail"){
                let alert = UIAlertController(title: error, message: tryagain, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: goHome))
                self.present(alert, animated: true)
            }
            else {
                self.webView.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
            }
        }
        decisionHandler(.allow)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
       let jsFunc = " var link = window.location.href; "
        + " if(link.includes('trans_id')){ "
            + " document.getElementById('cardNumber').value = '" + number + "'; "
            + " document.getElementById('expmonth').value = '" + month + "'; "
            + " document.getElementById('expyear').value = '" + year + "'; "
            + " document.getElementById('cvc2').value = '" + cvv + "'; "
            + " document.getElementById('payment-submit').click() }"
        webView.evaluateJavaScript( jsFunc, completionHandler: {( result, error ) in
            if let r = result {
                print(r)
            }
            if let e = error {
                print(e)
            }
        })
    }
    func resultRequest(url: String){
        if let myURL = NSURL(string: url) {
            do {
                let myHTMLString = try NSString(contentsOf: myURL as URL, encoding: String.Encoding.utf8.rawValue)
                if (!myHTMLString.lowercased.contains("ok")){
                    let alert = UIAlertController(title: error, message: tryagain, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: goHome))
                    self.present(alert, animated: true)
                }
                else{
                    let logged = UserDefaults.standard.string(forKey: "logged")
                    let loggedID = logged!.split(separator: ";").map(String.init)
                    let ID = loggedID[1].split(separator: ":").map(String.init)
                    DispatchQueue.main.async{
                        [weak self] in
                        self!.balanceRequest(url: "https://www.vendpay.ge/user/transfer_money?userId=" + ID[1] + "&description=increase&amount=" + self!.amount + "&addressId=0")
                    }
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
                if (myHTMLString.lowercased.contains("error")){
                    let alert = UIAlertController(title: error, message: tryagain, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: goHome))
                    self.present(alert, animated: true)
                }
                else{
                    let logged = UserDefaults.standard.string(forKey: "logged")
                    let loggedID = logged!.split(separator: ";").map(String.init)
                    let ID = loggedID[1].split(separator: ":").map(String.init)
                    self.changeBalanceRequest(url: "https://www.vendpay.ge/user/change_balance?change=plus&userId=" + ID[1] + "&amount=" + amount)
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
                if (myHTMLString.lowercased.contains("error")){
                    let alert = UIAlertController(title: error, message: tryagain, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: goHome))
                    self.present(alert, animated: true)
                }
                else{
                    let card = "n:" + number + ";m:" + month + ";y:" + year + ";c:" + cvv
                    let logged = UserDefaults.standard.string(forKey: "logged")
                    let loggedID = logged!.split(separator: ";").map(String.init)
                    let ID = loggedID[1].split(separator: ":").map(String.init)
                    let savedCard = UserDefaults.standard.string(forKey: ID[1] + "card")
                    if(card != savedCard){
                        let alert = UIAlertController(title: success, message: successfully + ". " + saveCard, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: saveCard))
                        alert.addAction(UIAlertAction(title: "No", style: .default, handler: goHome))
                        self.present(alert, animated: true)
                    }
                    else{
                        let alert2 = UIAlertController(title: success, message: successfully, preferredStyle: .alert)
                        alert2.addAction(UIAlertAction(title: "Ok", style: .default, handler: goHome))
                        self.present(alert2, animated: true)
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    func saveCard (action: UIAlertAction){
        let card = "n:" + number + ";m:" + month + ";y:" + year + ";c:" + cvv
        let logged = UserDefaults.standard.string(forKey: "logged")
        let loggedID = logged!.split(separator: ";").map(String.init)
        let ID = loggedID[1].split(separator: ":").map(String.init)
        UserDefaults.standard.set(card, forKey: ID[1] + "card")
        let vc = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeVC
        self.navigationController?.setViewControllers([vc], animated: true)
    }
    func goHome (action: UIAlertAction){
        let vc = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeVC
        self.navigationController?.setViewControllers([vc], animated: true)
    }
    func close (action: UIAlertAction){
        exit(-1)
    }
    func changeLanguage(str: String){
        self.error = "error".addLocalizableString(str: str)
        self.tryagain = "tryagain".addLocalizableString(str: str)
        self.success = "success".addLocalizableString(str: str)
        self.successfully = "successfully".addLocalizableString(str: str)
        self.warning = "warning".addLocalizableString(str: str)
        self.saveCard = "save_".addLocalizableString(str: str)
    }
}
