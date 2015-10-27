//
// 藍芽 BLE 測試,  HC-08模組
// D_DEVNAME = "HTEBT401"
// UUID  :0000ffe0-0000-1000-8000-00805f9b34fb (Service)
// chart :0000ffe1-0000-1000-8000-00805f9b34fb (Characteristic)
// 
// 藍牙 BLE 必填標準參數，關閉或打開通知(Notify)的UUID, 藍牙規格固定值
// NOTIFY = "00002902-0000-1000-8000-00805f9b34fb" (Descriptor)
//

import UIKit
import CoreBluetooth
import Foundation

class MainHome: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    let D_BTDEVNAME = "HTEBT401"
    let UID_SERV  : CBUUID = CBUUID(string: "0000ffe0-0000-1000-8000-00805f9b34fb")
    let UID_CHAR  : CBUUID = CBUUID(string: "0000ffe1-0000-1000-8000-00805f9b34fb")
    let UID_NOTIFY: CBUUID = CBUUID(string: "00002902-0000-1000-8000-00805f9b34fb")
    
    @IBOutlet weak var labMsg1: UILabel!
    @IBOutlet weak var txtMsg: UITextView!
    
    var centralManager:CBCentralManager!
    var blueToothReady = false
    var connectingPeripheral: CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func startUpCentralManager() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func discoverDevices() {
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    /**
     * start Discover BT peripheral(周邊裝置)
     * On detecting a device, will get a call back to "didDiscoverPeripheral"
     */
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("Discovered: \(peripheral.name)")
        txtMsg.text = txtMsg.text + "Discovered: \(peripheral.name)\n"
        
        // TODO 需要設定搜尋時間
        
        // 找到指定裝置名稱/addr
        if (peripheral.name == D_BTDEVNAME) {
            self.connectingPeripheral = peripheral
            self.centralManager.stopScan()
            self.centralManager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    /**
    * 找到指定的BT, 開始查詢與連接 BT Service channel
    */
    func centralManager(central: CBCentralManager,didConnectPeripheral peripheral: CBPeripheral) {
        
        peripheral.delegate = self
        peripheral.discoverServices([UID_SERV])
        print("Connected BT device")
        txtMsg.text! += "Connected BT device\n"
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) { //BLE status
        var msg = ""
        switch (central.state) {
        case .PoweredOff:
            msg = "CoreBluetooth BLE hardware is powered off"
            print("\(msg)")
            
        case .PoweredOn:
            msg = "CoreBluetooth BLE hardware is powered on and ready"
            blueToothReady = true;
            
        case .Resetting:
             msg = "CoreBluetooth BLE hardware is resetting"
            
        case .Unauthorized:
             msg = "CoreBluetooth BLE state is unauthorized"
            
        case .Unknown:
             msg = "CoreBluetooth BLE state is unknown"
            
        case .Unsupported:
             msg = "CoreBluetooth BLE hardware is unsupported on this platform"
            
        }
        txtMsg.text! += "\(msg)\n"
        
        print(msg)
        
        if blueToothReady {
            discoverDevices()
        }
    }
    
    /**
    * 查詢 BT Service channel 指定的 charccter code
    */
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?)
    {
        // 指定的 Service channel 查詢 character code
        let mService: CBService = peripheral.services![0]
        
        txtMsg.text! += "Service: \(mService.UUID)\n"
        peripheral.discoverCharacteristics([UID_CHAR], forService: mService)
        
        /**
        let servicePeripherals: [CBService] = peripheral.services!
        
        if (servicePeripherals.count > 0) {
            var strMsg: String = "";
            
            for servicePeripheral in servicePeripherals {
                print("Service: \(servicePeripheral.UUID)")
                strMsg += "Service: \(servicePeripheral.UUID)\n"
                peripheral.discoverCharacteristics(nil, forService: servicePeripheral)
            }
            
            txtMsg.text = strMsg
        }
        */

    }
    
    /*
    func peripheral(peripheral: CBPeripheral, didDiscoverDescriptorsForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
    }
    */

    /**
    * 查詢指定 Service channel 的 charccter code
    */
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {

        let mChart: CBCharacteristic = service.characteristics![0]
        //connectingPeripheral.discoverDescriptorsForCharacteristic(mChart)
        
        // 藍牙 BLE 必填標準參數，關閉或打開通知(Notify)的UUID, 藍牙規格固定值
        
        
        
        peripheral.setNotifyValue(true, forCharacteristic: mChart)
        print("Characteristic: \(mChart)")
        peripheral.readValueForCharacteristic(mChart)
        
        /*
        let charactericsArr: [CBCharacteristic] = service.characteristics!

        if (charactericsArr.count > 0) {
            var strMsg: String = "";
            
            for charactericsx in charactericsArr{
                peripheral.setNotifyValue(true, forCharacteristic: charactericsx)
                print("Characteristic: \(charactericsx)")
                strMsg += "Characteristic: \(charactericsx)\n"
                
                peripheral.readValueForCharacteristic(charactericsx)
            }
            
            txtMsg.text = strMsg
        }
        */
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if var data :NSData = characteristic.value {
            
            txtMsg.text! += "Data: \(characteristic.value)\n Notifying: \(characteristic.isNotifying)\n"
            print("Data: \(characteristic.value)\n Notifying: \(characteristic.isNotifying)")
        }
        
    }
    
    @IBAction func actConn(sender: UIButton) {
        startUpCentralManager()
    }
    
    @IBAction func actDisconn(sender: UIButton) {
        print("BT disconnect...")
    }
    
    @IBAction func actBtnA(sender: UIButton) {
    }
    
    @IBAction func actBtnB(sender: UIButton) {
    }
    
    @IBAction func actBtnC(sender: UIButton) {
        let data: NSData = "01:00".dataUsingEncoding(NSUTF8StringEncoding)!
        connectingPeripheral.writeValue(data, forCharacteristic: charactericsx, type: CBCharacteristicWriteType.WithResponse)
        //output("Characteristic", data: charactericsx)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

