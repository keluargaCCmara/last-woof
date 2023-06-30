//
//  iCloudAuthentication.swift
//  Last Woof
//
//  Created by Angela Christabel on 23/06/23.
//

import Foundation
import CloudKit
import SwiftUI

class iCloudAuthController: ObservableObject {
    private var container: CKContainer = CKContainer(identifier: "iCloud.Angela.Last-Woof")
    @Published var permissionStatus: Bool = false
    @Published var isSignedInToiCloud: Bool = false
    @Published var error: String = ""
    @Published var userName: String = ""
    @Published var iCloud: CKRecord.ID = CKRecord.ID(recordName: "Placeholder")
    @Published var isLoading: Bool = true
    
    init() {
        getiCloudStatus()
        requestPermission()
        fetchiCloudUserRecord()
    }
    
    private func getiCloudStatus() {
        container.accountStatus{ [weak self] returnedStatus, returnedError in
            DispatchQueue.main.async {
                switch returnedStatus {
                case .available:
                    self?.isSignedInToiCloud = true
                case .noAccount:
                    self?.error = CloudKitError.iCloudAccountNotFound.rawValue
                case .couldNotDetermine:
                    self?.error = CloudKitError.iCloudAccountNotDetermined.rawValue
                case .restricted:
                    self?.error = CloudKitError.iCloudAccountRestricted.rawValue
                default:
                    self?.error = CloudKitError.iCloudAccountUnknown.rawValue
                }
            }
        }
    }
    
    enum CloudKitError: String, LocalizedError {
        case iCloudAccountNotFound
        case iCloudAccountNotDetermined
        case iCloudAccountRestricted
        case iCloudAccountUnknown
    }
    
    func requestPermission() {
        container.requestApplicationPermission([.userDiscoverability]) { [weak self] returnedStatus, returnedError in
            DispatchQueue.main.async {
                if returnedStatus == .granted {
                    self?.permissionStatus = true
                }
            }
        }
    }
    
    func fetchiCloudUserRecord() {
        container.fetchUserRecordID { [weak self] returnedID, returnedError in
            if let id = returnedID {
                self?.discoveriCloudUser(id: id)
                self?.iCloud = id
                self?.isLoading = false
            }
        }
    }
    
    func discoveriCloudUser(id: CKRecord.ID){
        container.discoverUserIdentity(withUserRecordID: id) { [weak self] returnedIdentity, returnedError in
            DispatchQueue.main.async {
                if let name = returnedIdentity?.nameComponents?.givenName {
                    self?.userName = name
                }
            }
        }
    }
}
