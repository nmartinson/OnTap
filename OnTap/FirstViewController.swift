//
//  FirstViewController.swift
//  OnTap
//
//  Created by Nick Martinson on 12/22/14.
//  Copyright (c) 2014 Nick Martinson. All rights reserved.
//

import UIKit
import AVFoundation

class FirstViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate
{
    var mCode:String = ""
    var counter = 0
    var mCaptureSession:AVCaptureSession!
    var videoInput:AVCaptureDeviceInput!
    var videoCaptureDevice:AVCaptureDevice!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if(!mCaptureSession.running)
        {
            mCaptureSession.startRunning()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mCaptureSession = AVCaptureSession()
        videoCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error:NSErrorPointer = nil
        videoInput = AVCaptureDeviceInput.deviceInputWithDevice(videoCaptureDevice, error: error) as AVCaptureDeviceInput
        if(mCaptureSession.canAddInput(videoInput as AVCaptureInput))
        {
            mCaptureSession.addInput(videoInput as AVCaptureInput)
        }
        else
        {
            println("couldnt add input: \(error)")
        }
        
        var metadataOutput = AVCaptureMetadataOutput()
        if(mCaptureSession.canAddOutput(metadataOutput))
        {
            mCaptureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code]
        }
        else
        {
            println("could not add metadata output")
        }
        var previewLayer = AVCaptureVideoPreviewLayer(session: mCaptureSession)
        previewLayer.frame = self.view.layer.bounds
        self.view.layer.addSublayer(previewLayer)
        mCaptureSession.startRunning()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!)
    {
        for metadataObject in metadataObjects
        {
            var readableObject:AVMetadataMachineReadableCodeObject = metadataObject as AVMetadataMachineReadableCodeObject
            
            var type = (metadataObject as AVMetadataObject).type

            if( type == AVMetadataObjectTypeQRCode )
            {
                mCode = "\(readableObject.stringValue)"
            }
            else if(metadataObject.type == AVMetadataObjectTypeEAN13Code)
            {
                mCode = "\(readableObject.stringValue)"
            }
            else if(metadataObject.type == AVMetadataObjectTypeUPCECode)
            {
                mCode = "\(readableObject.stringValue)"
            }
//            else
//            {
//                mCode = "\(readableObject.stringValue)"
//            }
        }
        if( mCode != "" )
        {
            performSegueWithIdentifier("CodeViewSegue", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if( segue.identifier == "CodeViewSegue")
        {
            var controller = segue.destinationViewController as CodeViewController
            controller.codeStr = mCode
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        if(mCaptureSession.running)
        {
            mCaptureSession.stopRunning()
        }
    }
    
}

