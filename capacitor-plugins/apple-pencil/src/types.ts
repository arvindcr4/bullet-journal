export interface ApplePencilError {
  code: string;
  message: string;
  details: any;
}

export interface Drawing {
  strokes: Stroke[];
  bounds: Bounds;
  metadata?: any;
  version?: number;  // Add version number
  lastModified?: string;  // Add last modified timestamp
  history?: DrawingVersion[];  // Add version history
}

export interface DrawingVersion {
  version: number;
  timestamp: string;
  strokes: Stroke[];
  metadata?: any;
}

export interface Stroke {
  points: Point[];
  color: string;
  width: number;
  opacity: number;
  tool: string;
}

export interface Point {
  x: number;
  y: number;
  pressure?: number;
  timestamp?: number;
}

export interface Bounds {
  width: number;
  height: number;
}

export interface StorageOptions {
  storage: 'local' | 'file';
  name?: string;
  tags?: string[];
  metadata?: Record<string, any>;
}

