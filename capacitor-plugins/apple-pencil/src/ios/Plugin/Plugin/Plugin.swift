        // Add debugging notification
        CAPLog.print("⚠️ ApplePencil: Canvas view created successfully")
        
        // Set up backup interval
        DispatchQueue.global(qos: .background).async {
            // Schedule automatic backups every 5 minutes
            let timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
                self.createBackup()
            }
            RunLoop.current.add(timer, forMode: .common)
            RunLoop.current.run()
        }
        
    // MARK: - Backup and Version Control
    
    private func createBackup() {
        DispatchQueue.main.async {
            CAPLog.print("⚠️ ApplePencil: Creating automatic backup")
            
            // Save the current drawing state to user defaults
            if let canvasView = self.currentCanvasId.flatMap({ self.canvasViews[$0] }),
               let pdfData = try? canvasView.drawing.dataRepresentation() {
                
                let backupKey = "APPLE_PENCIL_BACKUP_\(Int(Date().timeIntervalSince1970))"
                UserDefaults.standard.set(pdfData, forKey: backupKey)
                
                // Clean up old backups (keep last 5)
                let backupKeys = UserDefaults.standard.dictionaryRepresentation().keys
                    .filter { $0.hasPrefix("APPLE_PENCIL_BACKUP_") }
                    .sorted()
                
                if backupKeys.count > 5 {
                    for key in backupKeys.prefix(backupKeys.count - 5) {
                        UserDefaults.standard.removeObject(forKey: key)
                    }
                }
            }
        }
    }
    
    @objc func listBackups(_ call: CAPPluginCall) {
        let backupKeys = UserDefaults.standard.dictionaryRepresentation().keys
            .filter { $0.hasPrefix("APPLE_PENCIL_BACKUP_") }
            .sorted()
        
        call.resolve(["backups": backupKeys])
    }
    
    @objc func restoreFromBackup(_ call: CAPPluginCall) {
        guard let backupKey = call.getString("backupKey"),
              let backupData = UserDefaults.standard.data(forKey: backupKey),
              let canvasView = self.currentCanvasId.flatMap({ self.canvasViews[$0] }) else {
            call.reject("Invalid backup key or no active canvas")
            return
        }
        
        do {
            let drawing = try PKDrawing(data: backupData)
            DispatchQueue.main.async {
                canvasView.drawing = drawing
                self.notifyListeners("drawingChanged", data: [
                    "action": "restored",
                    "source": "backup",
                    "key": backupKey
                ])
                call.resolve(["success": true])
            }
        } catch {
            call.reject("Failed to restore backup: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Pencil Connection Monitoring
    
