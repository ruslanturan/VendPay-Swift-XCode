//
//  ViewController.swift
//  VendPay
//
//  Created by Ruslan Cahangirov on 8/6/20.
//  Copyright © 2020 Ruslan Cahangirov. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard

        let logged = defaults.string(forKey: "logged") ?? ""
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if logged.contains("Balance"){
            let vc = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeVC
            self.navigationController?.setViewControllers([vc], animated:true)
        }
        else{
            let vc = storyBoard.instantiateViewController(withIdentifier: "Language") as! LanguageVC
            self.navigationController?.setViewControllers([vc], animated:true)
        }
    }
}
