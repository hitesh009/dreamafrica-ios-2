//
//  MovieDetailViewController.swift
//  Butter
//
//  Created by DjinnGA on 24/07/2015.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

import UIKit
import FloatRatingView
import XCDYouTubeKit

class MovieDetailViewController: UIViewController, ButterLoadingViewControllerDelegate, VDLPlaybackViewControllerDelegate, TablePickerViewDelegate, UIActionSheetDelegate {

    @IBOutlet var fanartTopImageView: UIImageView!
    @IBOutlet var fanartBottomImageView: UIImageView!
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var itemTitleLabelView: UILabel!
    @IBOutlet var itemDetailsLabelView: UILabel!
    @IBOutlet var itemSynopsisTextView: UITextView!
    @IBOutlet var itemRatingView: FloatRatingView!
    @IBOutlet var qualityBtn: UIButton!
	@IBOutlet weak var subtitlesButton: UIButton!
    
    var loadingVC: ButterLoadingViewController?
    var paymentVC: PaymentViewController?
    var currentItem: ButterItem?
    
    var quality: String = "720p"
    var qualityIDs :[String] = []
	
	var subtitles = [String : String]()
	var selectedSubtitleURL : String?
	
	var favouriteBtn : UIBarButtonItem!
	var watchedBtn : UIBarButtonItem!
	var subtitlesTablePickerView : TablePickerView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
        //Load data onto the view
		self.fanartTopImageView.alpha = 0.0
		self.fanartBottomImageView.alpha = 0.0
		
		fillView()
		
        if (!currentItem!.hasProperty("fanart")) {
            TraktTVAPI.sharedInstance.requestMovieInfo(currentItem!.getProperty("imdb") as! String!, onCompletion: {
				self.fillView()
            })
        }
		
		addSubtitlesTablePicker()
		YIFYSubtitles.sharedInstance.getSubtitle(currentItem!.getProperty("imdb") as! String!) { (subtitlesPerLanguageCode) in
			self.subtitles = subtitlesPerLanguageCode
			self.subtitlesTablePickerView?.setSourceDictionay(subtitlesPerLanguageCode)
            
            if let preferredLang = UserDefaults.standard.object(forKey: "PreferredSubtitleLanguage") as? String {
                if preferredLang != "None" {
                    let lang = ButterAPIManager.languages[preferredLang]!
                    if subtitlesPerLanguageCode.allKeysForValue(lang).count > 0 {
                        let key = subtitlesPerLanguageCode.allKeysForValue(lang)[0]
                        self.subtitlesTablePickerView?.setSelected([key])
                        self.selectedSubtitleURL = key
                        self.subtitlesButton.setTitle(lang + " ▾", for: UIControlState())
                    }
                }
            }
            
		}
		
		// Add Watched and Favourites Buttons
		favouriteBtn = UIBarButtonItem(image: getFavoriteButtonImage(), style: .plain, target: self, action: #selector(MovieDetailViewController.toggleFavorite))
		watchedBtn = UIBarButtonItem(image: getWatchedButtonImage(), style: .plain, target: self, action: #selector(MovieDetailViewController.toggleWatched))
		self.navigationItem.setRightBarButtonItems([favouriteBtn, watchedBtn], animated:false)
        
        
        // Set Paralax Effect on Fanart
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y",
            type: .tiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -15
        verticalMotionEffect.maximumRelativeValue = 15
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x",
            type: .tiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -15
        horizontalMotionEffect.maximumRelativeValue = 15
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        fanartTopImageView.addMotionEffect(group)
        fanartBottomImageView.addMotionEffect(group)
    }
	
	func fillView() {
        if let currentItem = currentItem {
            coverImageView.image = currentItem.getProperty("cover") as? UIImage
            itemTitleLabelView.text = currentItem.getProperty("title") as? String
            
            if let fanArt = currentItem.getProperty("fanart") as? UIImage {
//                setFanArt(fanArt)
            }
            
            if let description = currentItem.getProperty("description") as? String {
                self.itemSynopsisTextView.text = description
            } else {
                self.itemSynopsisTextView.text = ""
            }
            
            if let rating = currentItem.getProperty("rating") as? Double {
                itemRatingView.rating = Float(rating/2)
            }
            
            if let gen = currentItem.getProperty("genres") as? String {
                if let yr = currentItem.getProperty("year") as? Int {
                    if let run = currentItem.getProperty("runtime") as? Int {
                        itemDetailsLabelView.text = "\(gen) ● \(yr) ● \(run) min."
                    }
                }
            }
        }
	}
	
	func addSubtitlesTablePicker() {
		subtitlesTablePickerView = TablePickerView(superView: self.view, sourceDict: nil, self)
		subtitlesTablePickerView?.setCellBackgroundColor(UIColor.clear)
		subtitlesTablePickerView?.setCellTextColor(UIColor.lightGray)
		subtitlesTablePickerView?.setCellSeperatorColor(UIColor.darkGray)
		subtitlesTablePickerView?.tableView.backgroundColor = UIColor.clear
		subtitlesTablePickerView?.setMultipleSelect(false)
		subtitlesTablePickerView?.setNullAllowed(true)
		let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
		subtitlesTablePickerView?.tableView.backgroundView = blurEffectView
		self.tabBarController?.view.addSubview(subtitlesTablePickerView!)
	}
	
    override func viewWillAppear(_ animated: Bool) {
        // Do any additional setup after loading the view.
        // Set the navigation bar to transparent and tint to white.
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for:UIBarMetrics.default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = true
        self.navigationController!.view.backgroundColor = UIColor.clear
        self.navigationController!.navigationBar.backgroundColor = UIColor.clear
        self.navigationController!.navigationBar.tintColor = UIColor.white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController!.navigationBar.setBackgroundImage(nil, for:UIBarMetrics.default)
    }
	
	func setFanArt(_ image : UIImage) {
		self.fanartTopImageView.image = image
		let flippedImage: UIImage = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation:UIImageOrientation.downMirrored)
		self.fanartBottomImageView.image = flippedImage
		
		UIView.animate(withDuration: 0.2, animations: { () -> Void in
			self.fanartTopImageView.alpha = 1
			self.fanartBottomImageView.alpha = 1
		})
	}
	
