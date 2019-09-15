//
//  SquareChargeApi.swift
//  Erik Barbershop App
//
//  Created by Brian on 4/2/19.
//  Copyright © 2019 Brian. All rights reserved.
//


import Foundation
import Alamofire

/**
 
 Includes all things related to square such as methods for handling payments and OAuth tokens.
 
 THANK YOU ANNA 😍
 
 */
class SquareChargeApi {
    
    /**
     Processes a payment using the square charge API.
     
     - Parameter nonce: The card nonce provided by square.
     
     - Parameter amount: the amount that will be charged in pennies.
     
     - Parameter key: The idempotency key that will be sent to the server for charging a card.
     
     - Parameter OAuthToken: The OAuth token of the account that the money will be sent to.
     
     - Parameter isSubscribed: Determines wether or not the barbershop will pay a fee. THey don't if this is "true" and do if this is "false"
     
     - Parameter completion: A closure that contains the result of the transactions in this order: success,paymentError,networkError
     
     */
    static func processPayment(nonce: String, amount: Double, key: String, OAuthToken: String, isSubscribed:String, completion: @escaping ([String:String]?,[String:Any]?,Error?) -> Void) {
        
        //POST url
        let url = URL(string: "https://barberhub4.herokuapp.com/charge_for_cut")!
        
        //send request to the server.
        Alamofire.request(url, method: .post, parameters: ["nonce":nonce,"amount": amount,"idempotency_key":key,"OAuthToken": OAuthToken, "isSubscribed": isSubscribed], encoding:JSONEncoding.default).validate().responseJSON { (response) in
            
            //network error
            if response.error != nil {
                
                completion(nil,nil,response.error)
                
            }
                
            else if let json = response.result.value as? [String:Any] {
                //payment error
                if json["error"] != nil {
                    
                    completion(nil,json,nil)
                    
                }
                else {
                    //successful transaction
                    completion(json as? [String:String],nil,nil)
                }
                
                
            }
            
        }
        
    }
    
    /**
     Processes a refund using the square refund API.
     
     - Parameter transactionId: The ID of the transaction that will be refunded.
     
     - Parameter locationId: the ID of the location that the transaction was made with.
     
     - Parameter tenderId: the ID of the tender that will be refunded.
     
     - Parameter amount: the amount that will be refunded in pennies.
     
     - Parameter key: The idempotency key that will be sent to the server for attempting to refund.
     
     - Parameter OAuthToken: The OAuth token of the account that the transaction was made with.
     
     - Parameter completion: A closure that contains the result of the refund in this order: success,failure
     
     */
    static func processRefund(transactionId:String, locationId: String, tenderId: String, amount:Double,key:String,OAuthToken:String, completion: @escaping (String?,String?) -> Void) {
        
        //POST url
        let url = URL(string: "https://barberhub4.herokuapp.com/refund_the_cut")!
        
        Alamofire.request(url, method: .post, parameters: ["transactionId":transactionId, "locationId":locationId, "tenderId":tenderId, "amount": amount,"idempotency_key":key,"OAuthToken": OAuthToken], encoding:JSONEncoding.default).validate().responseJSON { (response) in
            
            //network error
            if response.error != nil {
                
                completion(nil,"Failure")
                
            }
                
            else if let json = response.result.value as? [String:Any] {
                
                //refund error
                if json["errors"] != nil {
                    
                    completion(nil,"Failure")
                }
                    //successful refund
                else {
                    
                    completion("Success",nil)
                    
                }
                
            }
            
        }
        
    } //end of process refund.
    
    /**
     Renews the given OAuth Token for the given barberId.
     
     - Parameter barberId: the Id of the barber whose token will be renewed.
     
     - Parameter OAuthToken: the OAuthToken that will be renewed.
     
     
     */
    static func renewOAuthToken(for barberId: String, in barbershopId: String ,OAuthToken:String) {
        
        //POST url
        let url = URL(string: "https://barberhub4.herokuapp.com/renew")!
        //send request to the server
        Alamofire.request(url,method: .post, parameters: ["barberId":barberId,"barbershopId": barbershopId,"OAuthToken":OAuthToken]).validate().response { (response) in
            
            //silently exit the function if renewal fails.
            if response.error != nil {
                
                return
                
            }
            
        }
        
    }
    
}



