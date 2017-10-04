//
//  TVShowDetailViewController.swift
//  Butter
//
//  Created by DjinnGA on 30/09/2015.
//  Copyright © 2015 Butter Project. All rights reserved.
//

import UIKit
import FloatRatingView

class TVShowDetailViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var seasonsScroller: UIScrollView!
    fileprivate var seasonTitles: [String]! = [String]()
    fileprivate var seasonLabels:[Int:UILabel]! = [Int:UILabel]()
    fileprivate var selectedSeason: Int = 0;
    fileprivate var indicatorView:UIView!
    
    @IBOutlet weak var fanartImageHeight: NSLayoutConstraint!
    
    @IBOutlet var fanartTopImageView: UIImageView!
    @IBOutlet var fanartBottomImageView: UIImageView!
    @IBOutlet var itemDetailsLabelView: UILabel!
    @IBOutlet var itemSynopsisTextView: UITextView!
    @IBOutlet var itemRatingView: FloatRatingView!
    @IBOutlet var qualityBtn: UIButton!
    @IBOutlet var episodesTable: UITableView!
    
    var showSeasons : [Int:[ButterItem]] = [Int:[ButterItem]]()
    var seasonEpisodes : [ButterItem] = [ButterItem]()
    
    var favouriteBtn : UIBarButtonItem!
    var watchedBtn : UIBarButtonItem!
    
    var currentItem: ButterItem?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		episodesTable.tableFooterView = UIView()
		
        seasonsScroller.backgroundColor = UIColor.clear
        seasonsScroller.translatesAutoresizingMaskIntoConstraints = false
		
        indicatorView = UIView(frame: CGRect.zero)
		
        //Load data onto the view
        seasonTitles.append(currentItem!.getProperty("title") as! String)
		
		self.fanartTopImageView.alpha = 0.0
		self.fanartBottomImageView.alpha = 0.0
		self.itemSynopsisTextView.alpha = 0.0
		
		fillView()
        
        if ((currentItem!.getProperty("description")) == nil) {
            TVAPI.sharedInstance.requestShowInfo(currentItem!.getProperty("imdb") as! String!, onCompletion: {
				self.fillView()
            })
        }
        
        // Add Watched and Favourites Buttons
        favouriteBtn = UIBarButtonItem(image: getFavoriteButtonImage(), style: .plain, target: self, action: #selector(TVShowDetailViewController.toggleFavorite))
        watchedBtn = UIBarButtonItem(image: getWatchedButtonImage(), style: .plain, target: self, action: #selector(TVShowDetailViewController.toggleWatched))
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
		
		let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(TVShowDetailViewController.swipeSeason(_:)))
		swipeLeft.direction = .left
		view.addGestureRecognizer(swipeLeft)
		
		let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(TVShowDetailViewController.swipeSeason(_:)))
		swipeRight.direction = .right
		view.addGestureRecognizer(swipeRight)
	}
	
    override func viewWillAppear(_ animated: Bool) {
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
	
	func fillView() {
		if let fanArt = currentItem!.getProperty("fanart") as? UIImage {
			setFanArt(fanArt)
		}
		
		if let description = currentItem!.getProperty("description") as? String {
			self.itemSynopsisTextView.text = description
			UIView.animate(withDuration: 0.2, animations: { () in
				self.itemSynopsisTextView.alpha = 1
			})
		} else {
			self.itemSynopsisTextView.text = ""
		}
		
		if let rating = currentItem!.getProperty("rating") as? Float {
			itemRatingView.rating = rating
		}
		
		if let showSeasons = currentItem!.getProperty("seasons") as? [Int:[ButterItem]] {
			if self.showSeasons.count == 0 {
				self.showSeasons = showSeasons
				let sortedSeasons = showSeasons.sorted { $0.0 < $1.0 }
				for season in sortedSeasons {
					let seasonNum: Int = season.0
					self.seasonTitles.append("Season \(seasonNum)")
				}
			}
		}
		
		if seasonsScroller.subviews.count <= 3 {
			createSeasonsScroller()
		}
		
		if(indicatorView.frame == CGRect.zero) {
			indicatorView.frame = CGRect(x: seasonLabels[-1]!.frame.origin.x-5, y: 61, width: seasonLabels[-1]!.intrinsicContentSize.width+10, height: 3)
			indicatorView.backgroundColor = UIColor.white
			seasonsScroller.addSubview(indicatorView)
		}
		
		if let seas = currentItem!.getProperty("seasons") as? Int {
			if let yr = currentItem!.getProperty("year") as? String {
				if let run = currentItem!.getProperty("runtime") as? Int {
					if (seas > 1) {
						itemDetailsLabelView.text = "\(seas) Seasons ● \(yr) ● \(run) min."
					} else {
						itemDetailsLabelView.text = "\(seas) Season ● \(yr) ● \(run) min."
					}
				}
			}
		}
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
    
    func createSeasonsScroller(){
        var x , y ,buffer:CGFloat
        
        x=0;y=0;buffer=10
        
        let sortedSeasons = showSeasons.sorted { $0.0 < $1.0 }
		
        for i in 0 ..< seasonTitles.count {
            
            var titleLabel:UILabel!
            titleLabel=UILabel();
            
            //Label
            if (i == 0) {
                titleLabel.font = UIFont.boldSystemFont(ofSize: 22.0)
            } else {
                titleLabel.font = UIFont.systemFont(ofSize: 18.0)
            }
            titleLabel.text = seasonTitles[i] as String //.uppercaseString as String
            titleLabel.isUserInteractionEnabled = true
            let lblWidth:CGFloat
            lblWidth = titleLabel.intrinsicContentSize.width + 32
            
            titleLabel.frame = CGRect(x: x, y: 16, width: lblWidth, height: 34)
            titleLabel.textAlignment = .left
            if (i > 0) {
				let season = sortedSeasons[i-1]
				titleLabel.tag = season.0//i+1
            } else {
                titleLabel.tag = -1
            }
            titleLabel.textColor = UIColor.white
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(TVShowDetailViewController.handleTap(_:)))
            tap.delegate = self
            titleLabel.addGestureRecognizer(tap)
            
            seasonsScroller.addSubview(titleLabel)
            seasonLabels[titleLabel.tag] = titleLabel
            
            x+=lblWidth+buffer
        }
        seasonsScroller.showsHorizontalScrollIndicator=false;
        seasonsScroller.backgroundColor = UIColor.clear;
        seasonsScroller.contentSize = CGSize(width: x,height: 64)
        seasonsScroller.contentInset = UIEdgeInsetsMake(0, 15, 0, 0.0);
        seasonsScroller.contentOffset = CGPoint(x: -15, y: y)
        seasonsScroller.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func handleTap(_ sender:UIGestureRecognizer){
		showSeason(sender.view!.tag)
    }
	
	func swipeSeason(_ gesture: UIGestureRecognizer) {
		if let swipeGesture = gesture as? UISwipeGestureRecognizer {
			switch swipeGesture.direction {
			case UISwipeGestureRecognizerDirection.right:
				let seasonLeft = findPreviousSeason(selectedSeason)
				if seasonLeft != -1 {
					if let _ = self.view.viewWithTag(seasonLeft) as? UILabel {
						showSeason(seasonLeft)
					}
				} else {
					showSeason(-1)
				}
			case UISwipeGestureRecognizerDirection.left:
				let seasonRight = findNextSeason(selectedSeason)
				if seasonRight != -1 {
					if let _ = self.view.viewWithTag(seasonRight) as? UILabel {
						showSeason(seasonRight)
					}
				}
			default:
				break
			}
		}
	}
	
	func findNextSeason(_ currentSeasonNr : Int) -> Int {
		let orderedSeasons = showSeasons.keys.sorted()
		for nr in orderedSeasons {
			if nr > currentSeasonNr {
				return nr
			}
		}
		
		return -1
	}
	
	func findPreviousSeason(_ currentSeasonNr : Int) -> Int {
		let orderedSeasons = showSeasons.keys.sorted(by: >)
		for nr in orderedSeasons {
			if nr < currentSeasonNr {
				return nr
			}
		}
		
		return -1
	}
	
	func showSeason(_ nr : Int) {
		selectedSeason = nr
		seasonsScroller.scrollRectToVisible(self.seasonLabels[nr]!.frame, animated: true)
		
		if (selectedSeason > -1) {
			UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
				self.fanartImageHeight.constant = 120
				self.view.layoutIfNeeded()
				}, completion: nil)
			seasonEpisodes = showSeasons[selectedSeason]!
			episodesTable.reloadData()
			episodesTable.alpha = 1.0
			itemDetailsLabelView.alpha = 0.0
			itemSynopsisTextView.alpha = 0.0
			itemRatingView.alpha = 0.0
		} else {
			UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
				self.fanartImageHeight.constant = 232
				self.view.layoutIfNeeded()
				}, completion: nil)
			seasonEpisodes = [ButterItem]()
			episodesTable.alpha = 0.0
			episodesTable.reloadData()
			itemDetailsLabelView.alpha = 1.0
			itemSynopsisTextView.alpha = 1.0
			itemRatingView.alpha = 1.0
		}
		
		UIView.animate(withDuration: 0.2, animations: { () -> Void in
			self.indicatorView.frame = CGRect(x: self.seasonLabels[self.selectedSeason]!.frame.origin.x-5, y: 61, width: self.seasonLabels[self.selectedSeason]!.intrinsicContentSize.width+10, height: 3)
			self.indicatorView.backgroundColor = UIColor.white
			self.seasonsScroller.scrollRectToVisible(self.seasonLabels[self.selectedSeason]!.frame, animated: true)
		})
	}
	
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return seasonEpisodes.count
    }
	
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = episodesTable.dequeueReusableCell(withIdentifier: "episodeCell") as! PTEpisodeTableViewCell
        
        let num = seasonEpisodes[indexPath.row].getProperty("episode") as! Int
        cell.numberLabel!.text = "\(num)"
        cell.titleLabel!.text = seasonEpisodes[indexPath.row].getProperty("title") as? String
        cell.backgroundColor = UIColor.clear
		
		let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
		cell.selectedBackgroundView = blurEffectView
        
        return cell
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let episode = seasonEpisodes[indexPath.row]
		
		print(episode.torrents["480p"]!.url)
		
		// Start playing episode
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
    
    func getFavoriteButtonImage() -> UIImage? {
        var favImage = UIImage(named: "favoritesOff")?.withRenderingMode(.alwaysOriginal)
        if let currentItem = currentItem {
            if ShowFavorites.isFavorite(currentItem.getProperty("imdb") as! String) {
                favImage = UIImage(named: "favoritesOn")?.withRenderingMode(.alwaysOriginal)
            }
        }
        
        return favImage
    }
    
    func getWatchedButtonImage() -> UIImage? {
        var watchedImage = UIImage(named: "watchedOff")?.withRenderingMode(.alwaysOriginal)
        if let currentItem = currentItem {
            if WatchedShows.isWatched(currentItem.getProperty("imdb") as! String) {
                watchedImage = UIImage(named: "watchedOn")?.withRenderingMode(.alwaysOriginal)
            }
        }
        
        return watchedImage
    }
    
    func toggleFavorite() {
        if let currentItem = currentItem {
            ShowFavorites.toggleFavorite(currentItem.getProperty("imdb") as! String)
            favouriteBtn.image = getFavoriteButtonImage()
        }
    }
    
    func toggleWatched() {
        if let currentItem = currentItem {
            WatchedShows.toggleWatched(currentItem.getProperty("imdb") as! String)
            watchedBtn.image = getWatchedButtonImage()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
