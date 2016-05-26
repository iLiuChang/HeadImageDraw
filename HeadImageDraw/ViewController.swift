//
//  ViewController.swift
//  HeadImageDraw
//
//  Created by 刘畅 on 16/5/26.
//  Copyright © 2016年 ifdoo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton()
        button.frame = CGRectMake(50, 50, 100, 50)
        button.setTitle("选择头像", forState: .Normal)
        button.backgroundColor = UIColor.purpleColor()
        button.addTarget(self, action: #selector(self.click(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(button)
        
        let imageView = UIImageView()
        imageView.tag = 101
        imageView.frame  = CGRectMake(50, 100, 100, 100)
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor.blackColor()
        self.view.addSubview(imageView)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func click(button: UIButton) {
        let alertVC = UIAlertController.init(title: nil, message: nil, preferredStyle: .ActionSheet)
        let actionCamera = UIAlertAction.init(title: "拍照", style: .Default) { (action: UIAlertAction) in
            alertVC.dismissViewControllerAnimated(true, completion: nil)
            if !self.isCamera() {
                return
            }
            let pickVC = UIImagePickerController()
            pickVC.allowsEditing = false
            pickVC.delegate = self
            pickVC.sourceType = .Camera
            self.presentViewController(pickVC, animated: true, completion: nil)
            
        }
        alertVC.addAction(actionCamera)
        let actionPhoto = UIAlertAction.init(title: "相册", style: .Default) { (action: UIAlertAction) in
            alertVC.dismissViewControllerAnimated(true, completion: nil)
            if !self.isPhoto() {
                return
            }
            
            let pickVC = UIImagePickerController()
            pickVC.allowsEditing = false
            pickVC.delegate = self
            pickVC.sourceType = .PhotoLibrary
            self.presentViewController(pickVC, animated: true, completion: nil)
        }
        alertVC.addAction(actionPhoto)
        
        let actionCancel = UIAlertAction.init(title: "取消", style: .Cancel) { (action: UIAlertAction) in
            alertVC.dismissViewControllerAnimated(true, completion: nil)
        }
        alertVC.addAction(actionCancel)
        self.presentViewController(alertVC, animated: true, completion: nil)
        
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true) {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            if picker.sourceType == .Camera {
                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
            }
            let vc = LCImageDrawViewController()
            vc.origialImage = image
            vc.imageFinishedBlock = { (image: UIImage) in
                let imageView = self.view.viewWithTag(101) as! UIImageView
                imageView.image = image
            }
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
  
    func isPhoto() -> Bool{
        return UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)
    }
    
    func isCamera() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.Camera)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


