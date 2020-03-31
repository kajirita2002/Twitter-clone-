//
//  TweetService.swift
//  Twitter_tutorial
//
//  Created by 梶村律太 on 2020/03/29.
//  Copyright © 2020 梶村律太. All rights reserved.
//

import Firebase

struct TweetService {
    static let shared = TweetService()
    
    func uploadTweet(caption:String, completion: @escaping(Error?,DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = ["uid": uid,
                      "timestamp":Int(NSDate().timeIntervalSince1970),
                      "likes":0,
                      "retweets":0,
                      "caption":caption] as [String:Any]
        let ref = REF_TWEETS.childByAutoId()
        ref.updateChildValues(values) { (err, ref) in
            //update user-sweet structure after tweetupload complete
            guard let tweetID = ref.key else { return }
            REF_USER_TWEETS.child(uid).updateChildValues([tweetID:1], withCompletionBlock: completion)
        }
    }
    func fetchTweets(completion:@escaping([Tweet]) -> Void){
        var tweets = [Tweet]()
        
        REF_TWEETS.observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String:Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            let tweetId = snapshot.key
            
            UserService.shared.fetchUser(uid: uid) { user in
                let tweet = Tweet(user: user, tweetId: tweetId, dictionary: dictionary)
                tweets.append(tweet)
                completion(tweets)
            }
            
        }
    }
    func fetchTweets(for user: User, completion: @escaping([Tweet]) -> Void){
        var tweets = [Tweet]()
        REF_USER_TWEETS.child(user.uid).observe(.childAdded) { snapshot in
            let tweetID = snapshot.key
            
            REF_TWEETS.child(tweetID).observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String:Any] else { return }
                guard let uid = dictionary["uid"] as? String else { return }
                
                UserService.shared.fetchUser(uid: uid) { user in
                    let tweet = Tweet(user: user, tweetId: tweetID, dictionary: dictionary)
                    tweets.append(tweet)
                    completion(tweets)
                }
            }
        }
    }
}
