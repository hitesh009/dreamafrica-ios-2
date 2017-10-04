//
//  FacebookLoginViewController.swift
//  DreamAfrica
//
//  Created by Franco Abbott on 8/21/16.
//  Copyright © 2016 popcorntime. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import AccountKit
import QuartzCore
import SafariServices
import CleverSDK

import BraintreeDropIn
import Braintree
import PassKit


// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class FacebookLoginViewConroller: UIViewController, FBSDKLoginButtonDelegate, AKFViewControllerDelegate,BTDropInControllerDelegate,PKPaymentAuthorizationViewControllerDelegate{
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
    }
    
    
    var accountKit: AKFAccountKit!
    var cleverLoginButton: CLVLoginButton!
    var clientToken = ""
    var braintreeClient: BTAPIClient?
    let request =  BTDropInRequest()
    var dropIn = BTDropInController()
    let loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["email"]
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        fetchClientToken()
        braintreeClient = BTAPIClient(authorization: "sandbox_f7nz3cd8_p635qsrzzvbs5x8y")
        
        self.navigationController?.isNavigationBarHidden = true
        
        // initialize Account Kit
        if accountKit == nil {
            // may also specify AKFResponseTypeAccessToken
            self.accountKit = AKFAccountKit(responseType: AKFResponseType.accessToken)
        }
        
        let loginWithSMS = self.view.subviews[0]
        let loginWithEmail = self.view.subviews[1]
        
        let widthConstraintAccountKit = NSLayoutConstraint(item: loginWithEmail, attribute: .width, relatedBy: .equal, toItem: loginWithSMS, attribute: .width, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([widthConstraintAccountKit])
        cleverLoginButton = CLVLoginButton(in: self, successHander: { (accessToken : String!) in
            print("Success")
            //                self.showStories()
        }, failureHandler: { (error: String!) in
            
            print(error)
            self.showLogin()
        })

    self.view.addSubview(cleverLoginButton)
    cleverLoginButton.translatesAutoresizingMaskIntoConstraints = false
    
    let xConstraintClever = NSLayoutConstraint(item: cleverLoginButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
    let widthConstraintClever = NSLayoutConstraint(item: cleverLoginButton, attribute: .width, relatedBy: .equal, toItem: loginWithEmail, attribute: .width, multiplier: 1, constant: 0)
    let heightConstraintClever = NSLayoutConstraint(item: cleverLoginButton, attribute: .width, relatedBy: .equal, toItem: loginWithEmail, attribute: .width, multiplier: 1, constant: 0)
    
    NSLayoutConstraint.activate([
    xConstraintClever,
    widthConstraintClever,
    heightConstraintClever
    ])
    
    FBSDKLoginManager().logOut() // TODO: This prevents showing login page with logout button. Probably a better way to do this.
    self.view.addSubview(loginButton)
    loginButton.translatesAutoresizingMaskIntoConstraints = false
    
    let xConstraint = NSLayoutConstraint(item: loginButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
    let topConstraint = NSLayoutConstraint(item: loginButton, attribute: .top, relatedBy: .equal, toItem: cleverLoginButton, attribute: .bottom, multiplier: 1, constant: 20)
    let widthConstraint = NSLayoutConstraint(item: loginButton, attribute: .width, relatedBy: .equal, toItem: cleverLoginButton, attribute: .width, multiplier: 1, constant: 0)
    let heightConstraint = NSLayoutConstraint(item: loginButton, attribute: .height, relatedBy: .equal, toItem: loginWithEmail, attribute: .height, multiplier: 1, constant: 0)
    let topConstraintAccountKit = NSLayoutConstraint(item: loginWithEmail, attribute: .top, relatedBy: .equal, toItem: loginButton, attribute: .bottom, multiplier: 1, constant: 20)
    
    NSLayoutConstraint.activate([
    xConstraint,
    topConstraint,
    widthConstraint,
    heightConstraint,
    topConstraintAccountKit
    ])
    loginButton.delegate = self
        
//        if checkApplePayAvaliable() {
//            checkPaymentNetworksAvaliable(usingNetworks: supportedPaymentNetworks)
//        }else
//        {
//            print("Not Avalible")
//        }
}

    
    
    func pay() {
        guard let amount = currentAmount else {
            return
        }
        
        // make an ApplePay request
        let request = PKPaymentRequest()
        request.currencyCode = "JPY"
        request.countryCode = "JP"
        request.merchantIdentifier = "merchant.com.pearldream.dreamafrica"
        
        let item = PKPaymentSummaryItem(label: "PAY.JP TEST ITEM", amount: amount)
        request.paymentSummaryItems = [item]
        request.supportedNetworks = supportedPaymentNetworks
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        request.requiredBillingAddressFields = PKAddressField.postalAddress
        
        let vc = PKPaymentAuthorizationViewController(paymentRequest: request)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    private var supportedPaymentNetworks: [PKPaymentNetwork] {
        get {
            if #available(iOS 10.0, *) {
                return PKPaymentRequest.availableNetworks()
            } else {
                return [.visa, .masterCard, .amex]
            }
        }
    }
    
    private var currentAmount: NSDecimalNumber? {
        get { return NSDecimalNumber(string: "100.0") }
    }
    
    private func checkApplePayAvaliable() -> Bool {
        if !PKPaymentAuthorizationViewController.canMakePayments() {
            let alertController = UIAlertController(
                title: "エラー",
                message: "このデバイスはApple Payに対応していません",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    private func checkPaymentNetworksAvaliable(usingNetworks networks: [PKPaymentNetwork]) {
        if !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: networks) {
            let alertController = UIAlertController(
                title: "DreameApp",
                message: "Not Avalible",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "YES", style: UIAlertActionStyle.default, handler: { action in
                if #available(iOS 8.3, *) {
                    PKPassLibrary().openPaymentSetup()
                }
            }))
            alertController.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
func fetchProfile() {
    FBSDKGraphRequest(graphPath: "me",
                      parameters: ["fields": "id, email"]).start(completionHandler: { (connection, result, error) -> Void in
                        if (error != nil){
                            print(error!)
                            return
                        }
                        
                        //                let email = result["email"] as? String
                        
                        if let id = (result as! NSMutableDictionary)["id"] as? String {
                            print(id)
                            UserDefaults.standard.setValue(id, forKey: "facebookId")
                        }
                        
                        if let email = (result as! NSMutableDictionary)["email"] as? String {
                            print(email)
                            UserDefaults.standard.setValue(email, forKey: "facebookEmail")
                        }
                      })
}

func showLogin() {
    
    // Do here if condition for not getting when I have UID
    
    if UserDefaults.standard.object(forKey: "accountKitId") != nil {
    
        showStories()
    }else
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginvc = storyboard.instantiateViewController(withIdentifier: "loginView") as! FacebookLoginViewConroller
        let navigationController = UINavigationController(rootViewController: loginvc)
        
        appDelegate.window?.rootViewController = navigationController
        appDelegate.window?.makeKeyAndVisible()
    }
    
    
}

func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: NSError!) {
    print("Loggin completed")
    fetchProfile()
    UserDefaults.standard.set(true, forKey: "loggedIn")
    showStories()
}

func showStories() {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let initialViewController = storyboard.instantiateViewController(withIdentifier: "rootDreamAfricaView")
    appDelegate.window?.rootViewController = initialViewController
    appDelegate.window?.makeKeyAndVisible()
}

func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    
}

func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
    return true
}

