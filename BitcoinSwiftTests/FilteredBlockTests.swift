//
//  FilteredBlockTests.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 10/26/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import BitcoinSwift
import XCTest

class FilteredBlockTests: XCTestCase {

  let filteredBlockBytes: [UInt8] = [
      0x01, 0x00, 0x00, 0x00,                           // version: 1
      0x79, 0xcd, 0xa8, 0x56, 0xb1, 0x43, 0xd9, 0xdb,
      0x2c, 0x1c, 0xaf, 0xf0, 0x1d, 0x1a, 0xec, 0xc8,
      0x63, 0x0d, 0x30, 0x62, 0x5d, 0x10, 0xe8, 0xb4,
      0xb8, 0xb0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,   // previous block hash
      0xb5, 0x0c, 0xc0, 0x69, 0xd6, 0xa3, 0xe3, 0x3e,
      0x3f, 0xf8, 0x4a, 0x5c, 0x41, 0xd9, 0xd3, 0xfe,
      0xbe, 0x7c, 0x77, 0x0f, 0xdc, 0xc9, 0x6b, 0x2c,
      0x3f, 0xf6, 0x0a, 0xbe, 0x18, 0x4f, 0x19, 0x63,   // merkle root
      0x67, 0x29, 0x1b, 0x4d,                           // timestamp
      0x4c, 0x86, 0x04, 0x1b,                           // difficulty bits
      0x8f, 0xa4, 0x5d, 0x63,                           // nonce
      0x01, 0x00, 0x00, 0x00,                           // num transactions in full block: 1
      0x01,                                             // num hashes
      0xb5, 0x0c, 0xc0, 0x69, 0xd6, 0xa3, 0xe3, 0x3e,
      0x3f, 0xf8, 0x4a, 0x5c, 0x41, 0xd9, 0xd3, 0xfe,
      0xbe, 0x7c, 0x77, 0x0f, 0xdc, 0xc9, 0x6b, 0x2c,
      0x3f, 0xf6, 0x0a, 0xbe, 0x18, 0x4f, 0x19, 0x63,   // tx hash
      0x01,                                             // num flag bytes: 1
      0x01]                                             // flag bytes

  var filteredBlockData: NSData!
  var filteredBlock: FilteredBlock!

  override func setUp() {
    filteredBlockData = NSData(bytes: filteredBlockBytes, length: filteredBlockBytes.count)
    let previousBlockHashBytes: [UInt8] = [
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb0, 0xb8,
        0xb4, 0xe8, 0x10, 0x5d, 0x62, 0x30, 0x0d, 0x63,
        0xc8, 0xec, 0x1a, 0x1d, 0xf0, 0xaf, 0x1c, 0x2c,
        0xdb, 0xd9, 0x43, 0xb1, 0x56, 0xa8, 0xcd, 0x79]
    let previousBlockHash = SHA256Hash(bytes: previousBlockHashBytes)
    let merkleRootBytes: [UInt8] = [
        0x63, 0x19, 0x4f, 0x18, 0xbe, 0x0a, 0xf6, 0x3f,
        0x2c, 0x6b, 0xc9, 0xdc, 0x0f, 0x77, 0x7c, 0xbe,
        0xfe, 0xd3, 0xd9, 0x41, 0x5c, 0x4a, 0xf8, 0x3f,
        0x3e, 0xe3, 0xa3, 0xd6, 0x69, 0xc0, 0x0c, 0xb5]
    let merkleRoot = SHA256Hash(bytes: merkleRootBytes)
    let timestamp = NSDate(timeIntervalSince1970: NSTimeInterval(1293625703))
    let header = BlockHeader(version: 1,
                             previousBlockHash: previousBlockHash,
                             merkleRoot: merkleRoot,
                             timestamp: timestamp,
                             compactDifficulty: 0x1b04864c,
                             nonce: 0x635da48f)
    let transactionHashBytes: [UInt8] = [
        0x63, 0x19, 0x4f, 0x18, 0xbe, 0x0a, 0xf6, 0x3f,
        0x2c, 0x6b, 0xc9, 0xdc, 0x0f, 0x77, 0x7c, 0xbe,
        0xfe, 0xd3, 0xd9, 0x41, 0x5c, 0x4a, 0xf8, 0x3f,
        0x3e, 0xe3, 0xa3, 0xd6, 0x69, 0xc0, 0x0c, 0xb5]
    let transactionHash = SHA256Hash(bytes: transactionHashBytes)
    filteredBlock = FilteredBlock(header: header,
                                  totalNumTransactions: 1,
                                  hashes: [transactionHash],
                                  flags: [0x01])

  }

  func testFilteredBlockEncoding() {
    XCTAssertEqual(filteredBlock.bitcoinData, filteredBlockData)
  }

  func testFilteredBlockDecoding() {
    let stream = NSInputStream(data: filteredBlockData)
    stream.open()
    if let testFilteredBlock = FilteredBlock.fromBitcoinStream(stream) {
      XCTAssertEqual(testFilteredBlock, filteredBlock)
    } else {
      XCTFail("Failed to parse FilteredBlock")
    }
    XCTAssertFalse(stream.hasBytesAvailable)
    stream.close()
  }
}
