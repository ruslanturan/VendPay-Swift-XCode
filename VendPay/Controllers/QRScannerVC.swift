
import AVFoundation
import UIKit

class QRScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var scanRect = UIImageView()
    var lblScan = UILabel()
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    var scanQR = ""
    var connecting = ""
    var amountForDevice = 0
    var loggedId = ""
    var amount = ""
    var error: String = ""
    var tryAgain: String = ""
    var wrongQR: String = ""
    var busyMachine: String = ""
    var vendName: String = ""
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
        vendName = code
        self.lblScan.text = connecting
        self.amountForDevice = Int(Double(self.amount)! * 100)
        let defaults = UserDefaults.standard
        let logged = defaults.string(forKey: "logged")!.split(separator: ";").map(String.init)
        let ID = logged[1].replacingOccurrences(of: " ", with: "").split(separator: ":").map(String.init)
        self.loggedId = ID[1]
        self.machineRequest(url: "https://vendpay.ge/machine/setbalance?name=" + code + "&amount=" + String(self.amountForDevice) + "&userId=" + self.loggedId)
        let vc = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeVC
        self.navigationController!.pushViewController(vc, animated:true)
    }
    func machineRequest(url: String){
        if let myURL = NSURL(string: url) {
            do {
                let myHTMLString = try NSString(contentsOf: myURL as URL, encoding: String.Encoding.utf8.rawValue)
                if (myHTMLString.contains("Error: Machine not ")){
                    let alert = UIAlertController(title: error, message: wrongQR, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                if (myHTMLString.contains("Error: Machine is busy")){
                    let alert = UIAlertController(title: error, message: busyMachine, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                if (myHTMLString.contains("Error")){
                    let alert = UIAlertController(title: error, message: tryAgain, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                else{
                    self.request(url: "https://vendpay.ge/user/change_balance?change=minus&userId=" + self.loggedId + "&amount=" + self.amount)
                    self.request(url: "https://vendpay.ge/user/transfer_money?userId=" + self.loggedId + "&description=Paid%20to%20-%20" + self.vendName + "&amount=" + self.amount + "&addressId=0")
                    self.request(url: "https://vendpay.ge/user/transaction?userId=" + self.loggedId + "&machinename=" + self.vendName + "&amount=" + self.amount)
                }
            } catch {
                print(error)
            }
        }
    }
    func request(url: String){
        if let myURL = NSURL(string: url) {
            do {
                let myHTMLString = try NSString(contentsOf: myURL as URL, encoding: String.Encoding.utf8.rawValue)
                if (myHTMLString.contains("Error")){
                    let alert = UIAlertController(title: error, message: tryAgain, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: goHome))
                    self.present(alert, animated: true)
                    return
                }
            } catch {
                print(error)
            }
        }
    }
    func goHome(action: UIAlertAction){
        let vc = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeVC
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
        self.error = "error".addLocalizableString(str: str)
        self.tryAgain = "tryagain".addLocalizableString(str: str)
        self.wrongQR = "wrongQR".addLocalizableString(str: str)
        self.busyMachine = "busyMachine".addLocalizableString(str: str)
    }
}
