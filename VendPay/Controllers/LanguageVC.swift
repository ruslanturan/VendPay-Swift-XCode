//
//  LanguageViewController.swift
//  VendPay
//
//  Created by Ruslan Cahangirov on 9/24/20.
//  Copyright © 2020 Ruslan Cahangirov. All rights reserved.
//

import UIKit

class LanguageVC: UIViewController {
    @IBOutlet weak var btnGe: UIButton!
    @IBOutlet weak var btnEng: UIButton!
    var screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        if !Reachability.isConnectedToNetwork(){
            let alert = UIAlertController(title: "Connection Failed", message: "Please check the internet connection and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: close))
            self.present(alert, animated: true)
        }
        let bigNumber = Int.max + 1
        print(bigNumber)
        let width = screenWidth * 7 / 10
        let height = width * 2 / 3
        let margin = (screenHeight - 2 * height) / 3
        btnGe.frame = CGRect(x: (screenWidth - width)/2, y: margin, width: width, height: height)
        btnGe.layer.cornerRadius = 12
        btnGe.layer.borderWidth = 2.0
        btnGe.layer.borderColor = UIColor.white.cgColor
        btnGe.clipsToBounds = true
        view.addSubview(btnGe)
        btnEng.frame = CGRect(x: (screenWidth - width)/2, y: 2 * margin + height, width: width, height: height)
        btnEng.layer.cornerRadius = 12
        btnEng.layer.borderWidth = 2.0
        btnEng.layer.borderColor = UIColor.white.cgColor
        btnEng.clipsToBounds = true
        view.addSubview(btnEng)
        
    }
    @IBAction func geOnClick(_ sender: Any) {
        UserDefaults.standard.set("ka", forKey: "lang")
        let vc = storyBoard.instantiateViewController(withIdentifier: "First") as! FirstVC
        self.navigationController?.setViewControllers([vc], animated:true)
    }
    @IBAction func engOnClick(_ sender: Any) {
        UserDefaults.standard.set("en", forKey: "lang")
        let vc = storyBoard.instantiateViewController(withIdentifier: "First") as! FirstVC
        self.navigationController?.setViewControllers([vc], animated:true)
    }
    func close (action: UIAlertAction){
        exit(-1)
    }
}
