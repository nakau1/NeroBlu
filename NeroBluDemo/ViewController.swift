//
//  ViewController.swift
//  NeroBluDemo
//
//  Created by 中安佑一 on 2016/06/30.
//  Copyright © 2016年 yuichi.nakayasu@gmail.com. All rights reserved.
//

import UIKit
import NeroBlu

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTapButton() {
        self.presentDialog(DialogViewController.create())
    }
}

class DialogViewController: NBCustomizedDialogViewController {
    
    class func create() -> DialogViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("temp") as! DialogViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTapButton() {
        
    }
    
    deinit {
        print("deinit \(self)")
    }
}
