import { WebPlugin } from '@capacitor/core';

import type { 
  ApplePencilPlugin, 
  CanvasOptions, 
  SaveOptions, 
  LoadOptions, 
  ToolOptions,
  StorageOptions
} from './definitions';
import { ApplePencilErrorHandler } from './error-handler';
import { DrawingPersistence } from './persistence';
import { Drawing } from './types';

export class ApplePencilWeb extends WebPlugin implements ApplePencilPlugin {
  private persistence: DrawingPersistence;
  private currentDrawing: Drawing;
  private activeCanvas: HTMLCanvasElement | null = null;
  
  constructor() {
    super({
      name: 'ApplePencil',
      platforms: ['web']
    });
    
    this.persistence = new DrawingPersistence();
    this.currentDrawing = {
      strokes: [],
      bounds: { width: 0, height: 0 }
    };
  }

  async getVersionHistory(drawingId: string): Promise<DrawingVersion[]> {
    try {
      const drawing = await this.persistence.loadDrawing(drawingId);
      return drawing.history || [];
    } catch (error) {
      throw ApplePencilErrorHandler.handleError(error);
    }
  }

  async revertToVersion(drawingId: string, version: number): Promise<{ success: boolean }> {
    try {
      const drawing = await this.persistence.revertToVersion(drawingId, version);
      
      // Update current drawing
      this.currentDrawing = drawing;
      
      // Redraw the canvas with reverted content
      if (this.activeCanvas) {
        await this.redrawCanvas(drawing.strokes);
      }

      return { success: true };
    } catch (error) {
      throw ApplePencilErrorHandler.handleError(error);
    }
  }
  
  async listBackups(): Promise<{ backups: string[] }> {
    try {
      const backups = await this.persistence.listBackups();
      return { backups };
    } catch (error) {
      throw ApplePencilErrorHandler.handleError(error);
    }
  }
  
  async restoreFromBackup(backupKey: string): Promise<{ success: boolean }> {
    try {
      const success = await this.persistence.restoreFromBackup(backupKey);
      return { success };
    } catch (error) {
      throw ApplePencilErrorHandler.handleError(error);
    }
  }

  async isSupported(): Promise<{ supported: boolean }> {
    // Apple Pencil is not supported on web
    return { supported: false };
  }

  async isPaired(): Promise<{ paired: boolean }> {
    // Apple Pencil cannot be paired on web
    return { paired: false };
  }

  async initializeCanvas(options: CanvasOptions): Promise<{ success: boolean }> {
    try {
      console.warn('ApplePencil.initializeCanvas: This method is not supported on web. Using standard canvas instead.');
      
      // Create a fallback canvas implementation using standard HTML5 Canvas
      const element = document.getElementById(options.elementId);
      if (!element) {
        throw new Error(`Element with id ${options.elementId} not found`);
      }
      
      // Create canvas element
      const canvas = document.createElement('canvas');
      canvas.width = options.width;
      canvas.height = options.height;
      canvas.style.backgroundColor = options.backgroundColor || 'white';
      
      // Clear any existing content and append canvas
      element.innerHTML = '';
      element.appendChild(canvas);
      
      // Store the active canvas
      this.activeCanvas = canvas;
      
      // Initialize current drawing with canvas bounds
      this.currentDrawing = {
        strokes: [],
        bounds: {
          width: options.width,
          height: options.height
        }
      };
      
      // Setup basic drawing functionality
      this.setupBasicDrawing(canvas);
      
      // Notify that canvas was initialized
      this.notifyListeners('drawingChanged', { action: 'initialized', canvasId: options.elementId });
      
      return { success: true };
    } catch (error) {
      throw ApplePencilErrorHandler.handleError(error);
    }
  }

