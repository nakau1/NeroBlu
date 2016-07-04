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
        print("open " + NBRealm.realmPath)
        
        
        //let p = NSPredicate(format: "id IN %@", argumentArray: [[1, 3, 4, 5]])
		
        let p = NSPredicate.empty
            .and(NSPredicate("name", valuesIn: ["ritsumeikan", "doshisha"]))
        print(p)
        
        let acc = SchoolAccessor()
        let records = acc.select(condition: p)
        
        print(records)
        
//        var id: Int64? = nil
//        
//        var schools = [School]()
//        for n in ["waseda", "keio", "ritsumeikan", "doshisha"] {
//            let school = acc.create(previousID: id)
//            school.name = n
//            schools.append(school)
//            id = school.id
//        }
//        
//        acc.insert(schools)
    }
}

class School: NBRealmEntity {
    
    dynamic var name = ""
    
    let schoolClasses = RealmSwift.List<SchoolClass>()
}

class Teacher: NBRealmEntity {
	
	dynamic var name = ""
	dynamic var subject = ""
}

class Student: NBRealmEntity {
	
	dynamic var name = ""
}

class SchoolClass: NBRealmEntity {
	
	dynamic var name = ""
	
	let students = RealmSwift.List<Student>()
	
	dynamic var value: Teacher?
}

// ====================

class SchoolAccessor: NBRealmAccessor<School> {
	
}

class TeacherAccessor: NBRealmAccessor<Teacher> {
	
}

class StudentAccessor: NBRealmAccessor<Student> {
	
}

class SchoolClassAccessor: NBRealmAccessor<SchoolClass> {
	
}
