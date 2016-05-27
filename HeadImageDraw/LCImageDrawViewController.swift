//
//  LCImageDrawViewController.swift
//  HeadImageDraw
//
//  Created by 刘畅 on 16/5/26.
//  Copyright © 2016年 ifdoo. All rights reserved.
//

import UIKit

extension UIImage {
    
    class func fixOrientation(aImage: UIImage) -> UIImage {
        if (aImage.imageOrientation == .Up){
            return aImage
        }
        var transform = CGAffineTransformIdentity
        if aImage.imageOrientation == .Down || aImage.imageOrientation == .DownMirrored {
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height)
            transform = CGAffineTransformRotate(transform,CGFloat( M_PI))
        }else if aImage.imageOrientation == .Left || aImage.imageOrientation == .LeftMirrored {
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0)
            transform = CGAffineTransformRotate(transform,CGFloat(M_PI_2))
        }else if aImage.imageOrientation == .Right || aImage.imageOrientation == .RightMirrored {
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height)
            transform = CGAffineTransformRotate(transform, -CGFloat(M_PI_2))
        }
        
        if aImage.imageOrientation == .UpMirrored || aImage.imageOrientation == .DownMirrored {
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        }else if aImage.imageOrientation == .LeftMirrored || aImage.imageOrientation == .RightMirrored {
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        }
        
        let ctx = CGBitmapContextCreate(nil,Int(aImage.size.width), Int(aImage.size.height),
                                        
                                        CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                        
                                        CGImageGetColorSpace(aImage.CGImage),
                                        
                                        CGImageGetBitmapInfo(aImage.CGImage).rawValue)
        CGContextConcatCTM(ctx, transform)
        if aImage.imageOrientation == .Left || aImage.imageOrientation == .LeftMirrored || aImage.imageOrientation == .RightMirrored || aImage.imageOrientation == .Right {
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage)
        }else {
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage)
        }
        let cgimg = CGBitmapContextCreateImage(ctx)
        return UIImage(CGImage: cgimg!)
    }
    
    
}
class LCImageDrawViewController: UIViewController {
    // 放大倍数
    let maxScale: CGFloat = 1.5
    // 半径
    let radius: CGFloat = 150
    // 原图
    var origialImage: UIImage?
    // 获取图片
    var imageFinishedBlock: ((image: UIImage) -> Void)?
    
