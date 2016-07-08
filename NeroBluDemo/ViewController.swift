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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.insert()
        
        NBRealmBrowsingViewController.show(self)
        //NBRealmBrowseViewController.show(self)
    }
        
//        //let p = NSPredicate(format: "id IN %@", argumentArray: [[1, 3, 4, 5]])
//		
////        let p = NSPredicate.empty
////            .and(NSPredicate("name", valuesIn: ["ritsumeikan", "doshisha"]))
////        print(p)
//        
//        let records = acc.select()
//        
//        print(records)
//        
////        var id: Int64? = nil
////        
////        var schools = [School]()
////        for n in ["waseda", "keio", "ritsumeikan", "doshisha"] {
////            let school = acc.create(previousID: id)
////            school.name = n
////            schools.append(school)
////            id = school.id
////        }
////        
////        acc.insert(schools)
    
    
    private func insert() {
        let aa = AuthorAccessor()
        var aarr = [Author]()
        for (i, name) in ["Tom", "Jeff", "Leo", "Alex"].enumerate() {
            let a = aa.create(withID: Int64(i+1))
            a.age.value = 34
            a.name = name
            aarr.append(a)
        }
        aa.save(aarr)

        func randomAuthor() -> Author {
            let r = Int(arc4random_uniform(4))
            return aarr[r]
        }
        
        
        let ffa = FontFamilyAccessor()
        let fa = FontAccessor()
        
        var fid: Int64 = 0
        
        let fontFamilies = ffa.create(UIFont.familyNames(), withID: 1) { fontFamily, familyName in
            fontFamily.name = familyName
            
            let fonts = fa.create(UIFont.fontNamesForFamilyName(familyName), withID: fid) { font, fontName in
                font.name = fontName
                font.author = randomAuthor()
                return font
            }
            fa.save(fonts)
            fid += fonts.count
            
            fontFamily.fonts.reset(fonts)
            
            return fontFamily
        }
        ffa.save(fontFamilies)
    }
}


class Font: NBRealmEntity {
    
    dynamic var name = ""
    
    dynamic var author: Author?
    
    override var description: String {
        return "#\(self.id) \"\(self.name)\""
    }
}

class FontFamily: NBRealmEntity {
    
    dynamic var name = ""
    
    let fonts = RealmSwift.List<Font>()
    
    override var description: String {
        return "#\(self.id) \"\(self.name)\""
    }
}

class Author: NBRealmEntity {
    
    dynamic var name = ""
    
    let age = RealmOptional<Int>(40)
    
    dynamic var email: String?
    
    dynamic var male = true
    
    dynamic var deleted = false
    
    dynamic var thumbnailImage: NSData = NSData()
    
    override var description: String {
        return "#\(self.id) \"\(self.name)\""
    }
}


// ====================

class FontAccessor: NBRealmAccessor<Font> {}

class FontFamilyAccessor: NBRealmAccessor<FontFamily> {}

class AuthorAccessor: NBRealmAccessor<Author> {}

