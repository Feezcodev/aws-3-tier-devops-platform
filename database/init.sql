CREATE DATABASE IF NOT EXISTS app_db;
USE app_db;

CREATE TABLE IF NOT EXISTS items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data for local development
INSERT INTO items (name, description) VALUES 
('DevOps Pipeline', 'Automated CI/CD using GitHub Actions'),
('Kubernetes Cluster', 'Local orchestration via Minikube'),
('Cloud Infrastructure', 'AWS EKS and Terraform provisioning');