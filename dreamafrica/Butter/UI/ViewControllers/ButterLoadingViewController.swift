//
//  ButterLoadingViewController
//  Butter
//
//  Created by Danylo Kostyshyn on 3/15/15.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

import UIKit

protocol ButterLoadingViewControllerDelegate {
    func didCancelLoading(_ controller: ButterLoadingViewController)
}

class ButterLoadingViewController: UIViewController {

    var delegate: ButterLoadingViewControllerDelegate?
    var paymentVC: PaymentViewController?
    
    @IBOutlet fileprivate weak var statusLabel: UILabel!
    @IBOutlet fileprivate weak var progressLabel: UILabel!
    @IBOutlet fileprivate weak var progressView: UIProgressView!
    @IBOutlet fileprivate weak var speedLabel: UILabel!
    @IBOutlet fileprivate weak var seedsLabel: UILabel!
    @IBOutlet fileprivate weak var peersLabel: UILabel!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var backgroundImage: UIImageView!
    
    var status: String? = nil {
        didSet {
            if let status = status {
                statusLabel?.text = status
            }
        }
    }
    
    var progress: Float = 0.0 {
        didSet {
            progressView.progress = progress
            progressLabel.text = String(format: "%.0f%%", progress*100)
        }
    }
    
    var speed: Int = 0 { // bytes/s
        didSet {
            let formattedSpeed = ByteCountFormatter.string(fromByteCount: Int64(speed), countStyle: .binary) + "/s"
            speedLabel.text = String(format:"Speed: %@", formattedSpeed)
        }
    }
    
//    var seeds: Int = 0 {
//        didSet {
//            seedsLabel.text = String(format: "Seeds: %d", seeds)
//        }
//    }
    
//    var peers: Int = 0 {
//        didSet {
//            peersLabel.text = String(format: "Peers: %d", peers)
//        }
//    }
    
    var loadingTitle: String? = nil {
        didSet {
            if let title = loadingTitle {
                titleLabel?.text = title
            }
        }
    }
    
    var bgImg: UIImage? = nil {
        didSet {
            if let img = bgImg {
                backgroundImage?.image = img
            }
        }
    }

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel?.text = loadingTitle
        status = "Loading..."
        progress =  0.0
        speed = 0
//        seeds = 0
//        peers = 0
        
        UIApplication.shared.isIdleTimerDisabled = true;
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = false;
    }

    // MARK: - Actions

    @IBAction fileprivate func cancelButtonPressed(_ sender: AnyObject) {
        delegate?.didCancelLoading(self)
    }
    
}