//Changing Status Bar. May be the wrong way to do it since the other views seem to have set it globaly.
override var preferredStatusBarStyle : UIStatusBarStyle {
    
    //LightContent
    return UIStatusBarStyle.lightContent
    
    //Default
    //return UIStatusBarStyle.Default
    
}

func viewController(_ viewController: UIViewController!, didCompleteLoginWith accessToken: AKFAccessToken!, state: String!) {
    print("Login succcess with AccessToken")
    
    accountKit.requestAccount{
        (account, error) -> Void in
        
        print(account!.accountID)
        UserDefaults.standard.setValue(account?.accountID, forKey: "accountKitId")
        if account?.emailAddress?.characters.count > 0 {
            //if the user is logged with email
            print(account!.emailAddress!)
            UserDefaults.standard.setValue(account!.emailAddress, forKey: "accountKitEmail")
            
        }
        else if account?.phoneNumber?.phoneNumber != nil {
            //if the user is logged with phone
            print(account!.phoneNumber!.stringRepresentation())
            UserDefaults.standard.setValue(account!.phoneNumber?.stringRepresentation(), forKey: "accountKitPhoneNumber")
        }
        
        self.showStories()
    }
    
   // showStories()
}
func viewController(_ viewController: UIViewController!, didCompleteLoginWithAuthorizationCode code: String!, state: String!) {
    print("Login succcess with AuthorizationCode")
}
    
    

    
func viewController(_ viewController: UIViewController!, didFailWithError error: Error!) {
    print("We have an error \(error)")
}
func viewControllerDidCancel(_ viewController: UIViewController!) {
    print("The user cancel the login")
}

