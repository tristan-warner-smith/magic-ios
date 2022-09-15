//
//  File.swift
//
//
//  Created by Jerry Liu on 9/6/22.
//

import Foundation
import MagicSDK_Web3

public class ConnectModule: BaseModule {

    /**
     showWallet
     */
    public func showWallet(response: @escaping Web3ResponseCompletion<String>) {

        let request = BasicRPCRequest(method: ConnectMethod.mc_wallet.rawValue, params: [])

        return self.provider.send(request: request, response: response)
    }

    /**
     requestUserInfo
     */
    public func requestUserInfo(response: @escaping Web3ResponseCompletion<String>) {

        let request = BasicRPCRequest(method: ConnectMethod.mc_request_user_info.rawValue, params: [])

        return self.provider.send(request: request, response: response)
    }

    /**
     disconnect
     */
    public func disconnect(response: @escaping Web3ResponseCompletion<String>) {

        let request = BasicRPCRequest(method: ConnectMethod.mc_disconnect.rawValue, params: [])

        return self.provider.send(request: request, response: response)
    }
}