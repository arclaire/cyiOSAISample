//
//  ExtView.swift
//  WeatherCy
//
//  Created by Lucy on 20/08/20.
//  Copyright © 2020 Lucy. All rights reserved.
//

import Foundation
import UIKit


extension UIView {
 
   func loadViewFromNIB() -> UIView {
    let bundle = Bundle(for:type(of: self))
    let nib = UINib(nibName: String(describing: self.classForCoder), bundle: bundle)
    let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
    
    return view
  }
  
  static func getViewFromNib(bundle bdl: Bundle? = nil, nibName strNibName: String? = nil, tag intTag: Int) -> UIView? {
    let nib: UINib
    
    if let strNibName = strNibName {
      if let bdl = bdl {
        nib = UINib(nibName: strNibName, bundle: bdl)
      } else {
        nib = UINib(nibName: strNibName, bundle: Bundle(for: self.classForCoder()))
      }
    } else {
      if let bdl = bdl {
        nib = UINib(nibName: String(describing: self.classForCoder()), bundle: bdl)
      } else {
        nib = UINib(nibName: String(describing: self.classForCoder()), bundle: Bundle(for: self.classForCoder()))
      }
    }
    
    
    let obj   = nib.instantiate(withOwner: nil, options: nil)
    
    for vw in obj {
      if let vw = vw as? UIView {
        if intTag == -1 {
          if vw.isKind(of: self.classForCoder()) {
            return vw
          }
        } else {
          if vw.tag == intTag {
            return vw
          }
        }
        
      }
    }
    
    return nil
  }
}

extension UIStoryboard {
  static func getMainStoryboard() -> UIStoryboard {
    return UIStoryboard.init(name: "Main", bundle: nil)
  }
}


extension UIFont {
  static func  printAllFonts() {
    for familyName in UIFont.familyNames as [String] {
      print("\(familyName)")
      for fontName in UIFont.fontNames(forFamilyName: familyName) as [String] {
        print("\tFont: \(fontName)")
      }
    }
  }
}

extension String {
    func formatDegree() -> String {
        let str: String = self + "°C"
        return str
    }
    
    func imageName() -> String {
        switch self.lowercased() {
        case "clouds":
            return "cloud.fill"
        case "clear":
            return "moon.stars.fill"
        default:
            return "cloud.fill"
        }
    }
    
    func stringByAppendingPathComponent(path: String) -> String {
        let string = self as NSString
        return string.appendingPathComponent(path)
    }
}

extension UIViewController {
  
}

extension Date
{
    var startOfDay: Date
    {
        return Calendar.current.startOfDay(for: self)
    }

    func getDate(dayDifference: Int) -> Date {
        var components = DateComponents()
        components.day = dayDifference
        return Calendar.current.date(byAdding: components, to:startOfDay)!
    }
    
    func getDatebyHour(dayDifference: Int) -> Date {
        var components = DateComponents()
        components.hour = dayDifference
        return Calendar.current.date(byAdding: components, to:startOfDay)!
    }
}

extension UIImageView {

    
    func setImageColor(color: UIColor) {
      let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
      self.image = templateImage
      self.tintColor = color
    }
    
}

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName:nil, bundle:Bundle.main, value:"", comment:"")
    }
    
    func localized(name: String) -> String {
        return NSLocalizedString(self, tableName:name, bundle:Bundle.main, value:"", comment:"")
    }
    
    func appendPath(path: String) -> String {
        let string = self as NSString
        return string.appendingPathComponent(path)
    }
    
    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func pcSubString(start:Int, offset:Int) -> String {
        return String.pcSubString(src: self, start: start, end: start+offset)
    }
    
    func pcSubString(start:Int, end:Int) -> String {
        return String.pcSubString(src: self, start: start, end: end)
    }
    
    static func pcSubString(src:String, start:Int, end:Int) -> String {
        let startIndex = src.index(src.startIndex, offsetBy: start)
        let endIndex =  src.index(src.startIndex, offsetBy: end)
        return String(src[startIndex..<endIndex])
    }

}

