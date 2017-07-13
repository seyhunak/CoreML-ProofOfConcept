//
//:  Unsplash.swift
//:  Created by Willow Bellemore on 2016-04-13
//:  Updated on 2016-10-09
//

import UIKit

public struct Unsplash {
    
    // MARK: Constants
    
    public typealias ImageHandler = (UIImage?) -> Void
    private static let baseUrl = "https://unsplash.it/"
    
    // MARK: Nested Types
    
    public enum Direction: String {
        case north
        case south
        case east
        case west
        case center
    }
    
    public struct Filter {
        public var isGrayscale: Bool
        public var isBlurred: Bool
        public var direction: Direction?
        
        public init(grayscale: Bool = false, blurred: Bool = false, direction: Direction? = nil) {
            self.isGrayscale = grayscale
            self.isBlurred = blurred
            self.direction = direction
        }
    }
    
    // MARK: Primary
    
    public static func randomImage(at size: CGSize, with filter: Unsplash.Filter? = nil, handler: @escaping ImageHandler) {
        var combinedUrlString = Unsplash.baseUrl
        
        if let filter = filter, filter.isGrayscale {
            combinedUrlString += "g/"
        }
        
        combinedUrlString += "\(size.width)/\(size.height)/?random"
        
        if let filter = filter {
            if filter.isBlurred {
                combinedUrlString += "&blur"
            }
            
            if let direction = filter.direction {
                combinedUrlString += "&gravity=\(direction.rawValue)"
            }
        }
        
        let dataTaskUrl = URL(string: combinedUrlString)!
        let task = URLSession.shared.dataTask(with: dataTaskUrl) { data, response, error in
            guard let data = data, let image = UIImage(data: data), error == nil else {
                DispatchQueue.main.async {
                    handler(nil)
                }
                
                print(error?.localizedDescription)
                return
            }
            
            DispatchQueue.main.async {
                handler(image)
            }
        }
        
        task.resume()
    }
    
}
