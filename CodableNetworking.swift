//
//  CodableNetworking.swift
//  SwiftUtils
//
//  Created by Lucas Henrique Machado da Silva on 29/09/2018.
//  Copyright © 2018 Lucas Henrique Machado da Silva. All rights reserved.
//  See the file "LICENSE" for the full license governing this code.
//

import Foundation

enum CodableError: Error {
    case dataNotFound
    case jsonDecodification
}

class CodableNetworking<CodableObject: Codable> {
    static func get(fromURL url: URL, completionHandler: @escaping(CodableObject?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            guard (error == nil) else {
                completionHandler(nil, error)
                return
            }
            
            guard let data = data else {
                completionHandler(nil, CodableError.dataNotFound)
                return
            }
            
            do {
                let codableObject = try JSONDecoder().decode(CodableObject.self, from: data)
                completionHandler(codableObject, nil)
                return
            } catch {
                completionHandler(nil, CodableError.jsonDecodification)
                return
            }
        }.resume()
    }
}
