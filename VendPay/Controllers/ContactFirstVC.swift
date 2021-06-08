//
//  ContactViewController.swift
//  VendPay
//
//  Created by Ruslan Cahangirov on 8/11/20.
//  Copyright © 2020 Ruslan Cahangirov. All rights reserved.
//

import UIKit

class ContactFirstVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var logo: UIButton!
    @IBOutlet weak var btnMail: UIButton!
    @IBOutlet weak var btnPhone: UIButton!
    var screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    var number = ""
    var mail = ""
    var error = ""
    var tryAgain = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        if !Reachability.isConnectedToNetwork(){
            let alert = UIAlertController(title: "Connection Failed", message: "Please check the internet connection and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: close))
            self.present(alert, animated: true)
        }
        let logoHeight = (self.screenHeight/5)
        logo.frame = CGRect(x: 0, y: 20, width: self.screenWidth, height: logoHeight)
        let image = UIImage(named: "logo.png")
        logo.setImage(image, for: .normal)
        logo.imageView?.contentMode = .scaleAspectFit
        scrollView.addSubview(logo)
        btnPhone.frame = CGRect(x: self.screenWidth/2 - 50, y: logoHeight + 70, width: 100, height: 100)
        scrollView.addSubview(btnPhone)
        btnMail.frame = CGRect(x:0, y: logoHeight + 240, width: self.screenWidth, height: 120)
        scrollView.addSubview(btnMail)
        scrollView.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            [weak self] in
            self!.contactRequest(url: "https://www.vendpay.ge/user/contact_info")
        }
    }
    @IBAction func logoOnClick(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "First") as! FirstVC
        self.navigationController?.setViewControllers([vc], animated:true)
    }
    @IBAction func phoneOnClick(_ sender: Any) {
        let phoneNumber = number.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
          let application:UIApplication = UIApplication.shared
          if (application.canOpenURL(phoneCallURL)) {
              if #available(iOS 10.0, *) {
                  application.open(phoneCallURL, options: [:], completionHandler: nil)
              } else {
                  let alert = UIAlertController(title: "Error", message: "There is not function here for your phone", preferredStyle: .alert)
                  alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                  self.present(alert, animated: true)
                  return
              }
          }
        }
    }
    @IBAction func mailOnClick(_ sender: Any) {
        if let url = URL(string: "mailto:\(mail)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    func close (action: UIAlertAction){
        exit(-1)
    }
    func contactRequest(url: String){
        if let myURL = NSURL(string: url) {
            do {
                let myHTMLString = try NSString(contentsOf: myURL as URL, encoding: String.Encoding.utf8.rawValue)
                if (myHTMLString.contains("Error")){
                    let alert = UIAlertController(title: error, message: tryAgain, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: close))
                    self.present(alert, animated: true)
                    return
                }
                else{
                    let string = String(myHTMLString)
                    let phone = string.split(separator: ";").map(String.init)
                    let num = phone[0].split(separator: ":").map(String.init)
                    number = "+995 " + num[1]
                    let email = phone[1].split(separator: ":").map(String.init)
                    mail = email[1]
                    let image2 = UIImage(named: "phoneicon.png")
                    btnPhone.setImage(image2, for: .normal)
                    btnPhone.imageView?.contentMode = .scaleAspectFit
                    btnMail.setTitle(email[1], for: .normal)
                }
            } catch {
                print(error)
            }
        }
    }
    func changeLanguage(str: String){
        self.error = "error".addLocalizableString(str: str)
        self.tryAgain = "tryagain".addLocalizableString(str: str)
    }
}
