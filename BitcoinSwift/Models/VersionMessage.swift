//
//  VersionMessage.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 7/3/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(lhs: VersionMessage, rhs: VersionMessage) -> Bool {
  return lhs.protocolVersion == rhs.protocolVersion &&
      lhs.services == rhs.services &&
      lhs.date == rhs.date &&
      lhs.senderAddress == rhs.senderAddress &&
      lhs.receiverAddress == rhs.receiverAddress &&
      lhs.nonce == rhs.nonce &&
      lhs.userAgent == rhs.userAgent &&
      lhs.blockStartHeight == rhs.blockStartHeight &&
      lhs.announceRelayedTransactions == rhs.announceRelayedTransactions
}

/// Message payload object corresponding to the Message.Command.Version command. When a node creates
/// an outgoing connection, it will immediately advertise its version with this message and the
/// remote node will respond with its version. No further communication is possible until both peers
/// have exchanged their version.
/// https://en.bitcoin.it/wiki/Protocol_specification#version
public struct VersionMessage: Equatable {

  public let protocolVersion: UInt32
  public let services: PeerServices
  public let date: NSDate
  public let senderAddress: PeerAddress
  public let receiverAddress: PeerAddress
  public let nonce: UInt64
  public let userAgent: String
  public let blockStartHeight: Int32
  public let announceRelayedTransactions: Bool

  public init(protocolVersion: UInt32,
              services: PeerServices,
              date: NSDate,
              senderAddress: PeerAddress,
              receiverAddress: PeerAddress,
              nonce: UInt64,
              userAgent: String,
              blockStartHeight: Int32,
              announceRelayedTransactions: Bool) {
    self.protocolVersion = protocolVersion
    self.services = services
    self.date = date
    self.senderAddress = senderAddress
    self.receiverAddress = receiverAddress
    self.nonce = nonce
    self.userAgent = userAgent
    self.blockStartHeight = blockStartHeight
    self.announceRelayedTransactions = announceRelayedTransactions
  }
}

extension VersionMessage: MessagePayload {

  public var command: Message.Command {
    return Message.Command.Version
  }

  public var data: NSData {
    var data = NSMutableData()
    data.appendUInt32(protocolVersion)
    data.appendUInt64(services.rawValue)
    data.appendInt64(Int64(date.timeIntervalSince1970))
    data.appendPeerAddress(receiverAddress, includeTimestamp: false)
    data.appendPeerAddress(senderAddress, includeTimestamp: false)
    data.appendUInt64(nonce)
    data.appendVarString(userAgent)
    data.appendInt32(blockStartHeight)
    data.appendBool(announceRelayedTransactions)
    return data
  }

  public static func fromData(data: NSData) -> VersionMessage? {
    if data.length == 0 {
      return nil
    }
    let stream = NSInputStream(data: data)
    stream.open()
    let protocolVersion = stream.readUInt32()
    if protocolVersion == nil {
      Logger.warn("Failed to parse protocolVersion from VersionMessage \(data)")
      return nil
    }
    let servicesRaw = stream.readUInt64()
    if servicesRaw == nil {
      Logger.warn("Failed to parse servicesRaw from VersionMessage \(data)")
      return nil
    }
    let services = PeerServices(rawValue: servicesRaw!)
    let timestamp = stream.readInt64()
    if timestamp == nil {
      Logger.warn("Failed to parse timestamp from VersionMessage \(data)")
      return nil
    }
    let date = NSDate(timeIntervalSince1970: NSTimeInterval(timestamp!))
    let receiverAddress = stream.readPeerAddress(includeTimestamp: false)
    if receiverAddress == nil {
      Logger.warn("Failed to parse receiverAddress from VersionMessage \(data)")
      return nil
    }
    let senderAddress = stream.readPeerAddress(includeTimestamp: false)
    if senderAddress == nil {
      Logger.warn("Failed to parse senderAddress from VersionMessage \(data)")
      return nil
    }
    let nonce = stream.readUInt64()
    if nonce == nil {
      Logger.warn("Failed to parse nonce from VersionMessage \(data)")
      return nil
    }
    let userAgent = stream.readVarString()
    if userAgent == nil {
      Logger.warn("Failed to parse userAgent from VersionMessage \(data)")
      return nil
    }
    let blockStartHeight = stream.readInt32()
    if blockStartHeight == nil {
      Logger.warn("Failed to parse blockStartHeight from VersionMessage \(data)")
      return nil
    }
    let announceRelayedTransactions = stream.readBool()
    if announceRelayedTransactions == nil {
      Logger.warn("Failed to parse announceRelayedTransactions from VersionMessage \(data)")
      return nil
    }
    return VersionMessage(protocolVersion: protocolVersion!,
                          services: services,
                          date: date,
                          senderAddress: senderAddress!,
                          receiverAddress: receiverAddress!,
                          nonce: nonce!,
                          userAgent: userAgent!,
                          blockStartHeight: blockStartHeight!,
                          announceRelayedTransactions: announceRelayedTransactions!)
  }
}
