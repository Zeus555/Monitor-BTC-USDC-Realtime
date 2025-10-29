BEGIN TRANSACTION;
	--ELIMINAR LOS NIVELES PREVIOS
	delete from dwd_level;

	--PRIMER NIVEL
	insert into dwd_level(level,ask,datelevel)
	with
		pmax as (select max(ask) as ask from dwd_price)
	select
		1 as level,
		a.ask,
		a.dateinsert
	from 
		dwd_price a, pmax b
	where 
		a.ask=b.ask
	order by 
		a.dateinsert desc
	limit 1;

	--NIVEL INFERIOR 2
	insert into dwd_level(level,ask,datelevel)
	WITH LASTLEVEL AS (select max(level) as mlevel from dwd_level)
	select 
		c.mlevel+1 as level,
		a.ask,
		a.dateinsert
	from dwd_price a, dwd_level b, LASTLEVEL c
	where 
		b.level=c.mlevel
		and a.dateinsert >= b.datelevel
	order by 
		a.ask 
	limit 1;

	--NIVEL SUPERIOR 3
	insert into dwd_level(level,ask,datelevel)
	WITH LASTLEVEL AS (select max(level) as mlevel from dwd_level)
	select 
		c.mlevel+1 as level,
		a.ask,
		a.dateinsert
	from dwd_price a, dwd_level b, LASTLEVEL c
	where 
		b.level=c.mlevel
		and a.dateinsert >= b.datelevel
	order by 
		a.ask DESC
	limit 1;

	--NIVEL INFERIOR 4
	insert into dwd_level(level,ask,datelevel)
	WITH LASTLEVEL AS (select max(level) as mlevel from dwd_level)
	select 
		c.mlevel+1 as level,
		a.ask,
		a.dateinsert
	from dwd_price a, dwd_level b, LASTLEVEL c
	where 
		b.level=c.mlevel
		and a.dateinsert >= b.datelevel
	order by 
		a.ask 
	limit 1;

	--NIVEL SUPERIOR 5
	insert into dwd_level(level,ask,datelevel)
	WITH LASTLEVEL AS (select max(level) as mlevel from dwd_level)
	select 
		c.mlevel+1 as level,
		a.ask,
		a.dateinsert
	from dwd_price a, dwd_level b, LASTLEVEL c
	where 
		b.level=c.mlevel
		and a.dateinsert >= b.datelevel
	order by 
		a.ask DESC
	limit 1;

	--ULTIMO NIVEL 6
	insert into dwd_level(level,ask,datelevel)
	WITH LASTLEVEL AS (select max(level) as mlevel from dwd_level)
	select 
		c.mlevel+1 as level,
		a.ask,
		a.dateinsert
	from dwd_price a, LASTLEVEL c
	order by 
		a.dateinsert DESC
	limit 1;
COMMIT;
