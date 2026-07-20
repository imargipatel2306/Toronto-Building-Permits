## Toronto Building Permits Project – SQL Queries for Data Extraction

USE torontobuildingpermits;

# 1. Total number of Permits 
SELECT COUNT(*) AS total_permits 
FROM Permit;

# 2. List all tables 
SHOW TABLES;

# 3. Permit table 
SELECT * 
FROM Permit;

# 4. Permits
SELECT 
    p.permit_id,
    a.postal,
    p.status_id,
    p.structure_type_id,
    p.est_const_cost
FROM Permit p
JOIN Address a ON p.address_id = a.address_id;

# 5. Permit count by Postal Code
SELECT a.postal, COUNT(p.permit_id) AS permit_count 
FROM Permit p
JOIN Address a ON p.address_id = a.address_id
GROUP BY a.postal
ORDER BY permit_count DESC;

# 6. Permit status by Postal Code
SELECT 
    postal,
    ps.status_name,
    COUNT(*) AS count_status
FROM Permit p
JOIN Address a ON p.address_id = a.address_id
JOIN Permit_Status ps ON p.status_id = ps.status_id
GROUP BY postal, ps.status_name
ORDER BY postal, count_status DESC;

# 7. Approval Rate by Postal Code
SELECT 
    postal,
    COUNT(*) AS total_permits,
    SUM(CASE WHEN ps.status_name = 'Permit Issued' THEN 1 END) AS approved_count,
    (SUM(CASE WHEN ps.status_name = 'Permit Issued' THEN 1 END) / COUNT(*)) * 100 AS approval_rate
FROM Permit p
JOIN Address a ON p.address_id = a.address_id
JOIN Permit_Status ps ON p.status_id = ps.status_id
GROUP BY postal
ORDER BY approval_rate DESC;

# 8. Permits by Zip Code and Category 
SELECT 
	a.postal, 
	pc.category_name, 
    COUNT(*) AS num_permits 
FROM Permit p 
JOIN Permit_Category pcat ON p.permit_id = pcat.permit_id 
JOIN Project_Category pc ON pcat.category_id = pc.category_id 
JOIN Address a ON p.address_id = a.address_id
GROUP BY a.postal, pc.category_name 
ORDER BY a.postal, num_permits DESC;

# 9. Permits by Structure Type 
SELECT 
	st.structure_type_id, 
	st.structure_type_name, 
    COUNT(*) AS count_permits 
FROM Permit p 
JOIN Structure_Type st ON p.structure_type_id = st.structure_type_id 
GROUP BY st.structure_type_name 
ORDER BY count_permits DESC;

# 7. Structure Type vs Permit Status 
SELECT 
	st.structure_type_id, 
    st.structure_type_name, 
    COUNT(*) AS total,
COALESCE(SUM(CASE WHEN ps.status_name = 'Permit Issued' THEN 1 ELSE 0 END), 0) AS approved_count,
	COALESCE((SUM(CASE WHEN ps.status_name = 'Permit Issued' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 0) AS approval_rate
FROM Permit p 
JOIN Structure_Type st ON p.structure_type_id = st.structure_type_id 
JOIN Permit_Status ps ON p.status_id = ps.status_id 
GROUP BY st.structure_type_name
ORDER BY st.structure_type_name, total DESC;