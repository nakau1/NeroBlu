//
//  ViewController.swift
//  NeroBluDemo
//
import UIKit
import NeroBlu

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("open " + NBRealmAccessor.realmPath)
    }
}

class User: NBRealmEntity {
    
    dynamic var name = ""
    
    dynamic var age = 18
}

class UserAccessor: NBRealmAccessor {
    
    
}