func prepareLoginViewController(_ loginViewController: AKFViewController) {
    
    loginViewController.delegate = self
    loginViewController.advancedUIManager = nil
    
    //Costumize the theme
    let theme:AKFTheme = AKFTheme.default()
    theme.headerBackgroundColor = UIColor(red: 0.325, green: 0.557, blue: 1, alpha: 1)
    theme.headerTextColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    theme.iconColor = UIColor(red: 0.325, green: 0.557, blue: 1, alpha: 1)
    theme.inputTextColor = UIColor(white: 0.4, alpha: 1.0)
    theme.statusBarStyle = .default
    theme.textColor = UIColor(white: 0.3, alpha: 1.0)
    theme.titleColor = UIColor(red: 0.247, green: 0.247, blue: 0.247, alpha: 1)
    loginViewController.theme = theme
    
    
}

@IBAction func loginWithPhone(_ sender: AnyObject) {
    //login with Phone
    let inputState: String = UUID().uuidString
    let viewController:AKFViewController = accountKit.viewControllerForPhoneLogin(with: nil, state: inputState)  as! AKFViewController
    viewController.enableSendToFacebook = true
    self.prepareLoginViewController(viewController)
    self.present(viewController as! UIViewController, animated: true, completion: nil)
}

@IBAction func loginWithEmail(_ sender: AnyObject) {
    //login with Email
    let inputState: String = UUID().uuidString
    let viewController: AKFViewController = accountKit.viewControllerForEmailLogin(withEmail: nil, state: inputState)  as! AKFViewController
    self.prepareLoginViewController(viewController)
    self.present(viewController as! UIViewController, animated: true, completion: { _ in })
}

    
    @IBAction func BraintreeBtnclicked(_ sender : UIButton)
    {
       
        showDropIn(clientTokenOrTokenizationKey: self.clientToken)
    }
    
    func showDropIn(clientTokenOrTokenizationKey: String) {
       
        dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
            } else if let result = result {
                
                
                if result.paymentOptionType == BTUIKPaymentOptionType.applePay
                {
                    print("applePay applePay")
                    
                    self.dropIn.dismiss(animated: true, completion: { 
                        
                        let paymentRequest = self.paymentRequest()
                        // Example: Promote PKPaymentAuthorizationViewController to optional so that we can verify
                        // that our paymentRequest is valid. Otherwise, an invalid paymentRequest would crash our app.
                        if let vc = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
                            as PKPaymentAuthorizationViewController?
                        {
                            vc.delegate = self
                            self.present(vc, animated: true, completion: nil)
                        } else {
                            print("Error: Payment request is invalid.")
                        }
                    })
                    
                }else if result.paymentOptionType == BTUIKPaymentOptionType.payPal
                {
                    print("payPal payPal")
                }else
                {
                    print("Other Card")
                }

            }
            controller.dismiss(animated: true, completion: nil)
        }!
        self.present(dropIn, animated: true, completion: nil)
    }
    
    func fetchClientToken() {
        // TODO: Switch this URL to your own authenticated API
        let clientTokenURL = NSURL(string: "https://braintree-sample-merchant.herokuapp.com/client_token")!
        let clientTokenRequest = NSMutableURLRequest(url: clientTokenURL as URL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: clientTokenRequest as URLRequest) { (data, response, error) -> Void in
            // TODO: Handle errors
            
            self.clientToken = String(data: data!, encoding: String.Encoding.utf8)!
            // As an example, you may wish to present Drop-in at this point.
            // Continue to the next section to learn more...
            }.resume()
    }

