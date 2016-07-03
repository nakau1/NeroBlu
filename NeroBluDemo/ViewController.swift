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
        //print("open " + NBRealm.realmPath)
		
		print(NSPredicate(ids: [1, 3, 4, 5]))
    }
}

class School: NBRealmEntity {
    
    dynamic var name = ""
	dynamic var address = ""
    
    let schoolClasses = RealmSwift.List<SchoolClass>
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
	
	func d(entity: Entity) {
		
	}
}

class TeacherAccessor: NBRealmAccessor<Teacher> {
	
}

class StudentAccessor: NBRealmAccessor<Student> {
	
}

class SchoolClassAccessor: NBRealmAccessor<SchoolClass> {
	
}
