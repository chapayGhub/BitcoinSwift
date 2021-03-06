//
//  AddressMessageTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 8/14/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class AddressMessageTests: XCTestCase {

  func testAddressMessageDecoding() {
    let bytes: [UInt8] = [
        0x02,                                             // Number of addresses
        // First PeerAddress
        0x11, 0xb2, 0xd0, 0x50,                           // Tue Dec 18 10:12:33 PST 2012
        0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,   // 1 (NODE_NETWORK services)
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0xff, 0xff, 0x0a, 0x00, 0x00, 0x01,   // IP of 10.0.0.1
        0x20, 0x8d,                                       // Port 8333
        // Second PeerAddress
        0x11, 0xb2, 0xd0, 0x50,                           // Tue Dec 18 10:12:33 PST 2012
        0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,   // 1 (NODE_NETWORK services)
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0xff, 0xff, 0x0a, 0x00, 0x00, 0x02,   // IP of 10.0.0.2
        0x20, 0x8d]                                       // Port 8333
    let data = NSData(bytes: bytes, length: bytes.count)
    let stream = NSInputStream(data: data)
    stream.open()
    let addressMessage = AddressMessage.fromBitcoinStream(stream)
    if addressMessage != nil {
      XCTAssertEqual(addressMessage!.peerAddresses.count, 2)
      let expectedPeerAddresses = [
          PeerAddress(services: PeerServices.NodeNetwork,
                      IP: IPAddress.IPV4(0x0a000001),
                      port: 8333,
                      timestamp: NSDate(timeIntervalSince1970: 1355854353)),
          PeerAddress(services: PeerServices.NodeNetwork,
                      IP: IPAddress.IPV4(0x0a000002),
                      port: 8333,
                      timestamp: NSDate(timeIntervalSince1970: 1355854353))]
      XCTAssertEqual(addressMessage!.peerAddresses[0], expectedPeerAddresses[0])
      XCTAssertEqual(addressMessage!.peerAddresses[1], expectedPeerAddresses[1])
    } else {
      XCTFail("Failed to parse AddressMessage")
    }
    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }

  func testAddressMessageEncoding() {
    let peerAddresses = [
        PeerAddress(services: PeerServices.NodeNetwork,
                    IP: IPAddress.IPV4(0x0a000001),
                    port: 8333,
                    timestamp: NSDate(timeIntervalSince1970: 1355854353)),
        PeerAddress(services: PeerServices.NodeNetwork,
                    IP: IPAddress.IPV4(0x0a000002),
                    port: 8333,
                    timestamp: NSDate(timeIntervalSince1970: 1355854353))]
    let addressMessage = AddressMessage(peerAddresses: peerAddresses)
    let expectedBytes: [UInt8] = [
        0x02,                                             // Number of addresses
        // First PeerAddress
        0x11, 0xb2, 0xd0, 0x50,                           // Tue Dec 18 10:12:33 PST 2012
        0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,   // 1 (NODE_NETWORK services)
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0xff, 0xff, 0x0a, 0x00, 0x00, 0x01,   // IP of 10.0.0.1
        0x20, 0x8d,                                       // Port 8333
        // Second PeerAddress
        0x11, 0xb2, 0xd0, 0x50,                           // Tue Dec 18 10:12:33 PST 2012
        0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,   // 1 (NODE_NETWORK services)
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0xff, 0xff, 0x0a, 0x00, 0x00, 0x02,   // IP of 10.0.0.2
        0x20, 0x8d]                                       // Port 8333
    let expectedData = NSData(bytes: expectedBytes, length: expectedBytes.count)
    XCTAssertEqual(addressMessage.bitcoinData, expectedData)
  }
}
