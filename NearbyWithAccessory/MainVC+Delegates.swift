//
//  MainVC+Delegates.swift
//  NearbyWithAccessory
//
//  Created by Jay Muthialu on 1/16/23.
//

import Foundation
import NearbyInteraction

extension MainVC: NISessionDelegate {
    
    // This is called after accessory configuration data is received
    // and NISession.run() is called
    func session(_ session: NISession, didGenerateShareableConfigurationData shareableConfigurationData: Data, for object: NINearbyObject) {

        print("didGenerateShareableConfigurationData")
        guard object.discoveryToken == configuration?.accessoryDiscoveryToken else { return }
        
        // Prepare to send a message to the accessory.
        var msg = Data([MessageId.configureAndStart.rawValue])
        msg.append(shareableConfigurationData)
        
        let str = msg.map { String(format: "0x%02x, ", $0) }.joined()
        print("Sending shareable configuration bytes: \(str)")
        
        let accessoryName = accessoryMap[object.discoveryToken] ?? "Unknown"
        send(data: msg)
    }
    
    // Called after Apple Shareable config is sent via `dataChannel.sendData(data)`
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        guard let accessory = nearbyObjects.first else { return }
        guard let distance = accessory.distance else { return }
        guard let name = accessoryMap[accessory.discoveryToken] else { return }
        
        let distanceString = String(format: "'%@' is %0.1f meters away", name, distance)
        print(distanceString)
    }
}
