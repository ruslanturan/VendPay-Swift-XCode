//
//  HomeViewController.swift
//  VendPay
//
//  Created by Ruslan Cahangirov on 8/11/20.
//  Copyright © 2020 Ruslan Cahangirov. All rights reserved.
//

import UIKit
import AVFoundation

class HomeVC: UIViewController {

    @IBOutlet weak var logo: UIButton!
    @IBOutlet weak var lblID: UILabel!
    @IBOutlet weak var lblBalance: UILabel!
    @IBOutlet weak var btnConnect: UIButton!
    @IBOutlet weak var btnExact: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imgQR: UIImageView!
    var screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var error = ""
    var norequest = ""
    var notFound = ""
    var tryAgain = ""
    var balance = ""
    var budget = ""
    var minimumAmount = ""
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
        lblID.frame = CGRect(x: 0, y: logoHeight + 50, width: self.screenWidth, height: 30)
        scrollView.addSubview(lblID)
        lblBalance.frame = CGRect(x: 0, y: logoHeight + 120, width: self.screenWidth, height: 30)
        scrollView.addSubview(lblBalance)
        btnConnect.frame = CGRect(x: 30, y: logoHeight + 210, width: self.screenWidth - 60, height: 110)
        btnConnect.layer.cornerRadius = 12
        btnConnect.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnConnect.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnConnect.layer.shadowOpacity = 1.0
        btnConnect.layer.shadowRadius = 0.0
        btnConnect.layer.masksToBounds = false
        scrollView.addSubview(btnConnect)
        imgQR.frame = CGRect(x: 30, y: logoHeight + 220, width: self.screenWidth - 60, height: 60)
        scrollView.addSubview(imgQR)
        btnExact.frame = CGRect(x: 30, y: logoHeight + 350, width: self.screenWidth - 60, height: 50)
        btnExact.layer.cornerRadius = 12
        btnExact.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btnExact.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnExact.layer.shadowOpacity = 1.0
        btnExact.layer.shadowRadius = 0.0
        btnExact.layer.masksToBounds = false
        scrollView.addSubview(btnExact)
        scrollView.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "unnamed"), style: .plain, target: self, action: #selector(goToMenu))
        self.navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -115);
        let logged = UserDefaults.standard.string(forKey: "logged")
        let loggedID = logged!.split(separator: ";").map(String.init)
        lblID.text = loggedID[1].replacingOccurrences(of: " ", with: "")
        let ID = loggedID[1].split(separator: ":").map(String.init)
        DispatchQueue.main.async {
            [weak self] in
            self!.balanceRequest(url: "https://www.vendpay.ge/user/getuserbalance?id=" + ID[1])
        }
        let lang = UserDefaults.standard.string(forKey: "lang")
        if(lang != nil){
            changeLanguage(str: lang!)
        }
    }
    @objc func goToMenu(){
        let vc = storyBoard.instantiateViewController(withIdentifier: "Menu") as! MenuVC
        self.navigationController!.pushViewController(vc, animated:true)
    }
    @IBAction func logoOnClick(_ sender: Any) {
        let logged = UserDefaults.standard.string(forKey: "logged")
        let loggedID = logged!.split(separator: ";").map(String.init)
        lblID.text = loggedID[1].replacingOccurrences(of: " ", with: "")
        let ID = loggedID[1].split(separator: ":").map(String.init)
        DispatchQueue.main.async {
            [weak self] in
            self!.balanceRequest(url: "https://www.vendpay.ge/user/getuserbalance?id=" + ID[1])
        }
    }
    
    @IBAction func connectClicked(_ sender: Any) {
        let decimalBudget = Decimal(string:budget)
        if(decimalBudget! > 0.49){
            switch AVCaptureDevice.authorizationStatus(for: .video) {
                case .authorized:
                    let vc = QRScannerVC()
                    vc.amount = self.budget
                    self.navigationController!.pushViewController(vc, animated:true)
                    return
                case .notDetermined:
                    AVCaptureDevice.requestAccess(for: .video) { granted in
                        if granted {
                            DispatchQueue.main.async {
                                let vc = QRScannerVC()
                                vc.amount = self.budget
                                self.navigationController!.pushViewController(vc, animated:true)
                            }
                        }
                    }
                case .denied:
                    let alert = UIAlertController(title: error, message: norequest, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                case .restricted:
                    print("restricted")
                    return
                @unknown default:
                    print("fatalError")
            }
        }
        else{
            let alert = UIAlertController(title: error, message: minimumAmount, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    @IBAction func exactOnClick(_ sender: Any) {
        let decimalBudget = Decimal(string:budget)
        if(decimalBudget! > 0.49){
            switch AVCaptureDevice.authorizationStatus(for: .video) {
                case .authorized:
                    let vc = ExactScannerVC()
                    self.navigationController!.pushViewController(vc, animated:true)
                    return
                case .notDetermined:
                    AVCaptureDevice.requestAccess(for: .video) { granted in
                        if granted {
                            DispatchQueue.main.async {
                                let vc = ExactScannerVC()
                                self.navigationController!.pushViewController(vc, animated:true)
                            }
                        }
                    }
                case .denied:
                    let alert = UIAlertController(title: error, message: norequest, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                case .restricted:
                    print("restricted")
                    return
                @unknown default:
                    print("fatalError")
            }
        }
        else{
            let alert = UIAlertController(title: error, message: minimumAmount, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    func balanceRequest(url: String){
        if let myURL = NSURL(string: url) {
            do {
                let myHTMLString = try NSString(contentsOf: myURL as URL, encoding: String.Encoding.utf8.rawValue)
                if (myHTMLString.contains("Error: User")){
                    let alert = UIAlertController(title: error, message: notFound, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: close))
                    self.present(alert, animated: true)
                }
                if (myHTMLString.contains("Error")){
                    let alert = UIAlertController(title: error, message: tryAgain, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: close))
                    self.present(alert, animated: true)
                }
                else{
                    let defaults = UserDefaults.standard
                    let logged = defaults.string(forKey: "logged")
                    let loggedID = logged!.split(separator: ";").map(String.init)
                    let loggedBalance = String(myHTMLString).split(separator: ";").map(String.init)
                    UserDefaults.standard.set(loggedBalance[0] + "; " + loggedID[1], forKey: "logged")
                    let amount = loggedBalance[0].split(separator: ":").map(String.init)
                    self.budget = amount[1]
                    lblBalance.text = balance + amount[1] + " GEL"
                    let phone = loggedBalance[1].split(separator: ":").map(String.init)
                    if(phone[1] == "0"){
                        let vc = storyBoard.instantiateViewController(withIdentifier: "EditPhone") as! EditPhoneVC
                        vc.comesFrom = "home"
                        self.navigationController!.pushViewController(vc, animated:true)
                    }
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
        btnConnect.setTitle("scan".addLocalizableString(str: str), for: .normal)
        btnExact.setTitle("exact".addLocalizableString(str: str), for: .normal)
        self.balance = "balance".addLocalizableString(str: str)
        self.error = "error".addLocalizableString(str: str)
        self.notFound = "notfound".addLocalizableString(str: str)
        self.tryAgain = "tryagain".addLocalizableString(str: str)
        self.norequest = "denied".addLocalizableString(str: str)
        self.minimumAmount = "minimumAmount".addLocalizableString(str: str)
    }
}
