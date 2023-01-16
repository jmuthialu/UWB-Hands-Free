//
//  MainVC.swift
//  NearbyWithAccessory
//
//  Created by Jay Muthialu on 1/16/23.
//

import UIKit
import Combine

class MainVC: UIViewController {

    var bleDataLink = BLEDataLink()
    var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindPublishers()
    }
    
    func bindPublishers() {
        bleDataLink.accessoryReadyPublisher.sink { _ in
            print("accessoryReadyPublisher")
        }.store(in: &cancellables)
        
        bleDataLink.dataReceivedPublisher.sink { data in
            print("dataReceivedPublisher")
        }.store(in: &cancellables)
    }

}

