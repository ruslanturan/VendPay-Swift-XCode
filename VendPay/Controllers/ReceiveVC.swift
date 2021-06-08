//
//  ReceiveViewController.swift
//  VendPay
//
//  Created by Ruslan Cahangirov on 8/12/20.
//  Copyright © 2020 Ruslan Cahangirov. All rights reserved.
//

import UIKit

class ReceiveVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var logo: UIButton!
    @IBOutlet weak var lblFrom: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblUnique: UILabel!
    @IBOutlet weak var btnRefresh: UIButton!
    var loggedId = ""
    var error = ""
    var tryAgain = ""
    var from = ""
    var code = ""
    var amount = ""
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
        let defaults = UserDefaults.standard
        let logged = defaults.string(forKey: "logged")
        let loggedID = logged!.split(separator: ";").map(String.init)
        let id = loggedID[1].split(separator: ":").map(String.init)
        loggedId = id[1]
        DispatchQueue.main.async {
            [weak self] in
            self!.receiveRequest(url: "https://www.vendpay.ge/user/get_unique?toId=" + self!.loggedId)
        }
        let lang = UserDefaults.standard.string(forKey: "lang")
        if(lang != nil){
            changeLanguage(str: lang!)
        }
        let logoHeight = (self.screenHeight/5)
        logo.frame = CGRect(x: 0, y: 20, width: self.screenWidth, height: logoHeight)
        let image = UIImage(named: "logo.png")
        logo.setImage(image, for: .normal)
        logo.imageView?.contentMode = .scaleAspectFit
        scrollView.addSubview(logo)
        lblFrom.frame = CGRect(x: 0, y: logoHeight + 20, width: self.screenWidth, height: 50)
        scrollView.addSubview(lblFrom)
        lblAmount.frame = CGRect(x: 0, y: logoHeight + 120, width: self.screenWidth, height: 50)
        scrollView.addSubview(lblAmount)
        lblUnique.frame = CGRect(x: 0, y: logoHeight + 220, width: self.screenWidth, height: 50)
        scrollView.addSubview(lblUnique)
        btnRefresh.frame = CGRect(x: 20, y: logoHeight + 320, width: self.screenWidth - 40, height: 55)
        btnRefresh.layer.cornerRadius = 12
        btnRefresh.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnRefresh.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnRefresh.layer.shadowOpacity = 1.0
        btnRefresh.layer.shadowRadius = 0.0
        btnRefresh.layer.masksToBounds = false
        scrollView.addSubview(btnRefresh)
        scrollView.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
    }
    @IBAction func logoOnClick(_ sender: Any) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeVC
        self.navigationController?.setViewControllers([vc], animated:true)
    }
    @IBAction func refreshOnClick(_ sender: Any) {
        DispatchQueue.main.async {
            [weak self] in
            self!.uniqueRequest(url: "https://www.vendpay.ge/user/remove_unique?id=" + self!.loggedId)
        }
        let vc = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeVC
        self.navigationController?.setViewControllers([vc], animated:true)
    }
    func receiveRequest(url: String){
        if let myURL = NSURL(string: url) {
            do {
                let myHTMLString = try NSString(contentsOf: myURL as URL, encoding: String.Encoding.utf8.rawValue)
                if (myHTMLString.contains("Error")){
                    let vc = storyBoard.instantiateViewController(withIdentifier: "Transfer") as! TransferVC
                    self.navigationController?.setViewControllers([vc], animated:true)
                    let alert = UIAlertController(title: error, message: tryAgain, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                else{
                    let result = String(myHTMLString).split(separator: ";").map(String.init)
                    let fr = result[0].split(separator: ":").map(String.init)
                    lblFrom.text = from + fr[1]
                    let am = result[1].split(separator: ":").map(String.init)
                    lblAmount.text = amount + am[1] + " GEL"
                    let uni = result[2].split(separator: ":").map(String.init)
                    lblUnique.text = code + ":" + uni[1]
                }
            } catch {
                print(error)
            }
        }
    }
    func uniqueRequest(url: String){
        if let myURL = NSURL(string: url) {
            do {
                _ = try NSString(contentsOf: myURL as URL, encoding: String.Encoding.utf8.rawValue)
            } catch {
                print(error)
            }
        }
    }
    func close (action: UIAlertAction){
        exit(-1)
    }
    func changeLanguage(str: String){
        btnRefresh.setTitle("refresh".addLocalizableString(str: str), for: .normal)
        self.from = "from_".addLocalizableString(str: str)
        self.amount = "amount_".addLocalizableString(str: str)
        self.code = "unique".addLocalizableString(str: str)
        self.error = "error".addLocalizableString(str: str)
        self.tryAgain = "tryagain".addLocalizableString(str: str)
    }
}