func openUrl(_ url : String) {
    if #available(iOS 9.0, *) {
        let svc = SFSafariViewController(url: URL(string: url)!)
        svc.view.tintColor = UIColor(red:0.37, green:0.41, blue:0.91, alpha:1.0)
        self.present(svc, animated: true, completion: nil)
    } else {
        UIApplication.shared.openURL(URL(string: url)!)
    }
}
    
    
    //MARK:- DropIn Delegate
    
    func reloadDropInData() {
        
        print("reloadDropInData")
    }
    
    
    //MARK:- PassKit
    
    func paymentRequest() -> PKPaymentRequest {
        let paymentRequest = PKPaymentRequest()
        paymentRequest.merchantIdentifier = "merchant.com.pearldream.dreamafrica";
        paymentRequest.supportedNetworks = PKPaymentRequest.availableNetworks()
//[PKPaymentNetwork.amex, PKPaymentNetwork.visa, PKPaymentNetwork.masterCard];
        paymentRequest.merchantCapabilities = PKMerchantCapability.capability3DS;
        paymentRequest.countryCode = "US"; // e.g. US
        paymentRequest.currencyCode = "USD"; // e.g. USD
        paymentRequest.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "DreameAi", amount: NSDecimalNumber(string: "100.0")),
            // Add payment summary items...
            PKPaymentSummaryItem(label: "Multipz", amount: NSDecimalNumber(string: "200.0"))
        ]
        return paymentRequest
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                            didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        
        // Example: Tokenize the Apple Pay payment
        let applePayClient = BTApplePayClient(apiClient: braintreeClient!)
        applePayClient.tokenizeApplePay(payment) {
            (tokenizedApplePayPayment, error) in
            guard let tokenizedApplePayPayment = tokenizedApplePayPayment else {
                // Tokenization failed. Check `error` for the cause of the failure.
                
                // Indicate failure via completion callback.
                completion(PKPaymentAuthorizationStatus.failure)
                
                return
            }
            
            // Received a tokenized Apple Pay payment from Braintree.
            // If applicable, address information is accessible in `payment`.
            
            // Send the nonce to your server for processing.
            print("nonce = \(tokenizedApplePayPayment.nonce)")
            
            // Then indicate success or failure via the completion callback, e.g.
            completion(PKPaymentAuthorizationStatus.success)
        }
    }
    
    // Be sure to implement paymentAuthorizationViewControllerDidFinish.
    // You are responsible for dismissing the view controller in this method.
    @available(iOS 8.0, *)
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func paymentAuthorizationViewControllerWillAuthorizePayment(_ controller: PKPaymentAuthorizationViewController) {
        
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelect paymentMethod: PKPaymentMethod, completion: @escaping ([PKPaymentSummaryItem]) -> Void) {
        
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelect shippingMethod: PKShippingMethod, completion: @escaping (PKPaymentAuthorizationStatus, [PKPaymentSummaryItem]) -> Void) {
        
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelectShippingContact contact: PKContact, completion: @escaping (PKPaymentAuthorizationStatus, [PKShippingMethod], [PKPaymentSummaryItem]) -> Void) {
        
    }
}
