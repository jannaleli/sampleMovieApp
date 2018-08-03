//
//  BackgroundController.swift
//  movieSort
//
//  Created by Jann Aleli Zaplan on 2/8/18.
//  Copyright © 2018 Jann Aleli Zaplan. All rights reserved.
//

import Foundation

open class BackgroundController {
    open func authenticate (completionBlock: @escaping completionBlock) {
        //Call
        CallAPI().aunthenticate(completionBlock: {
            data, error in
            let requestToken = data as! String
            if error != nil {
                //Token
                self.approveToken(requestToken: requestToken, completionBlock: completionBlock)
            }else{
                //display error
                completionBlock(nil, error)
            }
            
        })
    }
    
    func approveToken(requestToken: String, completionBlock: @escaping completionBlock){
        CallAPI().validateRequestToken(requestToken: requestToken, completionBlock: {
            data, error in
            
            if error != nil {
                self.getSessionId(requestToken: requestToken, completionBlock: completionBlock)
                    
                
            }else{
                //display error
                 completionBlock(nil, error)
            }
            
        })
    }
    
    func getSessionId(requestToken: String, completionBlock: @escaping completionBlock){
        CallAPI().validateRequestToken( requestToken: requestToken, completionBlock: {
            data, error in
            
            if error != nil {
                //Start the UI :)
                self.getSessionId(requestToken: requestToken, completionBlock:{data, error in
                    
                    if error != nil {
                        completionBlock(data, nil)
                    }else{
                        completionBlock(nil, error)
                    }
                })
            }else{
                //display error
                 completionBlock(nil, error)
            }
            
        })
    }
}