    func getFavoriteButtonImage() -> UIImage? {
        var favImage = UIImage(named: "favoritesOff")?.withRenderingMode(.alwaysOriginal)
        if let currentItem = currentItem {
            if MovieFavorites.isFavorite(currentItem.getProperty("imdb") as! String) {
                favImage = UIImage(named: "favoritesOn")?.withRenderingMode(.alwaysOriginal)
            }
        }
        
        return favImage
    }
    
    func getWatchedButtonImage() -> UIImage? {
        var watchedImage = UIImage(named: "watchedOff")?.withRenderingMode(.alwaysOriginal)
        if let currentItem = currentItem {
            if WatchedMovies.isWatched(currentItem.getProperty("imdb") as! String) {
                watchedImage = UIImage(named: "watchedOn")?.withRenderingMode(.alwaysOriginal)
            }
        }
        
        return watchedImage
    }
	
	func toggleFavorite() {
		if let currentItem = currentItem {
			MovieFavorites.toggleFavorite(currentItem.getProperty("imdb") as! String)
			favouriteBtn.image = getFavoriteButtonImage()
		}
	}
    
    func toggleWatched() {
        if let currentItem = currentItem {
            WatchedMovies.toggleWatched(currentItem.getProperty("imdb") as! String)
            watchedBtn.image = getWatchedButtonImage()
        }
    }
    
