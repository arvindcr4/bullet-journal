export interface SaveOptions {
  format?: 'png' | 'jpeg' | 'pdf';
  quality?: number;
  directory?: 'DOCUMENTS' | 'CACHE' | 'LIBRARY';
  filename?: string;
}

export interface StorageOptions {
  storage: 'local' | 'file';
  name?: string;
  tags?: string[];
  metadata?: Record<string, any>;
}
se<{ success: boolean }>;
  saveDrawing(options: SaveOptions): Promise<{ path: string }>;
  loadImage(options: LoadOptions): Promise<{ success: boolean }>;
  setToolProperties(options: ToolOptions): Promise<{ success: boolean }>;
  
  // New persistence methods
  saveCurrentDrawing(options: StorageOptions): Promise<{ id: string }>;
  loadDrawing(drawingId: string): Promise<{ success: boolean }>;
  listDrawings(): Promise<Array<{id: string, metadata: any}>>;
  deleteDrawing(drawingId: string): Promise<{ success: boolean }>;
  
  // Version control methods
  getVersionHistory(drawingId: string): Promise<DrawingVersion[]>;
  revertToVersion(drawingId: string, version: number): Promise<{ success: boolean }>;
  
  // Backup methods
  listBackups(): Promise<{ backups: string[] }>;
  restoreFromBackup(backupKey: string): Promise<{ success: boolean }>;
  
  addListener(
    eventName: 'pencilConnected' | 'pencilDisconnected' | 'pencilDataReceived' | 'drawingChanged',
    listenerFunc: (info: any) => void
  ): Promise<{ id: string }>;
  
  removeListener(id: string): Promise<void>;
}
   * @returns Promise with result of the initialization
   */
  initializeCanvas(options: CanvasOptions): Promise<{ success: boolean }>;

  /**
   * Clear the drawing canvas
   * @returns Promise with result of the clear operation
   */
  clearCanvas(): Promise<{ success: boolean }>;

  /**
   * Save the current drawing as an image
   * @param options Options for saving the drawing
   * @returns Promise with the path to the saved image
   */
  saveDrawing(options: SaveOptions): Promise<{ path: string }>;

  /**
   * Load an image into the drawing canvas
   * @param options Options for loading the image
   * @returns Promise with result of the load operation
   */
  loadImage(options: LoadOptions): Promise<{ success: boolean }>;

  /**
   * Set the tool properties for drawing
   * @param options Tool properties
   * @returns Promise with result of the operation
   */
  setToolProperties(options: ToolOptions): Promise<{ success: boolean }>;

  /**
   * Add a listener for pencil events
   * @param eventName Name of the event to listen for
   * @param callback Callback function to be called when the event occurs
   */
  addListener(
    eventName: 'pencilConnected' | 'pencilDisconnected' | 'pencilDataReceived' | 'drawingChanged',
    callback: (info: any) => void
  ): Promise<{ id: string }>;

  /**
   * Remove a previously registered listener
   * @param id The ID of the listener to remove
   */
  removeListener(id: string): Promise<void>;
}

export interface CanvasOptions {
  /**
   * ID of the HTML element to attach the native canvas to
   */
  elementId: string;

  /**
   * Width of the canvas in points
   */
  width: number;

  /**
   * Height of the canvas in points
   */
  height: number;

  /**
   * Background color of the canvas (CSS color string)
   */
  backgroundColor?: string;

  /**
   * Whether to allow finger drawing (default: true)
   */
  allowsFingerDrawing?: boolean;
}

export interface SaveOptions {
  /**
   * Format to save the image as ('png', 'jpeg', 'pdf')
   */
  format: 'png' | 'jpeg' | 'pdf';

  /**
   * Quality of the saved image (0.0 to 1.0, for jpeg only)
   */
  quality?: number;

  /**
   * Directory to save the image to
   */
  directory?: string;

  /**
   * Filename to save the image as
   */
  filename?: string;
}

export interface LoadOptions {
  /**
   * Path to the image to load
   */
  path: string;

  /**
   * Whether to fit the image to the canvas
   */
  fitToCanvas?: boolean;
}

export interface ToolOptions {
  /**
   * Type of tool to use
   */
  type: 'pen' | 'marker' | 'pencil' | 'eraser';

  /**
   * Color of the tool (CSS color string)
   */
  color?: string;

  /**
   * Width of the tool stroke
   */
  width?: number;

  /**
   * Opacity of the tool (0.0 to 1.0)
   */
  opacity?: number;
}

export interface PencilData {
  /**
   * Force applied by the pencil (0.0 to 1.0)
   */
  force: number;

  /**
   * Azimuth angle of the pencil in radians
   */
  azimuth: number;

  /**
   * Altitude angle of the pencil in radians
   */
  altitude: number;

  /**
   * X coordinate of the pencil
   */
  x: number;

  /**
   * Y coordinate of the pencil
   */
  y: number;
}