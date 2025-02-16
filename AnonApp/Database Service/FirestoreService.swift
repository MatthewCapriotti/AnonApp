//
//  FirestoreService.swift
//  AnonApp
//
//  Created by Matthew Capriotti on 5/29/20.
//  Copyright © 2020 Matthew Capriotti. All rights reserved.
//

import UIKit
import Firebase

class FirestoreService: NSObject {

    
    let db = Firestore.firestore()
    
    static let sharedInstance = FirestoreService()
    
    private var lastRecentDocFeed:DocumentSnapshot?
    private var lastHotDocumentFeed:DocumentSnapshot?
    private var lastHotDocUser:DocumentSnapshot?
    private var myLastRecentDocUser:DocumentSnapshot?
    private var hotQuipAdds:[String] = []
    private var myNewHotQuipData:[String:Any] = [:]
    
    
    func getNewQuipsFeed(myChannelKey:String, myChannelName:String, completion: @escaping ([Quip], Bool)->() ){
        let channelRef = db.collection("Channels/\(myChannelKey)/RecentQuips")
               var moreRecentQuipsFirestore = false
        
        var newQuips:[Quip] = []
               //gets 2 most recent documents that have quips
        channelRef.order(by: "t", descending: true).whereField("a", isEqualTo: true).limit(to: 2).getDocuments(){[weak self] (querySnapshot, err) in
                   if let err = err {
                                   print("Error getting documents: \(err)")
                   }
                   else{
                       let length = querySnapshot!.documents.count
                       if length == 0 {
                        completion(newQuips, moreRecentQuipsFirestore)
                           return
                       }
                       
                       for i in 0...length-1{
                          
                           
                           let document = querySnapshot!.documents[i]
                       
                           if i == 1{
                            self?.lastRecentDocFeed = document
                               moreRecentQuipsFirestore = true
                           }
                           
                           guard document.data(with: ServerTimestampBehavior.estimate)["quips"] != nil else {continue}
                           let myQuips = document.data(with: ServerTimestampBehavior.estimate)["quips"] as! [String:Any]
                       let sortedKeys = Array(myQuips.keys).sorted(by: >)
                       
                       for aQuip in sortedKeys{
                           let myInfo = myQuips[aQuip] as! [String:Any]
                           let aQuipID = aQuip
                           let atimePosted = myInfo["d"] as? Timestamp
                           let aQuipText = myInfo["t"] as? String
                           let myAuthor = myInfo["a"] as? String
                           let channelkey = myInfo["k"] as? String
                        let parentChannelkey = myInfo["pk"] as? String
                        let aChannelName = myInfo["c"] as? String ?? myChannelName
                          
                           
                        let aQuipScore = 0
                        let aReplies = 0
                          let myImageRef = myInfo["i"] as? String
                           
                           let myOptions = myInfo["options"] as? [String]
                           let myGifRef = myInfo["g"] as? String
                        let myQuip = Quip(text: aQuipText!, bowl: aChannelName, time: atimePosted!, score: aQuipScore, myQuipID: aQuipID, author: myAuthor!, replies: aReplies, myImageRef: myImageRef, myGifID: myGifRef, options: myOptions)
                        myQuip.channelKey = channelkey
                        myQuip.parentKey = parentChannelkey
                         
                            newQuips.append(myQuip)
                         
                           
                       }
                       
                   }
                      
                       
                   }
                completion(newQuips, moreRecentQuipsFirestore)
                   
               }
    }
    
    
    func getUserLikesDislikesForChannelOrUser(aUid:String, aKey:String, completion: @escaping ([String:Int])->()){
        var myLikesDislikesMap:[String:Int] = [:]
        let docRef = db.collection("/Users/\(aUid)/LikesDislikes").document(aKey)
                         
                     
                         docRef.getDocument{(document, error) in
                             if let document = document, document.exists {
                               if let myMap = document.data() as? [String:Int]{
                                   myLikesDislikesMap=myMap
                               }
                               
                             
                              
                             }
                           completion(myLikesDislikesMap)
                         }
       
    }
    
    func loadMoreNewQuipsFeed(myChannelKey:String,  channelName:String, completion: @escaping ([Quip], Bool)->()){
        var moreRecentQuipsFirestore:Bool = false
        var newQuips:[Quip] = []
        let channelRef = db.collection("Channels/\(myChannelKey)/RecentQuips")
        if let myLastDoc = lastRecentDocFeed{
            channelRef.order(by: "t", descending: true).start(afterDocument: myLastDoc).limit(to: 1).getDocuments(){ [weak self](querySnapshot, err) in
                            if let err = err {
                                            print("Error getting documents: \(err)")
                            }
                            else{
                                let length = querySnapshot!.documents.count
                                if length == 0 {
                                    return
                                }
                                
                               
                                   
                                
                                    
                                    let document = querySnapshot!.documents[0]
                                 
                                self?.lastRecentDocFeed = document
                                moreRecentQuipsFirestore = true
                                  
                                    
                                    guard document.data(with: ServerTimestampBehavior.estimate)["quips"] != nil else {return}
                                    let myQuips = document.data(with: ServerTimestampBehavior.estimate)["quips"] as! [String:Any]
                                let sortedKeys = Array(myQuips.keys).sorted(by: >)
                                for aQuip in sortedKeys{
                                    let myInfo = myQuips[aQuip] as! [String:Any]
                                    let aQuipID = aQuip
                                    let atimePosted = myInfo["d"] as? Timestamp
                                    let aQuipText = myInfo["t"] as? String
                                    let myAuthor = myInfo["a"] as? String
                                   let channelkey = myInfo["k"] as? String
                                    let parentChannelKey = myInfo["pk"] as? String
                                    let aChannelName = myInfo["c"] as? String ?? channelName
                                    let aQuipScore = 0
                                    let aReplies = 0
                                    let myImageRef = myInfo["i"] as? String
                                   let myGifRef = myInfo["g"] as? String
                                    let myOptions = myInfo["options"] as? [String]
                                   let myQuip = Quip(text: aQuipText!, bowl: aChannelName, time: atimePosted!, score: aQuipScore, myQuipID: aQuipID, author: myAuthor!, replies: aReplies, myImageRef: myImageRef, myGifID: myGifRef,options: myOptions)
                                     myQuip.channelKey = channelkey
                                    myQuip.parentKey = parentChannelKey
                                    newQuips.append(myQuip)
                                    
                                }
                                
                            
                                
                              
                             
                            }
                           completion(newQuips, moreRecentQuipsFirestore)
                        }
        }
    
    }
    
