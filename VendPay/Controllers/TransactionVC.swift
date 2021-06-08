//
//  TransactionViewController.swift
//  VendPay
//
//  Created by Ruslan Cahangirov on 2/18/21.
//  Copyright © 2021 Ruslan Cahangirov. All rights reserved.
//

import UIKit

class TransactionVC: UIViewController {

    @IBOutlet weak var logo: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    var loggedID: String = ""
    var transactions = Data()
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    var logoHeight = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        if !Reachability.isConnectedToNetwork(){
            let alert = UIAlertController(title: "Connection Failed", message: "Please check the internet connection and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: close))
            self.present(alert, animated: true)
        }
        self.hideKeyboard()
        logoHeight = Int((self.screenHeight/5))
        logo.frame = CGRect(x: 0, y: 20, width: Int(screenWidth), height: Int(logoHeight))
        let image = UIImage(named: "logo.png")
        logo.setImage(image, for: .normal)
        logo.imageView?.contentMode = .scaleAspectFit
        scrollView.addSubview(logo)
        scrollView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        scrollView.contentSize = CGSize(width: screenWidth, height: screenHeight)
    }
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            let logged = UserDefaults.standard.string(forKey: "logged")!.split(separator: ";").map(String.init)
            self.loggedID = logged[1].replacingOccurrences(of: " ", with: "").split(separator: ":").map(String.init)[1]
            let url = URL(string: "https://vendpay.ge/api/transaction/get/" + self.loggedID)!
            print(url)
            let task = URLSession.shared.dataTask(with: url) {(data,response,error) in guard let data = data else {return}
                    self.transactions = data
                    do {
                        if var jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>]
                        {
                            var y = self.logoHeight + 20
                            jsonArray.reverse()
                            for transaction in jsonArray{
                                DispatchQueue.main.async {
                                    let amount = transaction["amount"] as? Double
                                    var date = transaction["date"] as? String
                                    let addressId = transaction["addressId"] as? Int
                                    let addressId_number = transaction["addressId_number"] as? Int
                                    let address_Mail = transaction["address_Mail"] as? String
                                    let index = date!.index(date!.startIndex, offsetBy: 16)
                                    date = date?.substring(to: index).replacingOccurrences(of: "T", with: " ")
                                    let trView = UIView(frame: CGRect(x: 15, y: y, width: Int(self.screenWidth - 30), height: 141))
                                    trView.backgroundColor = UIColor.white
                                    trView.layer.shadowColor = UIColor.gray.cgColor
                                    trView.layer.shadowOffset = CGSize(width: 1.5, height: 1)
                                    trView.layer.shadowOpacity = 1
                                    trView.layer.shadowRadius = 1.0
                                    trView.clipsToBounds = true
                                    trView.layer.masksToBounds = false
                                    trView.layer.cornerRadius = 2
                                    trView.layer.backgroundColor = UIColor.black.cgColor
                                    let txtAmount = UILabel(frame: CGRect(x: 0, y: 0, width: Int(self.screenWidth - 30)/3 - 1, height: 70))
                                    txtAmount.text = String(amount!)
                                    txtAmount.textAlignment = .center
                                    txtAmount.layer.backgroundColor = UIColor.white.cgColor
                                    txtAmount.font = UIFont(name:"BPGExtraSquareMtavruli",size:25)
                                    if(amount! >= 0.0){
                                        //green
                                        txtAmount.textColor = UIColor(red: 0.0, green: 138/255, blue: 44/255, alpha: 1.0)
                                    }else{
                                        //red
                                        txtAmount.textColor = UIColor(red: 252/255, green: 0, blue: 0, alpha: 1.0)
                                    }
                                    let txtDate = UILabel(frame: CGRect(x: Int(self.screenWidth-30)/3, y: 0, width: Int(self.screenWidth - 30)*2/3, height: 70))
                                    txtDate.text = date
                                    txtDate.textAlignment = .center
                                    txtDate.layer.backgroundColor = UIColor.white.cgColor
                                    txtDate.font = UIFont(name:"BPGExtraSquareMtavruli",size:18)
                                    let txtID_number = UILabel(frame: CGRect(x: 0, y: 71, width: Int(self.screenWidth-30)/3 - 1, height: 70))
                                    if(addressId ?? 0 > 0){
                                        txtID_number.text = String(addressId_number!)
                                    }
                                    else{
                                        txtID_number.text = " "
                                    }
                                    txtID_number.layer.backgroundColor = UIColor.white.cgColor
                                    txtID_number.textAlignment = .center
                                    txtID_number.font = UIFont(name:"BPGExtraSquareMtavruli",size:16)
                                    let txtMail = UILabel(frame: CGRect(x: Int(self.screenWidth-30)/3, y: 71, width: Int(self.screenWidth - 30)*2/3, height: 70))
                                    txtMail.text = address_Mail
                                    txtMail.numberOfLines = 0
                                    txtMail.textAlignment = .center
                                    txtMail.layer.backgroundColor = UIColor.white.cgColor
                                    txtMail.font = UIFont(name:"BPGExtraSquareMtavruli",size:16)
                                    trView.addSubview(txtAmount)
                                    trView.addSubview(txtDate)
                                    trView.addSubview(txtID_number)
                                    trView.addSubview(txtMail)
                                    self.scrollView.addSubview(trView)
                                    y += 150
                                    self.scrollView.isScrollEnabled = true
                                    self.scrollView.contentSize = CGSize(width: self.screenWidth, height: CGFloat(Float(y + 20)))
                                }
                            }
                        } else {
                            print("bad json")
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                }
                task.resume()
            
        }
    }
    @IBAction func logoOnClick(_ sender: Any) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeVC
        self.navigationController?.setViewControllers([vc], animated:true)
    }
    func close (action: UIAlertAction){
        exit(-1)
    }
}
