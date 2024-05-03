alter table properties rename weight to atomic_mass;
alter table properties rename melting_point to melting_point_celsius;
alter table properties rename boiling_point to boiling_point_celsius;

alter table properties 
alter column melting_point_celsius SET NOT NULL,
alter column boiling_point_celsius SET NOT NULL;


CREATE UNIQUE INDEX CONCURRENTLY elements_symbol 
ON elements (symbol);

CREATE UNIQUE INDEX CONCURRENTLY elements_name
ON elements (name);

ALTER TABLE elements 
ADD CONSTRAINT unique_elements_symbol 
UNIQUE USING INDEX elements_symbol;

ALTER TABLE elements 
ADD CONSTRAINT unique_elements_name 
UNIQUE USING INDEX elements_name;

alter table elements 
alter column symbol SET NOT NULL,
alter column name SET NOT NULL;

ALTER TABLE properties 
ADD CONSTRAINT fk_atomic_number
FOREIGN KEY (atomic_number) 
REFERENCES elements (atomic_number);


CREATE TABLE types(
  type_id INT GENERATED ALWAYS AS IDENTITY,
  type VARCHAR(30) NOT NULL,
  PRIMARY KEY(type_id)
);

INSERT INTO types(type)
select distinct type from properties;

ALTER TABLE properties
ADD COLUMN type_id INT;

UPDATE properties p
SET type_id = (SELECT type_id FROM types t WHERE t.type = p.type);

alter table properties 
alter column type_id SET NOT NULL;

ALTER TABLE properties 
ADD CONSTRAINT fk_type_id
FOREIGN KEY (type_id) 
REFERENCES types (type_id);

update properties set atomic_mass = 15.999 where atomic_number = 8;

alter table properties 
alter column atomic_mass TYPE NUMERIC;

update properties set atomic_mass = 1.008 where atomic_number = 1;
update properties set atomic_mass = 4.0026 where atomic_number = 2;
update properties set atomic_mass = 6.94 where atomic_number = 3;
update properties set atomic_mass = 9.0122 where atomic_number = 4;
update properties set atomic_mass = 10.81 where atomic_number = 5;
update properties set atomic_mass = 12.011 where atomic_number = 6;
update properties set atomic_mass = 14.007 where atomic_number = 7;

update properties set atomic_mass = 1 where atomic_number = 1000;

insert into elements(atomic_number, symbol, name)
values
(9, 'F', 'Fluorine')
,(10, 'Ne', 'Neon');

insert into properties(atomic_number, type, atomic_mass, melting_point_celsius, boiling_point_celsius, type_id)
values
(9, 'nonmetal', 18.998, -220, -188.1, 3)
,(10, 'nonmetal', 20.18, -248.6, -246.1, 3);

alter table properties 
drop column type;

delete from properties where atomic_number = 1000;
delete from elements where atomic_number = 1000;

select e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
from elements e
inner join properties p on p.atomic_number = e.atomic_number
inner join types t on t.type_id = p.type_id
where e.atomic_number = 1;
