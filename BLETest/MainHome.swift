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
    
    var activeTimer:NSTimer!
    
    var centralManager:CBCentralManager!
    var blueToothReady = false
    var connectingPeripheral: CBPeripheral!
    
    var actBTService: CBService!
    var actBTCharact: CBCharacteristic!
    
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
        
        // 找到指定裝置 名稱 or addr
        if (peripheral.name == D_BTDEVNAME) {
            self.connectingPeripheral = peripheral
            self.centralManager.stopScan()
            self.centralManager.connectPeripheral(peripheral, options: nil)
        }
        
        //NSTimer(timeInterval: 2.0, target: self, selector: selector(scanTimeout:), userInfo: nil, repeats: false)
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

    /**
    * 目前 BLE center manage statu
    */
    func centralManagerDidUpdateState(central: CBCentralManager) {
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
        self.actBTService = peripheral.services![0]
        
        // Discover 指定的 charact 執行測試連接
        txtMsg.text! += "Service: \(self.actBTService.UUID)\n"
        print("Service: \(self.actBTService.UUID)")
        peripheral.discoverCharacteristics([UID_CHAR], forService: self.actBTService)
    }

    /**
    * 查詢指定 Service channel 的 charccter code
    */
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        self.actBTCharact = service.characteristics![0]
        print("Characteristic: \(self.actBTCharact)")
        
        // 直接執行關閉或打開通知(Notify)的UUID, 藍牙規格固定值
        peripheral.setNotifyValue(true, forCharacteristic: self.actBTCharact)
        
        //peripheral.readValueForCharacteristic(self.actBTCharact)
        
        //peripheral.discoverDescriptorsForCharacteristic(self.actBTCharact)
        
        print("SetNotify: \(self.actBTCharact)")
    }
    
    /**
    * NotificationStateForCharacteristic 更新
    */
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        print("didUpdata Notify: \(characteristic)")
        
        connectingPeripheral.writeValue( NSData(bytes: [0x01] as [UInt8], length: 1), forCharacteristic: self.actBTCharact, type: CBCharacteristicWriteType.WithResponse)
    }
    
    /**
    * Discover characteristics 的 DiscoverDescriptors
    * 主要執行 BT 的 關閉或打開通知(Notify)
    */
    func peripheral(peripheral: CBPeripheral, didDiscoverDescriptorsForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        print("Descriptor: \(characteristic.descriptors)")
        
        let mDisp: CBDescriptor = characteristic.descriptors![0]
        mDisp.setValue(1, forKey: "value")
        mDisp.setValue(UID_NOTIFY, forKey: "UUID")
    
        print("disp0: \(mDisp)")
        
        //let mNSData = NSData()
        let mNSData = NSData(bytes: [0x01] as [UInt8], length: 1)
        peripheral.writeValue(mNSData, forDescriptor: mDisp)
       
        peripheral.readValueForCharacteristic(self.actBTCharact)
        
        /*
        var parameter = NSInteger(1)
        let mNSData = NSData(bytes: &parameter, length: 1)
        peripheral.writeValue(mNSData, forDescriptor: mDisp)
        */
    }
    
    /**
    * BT 有資料更新，傳送到本機 BT 顯示
    */
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if (characteristic.value?.length > 0) {
            //print("from BT value: \(characteristic.value!)")

            // 將回傳資料轉為 [Byte] = [UInt8]
            let data = characteristic.value!
            var values = [UInt8](count:data.length, repeatedValue:0)
            data.getBytes(&values, length:data.length)
            
            print(values)
        }
        
    }
    
    @IBAction func actConn(sender: UIButton) {
        startUpCentralManager()
    }
    
    @IBAction func actDisconn(sender: UIButton) {
        if activeTimer != nil {
            activeTimer.invalidate()
            activeTimer = nil
        }
        
        centralManager.cancelPeripheralConnection(connectingPeripheral)
        connectingPeripheral = nil
        actBTCharact = nil
        actBTService = nil
        
        print("BT disconnect...")
    }
    
    @IBAction func actBtnA(sender: UIButton) {
        let mNSData = NSData(bytes: [UInt8]("A".utf8), length: 1)
        connectingPeripheral.writeValue(mNSData, forCharacteristic: self.actBTCharact, type: CBCharacteristicWriteType.WithoutResponse)
    }
    
    @IBAction func actBtnB(sender: UIButton) {
        let mNSData = NSData(bytes: [UInt8]("B".utf8), length: 1)
        connectingPeripheral.writeValue(mNSData, forCharacteristic: self.actBTCharact, type: CBCharacteristicWriteType.WithoutResponse)
    }
    
    @IBAction func actBtnC(sender: UIButton) {
        let mNSData = NSData(bytes: [UInt8]("C".utf8), length: 1)
        connectingPeripheral.writeValue(mNSData, forCharacteristic: self.actBTCharact, type: CBCharacteristicWriteType.WithoutResponse)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

