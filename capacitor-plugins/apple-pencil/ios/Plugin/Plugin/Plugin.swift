import Foundation
import Capacitor
import PencilKit
import UIKit

/**
 * ApplePencil Plugin for Capacitor
 * Provides deep integration with Apple Pencil features through PencilKit
 */
@objc(ApplePencil)
public class ApplePencil: CAPPlugin {
    private var canvasViews: [String: PKCanvasView] = [:]
    private var toolPicker: PKToolPicker?
    private var currentCanvasId: String?
    private var isScrollObserverAdded = false
    
    // MARK: - Plugin Methods
    
    @objc func isSupported(_ call: CAPPluginCall) {
        // Check if the device supports Apple Pencil - we need both iPad and iOS 13+ for PencilKit
        var supported = UIDevice.current.userInterfaceIdiom == .pad
        
        // Check if PencilKit is available
        if #available(iOS 13.0, *) {
            // PencilKit is available on this iOS version
            // We also need to check if the hardware supports it
            supported = supported && PKCanvasView().allowsFingerDrawing // This is a quick check if PencilKit is properly initializable
        } else {
            supported = false // iOS version is too old for PencilKit
        }
        
        call.resolve(["supported": supported])
    }
    
    @objc func isPaired(_ call: CAPPluginCall) {
        // Check if an Apple Pencil is paired with the device
        if #available(iOS 14.0, *) {
            let isPaired = UIPencilInteraction.prefersPencilOnlyDrawing
            var isConnected = false
            
            // Check if a pencil is currently connected
            if #available(iOS 14.0, *) {
                isConnected = UIDevice.current.userInterfaceIdiom == .pad && 
                              UIScreen.main.traitCollection.supportsPencilInput
            }
            
            call.resolve([
                "paired": isPaired,
                "connected": isConnected
            ])
        } else if #available(iOS 13.0, *) {
            let pencilState = UIPencilInteraction.preferredTapAction != .ignore
            call.resolve([
                "paired": pencilState,
                "connected": pencilState
            ])
        } else {
            call.resolve([
                "paired": false,
                "connected": false
            ])
        }
    }
    
    @objc func initializeCanvas(_ call: CAPPluginCall) {
        guard let elementId = call.getString("elementId") else {
            call.reject("Must provide an element ID")
            return
        }
        
        // Log that we're initializing a canvas
        CAPLog.print("⚠️ ApplePencil: Initializing canvas with ID \(elementId)")
        
        let width = call.getFloat("width") ?? 300
        let height = call.getFloat("height") ?? 300
        let backgroundColor = call.getString("backgroundColor") ?? "#FFFFFF"
        let allowsFingerDrawing = call.getBool("allowsFingerDrawing") ?? true
        
        // Check if PencilKit is supported
        if #available(iOS 13.0, *) {
            DispatchQueue.main.async {
                self.setupCanvas(
                    elementId: elementId,
                    width: CGFloat(width),
                    height: CGFloat(height),
                    backgroundColor: self.hexStringToUIColor(hex: backgroundColor),
                    allowsFingerDrawing: allowsFingerDrawing,
                    call: call
                )
            }
        } else {
            call.reject("PencilKit is not supported on this device (requires iOS 13+)")
        }
    }
    
    @objc func clearCanvas(_ call: CAPPluginCall) {
        guard let currentCanvasId = self.currentCanvasId,
              let canvasView = self.canvasViews[currentCanvasId] else {
            call.reject("No active canvas found")
            return
        }
        
        CAPLog.print("⚠️ ApplePencil: Clearing canvas")
        
        DispatchQueue.main.async {
            canvasView.drawing = PKDrawing()
            self.notifyListeners("drawingChanged", data: ["action": "cleared"])
            call.resolve(["success": true])
        }
    }
    
    @objc func saveDrawing(_ call: CAPPluginCall) {
        guard let currentCanvasId = self.currentCanvasId,
              let canvasView = self.canvasViews[currentCanvasId] else {
            call.reject("No active canvas found")
            return
        }
        
        let format = call.getString("format") ?? "png"
        let quality = call.getFloat("quality") ?? 0.8
        let directory = call.getString("directory") ?? "DOCUMENTS"
        let filename = call.getString("filename") ?? "drawing-\(Int(Date().timeIntervalSince1970))"
        
        DispatchQueue.main.async {
            var imageData: Data?
            var fileExtension: String
            
            switch format.lowercased() {
            case "jpeg", "jpg":
                imageData = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale).jpegData(compressionQuality: CGFloat(quality))
                fileExtension = "jpg"
            case "pdf":
                let pdfData = canvasView.drawing.dataRepresentation()
                imageData = pdfData
                fileExtension = "pdf"
            default: // png
                imageData = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale).pngData()
                fileExtension = "png"
            }
            
            guard let data = imageData else {
                call.reject("Failed to generate image data")
                return
            }
            
            let fileManager = FileManager.default
            let directoryPath: URL
            
            switch directory.uppercased() {
            case "CACHE":
                directoryPath = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
            case "LIBRARY":
                directoryPath = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
            default: // DOCUMENTS
                directoryPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            }
            
            let filePath = directoryPath.appendingPathComponent("\(filename).\(fileExtension)")
            
            do {
                try data.write(to: filePath)
                call.resolve(["path": filePath.path])
            } catch {
                call.reject("Failed to save drawing: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func loadImage(_ call: CAPPluginCall) {
        guard let currentCanvasId = self.currentCanvasId,
              let canvasView = self.canvasViews[currentCanvasId] else {
            call.reject("No active canvas found")
            return
        }
        
        guard let path = call.getString("path") else {
            call.reject("Must provide an image path")
            return
        }
        
        let fitToCanvas = call.getBool("fitToCanvas") ?? true
        
        DispatchQueue.main.async {
            guard let image = UIImage(contentsOfFile: path) else {
                call.reject("Failed to load image from path")
                return
            }
            
            // Create a new drawing from the image
            let imageView = UIImageView(image: image)
            if fitToCanvas {
                imageView.frame = canvasView.bounds
                imageView.contentMode = .scaleAspectFit
            } else {
                imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            }
            
            UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, false, UIScreen.main.scale)
            if let context = UIGraphicsGetCurrentContext() {
                canvasView.layer.render(in: context)
                imageView.layer.render(in: context)
                if let compositeImage = UIGraphicsGetImageFromCurrentImageContext() {
                    UIGraphicsEndImageContext()
                    
                    // Convert the composite image to a PKDrawing
                    // This is a simplified approach - for more complex needs, you might need to use PKDrawing's dataRepresentation
                    let renderer = UIGraphicsImageRenderer(size: canvasView.bounds.size)
                    let _ = renderer.image { ctx in
                        compositeImage.draw(in: canvasView.bounds)
                    }
                    
                    // For now, we'll just set the background image
                    canvasView.backgroundColor = UIColor(patternImage: compositeImage)
                    call.resolve(["success": true])
                } else {
                    UIGraphicsEndImageContext()
                    call.reject("Failed to create composite image")
                }
            } else {
                UIGraphicsEndImageContext()
                call.reject("Failed to create graphics context")
            }
        }
    }
    
    @objc func setToolProperties(_ call: CAPPluginCall) {
        guard let currentCanvasId = self.currentCanvasId,
              let canvasView = self.canvasViews[currentCanvasId] else {
            call.reject("No active canvas found")
            return
        }
        
        let type = call.getString("type") ?? "pen"
        let color = call.getString("color") ?? "#000000"
        let width = call.getFloat("width") ?? 2.0
        let opacity = call.getFloat("opacity") ?? 1.0
        
        CAPLog.print("⚠️ ApplePencil: Setting tool properties - type: \(type), color: \(color), width: \(width), opacity: \(opacity)")
        
        DispatchQueue.main.async {
            if #available(iOS 14.0, *) {
                if let toolPicker = self.toolPicker {
                    // Show the tool picker
                    toolPicker.setVisible(true, forFirstResponder: canvasView)
                    canvasView.becomeFirstResponder()
                    
                    // Apply custom ink settings using PKInkingTool
                    if type == "pen" {
                        if #available(iOS 14.0, *) {
                            let ink = PKInk(.pen, color: self.hexStringToUIColor(hex: color))
                            let tool = PKInkingTool(ink, width: CGFloat(width))
                            canvasView.tool = tool
                        }
                    } else if type == "pencil" {
                        if #available(iOS 14.0, *) {
                            let ink = PKInk(.pencil, color: self.hexStringToUIColor(hex: color))
                            let tool = PKInkingTool(ink, width: CGFloat(width))
                            canvasView.tool = tool
                        }
                    } else if type == "marker" {
                        if #available(iOS 14.0, *) {
                            let ink = PKInk(.marker, color: self.hexStringToUIColor(hex: color))
                            let tool = PKInkingTool(ink, width: CGFloat(width))
                            canvasView.tool = tool
                        }
                    } else if type == "eraser" {
                        if #available(iOS 14.0, *) {
                            canvasView.tool = PKEraserTool(.vector)
                        } else {
                            // Fallback for earlier iOS versions
                            UIPasteboard.general.string = "eraser"
                            self.notifyListeners("toolChange", data: ["type": "eraser"])
                        }
                    }
                }
            }
            
            // Store these preferences for future reference
            UserDefaults.standard.set(type, forKey: "ApplePencil.toolType")
            UserDefaults.standard.set(color, forKey: "ApplePencil.toolColor")
            UserDefaults.standard.set(width, forKey: "ApplePencil.toolWidth")
            UserDefaults.standard.set(opacity, forKey: "ApplePencil.toolOpacity")
            
            // Notify listeners about the tool change
            self.notifyListeners("toolPropertiesChanged", data: [
                "type": type,
                "color": color,
                "width": width,
                "opacity": opacity
            ])
            
            call.resolve(["success": true])
        }
    }
    
    // MARK: - Helper Methods
    
    private func setupCanvas(
        elementId: String,
        width: CGFloat,
        height: CGFloat,
        backgroundColor: UIColor,
        allowsFingerDrawing: Bool,
        call: CAPPluginCall
    ) {
        // Get the web view
        guard let webView = self.webView else {
            call.reject("WebView is not available")
            return
        }
        
        // Create a PKCanvasView
        let canvasView = PKCanvasView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        canvasView.backgroundColor = backgroundColor
        canvasView.isOpaque = false
        canvasView.drawingPolicy = allowsFingerDrawing ? .anyInput : .pencilOnly
        
        // Set up the tool picker if available
        if #available(iOS 13.0, *) {
            let toolPicker = PKToolPicker()
            toolPicker.addObserver(canvasView)
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            canvasView.becomeFirstResponder()
            self.toolPicker = toolPicker
        }
        
        // Add drawing changed observer
        canvasView.delegate = self
        
        // Store the canvas view
        self.canvasViews[elementId] = canvasView
        self.currentCanvasId = elementId
        
        // Add debugging notification
        CAPLog.print("⚠️ ApplePencil: Canvas view created successfully")
        
        // Inject the native view into the web view
        self.bridge?.viewController?.view.addSubview(canvasView)
        
        // Add pencil connectivity observer
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.pencilConnectionChanged(_:)),
                name: UIAccessory.didConnectNotification,
                object: nil
            )
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.pencilConnectionChanged(_:)),
                name: UIAccessory.didDisconnectNotification,
                object: nil
            )
        }
        // Position the canvas view over the web element
        webView.evaluateJavaScript("""
            (function() {
                const element = document.getElementById('\(elementId)');
                if (!element) return null;
                const rect = element.getBoundingClientRect();
                const scrollLeft = window.pageXOffset || document.documentElement.scrollLeft;
                const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
                return {
                    x: rect.left + scrollLeft,
                    y: rect.top + scrollTop,
                    width: rect.width,
                    height: rect.height,
                    scrollLeft: scrollLeft,
                    scrollTop: scrollTop
                };
            })()
        """) { (result, error) in
        """) { (result, error) in
            if let error = error {
                call.reject("Failed to get element position: \(error.localizedDescription)")
                return
            }
            
            guard let rect = result as? [String: Any],
                  let x = rect["x"] as? CGFloat,
                  let y = rect["y"] as? CGFloat,
                  let elementWidth = rect["width"] as? CGFloat,
                  let elementHeight = rect["height"] as? CGFloat else {
                call.reject("Element not found or invalid dimensions")
                return
            }
            
            // Position the canvas view
            canvasView.frame = CGRect(
                x: x,
                y: y,
                width: elementWidth,
                height: elementHeight
            )
            
            // Set up pencil interactions
            if #available(iOS 12.1, *) {
                let interaction = UIPencilInteraction()
                interaction.delegate = self
                canvasView.addInteraction(interaction)
            }
            
            call.resolve(["success": true])
            
            // Add scroll event listener if not already added
            if !self.isScrollObserverAdded {
                self.observeScrolling(elementId: elementId)
                self.isScrollObserverAdded = true
            }
        }
    }
    
    private func updateCanvasPosition(_ elementId: String) {
        guard let webView = self.webView,
              let canvasView = self.canvasViews[elementId] else {
            return
        }
        
        webView.evaluateJavaScript("""
            (function() {
                const element = document.getElementById('\(elementId)');
                if (!element) return null;
                const rect = element.getBoundingClientRect();
                const scrollLeft = window.pageXOffset || document.documentElement.scrollLeft;
                const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
                return {
                    x: rect.left + scrollLeft,
                    y: rect.top + scrollTop,
                    width: rect.width,
                    height: rect.height
                };
            })()
        """) { (result, _) in
            if let rect = result as? [String: Any],
               let x = rect["x"] as? CGFloat,
               let y = rect["y"] as? CGFloat,
               let width = rect["width"] as? CGFloat,
               let height = rect["height"] as? CGFloat {
                
                DispatchQueue.main.async {
                    canvasView.frame = CGRect(x: x, y: y, width: width, height: height)
                }
            }
        }
    }
    
    private func observeScrolling(elementId: String) {
        guard let webView = self.webView else {
            return
        }
        
        // Set up the message handler
        webView.configuration.userContentController.add(self, name: "scrollChanged")
        
        // Add scroll event listener to the webpage
        webView.evaluateJavaScript("""
            window.addEventListener('scroll', function() {
                window.webkit.messageHandlers.scrollChanged.postMessage({elementId: '\(elementId)'});
            }, true);
            
            // Also observe resize events
            window.addEventListener('resize', function() {
                window.webkit.messageHandlers.scrollChanged.postMessage({elementId: '\(elementId)'});
            }, true);
        """, completionHandler: nil)
    }
    
    private func hexStringToUIColor(hex: String) -> UIColor {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    // MARK: - Pencil Connection Monitoring
    
    @objc private func pencilConnectionChanged(_ notification: Notification) {
        if #available(iOS 13.0, *) {
            let isConnected = notification.name == UIAccessory.didConnectNotification
            let isPencil = (notification.object as? UIAccessory)?.accessoryCategory == .pencil
            
            if isPencil {
                CAPLog.print("⚠️ ApplePencil: Pencil connection changed - connected: \(isConnected)")
                
                DispatchQueue.main.async {
                    if isConnected {
                        self.notifyListeners("pencilConnected", data: [:])
                    } else {
                        self.notifyListeners("pencilDisconnected", data: [:])
                    }
                }
            }
        }
    }
}

// MARK: - PKCanvasViewDelegate

extension ApplePencil: PKCanvasViewDelegate {
    public func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        // Notify when the drawing changes
        self.notifyListeners("drawingChanged", data: [
            "timestamp": Date().timeIntervalSince1970,
            "canvasId": self.currentCanvasId ?? ""
        ])
    }
}

// MARK: - WKScriptMessageHandler

extension ApplePencil: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "scrollChanged", 
           let body = message.body as? [String: Any],
           let elementId = body["elementId"] as? String {
            
            DispatchQueue.main.async {
                self.updateCanvasPosition(elementId)
            }
        }
    }
}

// MARK: - UIPencilInteractionDelegate

@available(iOS 12.1, *)
extension ApplePencil: UIPencilInteractionDelegate {
    public func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
        // Handle pencil tap interaction
        self.notifyListeners("pencilTap", data: [:])
    }
}