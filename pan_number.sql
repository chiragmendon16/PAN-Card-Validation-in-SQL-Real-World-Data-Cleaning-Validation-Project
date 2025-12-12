--- PAN Number Validation Project using SQL ---

create table stg_pan_numbers_dataset
(
	pan_number		text
);

select * from stg_pan_numbers_dataset;

-- 1. Data Cleaning and Processing Rough  --

-- Identify and handle missing data:
select * from stg_pan_numbers_dataset
where pan_number is null

-- Checking for the duplicates (Distinct Or Group by)--
select pan_number, count(1)
from stg_pan_numbers_dataset
group by pan_number
having count(1)>1;

-- Handle the Spaces --
select * from stg_pan_numbers_dataset
where pan_number <> trim (pan_number);

-- Correct the Letter Case --
select * from stg_pan_numbers_dataset
where pan_number <> upper(pan_number);

---*** Cleaned Pan Numbers ***---

select distinct upper(trim (pan_number)) as pan_number
from stg_pan_numbers_dataset
where pan_number is not null
and trim (pan_number) <> ''

-- 2. PAN Format Validation Rough  --

/* Function to check if the adjacent characters are the same
ZWOVO3987M ==> ZWOVO
*/
create or replace function fn_ch_adj_chars(p_str text)
returns boolean
language plpgsql
as $$
begin
	for i in 1 .. (length (p_str) - 1)
	loop
		if substring(p_str, i, 1) = substring(p_str, i+1, 1)
		then
			return true; -- the character are adjacent
		end if;
	end loop;
	return false; -- none of the character are adjacent to each other were the same
end;
$$

select fn_ch_adj_chars('ZGWDA')

/* Function to check if the sequential characters are used
ABCDE, AXDGE
*/

create or replace function fn_ch_seq_chars(p_str text)
returns boolean
language plpgsql
as $$
begin
	for i in 1 .. (length (p_str) - 1)
	loop
		if ascii(substring(p_str, i+1, 1)) - ascii(substring(p_str, i, 1)) <> 1
		then
			return false; -- the string does not form the sequence
		end if;
	end loop;
	return true; -- the string is forming the sequence
end;
$$

select fn_ch_seq_chars('ABXDE')
/* Regular expression to validate the pattern or structure of the PAN Numbers
-- AAAAA1234A
*/

select *
from stg_pan_numbers_dataset
where pan_number ~ '^[A-Z]{5}[0-9]{4}[A-Z]$'


-- 3.  Categorization - Valid and Invalid PAN  --
create or replace view vw_val_inval_pans
as
with cte_cleaned_pan as
		(select distinct upper(trim (pan_number)) as pan_number
		from stg_pan_numbers_dataset
		where pan_number is not null
		and trim (pan_number) <> ''),

	cte_valid_pans as
		(
		select *
		from cte_cleaned_pan
		where fn_ch_adj_chars(pan_number) = false
		and fn_ch_seq_chars (substring(pan_number, 1,5)) = false
		and fn_ch_seq_chars (substring(pan_number, 6,4)) = false
		and pan_number ~ '^[A-Z]{5}[0-9]{4}[A-Z]$'
		)
select cln.pan_number
, case when vld.pan_number is not null
			then 'Valid PAN'
		else 'InValid PAN'
  end as status
from cte_cleaned_pan cln
left join cte_valid_pans vld on vld.pan_number = cln.pan_number
	
/*
"PIHOQ0368S"	"Valid PAN"
"WOUCP7730E"	"InValid PAN"
*/

select *
from vw_val_inval_pans


--- 4. Summary Report ---

stg_pan_numbers_dataset
vw_val_inval_pans

with cte as
	(select 
		   (select count(*) from stg_pan_numbers_dataset) as total_processed_records
	,      count(*) filter (where status = 'Valid PAN') as total_valid_pans
	,      count(*) filter (where status = 'InValid PAN') as total_invalid_pans
	from vw_val_inval_pans)
select total_processed_records, total_valid_pans, total_invalid_pans
,(total_processed_records - (total_valid_pans + total_invalid_pans)) as total_missing_pans
from cte

