//
//  FilterAddMessage.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 10/18/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(lhs: FilterAddMessage, rhs: FilterAddMessage) -> Bool {
  return lhs.filterData = rhs.filterData
}

/// The given data element will be added to the bloom filter. A filter must have previously been
/// provided using filterload. This command is useful if a new key or script is added to a client's
/// wallet whilst it has a connection to the network open. It avoids the need to re-calculate and
/// send an entirely new filter to every peer (though doing so is usually advisable to maintain
/// anonymity).
/// https://en.bitcoin.it/wiki/Protocol_specification#filterload.2C_filteradd.2C_filterclear.2C_merkleblock
public struct FilterAddMessage: Equatable {

  /// The maximum size of any potentially matched object.
  public static let MaxFilterDataLength = 520

  public let filterData: NSData

  public init(filterData: NSData) {
    precondition(filterData.length <= MaxFilterDataLength)
    self.filterData = filterData
  }
}

extension FilterAddMessage: MessagePayload {

  public var command: Message.Command {
    return Message.Command.FilterAdd
  }

  public var data: NSData {
    var data = NSMutableData()
    data.appendVarInt(filterData.length)
    data.appendData(filterData)
    return data
  }

  public static func fromData(data: NSData) -> FilterAddMessage? {
    if data.length == 0 {
      return nil
    }
    let stream = NSInputStream(data: data)
    stream.open()
    let filterDataLength = stream.readVarInt()
    if filterDataLength == nil {
      Logger.warn("Failed to parse filterDataLength from FilterAddMessage \(data)")
      return nil
    }
    if filterDataLength! <= 0 || filterDataLength! > MaxFilterDataLength {
      Logger.warn("Invalid filterDataLength \(filterDataLength!) in FilterAddMessage \(data)")
      return nil
    }
    let filterData = stream.readData(length: filterDataLength!)
    if filterData == nil {
      Logger.warn("Failed to parse filterData from FilterAddMessage \(data)")
      return nil
    }
    return FilterAddMessage(filterData: filterData!)
  }
}