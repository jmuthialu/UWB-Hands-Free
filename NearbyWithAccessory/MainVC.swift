//
//  MainVC.swift
//  NearbyWithAccessory
//
//  Created by Jay Muthialu on 1/16/23.
//

import UIKit
import Combine
import NearbyInteraction

enum MessageId: UInt8 {
    
    // Messages from the accessory.
    case accessoryConfigurationData = 0x1
    case accessoryUwbDidStart = 0x2
    case accessoryUwbDidStop = 0x3
    
    // Messages to the accessory.
    case initialize = 0xA
    case configureAndStart = 0xB
    case stop = 0xC
}

class MainVC: UIViewController {

    var bleDataLink = BLEDataLink()
    var cancellables = Set<AnyCancellable>()
    
    var niSession = NISession()
    var configuration: NINearbyAccessoryConfiguration?
    
    // A mapping from a discovery token to a name.
    var accessoryMap = [NIDiscoveryToken: String]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        niSession.delegate = self
        bindPublishers()
    }
    
    func bindPublishers() {
        bleDataLink.accessoryReadyPublisher.sink { [weak self] _ in
            print("accessoryReadyPublisher")
            
            let initializingData = Data([MessageId.initialize.rawValue])
            self?.send(data: initializingData)

        }.store(in: &cancellables)
        
        bleDataLink.dataReceivedPublisher.sink { [weak self] data in
            print("dataReceivedPublisher")
            self?.handleAccessory(data: data)
        }.store(in: &cancellables)
    }
    
    func send(data: Data) {
        bleDataLink.writeData(data: data)
    }
    
    func handleAccessory(data: Data) {
        if data.count < 1 {
            print("Accessory shared data length was less than 1.")
            return
        }
        
        // Assign the first byte which is the message identifier.
        guard let messageId = MessageId(rawValue: data.first!) else {
            fatalError("\(data.first!) is not a valid MessageId.")
        }
        
        switch messageId {
        case .accessoryConfigurationData:
            print("accessoryConfigurationData processing...")
            let message = data.advanced(by: 1)
            setupAccessory(message, name: bleDataLink.peripheralName)
        case .accessoryUwbDidStart:
            print("accessoryUwbDidStart")
//            handleAccessoryUwbDidStart()
        case .accessoryUwbDidStop:
            print("accessoryUwbDidStop")
//            handleAccessoryUwbDidStop()
        case .configureAndStart:
            fatalError("Accessory should not send 'configureAndStart'.")
        case .initialize:
            fatalError("Accessory should not send 'initialize'.")
        case .stop:
            fatalError("Accessory should not send 'stop'.")
        }
    }
    
    func setupAccessory(_ configData: Data, name: String) {
        
        do {
            configuration = try NINearbyAccessoryConfiguration(data: configData)
        } catch {
            print("Failed to create NINearbyAccessoryConfiguration for '\(name)'. Error: \(error)")
            return
        }
        
        guard let configuration = configuration else { return }
        print("accessoryDiscoveryToken: \(configuration.accessoryDiscoveryToken)")
        cacheToken(configuration.accessoryDiscoveryToken, accessoryName: name)
        niSession.run(configuration) // triggers didGenerateShareableConfigurationData
        print("niSession.run called")
    }
    
    func cacheToken(_ token: NIDiscoveryToken, accessoryName: String) {
        accessoryMap[token] = accessoryName
    }
    

}

