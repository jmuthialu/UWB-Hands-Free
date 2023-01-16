//
//  BLEDataLink.swift
//  NearbyWithAccessory
//
//  Created by Jay Muthialu on 1/16/23.
//

import Foundation
import CoreBluetooth
import Combine

struct Constants {
    static let whiteUWBIdentifier = "B730C7A4-FD26-4ACF-5F9A-78C952F2C7CC" // White UWB
    static let serviceUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    static let rxCharacteristicUUID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    static let txCharacteristicUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
}

class BLEDataLink: NSObject {
    
    var centralManager: CBCentralManager?
    var peripheral: CBPeripheral?
    var peripheralName = ""
    
    var rxCharacteristic: CBCharacteristic? // Peripheral receives from central
    var txCharacteristic: CBCharacteristic? // Peripheral transmits to central
    
    var accessoryReadyPublisher = PassthroughSubject<Void, Never>()
    var dataReceivedPublisher = PassthroughSubject<Data, Never>()
    
    override init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self,
                                          queue: nil,
                                          options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
}
