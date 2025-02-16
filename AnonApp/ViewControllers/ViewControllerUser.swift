//
//  ViewControllerUser.swift
//  AnonApp
//
//  Created by Matthew Capriotti on 4/25/20.
//  Copyright © 2020 Matthew Capriotti. All rights reserved.
//

import UIKit
import Firebase

class ViewControllerUser: myUIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    
    @IBOutlet weak var progressDot: UIView!
    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var levelLable: UILabel!
    @IBOutlet weak var firstRangeLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var userScoreLabel: UILabel!
    @IBOutlet weak var secondRangeLabel: UILabel!
    @IBOutlet weak var viewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newBtn: UIButton!
    @IBOutlet weak var topBtn: UIButton!
    @IBOutlet weak var bottomBarLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var leadingScoreBarConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var redeemBtn: UIButton!
    
    
  //  var bioHeightConstraint:NSLayoutConstraint?
    var uid:String?
    var uidProfile:String?
  private weak var quipVC:ViewControllerQuip?
   private weak var passedQuip:Quip?
   var myLikesDislikesMap:[String:Int] = [:]
   var myNewLikesDislikesMap:[String:Int] = [:]
   var myChannelsMap:[String:String] = [:]
   var myParentChannelsMap:[String:String] = [:]
   var myParentQuipsMap:[String:String] = [:]
    let bioPlaceholderText = "Insert Bio"
    var progressBarLength:CGFloat = 0
    var progress:Float = 0
    var nuts:Int = 0
   
    
 
    
 
    
    lazy var settingsMenuLauncher:SettingsMenuQuip = {
                 let launcher = SettingsMenuQuip()
              launcher.userController = self
                  return launcher
             }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
     //   bioHeightConstraint = NSLayoutConstraint(item: bioTextView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        // Do any additional setup after loading the view.
        if navigationController?.viewControllers.count == 1{
             
             
        }else{
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = nil
            addGesture()
        }
        bioTextView.isHidden = true
        
        nameTextView.layer.cornerRadius = 10
        nameTextView.clipsToBounds = true
        bioTextView.layer.cornerRadius = 10
        bioTextView.clipsToBounds = true
        nameTextView.textContainer.maximumNumberOfLines = 2
        nameTextView.textContainer.lineBreakMode = .byClipping
        bioTextView.textContainer.maximumNumberOfLines = 5
        bioTextView.textContainer.lineBreakMode = .byClipping
        bioTextView.tintColorDidChange()
        nameTextView.tintColorDidChange()
        bioTextView.textContainerInset = .zero
        nameTextView.textContainerInset = .zero
       
        progressDot.layer.zPosition = 1
        progressDot.layer.cornerRadius = 4
        progressDot.clipsToBounds = true
        
        
            collectionView.delegate = self
                   collectionView.dataSource = self
                  setUpButtons()
                  selectNew()
        redeemBtn.layer.cornerRadius = 20
        redeemBtn.clipsToBounds = true
       
    }
    
   
    
    override func viewWillAppear(_ animated: Bool){
          super.viewWillAppear(animated)
        if navigationController?.viewControllers.count == 1{
          //maybe move to view did load
              self.uid = UserDefaults.standard.string(forKey: "UID")
            uidProfile = uid
           // loadUserProfile()
            getUserScore()
        }
           
        }
    
    //updates firestore and firebase with likes when view is dismissed
      override func viewWillDisappear(_ animated: Bool){
             super.viewWillDisappear(animated)
        let indexPath = IndexPath(item: 0, section: 0)
        if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCellUserNew{
            cell.refreshControl.endRefreshing()
        }
        let indexPath2 = IndexPath(item: 1, section: 0)
        if let cell = collectionView.cellForItem(at: indexPath2) as? CollectionViewCellUserTop{
            cell.refreshControl.endRefreshing()
        }
          
             
           }
    func loadUserProfile(){
        if let auid = uidProfile{
        /*
        FirestoreService.sharedInstance.getUserProfile(uid: auid) {[weak self] (name, bio) in
            self?.nameTextView.text = name
            self?.bioTextView.text = bio
            if bio == self?.bioPlaceholderText{
             //   self?.bioTextView.addConstraint((self?.bioHeightConstraint)!)
                self?.bioTextView.isHidden = true
            }else{
             //   self?.bioTextView.removeConstraint((self?.bioHeightConstraint)!)
                self?.bioTextView.isHidden = false
            }
            self?.view.setNeedsLayout()
        }
             */
        }
        
    }
    
    func setUpButtons(){
               let selectedColor = UIColor(hexString: "ffaf46")
                newBtn.setTitleColor(selectedColor, for: .selected  )
                topBtn.setTitleColor(selectedColor, for: .selected  )
                
            }
    
    func getUserScore(){
        if let auid = uidProfile{
            FirebaseService.sharedInstance.getUserOverallScore(uid: auid) {[weak self] (score) in
                self?.adjustScoreLogic(score: score)
                
            }
        }
    }
    
    func adjustScoreLogic(score:Int){
        
        if score < 0 {
            userScoreLabel.text = "0"
            levelLable.text = "Nut Count: 0"
            firstRangeLabel.text = "0"
            secondRangeLabel.text = "100"
            progressBarLength = progressBar.bounds.width
            progressBar.progress = 0.0
            leadingScoreBarConstraint.constant = 0
            
        }
        else{
            let nextScore = score % 100
            nuts = Int(floor(Double(score)/100.0))
            
            userScoreLabel.text = String(nextScore)
            levelLable.text = "Nut Count: \(nuts)"
            self.view.layoutIfNeeded()
                      let progress = Float(nextScore) / 100.0
                  progressBar.progress = progress
                      progressBarLength = progressBar.bounds.width
                      leadingScoreBarConstraint.constant = progressBarLength * CGFloat(progress)
        }
        /*
        else if score < 100{
        
        userScoreLabel.text = String(score)
        levelLable.text = "Level 1"
        firstRangeLabel.text = "0"
        secondRangeLabel.text = "100"
            self.view.layoutIfNeeded()
            let progress = Float(score) / 100.0
        progressBar.progress = progress
            progressBarLength = progressBar.bounds.width
            leadingScoreBarConstraint.constant = progressBarLength * CGFloat(progress)
        }
        else if score < 1000{
            userScoreLabel.text = String(score)
                   levelLable.text = "Level 2"
                   firstRangeLabel.text = "100"
                   secondRangeLabel.text = "1000"
            self.view.layoutIfNeeded()
                       let progress = (Float(score) - 100) / 900.0
                   progressBar.progress = progress
             progressBarLength = progressBar.bounds.width
                       leadingScoreBarConstraint.constant = progressBarLength * CGFloat(progress)
        }
        else if score < 10000{
                   userScoreLabel.text = String(score)
                          levelLable.text = "Level 3"
                          firstRangeLabel.text = "1000"
                          secondRangeLabel.text = "10000"
                self.view.layoutIfNeeded()
                              let progress = (Float(score) - 1000) / 9000.0
                          progressBar.progress = progress
             progressBarLength = progressBar.bounds.width
                              leadingScoreBarConstraint.constant = progressBarLength * CGFloat(progress)
               }
 */
        
    }
    
    @IBAction func newBtnClicked(_ sender: Any) {
        selectNew()
               scrollToItemAtIndexPath(index: 0)
    }
    
    @IBAction func topBtnClicked(_ sender: Any) {
        selectTop()
               scrollToItemAtIndexPath(index: 1)
    }
    
    func selectNew(){
        topBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        newBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
           newBtn.isSelected = true
           topBtn.isSelected = false
           
       }
       
       func selectTop(){
        topBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        newBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
           newBtn.isSelected = false
           topBtn.isSelected = true
           
           
       }
    
    func scrollToItemAtIndexPath(index: Int){
                let indexPath = IndexPath(item: index, section: 0)
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
      
      func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return 2
       }
       
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           if indexPath.row == 0{
               if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newCell", for: indexPath) as? CollectionViewCellUserNew{
                  cell.myUserController = self
                  cell.updateNew()
                return cell
               }
               
           }else if indexPath.row == 1{
               if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topCell", for: indexPath) as? CollectionViewCellUserTop{
                  cell.myUserController = self
                  cell.updateTop()
                return cell
               }
               
           }
         
           
           return UICollectionViewCell()
       }
       
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
       }
       
       func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
           let index = targetContentOffset.pointee.x / view.frame.width
           if index == 0 {
              selectNew()
           }else if index == 1{
               selectTop()
           }
           
       }
      
      func scrollViewDidScroll(_ scrollView: UIScrollView) {
          bottomBarLeadingConstraint.constant = scrollView.contentOffset.x / 2
      }
    
    
      
      //resets all arrays haveing to do with new user likes/dislikes
      func resetVars(){
          myChannelsMap=[:]
          myNewLikesDislikesMap=[:]
     
      }
   
    @IBAction func settingsBtnClicked(_ sender: Any) {
       
        settingsMenuLauncher.makeViewFade()
        settingsMenuLauncher.addMenuFromSide()
    }
    
    func showNextControllerSettings(menuItem:MenuItem){
        if menuItem.name == "Edit Profile"{
            changeToEditMode()
        }else if menuItem.name == "Privacy Policy"{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PrivacyController") as! myUIViewController
            navigationController?.pushViewController(nextViewController, animated: true)
        }else if menuItem.name == "Report a Problem"{
            let email = supportEmail
            if let url = URL(string: "mailto:\(email)") {
                 UIApplication.shared.open(url)
            }
        }else if menuItem.name == "Contact Us"{
            let email = supportEmail
                       if let url = URL(string: "mailto:\(email)") {
                            UIApplication.shared.open(url)
                       }
        }else if menuItem.name == "Link Email"{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "CreateAccount") as! myUIViewController
            nextViewController.navigationItem.title = "Link Email"
            navigationController?.pushViewController(nextViewController, animated: true)
        }else if menuItem.name == "EULA"{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                       let nextViewController = storyBoard.instantiateViewController(withIdentifier: "EULAViewController") as! myUIViewController
                       navigationController?.pushViewController(nextViewController, animated: true)
        }else if menuItem.name == "Share"{
            shareApp()
        }
        
    }
    func shareApp(){
        var components = URLComponents()
        components.scheme = "https"
        components.host = "nuthouse.page.link"
        components.path = "/app"
        
        let eventUIDQueryItem = URLQueryItem(name: "invitedby", value: uid)
      
        components.queryItems = [eventUIDQueryItem]
        guard let linkparam = components.url else {return}
        print(linkparam)
        let dynamicLinksDomainURIPrefix = "https://nuthouse.page.link"
        guard let sharelink = DynamicLinkComponents.init(link: linkparam, domainURIPrefix: dynamicLinksDomainURIPrefix) else {return}
        if let bundleId = Bundle.main.bundleIdentifier {
            sharelink.iOSParameters = DynamicLinkIOSParameters(bundleID: bundleId)
        }
        //change to app store id
        sharelink.iOSParameters?.appStoreID = appStoreID
        sharelink.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        sharelink.socialMetaTagParameters?.imageURL = logoURL
        
       // sharelink.socialMetaTagParameters?.descriptionText = aquip.channel
       
            guard let longDynamicLink = sharelink.url else { return }
            print("The long URL is: \(longDynamicLink)")
                sharelink.shorten {[weak self] (url, warnings, error) in
                    if let error = error{
                        print(error)
                        return
                    }
                    if let warnings = warnings{
                        for warning in warnings{
                            print(warning)
                        }
                    }
                    guard let url = url else {return}
                    print(url)
                    self?.showShareViewController(url: url)
                }
        
        
            Analytics.logEvent(AnalyticsEventShare, parameters:
                [AnalyticsParameterItemID:"id- \(uid ?? "Other")",
                    AnalyticsParameterItemName: uid ?? "None",
                          AnalyticsParameterContentType: "event"])
        
    }
    
    func showShareViewController(url:URL){
        let myactivity1 = "Join the Nut House now!"
        let myactivity2 = url
                             
                        
                               // set up activity view controller
        let firstactivity = [myactivity1, myactivity2] as [Any]
                        let activityViewController = UIActivityViewController(activityItems: firstactivity, applicationActivities: nil)
                              activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash

                               // exclude some activity types from the list (optional)
                        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.markupAsPDF, UIActivity.ActivityType.openInIBooks, UIActivity.ActivityType.print]

                               // present the view controller
                               self.present(activityViewController, animated: true, completion: nil)
    }
    
    func showNextControllerEllipses(menuItem: MenuItem, quip: Quip?){
        if menuItem.name == "View Event Feed"{
            
        }else if menuItem.name == "Report Crack"{
            if let aquip = quip{
            FirestoreService.sharedInstance.reportQuip(quip: aquip)
            
            }
            displayMsgBox()
        }else if menuItem.name == "Share Crack"{
            if let aquip = quip{
            if let collectionViewCell = collectionView.visibleCells[0] as? CollectionViewCellUser{
                collectionViewCell.generateDynamicLink(aquip: aquip, cell: nil)
            }
            }
        }else if menuItem.name == "Delete Crack"{
            if let aQuipID = quip?.quipID{
                           FirestoreService.sharedInstance.deleteQuip(quipID: aQuipID){
                               self.collectionView.reloadData()
                           }
                       }
        }
        
    }
    
    func displayMsgBox(){
    let title = "Report Successful"
    let message = "The user has been reported. If you want to give us more details on this incident please email us at \(supportEmail)"
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
          switch action.style{
          case .default:
                print("default")

          case .cancel:
                print("cancel")

          case .destructive:
                print("destructive")


          @unknown default:
            print("unknown action")
        }}))
    self.present(alert, animated: true, completion: nil)
    }
  /*
    @IBAction func editBtnClicked(_ sender: Any) {
        if nameTextView.isEditable {
            changeToNormalMode()
            saveChanges()
        }else{
            changeToEditMode()
        }
    }
    */
    func changeToEditMode(){
      //  bioTextView.removeConstraint(bioHeightConstraint!)
        bioTextView.isHidden = false
        self.view.setNeedsLayout()
        nameTextView.isEditable = true
        nameTextView.isSelectable = true
        bioTextView.isSelectable = true
        bioTextView.isEditable = true
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .light{
                nameTextView.backgroundColor = .white
                bioTextView.backgroundColor = .white
            }else{
                nameTextView.backgroundColor = .darkGray
                bioTextView.backgroundColor = .darkGray
            }
        } else {
            // Fallback on earlier versions
            nameTextView.backgroundColor = .white
            bioTextView.backgroundColor = .white
        }
        self.navigationItem.leftBarButtonItem?.title = "Done"
        self.navigationItem.title = "Edit Profile"
        self.navigationItem.rightBarButtonItem?.isEnabled = false
       
    }
   
    func changeToNormalMode(){
        nameTextView.isEditable = false
        nameTextView.isSelectable = false
        bioTextView.isSelectable = false
        bioTextView.isEditable = false
        if #available(iOS 13.0, *) {
            nameTextView.backgroundColor = .secondarySystemBackground
            bioTextView.backgroundColor = .secondarySystemBackground
        } else {
            // Fallback on earlier versions
            nameTextView.backgroundColor = self.view.backgroundColor
            bioTextView.backgroundColor = self.view.backgroundColor
        }
        if bioTextView.text == bioPlaceholderText{
      //      bioTextView.addConstraint(bioHeightConstraint!)
            bioTextView.isHidden = true
        }else{
      //     bioTextView.removeConstraint(bioHeightConstraint!)
            bioTextView.isHidden = false
            
        }
        
        
        self.navigationItem.leftBarButtonItem?.title = "Edit"
        self.navigationItem.title = "Profile"
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    func saveChanges(){
        if let auid = uid{
            FirestoreService.sharedInstance.saveUserProfile(uid: auid, name: nameTextView.text, bio: bioTextView.text)
        }
        
    }
    
   
    
   
       
    func updateVotesFirebase(diff:Int, quipID:String, myQuip:Quip){
        //increment value has to be double or long or it wont work properly
        let myDiff = Double(diff)
        var myVotes:[String:Any] = [:]
        if let aChannelKey =  myQuip.channelKey{
           myVotes["A/\(aChannelKey)/Q/\(quipID)/s"] = ServerValue.increment(NSNumber(value: myDiff))
           }
        if let aParentChannelKey = myQuip.parentKey{
              myVotes["A/\(aParentChannelKey)/Q/\(quipID)/s"] = ServerValue.increment(NSNumber(value: myDiff))
           }
        if let aUID = uidProfile {
           myVotes["M/\(aUID)/q/\(quipID)/s"] = ServerValue.increment(NSNumber(value: myDiff))
            myVotes["M/\(aUID)/s"] = ServerValue.increment(NSNumber(value: myDiff))
           }
        if myQuip.isReply {
            if let quipParent = myQuip.quipParent{
            myVotes["Q/\(quipParent)/R/\(quipID)/s"] = ServerValue.increment(NSNumber(value: myDiff))
            }
        }
        updateFirestoreLikesDislikes()
               FirebaseService.sharedInstance.updateChildValues(myUpdates: myVotes)
                 resetVars()
       }
       
    func updateFirestoreLikesDislikes(){
        if myNewLikesDislikesMap.count>0{
           if let aUID = uid {
               if let bUId = uidProfile{
                
                FirestoreService.sharedInstance.updateLikesDislikes(myNewLikesDislikesMap: myNewLikesDislikesMap, aChannelOrUserKey: bUId, myMap: myChannelsMap, aUID: aUID, parentChannelKey: nil, parentChannelMap: myParentChannelsMap,parentQuipsMap: myParentQuipsMap)
                
            }
        }
       }
    }
  
    func checkNewQuips(myQuipID:String, isUp:Bool){
              var i = 0
        let indexPath = IndexPath(item: 0, section: 0)
               if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCellUserNew{
                for aQuip in cell.newUserQuips{
                
                 if aQuip?.quipID == myQuipID{
                     if let myQuip = aQuip{
                         updateOtherQuipList(index: 0, myQuip: myQuip, i: i, isUp: isUp)

                     }
                    
                 }
                i += 1
             }
        
        }
         }
    
    func checkHotQuips(myQuipID:String, isUp:Bool){
           var i = 0
        let indexPath = IndexPath(item: 1, section: 0)
        if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCellUserTop{
            for aQuip in cell.topUserQuips{
               
               if aQuip?.quipID == myQuipID{
                   if let myQuip = aQuip{
                       updateOtherQuipList(index: 1, myQuip: myQuip, i: i, isUp: isUp)

                   }
                   
               }
               i += 1
           }
        }
       }
    
    func updateOtherQuipList(index:Int, myQuip:Quip, i:Int, isUp:Bool){
        let indexPath = IndexPath(item: index, section: 0)
        if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCellUserNew{
            let indexPath2 = IndexPath(item: i, section: 0)
            if let myCell = cell.userQuipsTable.cellForRow(at: indexPath2) as? QuipCells{
            if isUp{
                cell.upPressedForOtherCell(aQuip: myQuip, cell: myCell)
            }else{
                cell.downPressedForOtherCell(aQuip: myQuip, cell: myCell)
            }
            }
        }
        if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCellUserTop{
        let indexPath2 = IndexPath(item: i, section: 0)
        if let myCell = cell.userQuipsTable.cellForRow(at: indexPath2) as? QuipCells{
                   if isUp{
                       cell.upPressedForOtherCell(aQuip: myQuip, cell: myCell)
                   }else{
                       cell.downPressedForOtherCell(aQuip: myQuip, cell: myCell)
                   }
                   }
    }
    }

   
     
    
     
  
    
    // MARK: - Navigation
    
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let redeemVC = segue.destination as? RedeemViewController{
            redeemVC.nutsAvailable = nuts
            redeemVC.auid = uidProfile
        }
        
        if let quipVC = segue.destination as? ViewControllerQuip{
               if newBtn.isSelected{
                   let indexPath = IndexPath(item: 0, section: 0)
                   if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCellUserNew {
                   if let index = cell.userQuipsTable.indexPathForSelectedRow?.row {
                       passedQuip = cell.newUserQuips[index]
                    passedQuip?.user = uidProfile
                    if passedQuip?.isReply ?? false{
                        quipVC.passedReply = passedQuip
                        
                    }
                   }
                if passedQuip?.isReply ?? false {
                               if let aquipId = passedQuip?.quipParent{
                               passedQuip = nil
                                   quipVC.loadParentQuip(aquipId: aquipId)
                               }
                    quipVC.currentTime = cell.currentTime
              //       let myCell = cell.userQuipsTable.cellForRow(at: cell.userQuipsTable.indexPathForSelectedRow!) as? QuipCells
                    //   quipVC.passedQuipCell = myCell
                     cell.userQuipsTable.deselectRow(at: cell.userQuipsTable.indexPathForSelectedRow!, animated: false)
                }else{
                   let myCell = cell.userQuipsTable.cellForRow(at: cell.userQuipsTable.indexPathForSelectedRow!) as? QuipCells
                              quipVC.quipScore = myCell?.score.text
                              if myCell?.upButton.isSelected == true {
                                  quipVC.quipLikeStatus = true
                              }
                              else if myCell?.downButton.isSelected == true{
                                  quipVC.quipLikeStatus = false
                              }
                   quipVC.currentTime = cell.currentTime
              //     quipVC.passedQuipCell = myCell
                   cell.userQuipsTable.deselectRow(at: cell.userQuipsTable.indexPathForSelectedRow!, animated: false)
                   }
                }
                
                   quipVC.parentIsNew = true
               }else if topBtn.isSelected{
                   let indexPath = IndexPath(item: 1, section: 0)
                   if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCellUserTop{
                   if let index = cell.userQuipsTable.indexPathForSelectedRow?.row {
                       passedQuip = cell.topUserQuips[index]
                    passedQuip?.user = uidProfile
                    if passedQuip?.isReply ?? false{
                        quipVC.passedReply = passedQuip
                        
                    }
                   }
                    if passedQuip?.isReply ?? false {
                        if let aquipId = passedQuip?.quipParent{
                            passedQuip = nil
                           
                            quipVC.loadParentQuip(aquipId: aquipId)
                                                  }
                                       quipVC.currentTime = cell.currentTime
              //           let myCell = cell.userQuipsTable.cellForRow(at: cell.userQuipsTable.indexPathForSelectedRow!) as? QuipCells
                   //quipVC.passedQuipCell = myCell
                         cell.userQuipsTable.deselectRow(at: cell.userQuipsTable.indexPathForSelectedRow!, animated: false)
                                   }else{
                   let myCell = cell.userQuipsTable.cellForRow(at: cell.userQuipsTable.indexPathForSelectedRow!) as? QuipCells
                                         quipVC.quipScore = myCell?.score.text
                                         if myCell?.upButton.isSelected == true {
                                             quipVC.quipLikeStatus = true
                                         }
                                         else if myCell?.downButton.isSelected == true{
                                             quipVC.quipLikeStatus = false
                                         }
                    quipVC.currentTime = cell.currentTime
                 //  quipVC.passedQuipCell = myCell
               cell.userQuipsTable.deselectRow(at: cell.userQuipsTable.indexPathForSelectedRow!, animated: false)
                   }
                }
                   quipVC.parentIsNew = false

               }
           
           
            
                       
            quipVC.myQuip = self.passedQuip
         
            quipVC.uid = uid
            
            
            
            quipVC.parentViewUser = self
            
            
        }
        
    }
    

}