    func getHotQuipsFeed(myChannelKey:String, aHotIDs:[String], hotQuips:[Quip], completion: @escaping ([String:Any],[Quip], Bool)->()){
        var mydata:[String:Any] = [:]
        let channelRef = db.collection("Channels/\(myChannelKey)/HotQuips")
            channelRef.order(by: "t", descending: false).limit(to: 1).getDocuments(){[weak self] (querySnapshot, err) in
                  if let err = err {
                                  print("Error getting documents: \(err)")
                  }
                  else{
                    if let querySnapshot = querySnapshot{
                      let length = querySnapshot.documents.count
                       
                     if length == 0 {
                                                  
                        self?.createHotQuipsDoc(aHotIDs: aHotIDs, aHotQuips: hotQuips, more: false, aChannelKey: myChannelKey) { (myData, aHotQuips, more) in
                            completion(myData, aHotQuips, more)
                        }
                                                   
                     }else{
                        mydata = querySnapshot.documents[0].data(with: .estimate) as [String:Any]
                        if self?.compareHotQuips(myData: mydata, aHotIDs: aHotIDs, docRef: querySnapshot.documents[0])==false{
                            self?.lastHotDocumentFeed = querySnapshot.documents[0]
                            self?.updateHotQuipsDoc(doc: querySnapshot.documents[0], aHotQuips: hotQuips, more: false) { (myData, aHotQuips, more) in
                                completion(myData, aHotQuips, more)
                            }
                                
                                       
                        }else{
                            
                            self?.lastHotDocumentFeed = querySnapshot.documents[0]
                            completion(mydata, hotQuips, false)
                                    
                                        
                        }
                    }
                    
                   
                    }
                    
                     
                  }
                
                 
              }
    }
    
    func loadMoreHotFeed(myChannelKey:String, aHotIDs:[String], hotQuips:[Quip], completion: @escaping ([String:Any],[Quip], Bool)->()){
        var mydata:[String:Any] = [:]
        let channelRef = db.collection("Channels/\(myChannelKey)/HotQuips")
        if let lastdoc = lastHotDocumentFeed{
               channelRef.order(by: "t", descending: false).start(afterDocument: lastdoc).limit(to: 1).getDocuments(){ [weak self](querySnapshot, err) in
                          if let err = err {
                                          print("Error getting documents: \(err)")
                          }
                          else{
                              if let querySnapshot = querySnapshot{
                                let length = querySnapshot.documents.count
                               
                                if length == 0 {
                                                                        
                                    self?.createHotQuipsDoc(aHotIDs: aHotIDs, aHotQuips: hotQuips, more: true, aChannelKey: myChannelKey) { (myData, aHotQuips, more) in
                                            completion(myData, aHotQuips, more)
                                        }
                                                                                
                                }else{
                                     mydata = querySnapshot.documents[0].data(with: .estimate) as [String:Any]
                                    if self?.compareHotQuips(myData: mydata, aHotIDs: aHotIDs, docRef: querySnapshot.documents[0])==false{
                                    self?.lastHotDocumentFeed = querySnapshot.documents[0]
                                    self?.updateHotQuipsDoc(doc: querySnapshot.documents[0], aHotQuips: hotQuips, more: true) { (myData, aHotQuips, more) in
                                            completion(myData, aHotQuips, more)
                                    }
                                                         
                                                                
                                }else{
                                                    
                                    self?.lastHotDocumentFeed = querySnapshot.documents[0]
                                        completion(mydata, hotQuips, true)
                                                             
                                                                 
                                }
                                }
                                                
                            }
                           
                            
                           
                              
                          }
                          
                      }
        }
    }
    
    func getHotQuipsUser(myUid:String, aHotIDs:[String], hotQuips:[Quip], completion: @escaping ([String:Any],[Quip], Bool)->()){
           var mydata:[String:Any] = [:]
           let channelRef = db.collection("Users/\(myUid)/HotQuips")
               channelRef.order(by: "t", descending: false).limit(to: 1).getDocuments(){[weak self] (querySnapshot, err) in
                     if let err = err {
                                     print("Error getting documents: \(err)")
                     }
                     else{
                       if let querySnapshot = querySnapshot{
                         let length = querySnapshot.documents.count
                          
                        if length == 0 {
                                                     
                            self?.createHotQuipsDocUser(aHotIDs: aHotIDs, aHotQuips: hotQuips, more: false, aUid: myUid) { (myData, aHotQuips, more) in
                               completion(myData, aHotQuips, more)
                           }
                                                      
                        }else{
                           mydata = querySnapshot.documents[0].data(with: .estimate) as [String:Any]
                            if self?.compareHotQuips(myData: mydata, aHotIDs: aHotIDs, docRef: querySnapshot.documents[0])==false{
                                self?.lastHotDocUser = querySnapshot.documents[0]
                                self?.updateHotQuipsDoc(doc: querySnapshot.documents[0], aHotQuips: hotQuips, more: false) { (myData, aHotQuips, more) in
                                   completion(myData, aHotQuips, more)
                               }
                                   
                                          
                           }else{
                               
                                self?.lastHotDocUser = querySnapshot.documents[0]
                               completion(mydata, hotQuips, false)
                                       
                                           
                           }
                       }
                       
                      
                       }
                       
                        
                     }
                   
                    
                 }
       }
    
    func compareHotQuips(myData:[String:Any], aHotIDs:[String], docRef:DocumentSnapshot)->Bool{
        hotQuipAdds = []
        
        myNewHotQuipData = [:]
        var isSame = true
        for aHotId in aHotIDs{
            let keyExists = myData[aHotId] != nil
            if keyExists{
                myNewHotQuipData[aHotId] = myData[aHotId]
            }
            else{
                isSame = false
                hotQuipAdds.append(aHotId)
               
                    }
            }
        if !isSame{
        var deletes:[String:Any] = [:]
        for currentHotID in myData.keys{
            if currentHotID == "t"{
                continue
            }else{
                
                if aHotIDs.contains(currentHotID){
                    
                }else{
                    deletes[currentHotID] = FieldValue.delete()
                }
            }
        }
            docRef.reference.updateData(deletes)
        }
        
        return isSame
    }
   
     
      func updateHotQuipsDoc(doc:DocumentSnapshot, aHotQuips:[Quip], more:Bool, completion: @escaping ([String:Any],[Quip], Bool)->()){
         
          var i:Int = 0
          
          for aHotId in self.hotQuipAdds{
                 self.db.collection("Quips").document(aHotId).getDocument { (document, error) in
                     if let document = document, document.exists {
                      let data = document.data(with: ServerTimestampBehavior.estimate)
                      self.myNewHotQuipData[aHotId] = data
                       i += 1
                     }
                  if i == self.hotQuipAdds.count{
                  
                      
                      doc.reference.updateData(self.myNewHotQuipData)
                    completion(self.myNewHotQuipData, aHotQuips, more)
                  }
                 }
                 
              }
          
      }
    
     
      