  async clearCanvas(): Promise<{ success: boolean }> {
    try {
      if (!this.activeCanvas) {
        console.warn('ApplePencil.clearCanvas: No active canvas found.');
        return { success: false };
      }
      
      const ctx = this.activeCanvas.getContext('2d');
      if (!ctx) {
        return { success: false };
      }
      
      // Clear the canvas
      ctx.clearRect(0, 0, this.activeCanvas.width, this.activeCanvas.height);
      
      // Reset current drawing
      this.currentDrawing.strokes = [];
      
      // Notify about canvas cleared
      this.notifyListeners('drawingChanged', { action: 'cleared' });
      
      return { success: true };
    } catch (error) {
      console.warn('ApplePencil.clearCanvas: Error clearing canvas', error);
      return { success: false };

  async saveDrawing(options: SaveOptions): Promise<{ path: string }> {
    console.warn('ApplePencil.saveDrawing: This method is not fully supported on web.');
    return { path: '' };
  }

  async loadImage(options: LoadOptions): Promise<{ success: boolean }> {
    console.warn('ApplePencil.loadImage: This method is not fully supported on web.');
    return { success: false };
  }

  async setToolProperties(options: ToolOptions): Promise<{ success: boolean }> {
    console.warn('ApplePencil.setToolProperties: This method is not fully supported on web.');
    return { success: false };
  }

  async addListener(
    eventName: 'pencilConnected' | 'pencilDisconnected' | 'pencilDataReceived' | 'drawingChanged',
    callback: (info: any) => void
  ): Promise<{ id: string }> {
    console.warn(`ApplePencil.addListener: Event ${eventName} is not supported on web.`);
    // Generate a random ID for the listener
    const id = Math.random().toString(36).substring(2, 15);
    return { id };
  }

  async removeListener(id: string): Promise<void> {
    console.warn(`ApplePencil.removeListener: Removing listeners is not supported on web.`);
    return;
  }

  private setupBasicDrawing(canvas: HTMLCanvasElement) {
    const ctx = canvas.getContext('2d');
    if (!ctx) return;
    
    let isDrawing = false;
    let lastX = 0;
    let lastY = 0;
    
    // Set default style
    ctx.lineWidth = 2;
    ctx.lineJoin = 'round';
    ctx.lineCap = 'round';
    ctx.strokeStyle = '#000';
    
    // Mouse events for desktop testing
    canvas.addEventListener('mousedown', (e) => {
      isDrawing = true;
      [lastX, lastY] = [e.offsetX, e.offsetY];
    });
    
    canvas.addEventListener('mousemove', (e) => {
      if (!isDrawing) return;
      ctx.beginPath();
      ctx.moveTo(lastX, lastY);
      ctx.lineTo(e.offsetX, e.offsetY);
      ctx.stroke();
      [lastX, lastY] = [e.offsetX, e.offsetY];
    });
    
    canvas.addEventListener('mouseup', () => {
      isDrawing = false;
    });
    
    canvas.addEventListener('mouseout', () => {
      isDrawing = false;
    });
    
    // Touch events for mobile
    canvas.addEventListener('touchstart', (e) => {
      e.preventDefault();
      const touch = e.touches[0];
      const rect = canvas.getBoundingClientRect();
      [lastX, lastY] = [touch.clientX - rect.left, touch.clientY - rect.top];
      isDrawing = true;
    });
    
    canvas.addEventListener('touchmove', (e) => {
      if (!isDrawing) return;
      e.preventDefault();
      const touch = e.touches[0];
      const rect = canvas.getBoundingClientRect();
      const x = touch.clientX - rect.left;
      const y = touch.clientY - rect.top;
      
      ctx.beginPath();
      ctx.moveTo(lastX, lastY);
      ctx.lineTo(x, y);
      ctx.stroke();
      [lastX, lastY] = [x, y];
    });
    
    canvas.addEventListener('touchend', (e) => {
      e.preventDefault();
      isDrawing = false;
    });
  }
  
  private async redrawCanvas(strokes: Stroke[]) {
    if (!this.activeCanvas) return;
    
    const ctx = this.activeCanvas.getContext('2d');
    if (!ctx) return;

    // Clear canvas
    ctx.clearRect(0, 0, this.activeCanvas.width, this.activeCanvas.height);

    // Redraw all strokes
    strokes.forEach(stroke => {
      ctx.beginPath();
      ctx.strokeStyle = stroke.color;
      ctx.lineWidth = stroke.width;
      ctx.globalAlpha = stroke.opacity || 1.0;

      const points = stroke.points;
      if (points.length > 0) {
        ctx.moveTo(points[0].x, points[0].y);
        points.slice(1).forEach(point => {
          ctx.lineTo(point.x, point.y);
        });
      }
      ctx.stroke();
    });

    ctx.globalAlpha = 1.0;
  }
}
