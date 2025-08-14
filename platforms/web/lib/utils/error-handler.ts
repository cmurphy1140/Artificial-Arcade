import { NextResponse } from 'next/server';

export class AppError extends Error {
  public readonly statusCode: number;
  public readonly isOperational: boolean;

  constructor(message: string, statusCode: number = 500, isOperational: boolean = true) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = isOperational;
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }
}

export class ValidationError extends AppError {
  constructor(message: string) {
    super(message, 400);
  }
}

export class AuthenticationError extends AppError {
  constructor(message: string = 'Authentication required') {
    super(message, 401);
  }
}

export class AuthorizationError extends AppError {
  constructor(message: string = 'Insufficient permissions') {
    super(message, 403);
  }
}

export class NotFoundError extends AppError {
  constructor(message: string = 'Resource not found') {
    super(message, 404);
  }
}

export class DatabaseError extends AppError {
  constructor(message: string = 'Database operation failed') {
    super(message, 500);
  }
}

export const handleApiError = (error: unknown): NextResponse => {
  console.error('API Error:', error);

  if (error instanceof AppError) {
    return NextResponse.json(
      { 
        error: error.message,
        type: error.constructor.name,
        statusCode: error.statusCode 
      },
      { status: error.statusCode }
    );
  }

  // Handle database connection errors
  if (error instanceof Error && error.message.includes('database')) {
    return NextResponse.json(
      { 
        error: 'Database temporarily unavailable',
        type: 'DatabaseError' 
      },
      { status: 503 }
    );
  }

  // Handle unknown errors
  return NextResponse.json(
    { 
      error: 'An unexpected error occurred',
      type: 'InternalServerError' 
    },
    { status: 500 }
  );
};

export const validateRequired = (fields: Record<string, unknown>, requiredFields: string[]): void => {
  const missing = requiredFields.filter(field => !fields[field]);
  if (missing.length > 0) {
    throw new ValidationError(`Missing required fields: ${missing.join(', ')}`);
  }
};

export const validateEmail = (email: string): boolean => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

export const validateWalletAddress = (address: string): boolean => {
  return /^0x[a-fA-F0-9]{40}$/.test(address);
};
