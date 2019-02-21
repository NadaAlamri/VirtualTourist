//
//  FlickerAPI.swift
//  VirtualTourist
//
//  Created by Nada AlAmri on 19/05/1440 AH.
//  Copyright © 1440 udacity. All rights reserved.
//

import Foundation
class FlickerAPI
{
    static let api_Key = "ce536091398653ea103239098c3c53ef"
    static var photoURLs = [String]()
    
    
    static func pageNo(latitude: Double, longitude: Double, completion: @escaping (_ page_no: Int?,  _ error: Error?) -> Void) {
        
        var request = URLRequest (url: URL (string: "https://api.flickr.com/services/rest?api_key=\(api_Key)&method=flickr.photos.search&format=json&tags=&accuracy=11&nojsoncallback=1&lat=\(latitude)&lon=\(longitude)")!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            if error != nil {
                completion (nil, error)
                return
            }
            guard let data = data else{
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                let statusCodeError = NSError(domain: NSURLErrorDomain, code: 0, userInfo: nil)
                
                completion (nil, statusCodeError)
                return
            }
            
            if statusCode >= 200 && statusCode < 300 {
                do
                {
                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : AnyObject]
                    // Get the list of photo ID's
                    let photos = result["photos"] as! [String : AnyObject]
                    let pageCount = photos["pages"] as! Int
                     completion(pageCount, nil)
                    
                }catch {
                    completion(nil, error)
                    return
                }
            }
        }
        task.resume()
    }
    
    
    static func  searchPhoto(latitude: Double, longitude: Double, limit: Int, page :Int , completion: @escaping (_ result: [String]?,  _ error: Error?) -> Void) {
        
        var request = URLRequest (url: URL (string: "https://api.flickr.com/services/rest?api_key=\(api_Key)&method=flickr.photos.search&format=json&tags=&page=\(page)&accuracy=12&nojsoncallback=1&lat=\(latitude)&lon=\(longitude)&radius=1")!)
        request.httpMethod = "GET"
        
             let task = URLSession.shared.dataTask(with: request) {data, response, error in
            if error != nil {
                completion (nil,error)
                return
            }
            guard let data = data else{
                return
            }
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                let statusCodeError = NSError(domain: NSURLErrorDomain, code: 0, userInfo: nil)
                
                completion (nil, statusCodeError)
                return
            }
            
            if statusCode >= 200 && statusCode < 300 {
                do
                {
                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : AnyObject]
                  // Get the list of photo ID's
                    let photos = result["photos"] as! [String : AnyObject]
                    var photo = photos["photo"] as! [AnyObject]
                      var photoCount = photo.count
                        var photoIDArray = [String]()
                        var repeatCount: Int8
                        
                        if photo.count > 0
                        {
                            repeatCount = Int8((limit < photoCount) ? limit : photoCount)
                            for _ in 1...repeatCount {
                             let randomPhotoIndex = arc4random_uniform(UInt32(photoCount))
                               let obj = photo.remove(at: Int(randomPhotoIndex))
                                photoIDArray.append(obj["id"] as! String)
                               photoCount -= 1
                            }
                            completion(photoIDArray, nil)
                        }
               }catch {
                    completion(nil, error)
                    return
                }
            }
        }
        task.resume()
    }
    
    
    
    
    static func getPhotoURL(id: String, completion: @escaping (_ result: String?, _ error: Error?) -> Void) {
        
        var request = URLRequest (url: URL (string: "https://api.flickr.com/services/rest?api_key=\(api_Key)&method=flickr.photos.getInfo&format=json&nojsoncallback=1&&photo_id=\(id)")!)
        request.httpMethod = "GET"
   
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            if error != nil {
                completion (nil, error)
                return
            }
            guard let data = data else{
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                let statusCodeError = NSError(domain: NSURLErrorDomain, code: 0, userInfo: nil)
                
                completion (nil, statusCodeError)
                return
            }
            
            if statusCode >= 200 && statusCode < 300 {
                do
                {
                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : AnyObject]
            
                    let photo = result["photo"] as! [String : AnyObject]
                    let farm = photo["farm"] as! Int8
                    let serverID = photo["server"] as! String
                    let id = photo["id"] as! String
                    let secret = photo["secret"] as! String
                    let imageUrl = "https://farm\(farm).staticflickr.com/\(serverID)/\(id)_\(secret).jpg"
                    //  print(imageUrl)
                    completion(imageUrl, nil)
                }catch {
                    completion(nil, error)
                    return
                }
            }
        }
        task.resume()
    }
}

