
import AVFoundation
import UIKit

class ExactScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var scanRect = UIImageView()
    var lblScan = UILabel()
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    var scanQR = ""
    var connecting = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !Reachability.isConnectedToNetwork(){
            let alert = UIAlertController(title: "Connection Failed", message: "Please check the internet connection and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: close))
            self.present(alert, animated: true)
        }
        let backBtn = UIBarButtonItem()
        backBtn.title = ""
        navigationItem.backBarButtonItem = backBtn
        let lang = UserDefaults.standard.string(forKey: "lang")
        if(lang != nil){
            changeLanguage(str: lang!)
        }
        view.backgroundColor = UIColor.white
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        let metadataOutput = AVCaptureMetadataOutput()
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        self.scanRect.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight*9/10)
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight*9/10)
        previewLayer.videoGravity = .resizeAspectFill
        view.addSubview(self.scanRect)
        let scanRound = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight*9/10))
        self.scanRect.addSubview(scanRound)
        scanRound.layer.addSublayer(previewLayer)
        self.lblScan.frame = CGRect(x: 0, y: screenHeight*9/10, width: screenWidth, height: screenHeight/10)
        self.lblScan.text = scanQR
        self.lblScan.font = UIFont.boldSystemFont(ofSize: 20.0)
        self.lblScan.textColor = UIColor.black
        self.lblScan.textAlignment = .center
        view.addSubview(lblScan)
        captureSession.startRunning()
    }
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        dismiss(animated: true)
    }
    func found(code: String) {
        self.lblScan.text = connecting
        let vc = storyBoard.instantiateViewController(withIdentifier: "Money2Device") as! Money2DeviceVC
        vc.vendName = code
        self.navigationController!.pushViewController(vc, animated:true)
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    func close (action: UIAlertAction){
        exit(-1)
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    func changeLanguage(str: String){
        self.scanQR = "focus".addLocalizableString(str: str)
        self.connecting = "connecting".addLocalizableString(str: str)
    }
}
