//
//  MainVC+Delegates.swift
//  NearbyWithAccessory
//
//  Created by Jay Muthialu on 1/16/23.
//

import UIKit
import NearbyInteraction

extension MainVC: NISessionDelegate {
    
    // This is called after accessory configuration data is received
    // and NISession.run() is called. NISession generates shareable
    // configuration data and calls this delegate method where it is
    // sent to accessory
    func session(_ session: NISession, didGenerateShareableConfigurationData shareableConfigurationData: Data, for object: NINearbyObject) {

        print("didGenerateShareableConfigurationData")
        guard object.discoveryToken == configuration?.accessoryDiscoveryToken else { return }
        
        // Prepare to send a message to the accessory.
        var msg = Data([MessageId.configureAndStart.rawValue])
        msg.append(shareableConfigurationData)
        
        let str = msg.map { String(format: "0x%02x, ", $0) }.joined()
        print("Sending shareable configuration bytes: \(str)")
        
        send(data: msg)
        distanceLabel.isHidden = false
        azimuthImageView.isHidden = false
    }
    
    // Retry if accessory connection is lost
    func session(_ session: NISession, didRemove nearbyObjects: [NINearbyObject], reason: NINearbyObject.RemovalReason) {
        guard let accessory = nearbyObjects.first, reason == .timeout else { return }
        
        accessoryMap.removeValue(forKey: accessory.discoveryToken)
        send(data: Data([MessageId.stop.rawValue]))
        send(data: Data([MessageId.initialize.rawValue]))
    }
    
    // Called after Apple Shareable config is sent via `dataChannel.sendData(data)`
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        guard let nearbyObject = nearbyObjects.first,
              let distance = nearbyObject.distance,
              let name = accessoryMap[nearbyObject.discoveryToken] else {
            return
        }
        
        let distanceInFeet = distance * 3.2
        let distanceString = String(format: "'%@' is %0.1f ft away", name, distanceInFeet)
        print(distanceString)
        updateDistanceLabel(to: distanceInFeet)
        
        if distanceInFeet < distanceThreshold {
            lockImageView.image = UIImage(systemName: "lock.open")
        } else {
            lockImageView.image = UIImage(systemName: "lock")
        }
        
        guard let direction = nearbyObject.direction else {
            azimuthImageView.transform = .identity
            return
        }
        let azimuth = asin(direction.x)
        let elevation = atan2(direction.z, direction.y) + .pi / 2
        print("azimuth: \(azimuth) - elevation: \(elevation)")
        azimuthImageView.transform = CGAffineTransform(rotationAngle: CGFloat(azimuth ))
    }
}
