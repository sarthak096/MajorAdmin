//
//  NewItemScan.swift
//  MajorProjectAdmin
//
//  Created by i on 4/3/18.
//  Copyright © 2018 com.sarthakkapadiya. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class NewItemScan : UIViewController, AVCaptureMetadataOutputObjectsDelegate{
    
    @IBOutlet weak var flashLight: UIButton!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var zoomPinch: UIPinchGestureRecognizer!
    var newView: NewItem?
    var prevView: OrdersViewController?
    var scannedCode: String?
    public var itemscanned: ((String) -> ())?
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var captureDevice: AVCaptureDevice?
    
    //Handles PinchZoom
    @IBAction func zoomPinch(_ sender: UIPinchGestureRecognizer) {
        
        guard let device = captureDevice else{return}
        
        if sender.state == .changed{
            let maxZoom = device.activeFormat.videoMaxZoomFactor
            let pinchvelocity: CGFloat = 4.0
            do{
                try device.lockForConfiguration()
                device.focusMode = .continuousAutoFocus
                defer{device.unlockForConfiguration()}
                
                let zoomFactor = device.videoZoomFactor + atan2(sender.velocity, pinchvelocity)
                device.videoZoomFactor = max(1.0,min(zoomFactor, maxZoom))
            }
            catch{
                print(error)
            }
        }
    }
    
   
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession?.startRunning()
        qrCodeFrameView?.frame = CGRect.zero
        
    }
    
    //Load ViewController
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        var error: NSError?
        let input: AnyObject!
        
        newView = self.storyboard!.instantiateViewController(withIdentifier: "NewItem") as? NewItem
        prevView = self.storyboard?.instantiateViewController(withIdentifier: "Orders") as? OrdersViewController
        if let captureDevice = captureDevice{
            do{
                input = try AVCaptureDeviceInput(device:captureDevice)
            }
            catch let error1 as NSError{
                error = error1
                input = nil
            }
            captureSession = AVCaptureSession()
            guard let captureSession = captureSession else{return}
            captureSession.addInput(input as! AVCaptureInput)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.upce,
                                                         AVMetadataObject.ObjectType.aztec,
                                                         AVMetadataObject.ObjectType.code128,
                                                         AVMetadataObject.ObjectType.code39,
                                                         AVMetadataObject.ObjectType.code39Mod43,
                                                         AVMetadataObject.ObjectType.code93,
                                                         AVMetadataObject.ObjectType.ean13,
                                                         AVMetadataObject.ObjectType.ean8,
                                                         AVMetadataObject.ObjectType.qr,
                                                         AVMetadataObject.ObjectType.pdf417]
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resize
            videoPreviewLayer?.frame = videoView.layer.bounds
            videoView.layer.addSublayer(videoPreviewLayer!)
            
            captureSession.startRunning()
        }
        
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.blue.cgColor
        qrCodeFrameView?.layer.borderWidth = 2
        qrCodeFrameView?.autoresizingMask = [UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleBottomMargin, UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin]
        
        view.addSubview(qrCodeFrameView!)
        view.bringSubview(toFront:qrCodeFrameView!)
        //Make Round FlashLightBTn
        flashLight.layer.cornerRadius = 0.3 * flashLight.bounds.size.width
        flashLight.clipsToBounds = true
        
        view.addSubview(flashLight!)
        view.bringSubview(toFront: flashLight!)
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Handles FlashLightBtn Action
    @IBAction func flashToggle(_ sender: UIButton) {
        if (captureDevice!.hasTorch) {
            do {
                try captureDevice?.lockForConfiguration()
                if (captureDevice?.torchMode == AVCaptureDevice.TorchMode.on) {
                    captureDevice?.torchMode = AVCaptureDevice.TorchMode.off
                } else {
                    do {
                        try captureDevice?.setTorchModeOn(level: 1.0)
                    } catch {
                        print(error)
                    }
                }
                captureDevice?.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        videoPreviewLayer?.frame = self.videoView.layer.bounds
        let orientation = UIApplication.shared.statusBarOrientation
        switch (orientation){
        case UIInterfaceOrientation.landscapeLeft:
            videoPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
        case UIInterfaceOrientation.landscapeRight:
            videoPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
        case UIInterfaceOrientation.portrait:
            videoPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        case UIInterfaceOrientation.portraitUpsideDown:
            videoPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portraitUpsideDown
        default: print("Unknown orientation state")
        }
    }
    
    public override func viewDidLayoutSubviews() {
        //
    }
    
    public override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        videoPreviewLayer?.frame = videoView.layer.bounds
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects:[AVMetadataObject], from connection: AVCaptureConnection){
        
        if metadataObjects.count == 0 || metadataObjects == nil{
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject;
        qrCodeFrameView!.frame = barCodeObject.bounds;
        if metadataObj.stringValue != nil{
            print(metadataObj.stringValue!)
           // GlobalVariables.sharedManager.codearray.append(metadataObj.stringValue!)
            GlobalVariables.sharedManager.barcode = metadataObj.stringValue!
            let alert = UIAlertController(title: "Add Item?", message: "Are you sure you want to add the item to database?", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (UIAlertAction) in
                self.prevView?.invent = { (barcode: String) in
                    _ = self.navigationController?.popViewController(animated: true)
                }
                if let prevView = self.prevView{
                    self.navigationController?.pushViewController(prevView, animated: true)
                }
            }
            let confirm = UIAlertAction(title: "Add", style: .default) { (UIAlertAction) in
                self.newView?.new = { (barcode: String) in
                    _ = self.navigationController?.popViewController(animated: true)
                }
                if let newView = self.newView{
                    self.navigationController?.pushViewController(newView, animated: true)
                }
            }
            alert.addAction(cancel)
            alert.addAction(confirm)
            present(alert,animated: true,completion: nil)
            captureSession?.stopRunning()
        }
    }
}
