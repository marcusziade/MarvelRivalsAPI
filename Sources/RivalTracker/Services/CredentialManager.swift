import Foundation

/// Manages secure storage of API credentials.
final class CredentialManager {
    /// Service name for credential storage.
    private let serviceName = "com.rivaltracker.credentials"
    
    /// Account name for API key storage.
    private let apiKeyAccount = "marvelrivalsapi"
    
    /// Initialize the credential manager.
    init() {}
    
    /// Store the API key securely.
    /// - Parameter apiKey: The API key to store.
    func storeAPIKey(_ apiKey: String) {
        #if os(macOS)
        // Use the keychain on macOS
        storeInKeychain(apiKey: apiKey)
        #else
        // Use encrypted file storage on other platforms
        storeInEncryptedFile(apiKey: apiKey)
        #endif
    }
    
    /// Retrieve the stored API key.
    /// - Returns: The stored API key, or nil if not found.
    func retrieveAPIKey() -> String? {
        #if os(macOS)
        // Use the keychain on macOS
        return retrieveFromKeychain()
        #else
        // Use encrypted file storage on other platforms
        return retrieveFromEncryptedFile()
        #endif
    }
    
    /// Clear the stored API key.
    func clearAPIKey() {
        #if os(macOS)
        // Delete from the keychain on macOS
        deleteFromKeychain()
        #else
        // Delete the encrypted file on other platforms
        deleteEncryptedFile()
        #endif
    }
    
    // MARK: - Keychain Storage (macOS)
    
    #if os(macOS)
    /// Store the API key in the keychain.
    /// - Parameter apiKey: The API key to store.
    private func storeInKeychain(apiKey: String) {
        guard let data = apiKey.data(using: .utf8) else {
            return
        }
        
        // Delete existing item first
        deleteFromKeychain()
        
        // Create the keychain query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: apiKeyAccount,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        // Add the item to the keychain
        SecItemAdd(query as CFDictionary, nil)
    }
    
    /// Retrieve the API key from the keychain.
    /// - Returns: The API key, or nil if not found.
    private func retrieveFromKeychain() -> String? {
        // Create the keychain query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: apiKeyAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess,
              let data = item as? Data,
              let apiKey = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return apiKey
    }
    
    /// Delete the API key from the keychain.
    private func deleteFromKeychain() {
        // Create the keychain query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: apiKeyAccount
        ]
        
        // Delete the item from the keychain
        SecItemDelete(query as CFDictionary)
    }
    #endif
    
    // MARK: - Encrypted File Storage (Linux)
    
    /// Store the API key in an encrypted file.
    /// - Parameter apiKey: The API key to store.
    private func storeInEncryptedFile(apiKey: String) {
        guard let url = credentialFileURL(),
              let data = apiKey.data(using: .utf8) else {
            return
        }
        
        // For simplicity, we'll use a basic XOR encryption
        // In a real app, use a proper encryption library
        let encryptedData = xorEncrypt(data: data)
        
        try? encryptedData.write(to: url)
    }
    
    /// Retrieve the API key from an encrypted file.
    /// - Returns: The API key, or nil if not found.
    private func retrieveFromEncryptedFile() -> String? {
        guard let url = credentialFileURL(),
              let encryptedData = try? Data(contentsOf: url) else {
            return nil
        }
        
        // Decrypt the data
        let decryptedData = xorEncrypt(data: encryptedData) // XOR is symmetrical
        
        return String(data: decryptedData, encoding: .utf8)
    }
    
    /// Delete the encrypted file.
    private func deleteEncryptedFile() {
        guard let url = credentialFileURL() else {
            return
        }
        
        try? FileManager.default.removeItem(at: url)
    }
    
    /// Get the URL for the credential file.
    /// - Returns: The URL for the credential file.
    private func credentialFileURL() -> URL? {
        guard let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let appDirectory = appSupportURL.appendingPathComponent("RivalTracker", isDirectory: true)
        
        // Create the directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: appDirectory.path) {
            try? FileManager.default.createDirectory(at: appDirectory, withIntermediateDirectories: true)
        }
        
        return appDirectory.appendingPathComponent("credentials.dat")
    }
    
    /// XOR encrypt/decrypt data with a simple key.
    /// - Parameter data: The data to encrypt or decrypt.
    /// - Returns: The encrypted or decrypted data.
    private func xorEncrypt(data: Data) -> Data {
        // Simple encryption key (in a real app, use a more secure method)
        let key: [UInt8] = [0x52, 0x49, 0x56, 0x41, 0x4C, 0x54, 0x52, 0x41, 0x43, 0x4B, 0x45, 0x52]
        
        var encryptedData = Data(count: data.count)
        
        for i in 0..<data.count {
            let keyByte = key[i % key.count]
            let dataByte = data[i]
            encryptedData[i] = dataByte ^ keyByte
        }
        
        return encryptedData
    }
}