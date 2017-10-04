//
//  PaymentViewController.swift
//  DreamAfrica
//
//  Created by Franco Abbott on 9/25/16.
//  Copyright © 2016 popcorntime. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController {
    
    @IBOutlet weak var paymentWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
        
        let ud = UserDefaults.standard
        let fbId = ud.string(forKey: "facebookId") as String!
        let fbEmail = ud.string(forKey: "facebookEmail") as String! ?? "communications@thepearldream.com"
        print("facebookId: \(fbId)")
        print("facebookEmail: \(fbEmail)")
        let url = URL (string: "http://www.wedreamafrica.com/payment.php?uid=\(fbId)" +
            "&email=\(fbEmail)")
        print(url);
//        UIApplication.sharedApplication().openURL(url!)
        let requestObj = URLRequest(url: url!)
        paymentWebView.loadRequest(requestObj)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Payment.checkPaid()
    }
    
}
