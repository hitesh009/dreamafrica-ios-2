//
//  NSLocale+Extension.swift
//  Butter
//
//  Created by Moorice on 07-10-15.
//  Copyright © 2015 Butter Project. All rights reserved.
//

import Foundation

extension Locale {

    static func get2LetterLanguageCode() -> String {
        let languageSplitted = Locale.preferredLanguages[0].components(separatedBy: "-")
        if languageSplitted.count > 1 {
            return languageSplitted[0]
        } else {
            return "en"
        }
    }
    
}