    @IBAction func changeQualityTapped(_ sender: UIButton) {
        if (currentItem!.torrents.count > 1) {
            if objc_getClass("UIAlertController") != nil {
                let qualitySheet: UIAlertController = UIAlertController(title:"Select Quality", message:nil, preferredStyle:UIAlertControllerStyle.actionSheet)
                for (_, thisTor) in currentItem!.torrents {
                    qualitySheet.addAction(UIAlertAction(title: "\(thisTor.quality)   \(thisTor.size)", style: .default, handler: { action in
                        self.quality = thisTor.quality
                        self.qualityBtn.setTitle("\(self.quality) ▾", for: UIControlState())
                    }))
                }
				qualitySheet.popoverPresentationController?.sourceView = sender as UIView // provide a popover sourceView on iPad
                self.present(qualitySheet, animated: true, completion: nil)
            } else {
                let qualitySheet: UIActionSheet = UIActionSheet(title: "Select Quality", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
                for (_, thisTor) in currentItem!.torrents {
                    qualitySheet.addButton(withTitle: "\(thisTor.quality)   \(thisTor.size)")
                    qualityIDs.append(thisTor.quality)
                }
                qualitySheet.show(in: self.view)
            }
        }
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        quality = qualityIDs[buttonIndex]
        self.qualityBtn.setTitle("\(quality) ▾", for: UIControlState())
    }
    
    @IBAction func changeSubtitlesTapped(_ sender: UIButton) {
        subtitlesTablePickerView?.toggle()
    }
    
    @IBAction func watchNowTapped(_ sender: UIButton) {
        
        let onWifi : Bool = (UIApplication.shared.delegate! as! AppDelegate).reachability!.isReachableViaWiFi()
        let wifiOnly : Bool = !UserDefaults.standard.bool(forKey: "StreamOnCellular")
        
        if !wifiOnly || onWifi {
            let ud = UserDefaults.standard
            if (ud.bool(forKey: "userPaid")) {
                print("User paid loading story")
                loadStory()
            } else {
                print("User is not paid")
                var numberWatched = ud.integer(forKey: "numberWatched")
                if (numberWatched % 2 == 0) {
                    print("Loading story because \(numberWatched)") 
                    loadStory()
                } else {
                    print("Loading payment because \(numberWatched)") 
                    loadPayment()
                }
                numberWatched += 1
                ud.set(numberWatched, forKey: "numberWatched")
            }        
        } else {
            let errorAlert = UIAlertController(title: "Cellular Data is Turned Off for streaming", message: "To enable it please go to settings.", preferredStyle: UIAlertControllerStyle.alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in }))
            errorAlert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action: UIAlertAction!) in
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let settingsVc = storyboard.instantiateViewController(withIdentifier: "SettingsView") as! SettingsTableViewController
                self.navigationController?.pushViewController(settingsVc, animated: true)
            }))
            self.present(errorAlert, animated: true, completion: nil)
        }
    }
    
    func loadPayment() {
        paymentVC = self.storyboard?.instantiateViewController(withIdentifier: "paymentViewController") as? PaymentViewController
        paymentVC!.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.navigationController?.pushViewController(paymentVC!, animated: true)
    }
    
    func loadStory() {
        loadingVC = self.storyboard?.instantiateViewController(withIdentifier: "loadingViewController") as? ButterLoadingViewController
        loadingVC!.delegate = self
        loadingVC!.status = "Downloading..."
        loadingVC!.loadingTitle = currentItem!.getProperty("title") as? String
        //loadingVC!.bgImg = coverImageView.image! //Can cause crash if not loaded yet
        loadingVC!.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(loadingVC!, animated: true, completion: nil)
        
        let runtime = currentItem!.getProperty("runtime") as! Int
        
        if (currentItem!.torrents[quality]!.hash != "") {
            let magnetLink: String = ButterAPIManager.sharedInstance.makeMagnetLink(currentItem!.torrents[quality]!.hash, title: currentItem!.getProperty("title") as! String)
            loadMovieTorrent(magnetLink, runtime: runtime)
        } else {
            RestApiManager.sharedInstance.makeAsyncDataRequest(currentItem!.torrents[quality]!.url, onCompletion: saveTorrentToFile)
        }
    }
    
    func saveTorrentToFile(_ torrent: Data) {
        let url: URL = URL(string: currentItem!.torrents[quality]!.url)!
        let runtime = currentItem!.getProperty("runtime") as! Int
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
        if FileManager().fileExists(atPath: destinationUrl.path) {
            print("file already exists [\(destinationUrl.path)]")
            loadMovieTorrent(destinationUrl.path, runtime: runtime)
        } else {
            if (try? torrent.write(to: destinationUrl, options: [.atomic])) != nil {
                print("file saved [\(destinationUrl.path)]")
                loadMovieTorrent(destinationUrl.path, runtime: runtime)
            } else {
                print("error saving file")
            }
        }
    }
    
    func loadMovieTorrent(_ torrURL: String, runtime: Int) {
        ButterTorrentStreamer.shared().startStreaming(fromFileOrMagnetLink: torrURL, runtime: Int32(runtime), progress: { (status) -> Void in
            
            self.loadingVC!.progress = status.totalProgreess
            self.loadingVC!.speed = Int(status.downloadSpeed)
//            self.loadingVC!.seeds = Int(status.seeds)
//            self.loadingVC!.peers = Int(status.peers)
            
            }, readyToPlay: { (url) -> Void in
                self.loadingVC!.dismiss(animated: false, completion: { () -> Void in
                    let vdl = VDLPlaybackViewController(nibName: "VDLPlaybackViewController", bundle: nil)
                    vdl.delegate = self
                    self.navigationController?.present(vdl, animated: true, completion: nil)
                    vdl.playMedia(from: url)
                })
                
            }, failure: { (error) -> Void in
                self.loadingVC!.dismiss(animated: true, completion: nil)
        })
    }
	
	@IBAction func coverTapped(_ sender: AnyObject) {
		if let trailer = currentItem?.getProperty("trailer") as? String {
			let splitted = trailer.components(separatedBy: "?v=")
			if let id = splitted.last {
				let vc = XCDYouTubeVideoPlayerViewController(videoIdentifier: id)
				presentMoviePlayerViewControllerAnimated(vc)
			}
		}
	}
	
	func tablePickerView(_ tablePickerView: TablePickerView, didChange items: [String]) {
		if items.count == 0 {
			selectedSubtitleURL = nil
			subtitlesButton.setTitle("None ▾", for: UIControlState())
		} else {
			selectedSubtitleURL = items[0]
			subtitlesButton.setTitle(subtitles[items[0]]! + " ▾", for: UIControlState())
		}
	}

    // MARK: - PlaybackViewControllerDelegate
    func playbackControllerDidFinishPlayback(_ playbackController: VDLPlaybackViewController!) {
        self.navigationController?.dismiss(animated: true, completion: nil)
        ButterTorrentStreamer.shared().cancelStreaming()
    }
    
    // MARK: - ButterLoadingViewControllerDelegate
    func didCancelLoading(_ controller: ButterLoadingViewController) {
        ButterTorrentStreamer.shared().cancelStreaming()
        controller.dismiss(animated: true, completion: nil)
    }
}
