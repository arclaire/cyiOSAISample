//
//  SDFaceHandler.swift
//  cyiOSAISample
//
//  Created by Lucy on 12/12/20.
//  Copyright © 2020 JKT APPTech Limited. All rights reserved.
//

import UIKit
import CoreImage
import Vision
public enum FacePhotoExif: Int {
    case orow_top_ocol_left = 1
    case orow_top_ocol_right = 2
    case orow_bottom_ocol_right = 3
    case orow_bottom_ocol_left = 4
    case orow_left_ocol_top = 5
    case orow_right_ocol_top = 6
    case orow_right_ocol_bottom = 7
    case orow_left_ocol_bottom = 8
}


class SDFaceHandler: NSObject {
    
    // MARK: - Property
    private var faceDetector: CIDetector!
    
    override init() {
        let deteDic = [CIDetectorAccuracy: CIDetectorAccuracyLow, CIDetectorTracking: true] as [String : Any]
        
        self.faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: deteDic)
    }
    
}


// MARK: - Class Methods

extension SDFaceHandler {
    class func faceOutlineRect(feature: CIFeature) -> CGRect {
        var faceRect = feature.bounds
        
        print("face rect: \(faceRect)")
        
        let prevY = faceRect.origin.y
        faceRect.origin.y = faceRect.origin.x
        faceRect.origin.x = prevY
        
        return faceRect
    }
    
    class func faceOutlineCenter(feature: CIFeature, buffer: CMSampleBuffer, parent view: UIView) -> CGPoint {
        let rect = SDFaceHandler.faceOutlineRect(feature: feature, buffer: buffer, parent: view)
        let point = CGPoint(x: (rect.minX + rect.maxX)/2, y: (rect.minY + rect.maxY)/2)
        
        return point
    }
    
    class func faceOutlineRect(feature: CIFeature, buffer: CMSampleBuffer, parent view: UIView) -> CGRect {
        let piexlBuffer = CMSampleBufferGetImageBuffer(buffer)!
        let attachments = CMCopyDictionaryOfAttachments(allocator: kCFAllocatorDefault, target: buffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)
        
        let convertedImage = CIImage(cvImageBuffer: piexlBuffer, options: attachments as? [CIImageOption : Any])
        let prevImageSize = UIImage(ciImage: convertedImage).size
        
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -prevImageSize.height)
        var newBounds = feature.bounds.applying(transform)
        
        
        let pareImageSize = view.bounds.size
        let scale = min(pareImageSize.width/prevImageSize.width, pareImageSize.height/prevImageSize.height)
        let offsetX = (pareImageSize.width - prevImageSize.width * scale)/2
        let offsetY = (pareImageSize.height - prevImageSize.height * scale)/2
        newBounds = newBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
        newBounds.origin.x += offsetX
        newBounds.origin.y += offsetY
        
        return newBounds
    }
    
}


// MARK: - Class Methods

extension SDFaceHandler {
    func facesOutlineFeatureInBuffer(image buffer: CMSampleBuffer, position: AVCaptureDevice.Position) -> [CIFeature] {
        let piexlBuffer = CMSampleBufferGetImageBuffer(buffer)!
        let attachments = CMCopyDictionaryOfAttachments(allocator: kCFAllocatorDefault, target: buffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)
        
        let convertedImage = CIImage(cvImageBuffer: piexlBuffer, options: attachments as? [CIImageOption : Any])
        
        var imageOptions: [String: Any] = [:]
        let currDeviceOrientation = UIDevice.current.orientation
        var exitOrientation: FacePhotoExif = .orow_top_ocol_left
        
        let isFrontFacingCamera = currDeviceOrientation.rawValue != AVCaptureDevice.Position.back.rawValue
        
        switch currDeviceOrientation {
            case .portraitUpsideDown:
                exitOrientation = .orow_left_ocol_bottom
            break
            
            case .landscapeLeft:
                if isFrontFacingCamera {
                    exitOrientation = .orow_bottom_ocol_right
                }else {
                    exitOrientation = .orow_top_ocol_left
                }
            break
            
            case .landscapeRight:
                if isFrontFacingCamera {
                    exitOrientation = .orow_top_ocol_left
                }else {
                    exitOrientation = .orow_bottom_ocol_right
                }
            break
            
            default:
                exitOrientation = .orow_right_ocol_top
            break
        }
        
        imageOptions = [CIDetectorImageOrientation: NSNumber(value: exitOrientation.rawValue)]
        
        return self.faceDetector.features(in: convertedImage, options: imageOptions)
    }
    
}

