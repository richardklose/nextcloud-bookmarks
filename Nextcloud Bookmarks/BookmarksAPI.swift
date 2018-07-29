//
//  BookmarksAPI.swift
//  Nextcloud Bookmarks
//
//  Created by Richard Klose on 27.07.18.
//  Copyright © 2018 Richard Klose. All rights reserved.
//

import Foundation

struct Bookmark {
    var id: Int
    var url: String
    var title: String
}



class BookmarksAPI {
    
    func BookmarksfromJSON(data: Data) -> Array<Bookmark> {
        typealias JSONDict = [String:AnyObject]
        let json : JSONDict
        
        do {
            json = try JSONSerialization.jsonObject(with: data, options: []) as! JSONDict
        } catch {
            NSLog("JSON parsing failed: \(error)")
            return []
        }
        let jsonBookmarks = json["data"] as! [JSONDict]
        
        var bookmarks: Array<Bookmark> = []
        
        for jsonBookmark in jsonBookmarks {
            bookmarks.append(Bookmark(
                id: Int(jsonBookmark["id"] as! String)!,
                url: jsonBookmark["url"] as! String,
                title: jsonBookmark["title"] as! String
            ))
        }
        
        return bookmarks
        
    }
    
    func prepareRequest(path: String) -> URLRequest {
        let server = UserDefaults.standard.string(forKey: "server") ?? ""
        let username = UserDefaults.standard.string(forKey: "username") ?? ""
        let password = UserDefaults.standard.string(forKey: "password") ?? ""
        
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        let url = URL(string: "\(server)\(path)")
        var request = URLRequest(url: url!)
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func fetchBookmarks(success: @escaping (Array<Bookmark>) -> Void, failed: @escaping (NSError) -> Void) {
        var request = prepareRequest(path: "/index.php/apps/bookmarks/public/rest/v2/bookmark")
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, err in
            if let error = err {
                NSLog("nextcloud api error: \(error)")
                failed(NSError(domain: error.localizedDescription, code: 400))
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    let bookmarks: Array<Bookmark> = self.BookmarksfromJSON(data: data!)
                    success(bookmarks)
                default:
                    let error = NSError(
                        domain:HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode),
                        code: httpResponse.statusCode
                    );
                    failed(error)
                    NSLog("Response: %d %@", httpResponse.statusCode, HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
                }
            }
        }
        task.resume()
    }
    
    func addBookmark(url: String, success: @escaping () -> Void, failed: @escaping (NSError) -> Void) {
        let query = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed.inverted)
        var request = prepareRequest(path: "/index.php/apps/bookmarks/public/rest/v2/bookmark?url=" + query!)
        request.httpMethod = "POST"
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, err in
            if let error = err {
                NSLog("nextcloud api error: \(error)")
                failed(NSError(domain: error.localizedDescription, code: 400))
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    success()
                default:
                    let error = NSError(
                        domain:HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode),
                        code: httpResponse.statusCode
                    );
                    failed(error)
                    NSLog("Response: %d %@", httpResponse.statusCode, HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
                }
            }
        }
        task.resume()
    }
}
