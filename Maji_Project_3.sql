##So first, grab the location_id and true_water_source_score columns from auditor_report.

SELECT 
location_id,
true_water_source_score
FROM
auditor_report;

#Now, we join the visits table to the auditor_report table. Make sure to grab subjective_quality_score, record_id and location_id.
SELECT
auditor_report.location_id AS audit_location,
auditor_report.true_water_source_score,
visits.location_id AS visit_location,
visits.record_id
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id;

##Now that we have the record_id for each location, our next step is to retrieve the corresponding scores from the water_quality table. We
##are particularly interested in the subjective_quality_score. To do this, we'll JOIN the visits table and the water_quality table, using the
##record_id as the connecting key.
SELECT
auditor_report.location_id AS audit_location,
auditor_report.true_water_source_score,
visits.location_id AS visit_location,
water_quality.subjective_quality_score,
visits.record_id
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN
water_quality ON water_quality.subjective_quality_score = auditor_report.true_water_source_score;

#It doesn't matter if your columns are in a different format, because we are about to clean this up a bit. Since it is a duplicate, we can drop one of
#the location_id columns. Let's leave record_id and rename the scores to surveyor_score and auditor_score to make it clear which scores
#we're looking at in the results set.
SELECT
auditor_report.location_id AS audit_location,
auditor_report.true_water_source_score AS audit_score,
water_quality.subjective_quality_score AS employee_score,
visits.record_id
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN
water_quality ON water_quality.subjective_quality_score = auditor_report.true_water_source_score;

##Ok, let's analyse! A good starting point is to check if the auditor's and exployees' scores agree. There are many ways to do it. We can have a
##WHERE clause and check if surveyor_score = auditor_score, or we can subtract the two scores and check if the result is 0.
SELECT
auditor_report.location_id AS audit_location,
auditor_report.true_water_source_score AS audit_score,
water_quality.subjective_quality_score AS employee_score,
visits.record_id
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN
water_quality ON water_quality.subjective_quality_score = auditor_report.true_water_source_score
WHERE
auditor_report.true_water_source_score = water_quality.subjective_quality_score
AND
visits.visit_count = 1;

##But that means that 102 records are incorrect. So let's look at those. You can do it by adding one character in the last query!
SELECT
auditor_report.location_id AS audit_location,
auditor_report.true_water_source_score AS auditor_score,
visits.record_id,
water_quality.subjective_quality_score AS empployee_score
FROM
auditor_report
JOIN
visits ON auditor_report.location_id = visits.location_id
JOIN water_quality ON visits.record_id = water_quality.record_id
WHERE
auditor_report.true_water_source_score !=water_quality.subjective_quality_score
AND
visits.visit_count = 1 ;

##So, to do this, we need to grab the type_of_water_source column from the water_source table and call it survey_source, using the
##source_id column to JOIN. Also select the type_of_water_source from the auditor_report table, and call it auditor_source.
SELECT
auditor_report.location_id AS audit_location,
auditor_report.true_water_source_score AS auditor_score,
visits.record_id,
water_quality.subjective_quality_score AS empployee_score,
water_source.type_of_water_source As survey_source,
auditor_report.type_of_water_source AS auditor_source
FROM
auditor_report
JOIN
visits ON auditor_report.location_id = visits.location_id
JOIN water_quality ON visits.record_id = water_quality.record_id
JOIN water_source ON auditor_report.type_of_water_source = water_source.type_of_water_source
WHERE
auditor_report.true_water_source_score !=water_quality.subjective_quality_score
AND
visits.visit_count = 1 ;

#Once you're done, remove the columns and JOIN statement for water_sources again.
SELECT
auditor_report.location_id AS audit_location,
auditor_report.true_water_source_score AS auditor_score,
visits.record_id,
water_quality.subjective_quality_score AS empployee_score
FROM
auditor_report
JOIN
visits ON auditor_report.location_id = visits.location_id
JOIN water_quality ON visits.record_id = water_quality.record_id
WHERE
auditor_report.true_water_source_score !=water_quality.subjective_quality_score
AND
visits.visit_count = 1 ;

##In either case, the employees are the source of the errors, so let's JOIN the assigned_employee_id for all the people on our list from the visits
##table to our query. Remember, our query shows the shows the 102 incorrect records, so when we join the employee data, we can see which
##employees made these incorrect records.
SELECT
auditor_report.location_id AS audit_location,
auditor_report.true_water_source_score AS auditor_score,
visits.record_id,
water_quality.subjective_quality_score AS empployee_score,
employee.assigned_employee_id
FROM
auditor_report
JOIN
visits ON auditor_report.location_id = visits.location_id
JOIN water_quality ON visits.record_id = water_quality.record_id
JOIN employee ON visits.assigned_employee_id = employee.assigned_employee_id
WHERE
auditor_report.true_water_source_score !=water_quality.subjective_quality_score
AND
visits.visit_count = 1 ;

