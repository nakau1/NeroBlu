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
        
        self.insert()
        
        
        
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
    }
    
    
    private func insert() {
        let ffa = FontFamilyAccessor()
        let fa = FontAccessor()
        
        var fid: Int64 = 0
        
        let fontFamilies = ffa.create(UIFont.familyNames(), previousID: 0) { fontFamily, familyName in
            fontFamily.name = familyName
            
            let fonts = fa.create(UIFont.fontNamesForFamilyName(familyName), previousID: fid) { font, fontName in
                font.name = fontName
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
}

class FontFamily: NBRealmEntity {
    
    dynamic var name = ""
    
    let fonts = RealmSwift.List<Font>()
}

// ====================

class FontAccessor: NBRealmAccessor<Font> {
	
}

class FontFamilyAccessor: NBRealmAccessor<FontFamily> {
	
}
