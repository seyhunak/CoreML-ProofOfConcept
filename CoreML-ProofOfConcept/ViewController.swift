//
//  ViewController.swift
//  CoreML-ProofOfConcept
//
//  Created by Seyhun Akyürek on 13/07/2017.
//  Copyright © 2017 seyhunak. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var classifiedLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    //MARK: - Properities
    var model: Inceptionv3!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        model = Inceptionv3()
        getRandomPhoto()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Actions
    @IBAction func getRandomButtonTapped(_ sender: Any) {
        getRandomPhoto()
    }
    
    //MARK: - Get Random Photo
    func getRandomPhoto() {
        self.classifiedLabel.text = "Identifing Image..."
        let size = CGSize(width: 300.0, height: 300.0)
        let filter = Unsplash.Filter(grayscale: false, blurred: false, direction: .west)
        Unsplash.randomImage(at: size, with: filter) { image in
            guard let image = image else {
                return
            }
            
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 299, height: 299), true, 2.0)
            image.draw(in: CGRect(x: 0, y: 0, width: 299, height: 299))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
            var pixelBuffer : CVPixelBuffer?
            let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(newImage.size.width), Int(newImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
            guard (status == kCVReturnSuccess) else {
                return
            }
            
            CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
            let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
            
            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: pixelData, width: Int(newImage.size.width), height: Int(newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) //3
            
            context?.translateBy(x: 0, y: newImage.size.height)
            context?.scaleBy(x: 1.0, y: -1.0)
            
            UIGraphicsPushContext(context!)
            newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
            UIGraphicsPopContext()
            CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
            
            self.imageView.image = newImage
            guard let prediction = try? self.model.prediction(image: pixelBuffer!) else {
                return
            }
            
            self.classifiedLabel.text = "This is a \(prediction.classLabel)."
        }
    }
}
