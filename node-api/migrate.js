import pool from './db.js';

async function migrate() {
  try {
    console.log('Running migrations...');
    await pool.query(`ALTER TABLE appointments ADD COLUMN reminder_sent TINYINT NOT NULL DEFAULT 0;`).catch(e => {
        if(e.code !== 'ER_DUP_FIELDNAME') throw e;
    });
    
    await pool.query(`
      CREATE TABLE IF NOT EXISTS patient_documents (
        id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
        patient_id BIGINT NOT NULL,
        uploader_id BIGINT NOT NULL,
        uploader_role VARCHAR(20) NOT NULL DEFAULT 'PATIENT',
        filename VARCHAR(255) NOT NULL,
        filepath VARCHAR(512) NOT NULL,
        uploaded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT fk_doc_patient FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE
      ) ENGINE=InnoDB;
    `);

    await pool.query(`
      CREATE TABLE IF NOT EXISTS prescriptions (
        id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
        appointment_id BIGINT NOT NULL,
        medication VARCHAR(255) NOT NULL,
        dosage VARCHAR(100) NOT NULL,
        instructions TEXT NULL,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT fk_rx_appointment FOREIGN KEY (appointment_id) REFERENCES appointments (id) ON DELETE CASCADE
      ) ENGINE=InnoDB;
    `);

    await pool.query(`
      CREATE TABLE IF NOT EXISTS notifications (
        id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
        user_id BIGINT NOT NULL,
        user_type VARCHAR(20) NOT NULL,
        message TEXT NOT NULL,
        is_read TINYINT NOT NULL DEFAULT 0,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB;
    `);

    console.log('Migrations complete!');
    process.exit(0);
  } catch (err) {
    console.error('Migration failed:', err);
    process.exit(1);
  }
}

migrate();
