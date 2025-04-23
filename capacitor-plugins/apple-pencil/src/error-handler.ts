import { ApplePencilError } from './types';

export class ApplePencilErrorHandler {
  static handleError(error: any): ApplePencilError {
    // Standardize error format
    return {
      code: this.getErrorCode(error),
      message: this.getErrorMessage(error),
      details: error
    };
  }

  private static getErrorCode(error: any): string {
    if (error.code) return error.code;
    
    // Map common errors to codes
    if (error.message?.includes('not supported')) return 'DEVICE_NOT_SUPPORTED';
    if (error.message?.includes('not paired')) return 'PENCIL_NOT_PAIRED';
    if (error.message?.includes('canvas')) return 'CANVAS_ERROR';
    if (error.message?.includes('storage')) return 'STORAGE_ERROR';
    
    return 'UNKNOWN_ERROR';
  }

  private static getErrorMessage(error: any): string {
    const messages = {
      DEVICE_NOT_SUPPORTED: 'This device does not support Apple Pencil functionality',
      PENCIL_NOT_PAIRED: 'No Apple Pencil is paired with this device',
      CANVAS_ERROR: 'Error manipulating the drawing canvas',
      STORAGE_ERROR: 'Error saving or loading drawing data',
      UNKNOWN_ERROR: 'An unexpected error occurred'
    };

    return messages[this.getErrorCode(error)] || error.message || 'Unknown error occurred';
  }
}

