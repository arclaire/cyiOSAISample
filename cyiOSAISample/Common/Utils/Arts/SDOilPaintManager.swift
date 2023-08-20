//
//  SDOilPaintManager.swift
//  cyiOSAISample
//
//  Created by Michael on 21/11/19.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import pie

class SDOilPaintManager {
    class func apply(originalImage image: UIImage, filePathOfPie path: String, completeHandler: (UIImage?) -> Void) {
        autoreleasepool {
            let processor = PIEProcessor(device: MTLCreateSystemDefaultDevice())
            
            if !FileManager.default.fileExists(atPath: path) {
                completeHandler(nil)
                
                return
            }
            
            let modelUrl: URL = URL(fileURLWithPath: path)
            
            let modelDataPie = try! Data(contentsOf: modelUrl)
            let modelPie = processor.loadModel(from: modelDataPie, useCircularPaddingConvolution: true)
            
            let inputImageCg = image.cgImage
            
            let outputImageCg = processor.styleTransfer(with: inputImageCg!, model: modelPie).takeUnretainedValue()
            
            let outputImage = UIImage(cgImage: outputImageCg)
            
            completeHandler(outputImage)
        }
    }
}