##So now we can link the incorrect records to the employees who recorded them. The ID's don't help us to identify them. We have employees' names
##stored along with their IDs, so let's fetch their names from the employees table instead of the ID's.
SELECT
auditor_report.location_id AS audit_location,
auditor_report.true_water_source_score AS auditor_score,
visits.record_id,
water_quality.subjective_quality_score AS empployee_score,
employee.employee_name
FROM
auditor_report
JOIN
visits ON auditor_report.location_id = visits.location_id
JOIN water_quality ON visits.record_id = water_quality.record_id
JOIN employee ON visits.assigned_employee_id = employee.assigned_employee_id
WHERE
auditor_report.true_water_source_score !=water_quality.subjective_quality_score
AND
visits.visit_count = 1 ;

##Well this query is massive and complex, so maybe it is a good idea to save this as a CTE, so when we do more analysis, we can just call that CTE
##like it was a table. Call it something like Incorrect_records. Once you are done, check if this query SELECT * FROM Incorrect_records, gets
##the same table back.
WITH Incorrect_records AS(
SELECT
auditor_report.location_id AS audit_location,
auditor_report.true_water_source_score AS auditor_score,
visits.record_id,
water_quality.subjective_quality_score AS employee_score,
employee.employee_name,
auditor_report.statements
FROM
auditor_report
JOIN
visits ON auditor_report.location_id = visits.location_id
JOIN water_quality ON visits.record_id = water_quality.record_id
JOIN employee ON visits.assigned_employee_id = employee.assigned_employee_id
WHERE
auditor_report.true_water_source_score !=water_quality.subjective_quality_score
AND
visits.visit_count = 1)
SELECT  *
FROM
incorrect_records;
#Let's first get a unique list of employees from this table. Think back to the start of your SQL journey to answer this one. I got 17 employees.#
SELECT  DISTINCT 
employee_name
FROM
incorrect_records;
#Next, let's try to calculate how many mistakes each employee made. So basically we want to count how many times their name is in
#Incorrect_records list, and then group them by name, right?
SELECT  
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
incorrect_records
GROUP BY employee_name
ORDER BY number_of_mistakes DESC;

# We have to first calculate the number of times someone's name comes up. (we just did that in the previous query). Let's call it error_count.




#Let's first get a unique list of employees from this table. Think back to the start of your SQL journey to answer this one. I got 17 employees.#

#Next, let's try to calculate how many mistakes each employee made. So basically we want to count how many times their name is in
#Incorrect_records list, and then group them by name, right?

WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records


GROUP BY
employee_name)
-- This CTE SELECTS the employees with above−average mistakes
SELECT
employee_name,
number_of_mistakes
FROM
error_count
WHERE
number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count);
##Converting the records cte to view
CREATE VIEW Incorrect_records AS(
SELECT
auditor_report.location_id AS audit_location,
auditor_report.true_water_source_score AS auditor_score,
visits.record_id,
water_quality.subjective_quality_score AS employee_score,
employee.employee_name,
auditor_report.statements
FROM
auditor_report
JOIN
visits ON auditor_report.location_id = visits.location_id
JOIN water_quality ON visits.record_id = water_quality.record_id
JOIN employee ON visits.assigned_employee_id = employee.assigned_employee_id
WHERE
auditor_report.true_water_source_score !=water_quality.subjective_quality_score
AND
visits.visit_count = 1);
SELECT  *
FROM
incorrect_records;

##Next, we convert the query error_count, we made earlier, into a CTE. Test it to make sure it gives the same result again, using SELECT * FROM
##Incorrect_records. On large queries like this, it is better to build the query, and test each step, because fixing errors becomes harder as the
##query grows.
WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
GROUP BY
employee_name),
suspect_list AS (-- This CTE SELECTS the employees with above−average mistakes
SELECT
employee_name,
number_of_mistakes
FROM
error_count
WHERE
number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count))

SELECT
employee_name,
location_id,
statements
FROM
Incorrect_records
WHERE
employee_name in (SELECT employee_name FROM suspect_list)
AND
statements LIKE "%cash%";



##Check if there are any employees in the Incorrect_records table with statements mentioning "cash" that are not in our suspect list. This should
##be as simple as adding one word.