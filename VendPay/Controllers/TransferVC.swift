//
//  TransferViewController.swift
//  VendPay
//
//  Created by Ruslan Cahangirov on 8/12/20.
//  Copyright © 2020 Ruslan Cahangirov. All rights reserved.
//

import UIKit

class TransferVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var logo: UIButton!
    @IBOutlet weak var lblID: UILabel!
    @IBOutlet weak var lblBalance: UILabel!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnReceive: UIButton!
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    var loggedId = ""
    var error = ""
    var norequest = ""

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
        btnSend.frame = CGRect(x: 20, y: logoHeight + 170, width: self.screenWidth - 40, height: 55)
        btnSend.layer.cornerRadius = 12
        btnSend.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnSend.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnSend.layer.shadowOpacity = 1.0
        btnSend.layer.shadowRadius = 0.0
        btnSend.layer.masksToBounds = false
        scrollView.addSubview(btnSend)
        btnReceive.frame = CGRect(x: 20, y: logoHeight + 260, width: self.screenWidth - 40, height: 55)
        btnReceive.layer.cornerRadius = 12
        btnReceive.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnReceive.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnReceive.layer.shadowOpacity = 1.0
        btnReceive.layer.shadowRadius = 0.0
        btnReceive.layer.masksToBounds = false
        scrollView.addSubview(btnReceive)
        scrollView.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
        let defaults = UserDefaults.standard
        let logged = defaults.string(forKey: "logged")
        let loggedID = logged!.split(separator: ";").map(String.init)
        lblID.text = loggedID[1].replacingOccurrences(of: " ", with: "")
        let id = loggedID[1].split(separator: ":").map(String.init)
        loggedId = id[1]
        lblBalance.text = loggedID[0].replacingOccurrences(of: " ", with: "") + " GEL"
        let lang = UserDefaults.standard.string(forKey: "lang")
        if(lang != nil){
            changeLanguage(str: lang!)
        }
    }
    @IBAction func logoOnClick(_ sender: Any) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeVC
        self.navigationController?.setViewControllers([vc], animated:true)
    }
    @IBAction func sendOnClick(_ sender: Any) {
        let vcSend = storyBoard.instantiateViewController(withIdentifier: "Send") as! SendVC
        self.navigationController!.pushViewController(vcSend, animated:true)
    }
    @IBAction func reciveOnClick(_ sender: Any) {
        DispatchQueue.main.async {
            [weak self] in
            self!.uniqueRequest(url: "https://www.vendpay.ge/user/get_unique?toId=" + self!.loggedId)
        }
    }
    func uniqueRequest(url: String){
        if let myURL = NSURL(string: url) {
            do {
                let myHTMLString = try NSString(contentsOf: myURL as URL, encoding: String.Encoding.utf8.rawValue)
                if (myHTMLString.contains("Error")){
                    let alert = UIAlertController(title: error, message: norequest, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                else{
                    let vc = storyBoard.instantiateViewController(withIdentifier: "Receive") as! ReceiveVC
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
    func changeLanguage(str: String){
        btnSend.setTitle("send".addLocalizableString(str: str), for: .normal)
        btnReceive.setTitle("receive".addLocalizableString(str: str), for: .normal)
        let balance = lblBalance.text!.split(separator: ":").map(String.init)
        lblBalance.text = "balance".addLocalizableString(str: str) + balance[1]
        self.error = "error".addLocalizableString(str: str)
        self.norequest = "noRequest".addLocalizableString(str: str)
    }
}