    private weak var origialImageView: UIImageView!
    private var originalFrame: CGRect!
    private weak var cropView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        initOriginalImageView()
        initCropView()
        initButton()
        initGestureRecognizer()
    }
    
    func initOriginalImageView() {
        let W = origialImage!.size.width / 2
        let H = origialImage!.size.height / 2
        let SW = self.view.frame.width
        let SH = self.view.frame.height
        var fitW: CGFloat = SW
        var fitH: CGFloat = SW / W * H
        if fitH > SH {
            fitW = SH / H * W
            fitH = SH
        }
        // width
        if fitW <= fitH && fitW < radius * 2 {
            let scale = fitW / (radius * 2)
            fitW = radius * 2
            fitH = fitH / scale
        }
        
        let imageView = UIImageView()
        imageView.frame = CGRectMake(0, 0, fitW, fitH)
        imageView.multipleTouchEnabled = true
        imageView.userInteractionEnabled = true
        imageView.image = origialImage
        imageView.center = self.view.center
        imageView.backgroundColor = UIColor.blackColor()
        
        self.view.addSubview(imageView)
        self.originalFrame = imageView.frame
        origialImageView = imageView
    }
    
    func initCropView() {
        let view = UIView()
        view.frame = CGRectMake((self.view.frame.width - (radius * 2)) / 2, (self.view.frame.height - (radius * 2)) / 2 , radius * 2, radius * 2)
        view.backgroundColor = UIColor.clearColor()
        self.view.addSubview(view)
        self.cropView = view
        let shaperLayer = CAShapeLayer()
        shaperLayer.strokeColor = UIColor.yellowColor().CGColor
        shaperLayer.fillColor = UIColor.clearColor().CGColor
        let path = UIBezierPath.init(arcCenter: self.view.center, radius: radius, startAngle: 0, endAngle: CGFloat(M_PI) * 2, clockwise: true)
        path.lineWidth = 2
        shaperLayer.path = path.CGPath
        self.view.layer.addSublayer(shaperLayer)
    }
    
    func initButton() {
        let bottomView = UIView()
        bottomView.frame = CGRectMake(0, self.view.frame.height - 50, self.view.frame.width, 50)
        bottomView.backgroundColor = UIColor.blackColor()
        bottomView.alpha = 0.7
        self.view.addSubview(bottomView)
        
        let button = UIButton()
        button.frame = CGRectMake(0, 0, 100, 50)
        button.setTitle("确定", forState: .Normal)
        button.addTarget(self, action: #selector(self.sure), forControlEvents: .TouchUpInside)
        bottomView.addSubview(button)
        
        let cancelBtn = UIButton()
        cancelBtn.frame = CGRectMake(self.view.frame.width - 100, 0, 100, 50)
        cancelBtn.setTitle("取消", forState: .Normal)
        cancelBtn.addTarget(self, action: #selector(self.cancel), forControlEvents: .TouchUpInside)
        bottomView.addSubview(cancelBtn)
    }
    func initGestureRecognizer() {
        let pinch = UIPinchGestureRecognizer.init(target: self, action: #selector(self.pinch(_:)))
        self.view.addGestureRecognizer(pinch)
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(self.pan(_:)))
        self.view.addGestureRecognizer(pan)
    }
    
    func cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func sure() {
        imageFinishedBlock!(image: getSubImage())
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getSubImage() -> UIImage {
        let squareFrame = self.cropView.frame
        let scaleRatio = self.origialImageView.frame.size.width / self.origialImage!.size.width
        var x = (squareFrame.origin.x - self.origialImageView.frame.origin.x) / scaleRatio
        var y = (squareFrame.origin.y - self.origialImageView.frame.origin.y) / scaleRatio
        var w = squareFrame.size.width / scaleRatio
        var h = squareFrame.size.width / scaleRatio
        if (self.origialImageView.frame.size.width < squareFrame.size.width) {
            let newW = self.origialImage!.size.width
            let newH = newW * (squareFrame.size.height / squareFrame.size.width)
            x = 0
            y = y + (h - newH) / 2
            w = newH
            h = newH
        }
        if (self.origialImageView.frame.size.height < squareFrame.size.height) {
            let newH = self.origialImage!.size.height
            let newW = newH * (squareFrame.size.width / squareFrame.size.height)
            x = x + (w - newW) / 2
            y = 0
            w = newH
            h = newH
        }
        let myImageRect = CGRectMake(x, y, w, h)
        return self.getCropImage(self.origialImage!, imageRect: myImageRect)
        
    }
    func pinch(pinch: UIPinchGestureRecognizer) {
        if pinch.state == .Began || pinch.state == .Changed {
            origialImageView.transform = CGAffineTransformScale(origialImageView.transform, pinch.scale, pinch.scale)
            pinch.scale = 1
            if self.origialImageView.frame.width > radius * 2 && self.origialImageView.frame.height > radius * 2 {
                self.origialImageView.frame = self.handleBorderOverflow(self.origialImageView.frame)
            }else {
                // 垂直
                var newFrame = self.origialImageView.frame
                if self.origialImageView.frame.origin.y > self.cropView.frame.origin.y {
                    newFrame.origin.y = self.cropView.frame.origin.y
                }
                if self.origialImageView.frame.maxY < self.cropView.frame.maxY {
                    newFrame.origin.y = self.cropView.frame.maxY - newFrame.size.height
                }
                self.origialImageView.frame = newFrame
            }
        }else if pinch.state == .Ended {
            var newFrame = handleScaleOverflow(self.origialImageView.frame)
            newFrame = handleBorderOverflow(newFrame)
            UIView.animateWithDuration(0.25, animations: {
                self.origialImageView.frame = newFrame
            })
        }
    }
    
    func pan(pan: UIPanGestureRecognizer) {
        if pan.state == .Began || pan.state == .Changed {
            let translation = pan.translationInView(origialImageView.superview)
            origialImageView.center = CGPointMake(origialImageView.center.x + translation.x, origialImageView.center.y + translation.y)
            pan.setTranslation(CGPointZero, inView: origialImageView.superview)
        }else if pan.state == .Ended {
            UIView.animateWithDuration(0.25, animations: {
                self.origialImageView.frame = self.handleBorderOverflow(self.origialImageView.frame)
            })
        }
        
    }
    
    func handleScaleOverflow(lastFrame: CGRect) -> CGRect {
        
        var newFrame = lastFrame
        let oriCenter = self.origialImageView.center
        if (newFrame.size.width < self.originalFrame.size.width) {
            newFrame = self.originalFrame
        }
        var maxFrame = self.originalFrame
        maxFrame.size.width = self.originalFrame.width * maxScale
        maxFrame.size.height = self.originalFrame.height * maxScale
        if (newFrame.size.width > maxFrame.size.width) {
            newFrame = maxFrame
        }
        newFrame.origin.x = oriCenter.x - (newFrame.size.width / 2)
        newFrame.origin.y = oriCenter.y - (newFrame.size.height / 2)
        return newFrame
    }
    
    func handleBorderOverflow(lastFrame: CGRect) -> CGRect {
        let cropFrame = self.cropView.frame
        var newFrame = lastFrame
        // 水平
        if lastFrame.origin.x > cropFrame.origin.x {
            newFrame.origin.x = cropFrame.origin.x
        }
        if lastFrame.maxX < cropFrame.maxX {
            newFrame.origin.x = cropFrame.maxX - newFrame.size.width
        }
        // 垂直
        if lastFrame.origin.y > cropFrame.origin.y {
            newFrame.origin.y = cropFrame.origin.y
        }
        if lastFrame.maxY < cropFrame.maxY {
            newFrame.origin.y = cropFrame.maxY - newFrame.size.height
        }
        if self.origialImageView.frame.size.width > self.origialImageView.frame.size.height && newFrame.size.height <= self.cropView.frame.size.height {
            newFrame.origin.y = self.cropView.frame.origin.y + (self.cropView.frame.size.height - newFrame.size.height) / 2
        }
        return newFrame
    }
    
    // 获取裁剪的图片
    func getCropImage(originalImage: UIImage, imageRect: CGRect) -> UIImage {
        let fixImage = UIImage.fixOrientation(originalImage)
        let subImageRef = CGImageCreateWithImageInRect(fixImage.CGImage, imageRect)
        UIGraphicsBeginImageContext(imageRect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextDrawImage(context, imageRect, subImageRef)
        let cropImage = UIImage(CGImage: subImageRef!)
        UIGraphicsEndImageContext()
        return cropImage
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