class FaceDetector {
    var intFace: Int = 0
    var isSmiline: Bool = false
    func findLandmarks(for image: UIImage, completion: @escaping (UIImage, Int) -> Void) {
        var resultImage = image
        let detectFaceRequest = VNDetectFaceLandmarksRequest { (request, error) in
            
            guard let observations = request.results as? [VNFaceObservation], error == nil else {
                return
            }
            
            print("Found \(observations.count) faces in the image")
            self.intFace = observations.count
            for face in observations {
                guard let landmark = face.landmarks else {
                    continue
                }
                
                let boundingBox = face.boundingBox
                var landmarkRegions: [VNFaceLandmarkRegion2D] = []
                
                if let faceContour = landmark.faceContour {
                    landmarkRegions.append(faceContour)
                }
                
                if let leftEye = landmark.leftEye {
                    landmarkRegions.append(leftEye)
                }
                
                if let rightEye = landmark.rightEye {
                    landmarkRegions.append(rightEye)
                }
                
                if let nose = landmark.nose {
                    landmarkRegions.append(nose)
                }
                
                if let noseCrest = landmark.noseCrest {
                    landmarkRegions.append(noseCrest)
                }
                
                if let medianLine = landmark.medianLine {
                    landmarkRegions.append(medianLine)
                }
                
                if let outerLips = landmark.outerLips {
                    landmarkRegions.append(outerLips)
                }
                
        
                resultImage = self.drawOnImage(source: resultImage, boundingBox: boundingBox, regions: landmarkRegions)
            }
            
            let ciImage = CIImage(cgImage: image.cgImage!)

                let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
                let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: options)!

                let faces = faceDetector.features(in: ciImage)

                if let face = faces.first as? CIFaceFeature {
                    print("Found face at \(face.bounds)")

                    if face.hasSmile {
                        self.isSmiline = true
                    }
                }
            completion(resultImage, observations.count)
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        do {
            try requestHandler.perform([detectFaceRequest])
        }catch {
            print(error)
        }
    }
    
    private func drawOnImage(source: UIImage, boundingBox: CGRect, regions faceLandmarks: [VNFaceLandmarkRegion2D]) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(source.size, false, 1)
        
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: source.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(CGBlendMode.colorBurn)
        context.setLineJoin(.round)
        context.setLineCap(.round)
        context.setShouldAntialias(true)
        context.setAllowsAntialiasing(true)
        
        let rectWidth = source.size.width * boundingBox.size.width
        let rectHeight = source.size.height * boundingBox.size.height
        
        let rect = CGRect(x: 0, y: 0, width: source.size.width, height: source.size.height)
        context.draw(source.cgImage!, in: rect)
        
        // draw face rect
        var fillColor = UIColor.yellow
        fillColor.setFill()
        let x = boundingBox.origin.x * source.size.width
        let y = boundingBox.origin.y * source.size.height
        let w = rectWidth
        let h = rectHeight
        context.addRect(CGRect(x: x, y: y, width: w, height: h))
        context.drawPath(using: CGPathDrawingMode.stroke)
        
        // draw features
        fillColor = UIColor.blue
        fillColor.setStroke()
        
        context.setLineWidth(2.0)
        for faceRegion in faceLandmarks {
            var points: [CGPoint] = []
            for i in 0..<faceRegion.pointCount {
                let point = faceRegion.normalizedPoints[i]
                let p = CGPoint(x: CGFloat(point.x), y: CGFloat(point.y))
                points.append(p)
            }

            let mappedPoints = points.map {
                CGPoint(x: boundingBox.origin.x * source.size.width + $0.x * rectWidth, y: boundingBox.origin.y * source.size.height + $0.y * rectHeight)
            }
            context.addLines(between: mappedPoints)
            context.drawPath(using: CGPathDrawingMode.stroke)
        }
        
        let faceImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return faceImage
    }
    
}
