    func createHotQuipsDoc(aHotIDs:[String], aHotQuips:[Quip], more:Bool, aChannelKey:String, completion: @escaping ([String:Any],[Quip], Bool)->()){
          var i:Int = 0
          var myData:[String:Any] = [:]
        if aHotIDs.count == 0{
            completion(myData, aHotQuips, more)
            return
        }
          for aHotId in aHotIDs{
             self.db.collection("Quips").document(aHotId).getDocument { (document, error) in
                 if let document = document, document.exists {
                  let data = document.data(with: ServerTimestampBehavior.estimate)
                  myData[aHotId] = data
                  i += 1
                 }
              if i == aHotIDs.count{
              myData["t"] = FieldValue.serverTimestamp()
                  
            let docRef=self.db.collection("Channels/\(aChannelKey)/HotQuips").addDocument(data: myData)
                //   sleep(1)
                 
                  docRef.getDocument { (document, error) in
                  if let document = document, document.exists {
                      self.lastHotDocumentFeed = document
                   
                      }
                      }
               completion(myData, aHotQuips, more)
                return
             }
             
          }
         
      }
      }
    func createHotQuipsDocUser(aHotIDs:[String], aHotQuips:[Quip], more:Bool, aUid:String, completion: @escaping ([String:Any],[Quip], Bool)->()){
             var i:Int = 0
             var myData:[String:Any] = [:]
        if aHotIDs.count == 0{
                   completion(myData, aHotQuips, more)
                   return
               }
             for aHotId in aHotIDs{
                db.collection("Quips").document(aHotId).getDocument { (document, error) in
                    if let document = document, document.exists {
                     let data = document.data(with: ServerTimestampBehavior.estimate)
                     myData[aHotId] = data
                     i += 1
                    }
                 if i == aHotIDs.count{
                 myData["t"] = FieldValue.serverTimestamp()
                     
               let docRef=self.db.collection("Users/\(aUid)/HotQuips").addDocument(data: myData)
                   //   sleep(1)
                    
                     docRef.getDocument { (document, error) in
                     if let document = document, document.exists {
                         self.lastHotDocUser = document
                      
                         }
                         }
                  completion(myData, aHotQuips, more)
                    return
                }
                
             }
            
         }
         }
    func updateLikesDislikes(myNewLikesDislikesMap:[String:Int], aChannelOrUserKey:String, myMap:[String:String], aUID:String, parentChannelKey:String?, parentChannelMap:[String:String]?, parentQuipsMap:[String:String]?){
        let batch = self.db.batch()
        
            let docRef = db.collection("/Users/\(aUID)/LikesDislikes").document(aChannelOrUserKey)
            
            batch.setData(myNewLikesDislikesMap, forDocument: docRef,merge: true)
        
        for aKey in myNewLikesDislikesMap.keys{
                           
                           if let myUserOrChannel = myMap[aKey]{
                               let docRefChannel = db.collection("/Users/\(aUID)/LikesDislikes").document(myUserOrChannel)
                            batch.setData([aKey:myNewLikesDislikesMap[aKey]  as Any], forDocument: docRefChannel, merge: true)
                           }
            if let myParentChannel = parentChannelMap?[aKey]{
                let docRefChannel = db.collection("/Users/\(aUID)/LikesDislikes").document(myParentChannel)
                                           batch.setData([aKey:myNewLikesDislikesMap[aKey]  as Any], forDocument: docRefChannel, merge: true)
            }
            if let myParentChannel = parentChannelKey {
                let docRefChannel = db.collection("/Users/\(aUID)/LikesDislikes").document(myParentChannel)
                batch.setData([aKey:myNewLikesDislikesMap[aKey]  as Any], forDocument: docRefChannel, merge: true)
            }
            if let myParentQuip = parentQuipsMap?[aKey]{
                let docRefChannel = db.collection("/Users/\(aUID)/LikesDislikes").document(myParentQuip)
                                           batch.setData([aKey:myNewLikesDislikesMap[aKey]  as Any], forDocument: docRefChannel, merge: true)
            }
        }
            batch.commit()
    }
    
    
    
