#  UWB based nearby using Estimote UWB beacons (White)


## How does this work?

### 1 - Establish BLE data link
- Scan for peripherals
- You should get UDID of white estimote beacon. This is advertised by the beacon
- Connect to this peripheral
- Discover services
- Discover characteristics
- Set notification for Rx Characterisrics
- Send accessoryReadyPublisher publisher

### 2 - Establish connection with UWB
- Subscriber to accessoryReadyPublisher will send `initialize` command to accessory
- Accessory sends configuration data and sends `accessoryConfigurationData` command
- Device (iPhone) receives config data and creates NISession
- Runs NISession with accessoryConfigurationData and this generates shared config data
- Send shared config data in delegate method `didGenerateShareableConfigurationData`
- On receipt of shared config data, accessory will update its configuration
- Accessory starts sending distance information to device. 
- Device gets the distance through delegete method `didUpdate nearbyObjects`






