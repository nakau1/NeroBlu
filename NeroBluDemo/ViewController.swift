//
//  ViewController.swift
//  NeroBluDemo
//
import UIKit
import NeroBlu
import RealmSwift

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let p = NSPredicate("age", greaterThan: 12).any(of: "student")
            .and(NSPredicate(isNotNil: "email"))
        .and(NSPredicate("created", fromDate: nil, toDate: NSDate()))
        
        print(p)
    }
}