-- SQLite Face Recognition Database Schema

-- Table for Known Faces
CREATE TABLE known_faces (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    image_path TEXT NOT NULL,
    face_encoding BLOB, -- Store face encoding data
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Table for Unknown Faces
CREATE TABLE unknown_faces (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    image_path TEXT NOT NULL,
    detected_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

-- Table for Recognition Logs
CREATE TABLE recognition_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    known_face_id INTEGER,
    image_path TEXT NOT NULL,
    recognition_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    confidence_score REAL,
    FOREIGN KEY (known_face_id) REFERENCES known_faces(id)
);

-- Create indexes for better performance
CREATE INDEX idx_known_faces_name ON known_faces(name);
CREATE INDEX idx_unknown_faces_detected_at ON unknown_faces(detected_at);
CREATE INDEX idx_recognition_logs_time ON recognition_logs(recognition_time);

-- Create trigger to update last_updated_at for known_faces
CREATE TRIGGER update_known_faces_timestamp
AFTER UPDATE ON known_faces
BEGIN
    UPDATE known_faces SET last_updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

-- Create view to get recent recognition summary
CREATE VIEW v_recognition_summary AS
SELECT 
    rl.recognition_time,
    kf.name,
    rl.image_path,
    rl.confidence_score
FROM recognition_logs rl
LEFT JOIN known_faces kf ON rl.known_face_id = kf.id
WHERE rl.recognition_time >= datetime('now', '-7 days')
ORDER BY rl.recognition_time DESC;
