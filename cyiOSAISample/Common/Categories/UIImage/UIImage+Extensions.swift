//
//  UIImage+Extensions.swift
//  cyiOSAISample
//
//  Created by Michael on 07/01/20.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit

extension UIImage {
    func scaleImage(_ scaleSize: CGFloat) -> UIImage {
        let newSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func resizeImageTo(size: CGSize) -> UIImage? {
        guard let cgImage = self.cgImage else {
            return self
        }
        
        let w = Int(size.width)
        let h = Int(size.height)
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGImageByteOrderInfo.orderDefault.rawValue
        let newContext = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * bytesPerPixel, space: colorSpaceRef, bitmapInfo: bitmapInfo)
        let renderFrame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        newContext?.draw(cgImage, in: renderFrame)
        if let newCGImage = newContext?.makeImage() {
            return UIImage(cgImage: newCGImage)
        }
        return self
    }
    
    func resizeImageTo(target: CGFloat) -> UIImage? {
        guard let cgImage = self.cgImage else {
            return self
        }
        
        let width = self.size.width
        let height = self.size.height
        let scale = width/height
        
        var sizeChange = CGSize()
        
        if width <= target && height <= target {
            return self
        } else if width > target || height > target {
            
            if scale <= 2 && scale >= 1 {
                let changedWidth:CGFloat = target
                let changedheight:CGFloat = changedWidth / scale
                sizeChange = CGSize(width: changedWidth, height: changedheight)
                
            } else if scale >= 0.5 && scale <= 1 {
                
                let changedheight:CGFloat = target
                let changedWidth:CGFloat = changedheight * scale
                sizeChange = CGSize(width: changedWidth, height: changedheight)
                
            } else if width > target && height > target {
                if scale > 2 {

                    let changedheight:CGFloat = target
                    let changedWidth:CGFloat = changedheight * scale
                    sizeChange = CGSize(width: changedWidth, height: changedheight)
                    
                } else if scale < 0.5{
                    
                    let changedWidth:CGFloat = target
                    let changedheight:CGFloat = changedWidth / scale
                    sizeChange = CGSize(width: changedWidth, height: changedheight)
                    
                }
            } else {
                return self
            }
        }
        let w = Int(sizeChange.width)
        let h = Int(sizeChange.height)
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGImageByteOrderInfo.orderDefault.rawValue
        let newContext = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * bytesPerPixel, space: colorSpaceRef, bitmapInfo: bitmapInfo)
        let renderFrame = CGRect(x: 0.0, y: 0.0, width: sizeChange.width, height: sizeChange.height)
        newContext?.draw(cgImage, in: renderFrame)
        
        if let newCGImage = newContext?.makeImage() {
            return UIImage(cgImage: newCGImage)
        }
        
