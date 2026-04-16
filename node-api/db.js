import mysql from 'mysql2/promise';

const pool = mysql.createPool({
  host: process.env.HOSPITAL_DB_HOST || 'localhost',
  port: Number(process.env.HOSPITAL_DB_PORT || 3306),
  user: process.env.HOSPITAL_DB_USER || 'hospital_user',
  password: process.env.HOSPITAL_DB_PASSWORD || 'hospital123',
  database: process.env.HOSPITAL_DB_NAME || 'hospital_db',
  waitForConnections: true,
  connectionLimit: 10,
});

export default pool;