    func getActive(aGenCat:String, aCatName:String, completion: @escaping ([Channel])->()){
        let docRef = db.collection("Categories/\(aGenCat)/\(aCatName)").document("Active")
        var activeChannels:[Channel] = []
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    
                  if let myChannels = document.data(){
                        for aChannel in myChannels.keys{
                            let key = aChannel
                            if let myInfo = myChannels[aChannel] as? [String:Any]{
                                 let priority = myInfo["priority"] as? Int
                                if let name = myInfo["name"] as? String{
                                let parent = myInfo["parent"] as? String
                                let parentkey = myInfo["parentkey"] as? String
                                let astart = myInfo["s"] as? Timestamp
                                let aend = myInfo["e"] as? Timestamp
                                    let myChannel = Channel(name: name, akey: key, aparent: parent, aparentkey: parentkey, apriority: priority, astartDate: astart?.dateValue(), aendDate:aend?.dateValue())
                                activeChannels.append(myChannel)
                                }
                            }
                            
                        }
                    activeChannels.sort { (event1, event2) -> Bool in
                        if event1.priority != nil && event2.priority == nil{
                            return true
                        }else if event1.priority == nil && event2.priority != nil{
                            return false
                        }else if event1.priority != nil && event2.priority != nil{
                            return event1.priority! < event2.priority!
                        }else{
                            return event1.endDate! < event2.endDate!
                        }
                    }
                    completion(activeChannels)
                       
                    }
                           
                            
                        
                        
                        
                } else {
                    print("Document does not exist")
                }
               
               
            }
        }
    
    func getUpcoming(aGenCat:String, aCatName:String, completion: @escaping ([Channel])->()){
        let docRef = db.collection("Categories/\(aGenCat)/\(aCatName)").document("Upcoming")
        var upcomingChannels:[Channel] = []
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                                     
                    if let myChannels = document.data(){
                                         for aChannel in myChannels.keys{
                                             let key = aChannel
                                             if let myInfo = myChannels[aChannel] as? [String:Any]{
                                                  let priority = myInfo["priority"] as? Int
                                                 if let name = myInfo["name"] as? String{
                                                 let parent = myInfo["parent"] as? String
                                                 let parentkey = myInfo["parentkey"] as? String
                                                    let astart = myInfo["s"] as? Timestamp
                                                    let aend = myInfo["e"] as? Timestamp
                                                    let myChannel = Channel(name: name, akey: key, aparent: parent, aparentkey: parentkey, apriority: priority,astartDate: astart?.dateValue(), aendDate:aend?.dateValue())
                                                 upcomingChannels.append(myChannel)
                                                 }
                                             }
                                             
                                         }
                        upcomingChannels.sort { (event1, event2) -> Bool in
                            if event1.priority != nil && event2.priority == nil{
                                return true
                            }else if event1.priority == nil && event2.priority != nil{
                                return false
                            }else if event1.priority != nil && event2.priority != nil{
                                return event1.priority! < event2.priority!
                            }else{
                                return event1.startDate! < event2.startDate!
                            }
                        }
                                completion(upcomingChannels)
                                     }
                                            
                                             
                                         
                                         
                                         
                                 } else {
                                     print("Document does not exist")
                                 }
                                
                                
                             }
                         }
    
    func getPast(aGenCat:String, aCatName:String, completion: @escaping ([Channel])->()){
        let docRef = db.collection("Categories/\(aGenCat)/\(aCatName)").document("Past")
        var pastChannels:[Channel] = []
                                    docRef.getDocument { (document, error) in
                                        if let document = document, document.exists {
                                            
                                          if let myChannels = document.data(){
                                                for aChannel in myChannels.keys{
                                                    let key = aChannel
                                                    if let myInfo = myChannels[aChannel] as? [String:Any]{
                                                         let priority = myInfo["priority"] as? Int
                                                        if let name = myInfo["name"] as? String{
                                                        let parent = myInfo["parent"] as? String
                                                        let parentkey = myInfo["parentkey"] as? String
                                                        let astart = myInfo["s"] as? Timestamp
                                                        let aend = myInfo["e"] as? Timestamp
                                                            let myChannel = Channel(name: name, akey: key, aparent: parent, aparentkey: parentkey, apriority: priority, astartDate: astart?.dateValue(), aendDate:aend?.dateValue())
                                                       pastChannels.append(myChannel)
                                                        }
                                                    }
                                                    
                                                }
                                            pastChannels.sort { (event1, event2) -> Bool in
                                                if event1.priority != nil && event2.priority == nil{
                                                    return true
                                                }else if event1.priority == nil && event2.priority != nil{
                                                    return false
                                                }else if event1.priority != nil && event2.priority != nil{
                                                    return event1.priority! < event2.priority!
                                                }else{
                                                    if let astart1 = event1.startDate {
                                                        if let astart2 = event2.startDate{
                                                                                                                return astart1 > astart2
                                                                                                           }
                                                                                                       }

                                                    if let aend1 = event1.endDate {
                                                        if let aend2 = event2.endDate{
                                                             return aend1 > aend2
                                                        }
                                                    }
                                                   return false
                                                }
                                            }
                                            completion(pastChannels)
                                                
                                            }
                                                   
                                                    
                                                
                                                
                                                
                                        } else {
                                            print("Document does not exist")
                                        }
                                       
                                       
                                    }
                                }
    
    func favoriteCatagory(aUid:String, myCatName:String, bigCategory:String){
        let favdoc = db.collection("/Users/\(aUid)/Favorites").document("Favs")
                   
                      
        let myData = ["n":myCatName,
                      "b":bigCategory]
        favdoc.setData(["favs":FieldValue.arrayUnion([myData])], merge:true)
        Analytics.logEvent(AnalyticsEventJoinGroup, parameters: [AnalyticsParameterGroupID:myCatName,
            AnalyticsParameterContentType:"favorite"])
    }
    
    func unfavoriteCatagory(aUid:String, myCatName:String, bigCategory:String){
        let favdoc = db.collection("/Users/\(aUid)/Favorites").document("Favs")
        
         let myData = ["n":myCatName,
                           "b":bigCategory]
        favdoc.setData(["favs":FieldValue.arrayRemove([myData])],merge:true)
    }
    
    func addQuipToRecentChannelTransaction(myChannelKey:String, data:[String:Any], key:String, completion: @escaping ()->()){
        
        let recentQuipsRef = self.db.collection("Channels/\(myChannelKey)/RecentQuips")
                  
        recentQuipsRef.order(by: "t", descending: true).limit(to: 2).getDocuments(){[weak self] (querySnapshot, err) in
                       if err != nil {
                           return
                       }
                       
            self?.db.runTransaction({[weak self] (transaction, errorPointer) -> Any? in
                        let sfDocument: DocumentSnapshot
                  do {
                       try sfDocument = transaction.getDocument((querySnapshot?.documents[0].reference)!)
                   } catch let fetchError as NSError {
                       errorPointer?.pointee = fetchError
                       return nil
                   }
                            
                        
                               if querySnapshot?.isEmpty ?? true ||
                                   querySnapshot?.documents[1].data()["n"] as! Double >= 20{
                               
                                self?.createNewDocForRecentChannel(data: data, key: key, transaction: transaction, channelKey: myChannelKey)
                           
                                
                                    let mydata2=["n":FieldValue.increment(Int64(1)),
                                                 "a": true] as [String : Any]
                                    
                                transaction.updateData(mydata2, forDocument: sfDocument.reference)
                                transaction.updateData(["quips.\(key)" : data], forDocument: sfDocument.reference)
                                    
                                    
                               }
                               else{
                                   let mydata2=["n":FieldValue.increment(Int64(1)),
                                                "a": true] as [String : Any]
                                  
                                   transaction.updateData(mydata2, forDocument: (querySnapshot?.documents[1].reference)!)
                                   transaction.updateData(["quips.\(key)" : data], forDocument: (querySnapshot?.documents[1].reference)!)
                                   
                           }
                       
                   
            return nil
        }){ (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            
            } else {
               completion()
               
            }
        }
        }
    }
    
    func createNewDocForRecentChannel(data:[String:Any], key:String, transaction:Transaction, channelKey:String){
           
           var mydata2:[String:Any] = [:]
           mydata2 = ["n": 0,
                      "t": FieldValue.serverTimestamp(),
                      "a": false]
           
           
        let recentQuipRef = self.db.collection("Channels/\(channelKey)/RecentQuips").document()
          
           transaction.setData(mydata2, forDocument: recentQuipRef)
       }
    
    
    func addQuipToRecentUserQuips(auid:String, data:[String:Any], key:String, completion: @escaping ()->()){
        let recentQuipsRef = self.db.collection("Users/\(auid)/RecentQuips")
                    
            recentQuipsRef.order(by: "t", descending: true).limit(to: 1).getDocuments(){[weak self] (querySnapshot, err) in
                        if let err = err {
                                   print("Error getting documents: \(err)")
                        }else{
                          
                            if querySnapshot?.isEmpty ?? true ||
                                querySnapshot?.documents[0].data()["n"] as! Double >= 10{
                                self?.createNewDocForRecentUser(data: data, key: key, auid: auid)
                        
                            }
                            else{
                                let mydata2=["n":FieldValue.increment(Int64(1))]
                                let batch = self?.db.batch()
                                batch?.updateData(mydata2, forDocument: (querySnapshot?.documents[0].reference)!)
                                batch?.updateData(["quips.\(key)" : data], forDocument: (querySnapshot?.documents[0].reference)!)
                                batch?.commit()
                                
                               }
                            completion()
                           
                       }
          
           }
    }
    func createNewDocForRecentUser(data:[String:Any], key:String, auid:String){
              
              var mydata2:[String:Any] = [:]
              mydata2 = ["n": 1,
                         "t": FieldValue.serverTimestamp()]
              let batch = db.batch()
          
              let recentQuipRef = self.db.collection("Users/\(auid)/RecentQuips").document()
              batch.setData(["quips" : [key:data]], forDocument: recentQuipRef, merge: true)
              batch.updateData(mydata2, forDocument: recentQuipRef)
              batch.commit()
           
          }
    
    func addQuipDocToFirestore(data:[String:Any], key:String){
        let batch = db.batch()
        let newQuipRef=db.collection("Quips").document(key)
              
        batch.setData(data, forDocument: newQuipRef)
             
              batch.commit()
    }
    
    func reorderUserFavs(aUid:String, myFavs:[Category]){
        var myNewFavCats:[[String:String]] = []
        let docRef = db.collection("/Users/\(aUid)/Favorites").document("Favs")
        for aCat in myFavs{
            if let myCatName = aCat.categoryName{
                if let myBigCat = aCat.bigCat{
                    myNewFavCats.append(["n":myCatName,
                                         "b":myBigCat])
                }
            }
            
        }
        docRef.setData(["favs":myNewFavCats])
            
               
    }
    
    func getUserFavCategories(aUid:String,  completion: @escaping ([Category])->()){
        
        var myFavCats:[Category] = []
        let docRef = db.collection("/Users/\(aUid)/Favorites").document("Favs")
               
           
               docRef.getDocument{ (document, error) in
                   if let document = document, document.exists {
                    if let myMap = document.data()?["favs"] as? [[String:String]]{
                        
                        for aCat in myMap{
                            if let aCatName = aCat["n"]{
                            let bigCatName = aCat["b"]
                            let myCategory = Category(name: aCatName, aPriority: nil, aBigCat: bigCatName)
                            myFavCats.append(myCategory)
                            }
                        }
                         
                     }
                     
                   
                    
                   } else {
                    myFavCats = []
                   }
                completion(myFavCats)
                 
               }
    }
    
    func getLiveEvents(completion: @escaping ([Channel])->()){
        var aLiveEvents:[Channel] = []
        let docRef = db.collection("Categories").document("Live")

               docRef.getDocument { (document, error) in
                   if let document = document, document.exists {
                       if let myLiveEvents = document.data() {
                       
                       for aEvent in myLiveEvents.keys{
                           let eventID = aEvent
                           if let eventInfo = myLiveEvents[aEvent] as? [String:Any]{
                               if let eventName = eventInfo["name"] as? String{
                                   let priority = eventInfo["priority"] as? Int
                                let astart = eventInfo["s"] as? Timestamp
                                let aend = eventInfo["e"] as? Timestamp
                                let myEvent = Channel(name: eventName, akey: eventID, aparent: nil, aparentkey: nil, apriority: priority, astartDate: astart?.dateValue(), aendDate: aend?.dateValue())
                                   aLiveEvents.append(myEvent)
                               }
                           }
                       }
                        
                        
                           
                       
                       
                       
                       }
                       
                   } else {
                       print("Document does not exist")
                   }
                aLiveEvents.sort{ (event1, event2) -> Bool in
                    if event1.priority != nil && event2.priority == nil{
                        return true
                    }else if event1.priority == nil && event2.priority != nil{
                        return false
                    }else if event1.priority != nil && event2.priority != nil{
                        return event1.priority! < event2.priority!
                    }else{
                        return event1.endDate! < event2.endDate!
                        
                    }
                }
                completion(aLiveEvents)
               }
               
           }
    
           
    func getSports(completion: @escaping ([Category], [Category])->()){
        var allSports:[Category] = []
        var aSports:[Category]=[]
                  let docRef = db.collection("Categories").document("Sports")

                  docRef.getDocument { (document, error) in
                      if let document = document, document.exists {
                       if let mySports = document.data(){
                           for aSport in mySports.keys{
                               let name = aSport
                               if let myInfo = mySports[aSport] as? [String:Any]{
                                    let priority = myInfo["priority"] as? Int
                                   let mySport = Category(name: name, aPriority: priority, aBigCat: "Sports")
                                   allSports.append(mySport)
                                   if priority != 0 {
                                   aSports.append(mySport)
                                   }
                               }
                               
                           }
                            
                       }
                           
                         
                              
                          
                      } else {
                          print("Document does not exist")
                      }
                    aSports.sort(by: { $0.priority! < $1.priority! })
                    allSports.sort(by: {$0.categoryName! < $1.categoryName!})
                    completion(aSports,allSports)
                  }
    }
    
      func getEntertainment(completion: @escaping ([Category], [Category])->()){
    let docRef = db.collection("Categories").document("Entertainment")
        var aEntertainments:[Category] = []
        var allEntertainment:[Category] = []
    docRef.getDocument { (document, error) in
    if let document = document, document.exists {
     if let myEntertainments = document.data(){
         for aEntertainment in myEntertainments.keys{
             let name = aEntertainment
             if let myInfo = myEntertainments[aEntertainment] as? [String:Any]{
                  let priority = myInfo["priority"] as? Int
                 let myEntertainment = Category(name: name, aPriority: priority, aBigCat: "Entertainment")
                 allEntertainment.append(myEntertainment)
                 if priority != 0 {
                 aEntertainments.append(myEntertainment)
                 }
             }
             
         }
         
         }
                
            
        } else {
            print("Document does not exist")
        }
        aEntertainments.sort(by: { $0.priority! < $1.priority! })
        allEntertainment.sort(by: {$0.categoryName! < $1.categoryName!})
        completion(aEntertainments, allEntertainment)
    }
    }
    
    
    func getRecentUserQuipsFirestore(uid:String, myScores:[String:Any], completion: @escaping ([Quip], Bool)->()){
        var newUserQuips:[Quip] = []
        var moreRecentQuips = false
        let userRecentRef = db.collection("Users/\(uid)/RecentQuips")
           
        userRecentRef.order(by: "t", descending: true).limit(to: 2).getDocuments(){[weak self] (querySnapshot, err) in
               if let err = err {
                               print("Error getting documents: \(err)")
               }
               else{
                   let length = querySnapshot!.documents.count
                   if length == 0 {
                       completion(newUserQuips, moreRecentQuips)
                        return
                   }
                   for i in 0...length-1{
                    var j = 0
                       let document = querySnapshot!.documents[i]
                   let myQuips = document.data(with: ServerTimestampBehavior.estimate)["quips"] as! [String:Any]
                   let sortedKeys = Array(myQuips.keys).sorted(by: >)
                   for aQuip in sortedKeys{
                    j += 1
                       let myInfo = myQuips[aQuip] as! [String:Any]
                       let aQuipID = aQuip
                       let atimePosted = myInfo["d"] as? Timestamp
                       let aQuipText = myInfo["t"] as? String
                       let myChannel = myInfo["c"] as? String
                        let myChannelKey = myInfo["k"] as? String
                    let myChannelParentKey = myInfo["pk"] as? String
                    let isReply = myInfo["r"] as? Bool
                    let quipParent = myInfo["p"] as? String
                    let aemail = myInfo["email"] as? String
                    let myOptions = myInfo["options"] as? [String]
                    var aQuipScore:Int?
                    var aReplies:Int?
                    if let myQuipNumbers = myScores[aQuipID] as? [String:Any]{
                        aQuipScore = myQuipNumbers["s"] as? Int
                        aReplies = myQuipNumbers["r"] as? Int
                    } else {
                       continue
                    }
                    
                      let myImageRef = myInfo["i"] as? String
                      let myGifRef = myInfo["g"] as? String
                    let myQuip = Quip(text: aQuipText ?? "", bowl: myChannel ?? "Other", time: atimePosted ?? Timestamp(), score: aQuipScore ?? 0, myQuipID: aQuipID, replies: aReplies ?? 0,myImageRef: myImageRef,myGifID: myGifRef, myChannelKey: myChannelKey,myParentChannelKey: myChannelParentKey, isReply: isReply, aquipParent: quipParent, email: aemail, options: myOptions)
                    
                       newUserQuips.append(myQuip)
                    
                    
                       
                   }
                    if i == 1 {
                    
                           if j == 10  {
                            self?.myLastRecentDocUser = document
                                    moreRecentQuips = true
                            }
                    }
               }
                completion(newUserQuips,moreRecentQuips)
                
               }
            
        }
    }
    
    func loadMoreRecentUserQuips(uid:String, myScores:[String:Any], completion: @escaping ([Quip], Bool)->()){
        var newUserQuips:[Quip] = []
        var moreRecentQuipsUser = false
        let userRecentRef = db.collection("Users/\(uid)/RecentQuips")
        if let myLastDoc = self.myLastRecentDocUser{
        userRecentRef.order(by: "t", descending: true).start(afterDocument: myLastDoc).limit(to: 1).getDocuments(){ [weak self](querySnapshot, err) in
                             var i = 0
                          if let err = err {
                                print("Error getting documents: \(err)")
                          }
                          else{
                              let length = querySnapshot!.documents.count
                              if length == 0 {
                                  return
                              }
                              
                                  let document = querySnapshot!.documents[0]
                              let myQuips = document.data(with: ServerTimestampBehavior.estimate)["quips"] as! [String:Any]
                              let sortedKeys = Array(myQuips.keys).sorted(by: >)
                            self?.myLastRecentDocUser = document
                            moreRecentQuipsUser = true
                              for aQuip in sortedKeys{
                                i += 1
                                  let myInfo = myQuips[aQuip] as! [String:Any]
                                  let aQuipID = aQuip
                                  let atimePosted = myInfo["d"] as? Timestamp
                                  let aQuipText = myInfo["t"] as? String
                                  let myChannel = myInfo["c"] as? String
                                  let quipParent = myInfo["p"] as? String
                                let aemail = myInfo["email"] as? String
                                let myOptions = myInfo["options"] as? [String]
                               var aQuipScore:Int?
                               var aReplies:Int?
                               if let myQuipNumbers = myScores[aQuipID] as? [String:Any]{
                                   aQuipScore = myQuipNumbers["s"] as? Int
                                   aReplies = myQuipNumbers["r"] as? Int
                               } else {
                                   continue
                                   
                               }
                                 let myImageRef = myInfo["i"] as? String
                                let myGifRef = myInfo["g"] as? String
                                let myChannelKey = myInfo["k"] as? String
                                let myChannelParentKey = myInfo["pk"] as? String
                                let isReply = myInfo["r"] as? Bool
                                let myQuip = Quip(text: aQuipText!, bowl: myChannel ?? "Other", time: atimePosted!, score: aQuipScore!, myQuipID: aQuipID, replies: aReplies ?? 0,myImageRef: myImageRef,myGifID: myGifRef, myChannelKey: myChannelKey,myParentChannelKey: myChannelParentKey, isReply: isReply, aquipParent:quipParent, email: aemail, options: myOptions)
                                  newUserQuips.append(myQuip)
                                
                                
                               
                                    
                                }
                            
                            
                            
                                    
                                        
                                    
                            completion(newUserQuips, moreRecentQuipsUser)
                                  
                              }
                           
            }
                       
        }
    }
    
    func loadMoreHotUser(auid:String, aHotIDs:[String], hotQuips:[Quip], completion: @escaping ([String:Any],[Quip], Bool)->()){
        var mydata:[String:Any] = [:]
        let channelRef = db.collection("Users/\(auid)/HotQuips")
        if let lastdoc = lastHotDocUser{
               channelRef.order(by: "t", descending: false).start(afterDocument: lastdoc).limit(to: 1).getDocuments(){ [weak self](querySnapshot, err) in
                          if let err = err {
                                          print("Error getting documents: \(err)")
                          }
                          else{
                              if let querySnapshot = querySnapshot{
                                let length = querySnapshot.documents.count
                               
                                if length == 0 {
                                                                        
                                    self?.createHotQuipsDocUser(aHotIDs: aHotIDs, aHotQuips: hotQuips, more: true, aUid:auid) { (myData, aHotQuips, more) in
                                            completion(myData, aHotQuips, more)
                                        }
                                                                                
                                }else{
                                     mydata = querySnapshot.documents[0].data(with: .estimate) as [String:Any]
                                if self?.compareHotQuips(myData: mydata, aHotIDs: aHotIDs, docRef: querySnapshot.documents[0])==false{
                                    self?.lastHotDocumentFeed = querySnapshot.documents[0]
                                    self?.updateHotQuipsDoc(doc: querySnapshot.documents[0], aHotQuips: hotQuips, more: true) { (myData, aHotQuips, more) in
                                            completion(myData, aHotQuips, more)
                                    }
                                                         
                                                                
                                }else{
                                                    
                                    self?.lastHotDocumentFeed = querySnapshot.documents[0]
                                        completion(mydata, hotQuips, true)
                                                             
                                                                 
                                }
                                }
                                                
                            }
                           
                            
                           
                              
                          }
                          
                      }
        }
    }
    
    func getQuip(quipID:String,completion: @escaping (Quip)->()){
       let quipRef = db.collection("/Quips").document(quipID)
        quipRef.getDocument { (snapshot, error) in
            if let error = error{
               print(error)
            }else{
                if let mydata = snapshot?.data(){
                let author = mydata["a"] as? String
                let channelkey = mydata["k"] as? String
                let parentchannelKey = mydata["pk"] as? String
                let atimePosted = mydata["d"] as? Timestamp
                let text = mydata["t"] as? String
                let quipParent = mydata["p"] as? String
                let isReply = mydata["r"] as? Bool
                let imageRef = mydata["i"] as? String
                let gifid = mydata["g"] as? String
                let options = mydata["options"] as? [String]
                    let aQuip = Quip(myQuipID: quipID, auser: author, parentchannelKey: parentchannelKey, achannelkey: channelkey, atimePosted: atimePosted, text:text, quipParent: quipParent, isReply: isReply, imageRef:imageRef, gifid:gifid, options: options)
                    
                completion(aQuip)
                }
            }
        }
    }
    
    func getReplies(quipID:String, replyScores:[String:Int], completion: @escaping ([Quip])->()){
        var aReplies:[Quip] = []
        let repliesRef = db.collection("/Quips/\(quipID)/Replies")
            
            repliesRef.getDocuments() {(querySnapshot, err) in
            if let err = err {
                    print("Error getting documents: \(err)")
            }
            else{
                          
                if querySnapshot!.documents.count == 0{
                    
                    completion(aReplies)
                }
                 let document = querySnapshot!.documents[0]
                               
           
                let myReplies = document.data(with: ServerTimestampBehavior.estimate)
                let sortedKeys = Array(myReplies.keys).sorted(by: <)
                for aKey in sortedKeys{
                    if aKey == "n"{
                        continue
                    }
                    let myInfo = myReplies[aKey] as! [String:Any]
                               let aReplyID = aKey
                               let atimePosted = myInfo["d"] as? Timestamp
                               let aReplyText = myInfo["t"] as? String
                               let myAuthor = myInfo["a"] as? String
                              let myImageRef = myInfo["i"] as? String
                                let myGifRef = myInfo["g"] as? String
                    if replyScores[aKey] == nil{
                        continue
                    } else {
                        let aReplyScore = replyScores[aKey]
                              
                        let myReply = Quip(aScore: aReplyScore ?? 0, aKey: aReplyID, atimePosted: atimePosted!, aText: aReplyText!, aAuthor: myAuthor!, image:myImageRef, gif:myGifRef, quipParentID: quipID)
                            aReplies.append(myReply)
                    }
                }
                           
            }
                completion(aReplies)
                
            
        }
    }
    
    func saveReply(quipId:String, mydata:[String:Any], key:String, completion: @escaping ()->()){
        let repliesQuipsRef = self.db.collection("/Quips/\(quipId)/Replies").document("RecentReplies")

                    let batch = self.db.batch()
                    batch.setData([key : mydata], forDocument: repliesQuipsRef, merge: true)
                                   batch.commit()
        completion()
                                   
    }
    func getUserProfile(uid:String, completion: @escaping (String, String)->()){
        let userRef = db.collection("/Users").document(uid)
        var name = "Anonymous"
        var bio = "Insert Bio"
        userRef.getDocument { (snapshot, error) in
            if let error = error{
                print(error)
                return
            }
            if let myData = snapshot?.data(){
               if let aname = myData["name"] as? String{
                    name = aname
                }
                if let abio = myData["bio"] as? String{
                    bio = abio
                }
                
            }
            completion(name, bio)
        }
    }
    
    func saveUserProfile(uid:String, name:String, bio:String){
        let userRef = db.collection("/Users").document(uid)

        let batch = self.db.batch()
        batch.setData(["name" : name,
                       "bio" : bio], forDocument: userRef, merge: true)
                       batch.commit()
    }
    func deleteQuip(quipID:String, completion: @escaping ()->()){
        getQuip(quipID: quipID) { (quip) in
            if let eventID = quip.channelKey{
                    if let author = quip.user{
                        self.removeQuip(eventID: eventID, author: author, quipID: quipID, quip: quip,parentEventID: quip.parentKey){
                           completion()
                       }
                }
            }
            else if let parentQuip = quip.quipParent{
                if let author = quip.user{
                   self.removeReply(parentID: parentQuip, author: author, replyID: quipID, quip: quip, parentEventID: nil) {
                        completion()
                    }
                }
            }
        }
        
    }
    
    func removeQuip(eventID:String, author:String, quipID:String, quip:Quip,parentEventID:String?, completion: @escaping ()->()){
       
        
             /*
                           db.collection("Quips/\(quipID)/Replies").document("RecentReplies").delete { (err) in
                                 if let err = err {
                                                         print("Error removing document: \(err)")
                                                     } else {
                                                         print("Document successfully removed!")
                                                     }
                           }
                           db.collection("Quips").document(quipID).delete { (err) in
                                 if let err = err {
                                                         print("Error removing document: \(err)")
                                                     } else {
                                                         print("Document successfully removed!")
                                                     }
                           }
                           let userRecentRef = db.collection("Users/\(author)/RecentQuips")
                           userRecentRef.order(by: "quips.\(quipID)").getDocuments { (querrySnapshot, error) in
                               if let error = error{
                                   print("error: \(error)")
                                   return
                               }
                            if let count = querrySnapshot?.documents.count{
                            if count > 0{
                                let doc = querrySnapshot?.documents[0]
                                                           doc?.reference.updateData(["quips.\(quipID)":FieldValue.delete(),
                                                           "n": FieldValue.increment(Int64(-1))])
                                }
                            }
                           }
                           let eventRecentRef = db.collection("Channels/\(eventID)/RecentQuips")
                        eventRecentRef.order(by: "quips.\(quipID)").getDocuments { (querrySnapshot, error) in
                                                  if let error = error{
                                                      print("error: \(error)")
                                                      return
                                                  }
                            if let count = querrySnapshot?.documents.count{
                            if count > 0{
                                let doc = querrySnapshot?.documents[0]
                            doc?.reference.updateData(["quips.\(quipID)":FieldValue.delete(),
                            "n": FieldValue.increment(Int64(-1))])
                            }
                            }
                        }
        if let aparent = parentEventID{
            let parentEventRecentRef = db.collection("Channels/\(aparent)/RecentQuips")
                                  parentEventRecentRef.order(by: "quips.\(quipID)").getDocuments { (querrySnapshot, error) in
                                                            if let error = error{
                                                                print("error: \(error)")
                                                                return
                                                            }
                                      if let count = querrySnapshot?.documents.count{
                                      if count > 0{
                                          let doc = querrySnapshot?.documents[0]
                                      doc?.reference.updateData(["quips.\(quipID)":FieldValue.delete(),
                                      "n": FieldValue.increment(Int64(-1))])
                                      }
                                      }
                                  }
        }
        FirebaseService.sharedInstance.deleteQuip(quipID: quipID, eventID: eventID, author: author, parentEventID: parentEventID){
            completion()
        }
                   if let imageRef = quip.imageRef{
                       FirebaseStorageService.sharedInstance.deleteImage(imageRef: imageRef)
                   }
        */
        cloudFunctionManager.sharedInstance.functions.httpsCallable("deleteCrack").call(["eventID": eventID, "user":author, "quipID":quipID]) { (result, error) in
          if let error = error as NSError? {
            if error.domain == FunctionsErrorDomain {
              let code = FunctionsErrorCode(rawValue: error.code)
              let message = error.localizedDescription
              let details = error.userInfo[FunctionsErrorDetailsKey]
             print("code:\(String(describing: code)), message:\(message), details:\(String(describing: details))")
            }
            // ...
          }
                completion()
            
          }
        
    }
    
    func removeReply(parentID:String, author:String, replyID:String, quip:Quip,parentEventID:String?, completion: @escaping ()->()){
      /*
        db.collection("Quips").document(replyID).delete { (err) in
              if let err = err {
                                      print("Error removing document: \(err)")
                                  } else {
                                      print("Document successfully removed!")
                                  }
        }
        let userRecentRef = db.collection("Users/\(author)/RecentQuips")
                                 userRecentRef.order(by: "quips.\(replyID)").getDocuments { (querrySnapshot, error) in
                                     if let error = error{
                                         print("error: \(error)")
                                         return
                                     }
                                  if let count = querrySnapshot?.documents.count{
                                  if count > 0{
                                      let doc = querrySnapshot?.documents[0]
                                                           doc?.reference.updateData(["quips.\(replyID)":FieldValue.delete(),
                                                                                      "n": FieldValue.increment(Int64(-1))])
                                      }
                                  }
                                 }
        
        let quipRecentRef = db.collection("Quips/\(parentID)/Replies")
                              quipRecentRef.getDocuments { (querrySnapshot, error) in
                                                        if let error = error{
                                                            print("error: \(error)")
                                                            return
                                                        }
                                  if let count = querrySnapshot?.documents.count{
                                  if count > 0{
                                      let doc = querrySnapshot?.documents[0]
                                  doc?.reference.updateData([replyID:FieldValue.delete()])
                                  }
                                  }
                              }
        
        FirebaseService.sharedInstance.deleteReply(parentQuipID: parentID, author: author, replyID: replyID) {
            completion()
        }
        
        
        if let imageRef = quip.imageRef{
                              FirebaseStorageService.sharedInstance.deleteImage(imageRef: imageRef)
                          }
 */
        cloudFunctionManager.sharedInstance.functions.httpsCallable("deleteReply").call(["parentID": parentID, "user":author, "replyID":replyID]) { (result, error) in
          if let error = error as NSError? {
            if error.domain == FunctionsErrorDomain {
              let code = FunctionsErrorCode(rawValue: error.code)
              let message = error.localizedDescription
              let details = error.userInfo[FunctionsErrorDetailsKey]
             print("code:\(String(describing: code)), message:\(message), details:\(String(describing: details))")
            }
            // ...
          }
          completion()
        }
        
    }
    
    func checkIfEventIsOpen(eventID:String, completion: @escaping (Bool)->()){
        db.collection("Channels").document(eventID).getDocument { (snapshot, error) in
            if let error = error{
                print(error)
            }
            if let data = snapshot?.data(){
                if let stage = data["a"] as? Int {
            if stage == 2{
                completion(true)
            }else{
                completion(false)
            }
            }
            }
        }
    }
    func getEvent(eventID:String, completion: @escaping (Int?, String?, String?)->()){
        db.collection("Channels").document(eventID).getDocument { (snapshot, error) in
            if let error = error{
                print(error)
            }
            if let data = snapshot?.data(){
             let parentKey = data["pk"] as? String
            let parentName = data["p"] as? String
              let stage = data["a"] as? Int
                completion(stage,parentKey,parentName)
            }
        }
    }
    
    func reportQuip(quip:Quip){
        let quipID = quip.quipID
        let quipText = quip.quipText
       // let quipIsReply = quip.isReply
       // let quipAuthor = quip.user
       // let quipParent = quip.quipParent
       // let quipParentChannel = quip.parentKey
       // let quipChannel = quip.channelKey
        let imageRef = quip.imageRef
       /* let data = ["id" : quipID as Any,
                    "text": quipText as Any,
                    "isReply": quipIsReply,
                    "author": quipAuthor as Any,
                    "quipParent": quipParent as Any,
                    "parentChannelKey": quipParentChannel as Any,
                    "channelKey": quipChannel as Any,
                    "image": imageRef as Any,
                    "t":FieldValue.serverTimestamp()] as [String : Any]
 */
     let data = [
          "to": supportEmail,
          "message": [
            "subject": "User Reported Quip",
            "text": "QuipID: \(quipID ?? "None")\nText: \(quipText ?? "None")\nImageRef: \(imageRef ?? "None")"
          ]
        ] as [String : Any]
        if let aquipId = quipID{
        db.collection("Reports").document(aquipId).setData(data)
        }
    }
    
    
    func checkVerificationCode(uid:String, code:String, completion: @escaping (Bool)->()){
        let docRef = db.collection("/Users").document(uid)
                         
                     
                         docRef.getDocument{(document, error) in
                             if let document = document, document.exists {
                               if let myMap = document.data() as? [String:String]{
                                let storedCode = myMap["code"]
                                if storedCode == code{
                                    completion(true)
                                    return
                                }else{
                                    completion(false)
                                    return
                                }
                               }
                               
                                completion(false)
                                return
                              
                             }
                           completion(false)
                            return
                         }
        
    }
    
    func sendEmailVerification(uid:String, code:String, email:String){
        db.collection("Reports").document(uid).delete()

     let data = [
          "to": email,
          "message": [
            "subject": "Nut House Email Verification Code: \(code)",
            "text": "Hi,\n\nPlease enter the verification code on Nut House to join your school community. This code will expire in 15 minutes.\n\nNut House validation code: \(code)\n\nGet Cracking!\n\n-Team Nut House"
          ]
        ] as [String : Any]
        
        db.collection("Reports").document(uid).setData(data)
        
    }
    
    func addQuipToUsersHiddenPost(quipID:String, uid:String, channelkey:String?, parentChannelKey:String?, quipParentKey:String?, quipAuthoruid:String?, completion: @escaping ()->()){
       let batch = self.db.batch()
        let docRef = db.collection("/Users/\(uid)/HiddenPosts").document("HiddenPosts")
        batch.setData([quipID:true], forDocument: docRef,merge: true)
        hiddenPosts[quipID] = true
        /*
        if let achannelkey = channelkey{
            
        }
        if let aparentChannelKey = parentChannelKey{
            let docRef = db.collection("/Users/\(uid)/HiddenPosts").document(aparentChannelKey)
            batch.setData([quipID:true], forDocument: docRef,merge: true)
        }
        if let aquipParentKey = quipParentKey{
            let docRef = db.collection("/Users/\(uid)/HiddenPosts").document(aquipParentKey)
            batch.setData([quipID:true], forDocument: docRef,merge: true)
        }
        if let aquipAuthor = quipAuthoruid{
            let docRef = db.collection("/Users/\(uid)/HiddenPosts").document(aquipAuthor)
            batch.setData([quipID:true], forDocument: docRef,merge: true)
        }
 */
            batch.commit()
            completion()
    }
    
    func getHiddenPosts(uid:String,  completion: @escaping ([String:Bool])->()){
        var myHiddenPosts:[String:Bool] = [:]
               let docRef = db.collection("/Users/\(uid)/HiddenPosts").document("HiddenPosts")
                                
                            
                                docRef.getDocument{(document, error) in
                                    if let document = document, document.exists {
                                      if let myMap = document.data() as? [String:Bool]{
                                          myHiddenPosts=myMap
                                      }
                                      
                                    
                                     
                                    }
                                  completion(myHiddenPosts)
                                }
    }
    
    func addBlockedUser(uid:String, blockedUid: String){
        let docRef = db.collection("/Users/\(uid)/HiddenPosts").document("BlockedUsers")
        docRef.setData([blockedUid:true],merge: true)
        blockedUsers[blockedUid] = true
    }
    
    func getBlockedUsers(uid:String, completion: @escaping ([String:Bool])->()){
        var myBlockedUsers:[String:Bool] = [:]
                      let docRef = db.collection("/Users/\(uid)/HiddenPosts").document("BlockedUsers")
                                       
                                   
                                       docRef.getDocument{(document, error) in
                                           if let document = document, document.exists {
                                             if let myMap = document.data() as? [String:Bool]{
                                                 myBlockedUsers=myMap
                                             }
                                             
                                           
                                            
                                           }
                                         completion(myBlockedUsers)
                                       }
    }
    
    func getUniversities(completion: @escaping ([Channel])->()){
        let docRef = db.collection("/Universities").document("Schools")
        var aSchools:[Channel] = []
        docRef.getDocument { (document, error) in
            if let error = error{
                print("error:\(error)")
            }else{
                if let mySchools = document?.data(){
                    for aSchool in mySchools.keys{
                        let schoolName = aSchool
                        if let schoolInfo = mySchools[aSchool] as? [String:Any]{
                            if let email = schoolInfo["email"] as? String{
                            let mySchool = Channel(name: schoolName, akey: schoolName, email: email)
                            aSchools.append(mySchool)
                            }
                        }
                    }
                }
            }
            let sortedSchools = aSchools.sorted { $0.channelName?.lowercased() ?? "" < $1.channelName?.lowercased() ?? "" }
            completion(sortedSchools)
        }
    }
    
    func linkEmail(uid:String, email:String,code:String, completion: @escaping ()->()){
        let docRef = db.collection("/Users").document(uid)
        let data = ["email":email,
                    "code":code]
        docRef.setData(data)
        completion()
        
    }
    func enterNutsInRaffle(uid:String, nuts:Int, completion: @escaping (Bool)->()){
        let docRef = db.collection("/Raffle").document("RaffleData")
        let data = [uid: FieldValue.increment(Int64(nuts))]
        docRef.updateData(data) { (error) in
            if let aerror = error {
                completion(false)
            }else{
                completion(true)
            }
        }
    }
}