        return self
    }
    
    func resizeWithScaleAspectFitMode(to dimension: CGFloat) -> UIImage? {
        if max(size.width, size.height) <= dimension { return self }

        var newSize: CGSize!
        let aspectRatio = size.width/size.height

        if aspectRatio > 1 {
            // Landscape image
            newSize = CGSize(width: dimension, height: dimension / aspectRatio)
        } else {
            // Portrait image
            newSize = CGSize(width: dimension * aspectRatio, height: dimension)
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        defer { UIGraphicsEndImageContext() }
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func decompressImage() -> UIImage? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        let width = cgImage.width
        let height = cgImage.height
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGImageByteOrderInfo.orderDefault.rawValue
        let newContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * bytesPerPixel, space: colorSpaceRef, bitmapInfo: bitmapInfo)
        let renderFrame = CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height))
        newContext?.draw(cgImage, in: renderFrame)
        
        if let newCGImage = newContext?.makeImage() {
            return UIImage(cgImage: newCGImage)
        }
        return nil
    }
    
    func compressImage(maxLength: Int) -> UIImage? {
        var compression: CGFloat = 0.7
        var data = self.jpegData(compressionQuality: compression)
        print("Image Data Count \(data!.count)")
        while data != nil && data!.count > maxLength && compression > 0.1 {
            compression -= 0.1
            data = self.jpegData(compressionQuality: compression)
            
            print("Image Data Count \(data!.count)")
        }
        if let compressedData = data {
            return UIImage(data: compressedData)
        }
        return nil
    }
    
    func format(maxLength: CGFloat) -> UIImage? {
        
        var scaleSize = self.size
        if (self.size.width > maxLength || self.size.height > maxLength) {
            
            if (self.size.width > maxLength) {
                let width = maxLength
                let height = self.size.height * (width / self.size.width)
                scaleSize = CGSize(width: width, height: height)
            } else {
                let height = maxLength
                let width = self.size.width * (height / self.size.height)
                scaleSize = CGSize(width: width, height: height)
            }
        }
        
        UIGraphicsBeginImageContextWithOptions(scaleSize, false, 1)
        self.draw(in: CGRect(x: 0, y: 0, width: scaleSize.width, height: scaleSize.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
    
    class func createImageWithColor(color: UIColor) -> UIImage {
        let drawRect = CGRect(x: 0.0, y: 0.0, width: 17.0, height: 17.0)
        UIGraphicsBeginImageContext(drawRect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(drawRect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    class func createImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let drawRect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(drawRect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(drawRect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func cricle(diameter: CGFloat) -> UIImage {
        let outputRect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        UIGraphicsBeginImageContextWithOptions(outputRect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        context?.addEllipse(in: outputRect)
        context?.clip()
        
        self.draw(in: CGRect(x: (diameter - self.size.width)/2, y: (diameter - self.size.height)/2, width: self.size.width, height: self.size.height))
        
        let maskImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return maskImage!
    }
    
     func circle() -> UIImage {
        let shotest = min(size.width, size.height)
        
        return cricle(diameter: shotest)
    }
}

extension UIImage {
    func normalize() -> UIImage {
        if (self.imageOrientation == .up) { return self }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        guard let normalizedImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        UIGraphicsEndImageContext()
        return normalizedImage
    }
    
    func resetPixelArtisticFilterOriginalImage() -> UIImage {
        var scaleThreshold : CGFloat =  3000000.00
        var scaleFloorThreshold : CGFloat = 3000000.00
        if UIDevice.current.modelName < "iPhone 6s" {
            scaleThreshold =  1200000.00
            scaleFloorThreshold = 1200000.00
        }else if UIDevice.current.modelName < "iPhone 8" && UIDevice.current.modelName >= "iPhone 6s" {
            scaleThreshold =  2200000.00
            scaleFloorThreshold = 2200000.00
        }
        
        let fbl = size.width * size.height
        
        var scaleImage : UIImage = self
        if fbl >= scaleThreshold {
            var scale = scaleThreshold / fbl
            scale = sqrt(scale)
            if scale < 1 {
                scaleImage = self.scaleImage(scaleTimes: scale)
            }
            
        } else if fbl <= scaleFloorThreshold {
            var scale = scaleFloorThreshold / fbl
            scale = sqrt(scale)
            if scale < 1 {
                scaleImage = self.scaleImage(scaleTimes: scale)
            }
            
        }
        
        return scaleImage
    }
    
    func fixOrientation(orientation: UIImage.Orientation) -> UIImage {
        if (orientation == .left || orientation == .right || orientation == .down) {
            var degree: CGFloat = 0
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rect: CGRect = .zero
            if (orientation == .left) {
                rect = CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width)
                degree = -CGFloat.pi / 2
                y = rect.height
                
            } else if (orientation == .right) {
                rect = CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width)
                degree = CGFloat.pi / 2
                x = rect.width
                
            } else {
                rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
                degree = CGFloat.pi
                x = rect.width
                y = rect.height
            }
            
            UIGraphicsBeginImageContextWithOptions(rect.size, false, self.scale)
            guard let context = UIGraphicsGetCurrentContext() else { return self }
            context.translateBy(x: x, y: y)
            context.rotate(by: degree)
            self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
            guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return self }
            UIGraphicsEndImageContext()
            return image
        }
        
        return self
    }
    
    func scaleImage(scaleTimes scale: CGFloat) -> UIImage {
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        UIGraphicsBeginImageContext(newSize)
        draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func scaleImageOptions(scaleTimes scale: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: CGSize(width: size.width * scale, height: size.height * scale)))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func rotateImageByRadious(radious: CGFloat) -> UIImage {
        let rotateView = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let transform = CGAffineTransform(rotationAngle: radious)
        rotateView.transform = transform
        
        let rotateSize = rotateView.frame.size
        
        UIGraphicsBeginImageContext(rotateSize)
        let context = UIGraphicsGetCurrentContext()
        
        context?.translateBy(x: rotateSize.width/2, y: rotateSize.height/2)
        context?.rotate(by: radious)
        context?.scaleBy(x: self.scale, y: self.scale)
        context?.draw(self.cgImage!, in: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))
        
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func mirrorImageInHorizontal() -> UIImage {
        let drawRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        
        UIGraphicsBeginImageContextWithOptions(drawRect.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        context?.clip(to: drawRect)
        
        context?.rotate(by: CGFloat.pi)
        context?.translateBy(x: -drawRect.size.width, y: -drawRect.size.height)
        context?.draw(self.cgImage!, in: drawRect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return UIImage(cgImage: (newImage?.cgImage!)!, scale: self.scale, orientation: self.imageOrientation)
    }
    
    func resized(to newSize: CGSize, scale: CGFloat = 1) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        let image = renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
        return image
    }
    
    func trim() -> UIImage {
        let newRect = self.cropRect
        if let imageRef = self.cgImage!.cropping(to: newRect) {
            return UIImage(cgImage: imageRef)
        }
        return self
    }
    
    func trimByRect(rect: CGRect) -> UIImage{
        if let imageRef = self.cgImage!.cropping(to:rect){
            return UIImage(cgImage: imageRef)
        }
        return self
    }

    var cropRect: CGRect {
        let cgImage = self.cgImage
        let context = createARGBBitmapContextFromImage(inImage: cgImage!)
        if context == nil {
            return CGRect.zero
        }

        let height = CGFloat(cgImage!.height)
        let width = CGFloat(cgImage!.width)

        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context?.draw(cgImage!, in: rect)

        //let data = UnsafePointer<CUnsignedChar>(CGBitmapContextGetData(context))
        guard let data = context?.data?.assumingMemoryBound(to: UInt8.self) else {
            return CGRect.zero
        }

        var lowX = width
        var lowY = height
        var highX: CGFloat = 0
        var highY: CGFloat = 0

        let heightInt = Int(height)
        let widthInt = Int(width)
        //Filter through data and look for non-transparent pixels.
        for y in (0 ..< heightInt) {
            let y = CGFloat(y)
            for x in (0 ..< widthInt) {
                let x = CGFloat(x)
                let pixelIndex = (width * y + x) * 4 /* 4 for A, R, G, B */

                if data[Int(pixelIndex)] == 0  { continue } // crop transparent

                if data[Int(pixelIndex+1)] > 0xE0 && data[Int(pixelIndex+2)] > 0xE0 && data[Int(pixelIndex+3)] > 0xE0 { continue } // crop white

                if (x < lowX) {
                    lowX = x
                }
                if (x > highX) {
                    highX = x
                }
                if (y < lowY) {
                    lowY = y
                }
                if (y > highY) {
                    highY = y
                }

            }
        }

        return CGRect(x: lowX, y: lowY, width: highX - lowX, height: highY - lowY)
    }

    func createARGBBitmapContextFromImage(inImage: CGImage) -> CGContext? {

        let width = inImage.width
        let height = inImage.height

        let bitmapBytesPerRow = width * 4
        let bitmapByteCount = bitmapBytesPerRow * height

        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let bitmapData = malloc(bitmapByteCount)
        if bitmapData == nil {
            return nil
        }

        let context = CGContext (data: bitmapData,
                                 width: width,
                                 height: height,
                                 bitsPerComponent: 8,      // bits per component
            bytesPerRow: bitmapBytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)

        return context
    }
    
    func visionSize() -> CGSize {
        let maxLength: CGFloat = 1080
        var scaleSize = self.size
        if (self.size.width > maxLength || self.size.height > maxLength) {
            
            if (self.size.width > maxLength) {
                let width = maxLength
                let height = self.size.height * (width / self.size.width)
                scaleSize = CGSize(width: width, height: height)
            } else {
                let height = maxLength
                let width = self.size.width * (height / self.size.height)
                scaleSize = CGSize(width: width, height: height)
            }
        }
        return scaleSize
    }
    
    func scaledImage(withSize size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Attempt to convert the scaled image to PNG or JPEG data to preserve the bitmap info.
        guard let image = scaledImage else { return nil }
        let imageData = image.pngData() ??
            image.jpegData(compressionQuality: 0.8)
        return imageData.map { UIImage(data: $0) } ?? nil
    }
    
}


// MARK: - Clip

extension UIImage {
    func clipImageWithRect(rect: CGRect) -> UIImage {
        let imageRef = self.cgImage?.cropping(to: rect)
        let tempImage = UIImage.init(cgImage: imageRef!)
        
        return tempImage
    }
    
    func clipImageWithRatio(ratio: CGFloat) -> UIImage {
        let width = self.cgImage?.width
        let height = self.cgImage?.height
        
        let ratioHeight = width!.cgFloat * ratio
        var rect: CGRect = .zero
        
        if Int(ratioHeight) <= height! {
            rect = CGRect(x: 0.cgFloat, y: height!.cgFloat/2 - ratioHeight/2, width: width!.cgFloat, height: ratioHeight)
        }else {
            let ratioWidth = height!.cgFloat/ratio
            rect = CGRect(x: width!.cgFloat/2 - ratioWidth/2, y: 0, width: ratioWidth, height: height!.cgFloat)
        }
        
        return clipImageWithRect(rect: rect)
    }
    
}

extension CGImage {
    public static func image(by texture: MTLTexture) -> CGImage? {
        let imageWidth = texture.width
        let imageHeight = texture.height
        let bytesPerRow = imageWidth * 4
        let region = MTLRegionMake2D(0, 0, imageWidth, imageHeight)
        let bytes = UnsafeMutableRawPointer.allocate(byteCount: bytesPerRow * imageHeight, alignment: MemoryLayout<UInt8>.alignment)
        texture.getBytes(bytes, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        
        return toCGImage(from: bytes, width: imageWidth, height: imageHeight)
    }
    
    private static func toCGImage(from pixelValues: UnsafeMutableRawPointer, width: Int, height: Int) -> CGImage? {
        var imageRef: CGImage?
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bitsPerPixel = bytesPerPixel * bitsPerComponent
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = height * bytesPerRow
        
        let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | CGImageByteOrderInfo.order32Little.rawValue
        let releaseMaskImagePixelData: CGDataProviderReleaseDataCallback = { (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
            return
        }
        let providerRef = CGDataProvider(dataInfo: nil, data: pixelValues, size: totalBytes, releaseData: releaseMaskImagePixelData)
        imageRef = CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, space: colorSpaceRef, bitmapInfo: CGBitmapInfo(rawValue: bitmapInfo), provider: providerRef!, decode: nil, shouldInterpolate: false, intent: CGColorRenderingIntent.defaultIntent)
        return imageRef
    }
}

extension CIImage {
    func createCGImage() -> CGImage? {
        let size = self.extent.size
        return CIContext().createCGImage(self, from: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    }
}
