//
//  FirebaseStoreManager.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 16/11/24.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

struct FirebaseStoreManager {
    static let db = Firestore.firestore()
    static let auth = Auth.auth()
    static let messaging = Messaging.messaging()
    
}
