//
//  BLEDataLink+Delegates.swift
//  NearbyWithAccessory
//
//  Created by Jay Muthialu on 1/16/23.
//

import Foundation
import CoreBluetooth

extension BLEDataLink: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {

        switch central.state {
        case .poweredOn:
            print("Central Manager is powered on")
            scanForPeripherals()
        case .poweredOff:
            print("Central Manager not powered on")
            return
        default:
            print("Unknown Central Manager state")
            return
        }
    }
    
    func scanForPeripherals() {
        // UWB service UUIS is not in Estimote advertisement packet so passing service UUID
        // will not scan any peripheral
        centralManager?.scanForPeripherals(withServices: nil,
                                          options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        
        if peripheral.identifier.uuidString ==  Constants.whiteUWBIdentifier {
            self.peripheral = peripheral
            
            let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String
            peripheralName = name ?? "NoName"
            
            print("Connecting to peripheral")
            centralManager?.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        centralManager?.stopScan()
        peripheral.delegate = self
        peripheral.discoverServices([Constants.serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            print("Failed to connect to \(peripheral). Error: \(error)")
        }
    }
}

extension BLEDataLink: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        
        guard let peripheralServices = peripheral.services,
                peripheralServices.count > 0 else { return }
        
        print("Did discovered service")
        for service in peripheralServices {
            let characteristics = [Constants.rxCharacteristicUUID,
                                   Constants.txCharacteristicUUID]
            peripheral.discoverCharacteristics(characteristics, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }

        guard let serviceCharacteristics = service.characteristics,
              serviceCharacteristics.count > 0 else { return }
                
        print("Did discover characteristics")
        for characteristic in serviceCharacteristics where characteristic.uuid == Constants.rxCharacteristicUUID {
            rxCharacteristic = characteristic
        }

        for characteristic in serviceCharacteristics where characteristic.uuid == Constants.txCharacteristicUUID {
            txCharacteristic = characteristic
            peripheral.setNotifyValue(true, for: characteristic)
        }
    
        accessoryReadyPublisher.send()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let error = error {
            print("Error discovering characteristics:\(error.localizedDescription)")
            return
        }
        guard let characteristicData = characteristic.value else { return }
    
        let receivedBytes = characteristicData.map { String(format: "0x%02x, ", $0) }.joined()
        print("Received data from accessory: \(receivedBytes)")
        
        dataReceivedPublisher.send(characteristicData)
    }
    
}