extension Date {
    func getHourDifference(time: String) -> Int {
        if time.isEmpty{
            return 0
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        let date = formatter.date(from: time)!
        let elapsedTime = self.timeIntervalSince(date)
        let hours = floor(elapsedTime / 60 / 60)

        return Int(hours)
    }
}


extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    convenience init(hex: String) {
        var string:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (string.hasPrefix("#")) {
            string.remove(at: string.startIndex)
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: string).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    convenience init(hex: String, alpha: CGFloat) {
        var string:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (string.hasPrefix("#")) {
            string.remove(at: string.startIndex)
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: string).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
    
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    public class func randomColor() -> UIColor {
        let red = arc4random() % 256
        let green = arc4random() % 256
        let blue = arc4random() % 256
        return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    public class func RGBA(r: CGFloat,g: CGFloat,b: CGFloat,a: CGFloat) -> UIColor {
        return UIColor.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
    
    public class func RGB(r: CGFloat,g: CGFloat,b: CGFloat) -> UIColor {
        return UIColor.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
    }
    
    class func colorEqual(color1:UIColor?, color2: UIColor?) -> Bool {
        guard let color1 = color1, let color2 = color2 else {
            return false
        }
        
        let componentsNum1 = color1.cgColor.numberOfComponents
        let componentsNum2 = color2.cgColor.numberOfComponents
        let components1 = color1.cgColor.components
        let components2 = color2.cgColor.components
        
        if componentsNum1 != componentsNum2 {
            return false
        } else {
            var flag = true
            
            for i in 0..<componentsNum1 {
                if components1?[i] != components2?[i] {
                    flag = false
                    break
                }
            }
            
            return flag
        }
    }
}


extension Int {
    var float: Float {
        return Float(self)
    }
    
    var cgFloat: CGFloat {
        return CGFloat(self)
    }
    
    var int32: Int32 {
        return Int32(self)
    }
    
    var string: String {
        return String(format: "%d", self)
    }
    
    func adaptBangS() -> CGFloat {
        if SDConstants.UI.Is_Iphone_X || SDConstants.UI.Is_Iphone_XR {
            return (self + 24).cgFloat
        }
        return self.cgFloat
    }
    
    func adaptNotBangS() -> CGFloat {
        if !(SDConstants.UI.Is_Iphone_X || SDConstants.UI.Is_Iphone_XR) {
            return (self - 24).cgFloat
        }
        return self.cgFloat
    }
    
    func adaptBottoms() -> CGFloat {
        if (SDConstants.UI.Is_Iphone_X || SDConstants.UI.Is_Iphone_XR) {
            return (self + 34).cgFloat
        }
        return self.cgFloat
    }
    
    func adaptNotBottomS() -> CGFloat {
        if !(SDConstants.UI.Is_Iphone_X || SDConstants.UI.Is_Iphone_XR) {
            return (self - 34).cgFloat
        }
        return self.cgFloat
    }
    
    func adaptScreenWidth() -> CGFloat {
        return (self.cgFloat/414.0) * SDConstants.UI.Screen_Width
    }
    
    func adapatScreenHeight() -> CGFloat {
        return (self.cgFloat/812.0) * SDConstants.UI.Screen_Width
    }
}


extension CGFloat {
    func timeInterval() -> CFTimeInterval {
        return CFTimeInterval(self)
    }
    
     var nt: Int {
        return Int(self)
    }
    
    var float: Float {
        return Float(self)
    }
    
    func adaptScreenWidth() -> CGFloat {
        return (self/414.0) * SDConstants.UI.Screen_Width
    }
    
    func adapatScreenHeight() -> CGFloat {
        return (self/812.0) * SDConstants.UI.Screen_Width
    }
    
    func adaptBangS() -> CGFloat {
        if SDConstants.UI.Is_Iphone_X || SDConstants.UI.Is_Iphone_XR {
            return self + 24
        }
        return self
    }
    
    func adaptNotBangS() -> CGFloat {
        if !(SDConstants.UI.Is_Iphone_X || SDConstants.UI.Is_Iphone_XR) {
            return (self - 24)
        }
        return self
    }
    
    func adaptBottoms() -> CGFloat {
        if (SDConstants.UI.Is_Iphone_X || SDConstants.UI.Is_Iphone_XR) {
            return (self + 34)
        }
        return self
    }
    
    func adaptNotBottomS() -> CGFloat {
        if !(SDConstants.UI.Is_Iphone_X || SDConstants.UI.Is_Iphone_XR) {
            return (self - 34)
        }
        return self
    }
    
    func adaptTabberBottom() -> CGFloat {
        if SDConstants.UI.Is_Iphone_X || SDConstants.UI.Is_Iphone_XR {
            return self + 34
        }
        return self
    }
    
    
}

extension UILabel {
    func setLineHeight(lineHeight: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.0
        paragraphStyle.lineHeightMultiple = lineHeight
        paragraphStyle.alignment = self.textAlignment

        let attrString = NSMutableAttributedString()
        if self.attributedText != nil {
            attrString.append( self.attributedText!)
        } else {
            if let text = self.text {
                attrString.append( NSMutableAttributedString(string: text))
            }
            if let font = self.font {
                attrString.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, attrString.length))
            }
        }
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        self.attributedText = attrString
    }
}



extension UIImage {
    
    func downsample(reductionAmount: Float) -> UIImage? {
        
        let image = UIKit.CIImage(image: self)
        guard let lanczosFilter = CIFilter(name: "CILanczosScaleTransform") else { return nil }
        lanczosFilter.setValue(image, forKey: kCIInputImageKey)
        lanczosFilter.setValue(NSNumber.init(value: reductionAmount), forKey: kCIInputScaleKey)
        
        guard let outputImage = lanczosFilter.outputImage else { return nil }
        let context = CIContext(options: [CIContextOption.useSoftwareRenderer: false])
        let scaledImage = UIImage(cgImage: context.createCGImage(outputImage, from: outputImage.extent)!)
        
        return scaledImage
    }
    
    func imageWithImageWidth (sourceImage:UIImage, scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width
        let scaleFactor = scaledToWidth / oldWidth

        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor

        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func aspectFittedToHeight(_ newHeight: CGFloat) -> UIImage {
       let scale = newHeight / self.size.height
       let newWidth = self.size.width * scale
       let newSize = CGSize(width: newWidth, height: newHeight)
       let renderer = UIGraphicsImageRenderer(size: newSize)

       return renderer.image { _ in
           self.draw(in: CGRect(origin: .zero, size: newSize))
       }
    }
    
    func fixOrientation() -> UIImage? {
        guard let cgImage = self.cgImage else {
            return nil
        }

        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }

        let width  = self.size.width
        let height = self.size.height

        var transform = CGAffineTransform.identity

        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: width, y: height)
            transform = transform.rotated(by: CGFloat.pi)

        case .left, .leftMirrored:
            transform = transform.translatedBy(x: width, y: 0)
            transform = transform.rotated(by: 0.5*CGFloat.pi)

        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: height)
            transform = transform.rotated(by: -0.5*CGFloat.pi)

        case .up, .upMirrored:
            break
        @unknown default:
            break
        }

        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)

        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)

        default:
            break;
        }

        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        guard let colorSpace = cgImage.colorSpace else {
            return nil
        }

        guard let context = CGContext(
            data: nil,
            width: Int(width),
            height: Int(height),
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: UInt32(cgImage.bitmapInfo.rawValue)
            ) else {
                return nil
        }

        context.concatenate(transform);

        switch self.imageOrientation {

        case .left, .leftMirrored, .right, .rightMirrored:
            // Grr...
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: height, height: width))

        default:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        }

        // And now we just create a new UIImage from the drawing context
        guard let newCGImg = context.makeImage() else {
            return nil
        }

        let img = UIImage(cgImage: newCGImg)

        return img;
    }
    
}


extension UIView {
    
    func makeCircleWith(size: CGSize, backgroundColor: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(backgroundColor.cgColor)
        context?.setStrokeColor(UIColor.clear.cgColor)
        let bounds = CGRect(origin: .zero, size: size)
        context?.addEllipse(in: bounds)
        context?.drawPath(using: .fill)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

}

extension Array {
    
    public mutating func replaceAllWith<C>(_ newElement: C) where Element == C.Element, C: Collection {
        replaceSubrange(startIndex..<endIndex, with: newElement)
    }
    
    subscript(i idx: Int) -> Element? {
        guard 0..<count ~= idx else { return nil }
        
        return self[idx]
    }
    
}
