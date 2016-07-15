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

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NBHud.show("やっほー")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

