//
//  Payment.swift
//  DreamAfrica
//
//  Created by Franco Abbott on 9/28/16.
//  Copyright © 2016 popcorntime. All rights reserved.
//

import Foundation

class Payment {
    
    internal static func checkPaid() {
        let ud = UserDefaults.standard
        let fbId = ud.string(forKey: "facebookId") as String!
        RestApiManager.sharedInstance.getJSONFromURL("http://www.wedreamafrica.com/check_user_paid.php?uid=\(String(describing: fbId))")  { json in
            
            if (json["user_paid"] == "True") {
                ud.set(true, forKey: "userPaid")
                print("Paid user")
            } else {
                ud.set(false, forKey: "userPaid")
                print("User not paid")
            }
        }
    }
}
