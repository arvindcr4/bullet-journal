import { Drawing, StorageOptions } from './types';
import { ApplePencilErrorHandler } from './error-handler';

export class DrawingPersistence {
  private readonly STORAGE_KEY = 'APPLE_PENCIL_DRAWINGS';
  private readonly BACKUP_INTERVAL = 5 * 60 * 1000; // 5 minutes
  private backupTimer: NodeJS.Timeout | null = null;
  
  constructor() {
    this.startAutoBackup();
  }
  
  private startAutoBackup() {
    this.backupTimer = setInterval(() => {
      this.createBackup();
    }, this.BACKUP_INTERVAL);
  }

  private stopAutoBackup() {
    if (this.backupTimer) {
      clearInterval(this.backupTimer);
      this.backupTimer = null;
    }
  }

  private async createBackup() {
    try {
      const drawings = await this.getStoredDrawings();
      const backupData = {
        timestamp: new Date().toISOString(),
        drawings: drawings
      };

      // Save backup to local storage with unique key
      const backupKey = `APPLE_PENCIL_BACKUP_${Date.now()}`;
      localStorage.setItem(backupKey, JSON.stringify(backupData));

      // Keep only last 5 backups
      const backups = this.listBackups();
      if (backups.length > 5) {
        backups.slice(0, -5).forEach(key => localStorage.removeItem(key));
      }
    } catch (error) {
      console.warn('Failed to create backup:', error);
    }
  }

  async listBackups(): Promise<string[]> {
    return Object.keys(localStorage)
      .filter(key => key.startsWith('APPLE_PENCIL_BACKUP_'))
      .sort();
  }

  async restoreFromBackup(backupKey: string): Promise<boolean> {
    try {
      const backupData = localStorage.getItem(backupKey);
      if (!backupData) return false;

      const { drawings } = JSON.parse(backupData);
      await this.saveToLocalStorage(drawings);
      return true;
    } catch (error) {
      throw ApplePencilErrorHandler.handleError(error);
    }
  }

  async saveDrawing(drawing: Drawing, options: StorageOptions): Promise<string> {
    try {
      // Add version control
      const now = new Date().toISOString();
      const newVersion: Drawing = {
        ...drawing,
        version: (drawing.version || 0) + 1,
        lastModified: now,
        history: [
          ...(drawing.history || []),
          {
            version: drawing.version || 0,
            timestamp: drawing.lastModified || now,
            strokes: [...drawing.strokes],
            metadata: { ...drawing.metadata }
          }
        ]
      };

      // Limit history to last 10 versions
      if (newVersion.history && newVersion.history.length > 10) {
        newVersion.history = newVersion.history.slice(-10);
      }

      // Generate unique ID for the drawing
      const drawingId = `drawing_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
      
      // Get existing drawings
      const drawings = await this.getStoredDrawings();
      
      // Add new drawing
      const drawingData = {
        id: drawingId,
        data: newVersion,
        metadata: {
          timestamp: new Date().toISOString(),
          name: options.name || drawingId,
          tags: options.tags || [],
          ...options.metadata
        }
      };
      
      drawings.push(drawingData);
      
      // Save to storage
      if (options.storage === 'local') {
        await this.saveToLocalStorage(drawings);
      } else {
        await this.saveToFileSystem(drawings);
      }
      
      // Create backup after save
      setTimeout(() => this.createBackup(), 1000);
      
      return drawingId;
    } catch (error) {
      throw ApplePencilErrorHandler.handleError(error);
    }
  }
  
  async revertToVersion(drawingId: string, version: number): Promise<Drawing> {
    try {
      const drawing = await this.loadDrawing(drawingId);
      if (!drawing.history) {
        throw new Error('No version history available');
      }

      const targetVersion = drawing.history.find(v => v.version === version);
      if (!targetVersion) {
        throw new Error(`Version ${version} not found`);
      }

      // Create new drawing with reverted content
      const revertedDrawing: Drawing = {
        strokes: [...targetVersion.strokes],
        bounds: drawing.bounds,
        version: (drawing.version || 0) + 1,
        lastModified: new Date().toISOString(),
        metadata: { ...targetVersion.metadata, reverted: true },
        history: drawing.history
      };

      return revertedDrawing;
    } catch (error) {
      throw ApplePencilErrorHandler.handleError(error);
    }
  }
  
  async loadDrawing(drawingId: string): Promise<Drawing> {
    try {
      const drawings = await this.getStoredDrawings();
      const drawing = drawings.find(d => d.id === drawingId);
      
      if (!drawing) {
        throw new Error(`Drawing with ID ${drawingId} not found`);
      }
      
      return drawing.data;
    } catch (error) {
      throw ApplePencilErrorHandler.handleError(error);
    }
  }
  
  async listDrawings(): Promise<Array<{id: string, metadata: any}>> {
    try {
      const drawings = await this.getStoredDrawings();
      return drawings.map(drawing => ({
        id: drawing.id,
        metadata: drawing.metadata
      }));
    } catch (error) {
      throw ApplePencilErrorHandler.handleError(error);
    }
  }
  
  async deleteDrawing(drawingId: string): Promise<boolean> {
    try {
      const drawings = await this.getStoredDrawings();
      const initialLength = drawings.length;
      
      const filteredDrawings = drawings.filter(d => d.id !== drawingId);
      
      if (filteredDrawings.length === initialLength) {
        return false; // Drawing wasn't found
      }
      
      // Save updated list
      await this.saveToLocalStorage(filteredDrawings);
      return true;
    } catch (error) {
      throw ApplePencilErrorHandler.handleError(error);
    }
  }
  
  private async getStoredDrawings(): Promise<any[]> {
    try {
      // Try local storage first
      const localData = localStorage.getItem(this.STORAGE_KEY);
      if (localData) {
        return JSON.parse(localData);
      }
      
      // Fall back to file system
      return await this.loadFromFileSystem();
    } catch (error) {
      return [];
    }
  }
  
  private async saveToLocalStorage(drawings: any[]): Promise<void> {
    localStorage.setItem(this.STORAGE_KEY, JSON.stringify(drawings));
  }
  
  private async saveToFileSystem(drawings: any[]): Promise<void> {
    // Implementation depends on your file system access method
    console.warn('File system storage not fully implemented yet');
    
    // Fallback to local storage for now
    this.saveToLocalStorage(drawings);
  }
  
  private async loadFromFileSystem(): Promise<any[]> {
    // Implementation depends on your file system access method
    console.warn('File system loading not fully implemented yet');
    return [];
  }
}

