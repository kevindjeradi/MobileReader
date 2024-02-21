import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

// Load environment variables
import dotenv from 'dotenv';
dotenv.config();

const JWT_SECRET = process.env.JWT_SECRET as string;

interface DecodedToken {
  userId: string;
}

const checkAuth = (req: Request, res: Response, next: NextFunction) => {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({ error: 'No authorization header sent' });
  }

  const tokenParts = authHeader.split(' ');
  if (tokenParts.length !== 2 || tokenParts[0] !== 'Bearer') {
    return res.status(401).json({ error: 'Authorization header format should be: Bearer [token]' });
  }

  const token = tokenParts[1];
  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) {
      return res.status(401).json({ error: 'Invalid token', details: err.message });
    }

    // Ensure "decoded" is not null and is a DecodedToken
    if (decoded && typeof decoded === 'object' && 'userId' in decoded) {
      req.userId = (decoded as DecodedToken).userId;
      next();
    } else {
      return res.status(401).json({ error: 'Invalid token payload' });
    }
  });
};

export default checkAuth;
