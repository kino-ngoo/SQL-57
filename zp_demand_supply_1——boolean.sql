USE [trxDB]
GO

/****** Object:  StoredProcedure [dbo].[zp_demand_supply_1]    Script Date: 01/19/2018 04:40:39 PM  ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- GRANT EXEC ON zp_demand_supply_1 TO PUBLIC

ALTER PROCEDURE [dbo].[zp_demand_supply_1] ( @option tinyint = 1 ,@hr int = 24 ,@stage varchar(10) = 'S1' )
AS  

/*
declare @option tinyint ,@stage varchar(10)
select  @option = 1

DECLARE @hr int 

SELECT  @hr = 24
SELECT  @stage = 'S1'

SELECT  @hr = 72
SELECT  @stage = 'S3'

SELECT  @hr = 72
SELECT  @stage = 'S4'


--select  @option = 5

*/

/*
exec zp_demand_supply_1 1 ,24 ,'S1'
exec zp_demand_supply_1 1 ,48 ,'S2'

exec zp_demand_supply_1 2  -- 產生需求計算 Table -- zone_transfer

exec zp_demand_supply_1 5  -- 產生 zone 轉倉單 (24hr)
	select * from zone_supply where stage = 'T1'
	select * from zone_demand where stage = 'T1'

exec zp_demand_supply_1 1 ,72 ,'S3' -- 轉倉庫含 A1 計算


select * from tab_inv_distri
where part_no = '102000000092A'
and stage = 'S1'
order by 1

   

select part_no,dt_request,zone_name,balance_d1,status_d1,balance_d2,status_d2
from zone_transfer
where part_no = '102000000208A'

select *
	from tab_inv_distri 
where category in ('9-9.Balance')
and stage = 'S1'
and part_no = '102000000208A'
	

*/

SET NOCOUNT ON  

declare @loop_count int ,@loop_index int ,@part_no varchar(50) ,@zone_name varchar(50)

IF  @option = 2
	begin

		-- select * from tab_inv_distri

		if object_id('tempdb.dbo.#t1') is not null drop table #t1
		if object_id('tempdb.dbo.#t2') is not null drop table #t2

		create table #t1 ( zone_name varchar(50) ,part_no varchar(50) ,id_loop int )
		create table #t2 ( zone_name varchar(50) ,part_no varchar(50) ,id_loop int ,balance decimal(18,0) ,status varchar(50) ,dt_request datetime )

		insert #t1 ( zone_name ,part_no ,id_loop )
		select zone_name,part_no,id_loop=max(id_loop)
		from tab_inv_distri where --part_no = '102000000163H' 
		--and category in ('1-1.Stock','2-1.Demand','9-9.Balance')
		category in ('9-9.Balance')
		and stage = 'S1'
		group by zone_name,part_no

		insert #t2 ( zone_name ,part_no ,balance ,status ,dt_request)
		select a.zone_name,a.part_no,b.balance,b.status,b.dt_request
		from #t1 a ,tab_inv_distri b
		where a.id_loop = b.id_loop
		and category in ('9-9.Balance')
		and a.part_no = b.part_no
		and a.zone_name = b.zone_name
		and stage = 'S1'
		
		truncate table zone_transfer

		insert zone_transfer ( zone_name,part_no,dt_request,balance_d1,status_d1 ,balance_d2 ,status_d2 ,balance_A1 ,status_A1 )
		select zone_name,part_no,dt_request,balance,status,0,'',0,''
		from #t2

		truncate table #t1
		truncate table #t2

		insert #t1 ( zone_name ,part_no ,id_loop )
		select zone_name,part_no,id_loop=max(id_loop)
		from tab_inv_distri where --part_no = '102000000163H' 
		--and category in ('1-1.Stock','2-1.Demand','9-9.Balance')
		category in ('9-9.Balance')
		and stage = 'S2'
		group by zone_name,part_no

		insert #t2 ( zone_name ,part_no ,balance ,status ,dt_request )
		select a.zone_name,a.part_no,b.balance,b.status,b.dt_request
		from #t1 a ,tab_inv_distri b
		where a.id_loop = b.id_loop
		and category in ('9-9.Balance')
		and a.part_no = b.part_no
		and a.zone_name = b.zone_name
		and stage = 'S2'
	
		update a set balance_d2 = b.balance
					,status_d2  = b.status
			from zone_transfer a ,#t2 b
				where a.zone_name = b.zone_name
					and a.part_no = b.part_no

		update a set balance_A1 = b.qty_onhand
					,status_A1  = case when b.qty_onhand = 0 then 'Safe'
									   when b.qty_onhand > 0 then 'Excess'
									   else 'Shortage' end
			from zone_transfer a ,icidf b with (nolock) ,icim_comp c with (nolock) ,icstockroom d with (nolock)
				where c.id_icim_comp = b.id_icim_comp
					and b.id_icstockroom = d.id_icstockroom
					and a.part_no = c.part_no
					and d.room_code = 'A1'
					and c.id_admcomp = 10

		-- select * from zone_transfer

		return

	end

if  @option = 3
	begin
		
		select part_no,zone_name,balance_d1,status_d1,balance_d2,status_d2
			  ,balance_A1 ,status_A1 ,dt_generate = dt_create
		from zone_transfer

		return
	end

if  @option = 31
	begin
		select * from tab_inv_distri -- where stage = 'S3'

		-- delete a from tab_inv_distri a where stage = 'S3'

		return

	end

if  @option = 5
	begin

		/*
		CREATE TABLE zone_demand ( id_zone_demand int identity(1,1) ,part_no varchar(50) ,dt_request datetime ,qty_request decimal(18,0) ,id_reference int ,ref_no varchar(50) ,category varchar(50) ,sort varchar(50) ,stat_active tinyint
						  ,stage varchar(50) )

		CREATE TABLE zone_supply ( id_zone_supply int identity(1,1) ,part_no varchar(50) ,dt_supply datetime ,qty_supply decimal(18,0) ,id_reference int ,ref_no varchar(50) ,category varchar(50) ,sort varchar(50) ,stat_active tinyint
						  ,stage varchar(50) ) 

		*/

		if object_id('tempdb.dbo.#tmp_zone_demand') is not null DROP TABLE #tmp_zone_demand
		CREATE TABLE #tmp_zone_demand ( id_zone_demand int identity(1,1) ,part_no varchar(50) ,dt_request datetime ,qty_request decimal(18,0) ,id_reference int ,ref_no varchar(50) ,category varchar(50) ,sort varchar(50) ,stat_active tinyint
						  ,stage varchar(50) )
		if object_id('tempdb.dbo.#tmp_zone_supply') is not null DROP TABLE #tmp_zone_supply
		CREATE TABLE #tmp_zone_supply ( id_zone_supply int identity(1,1) ,part_no varchar(50) ,dt_supply datetime ,qty_supply decimal(18,0) ,id_reference int ,ref_no varchar(50) ,category varchar(50) ,sort varchar(50) ,stat_active tinyint
						  ,stage varchar(50) ) 
		
		declare @qty_shortage decimal(18,0) ,@zone_name_shortage varchar(50)
		declare @qty_excess decimal(18,0) ,@zone_name_excess varchar(50) ,@qty_balance decimal(18,0) ,@qty decimal(18,0)
		declare @qty_transfer decimal(18,0) ,@dt_request datetime

		declare @loop_index_1 int ,@loop_count_1 int

		if object_id('tempdb.dbo.#tmp_part_no_only') is not null DROP TABLE #tmp_part_no_only
		select part_no,cnt=count(*) into #tmp_part_no_only from zone_transfer group by part_no having count(*) = 1

		-- select * from #tmp_part_no_only
		
		if object_id('tempdb.dbo.#tmp_part_no1') is not null DROP TABLE #tmp_part_no1
		create table #tmp_part_no1( id_loop int identity(1,1) ,part_no varchar(50) )
		insert #tmp_part_no1 ( part_no ) 
			select distinct part_no from zone_transfer a where status_d1 = 'Shortage'
				and not exists ( select 1 from #tmp_part_no_only b where a.part_no = b.part_no )
			order by 1

		if object_id('tempdb.dbo.#tmp_part_no2') is not null DROP TABLE #tmp_part_no2
		create table #tmp_part_no2( id_loop int identity(1,1) ,part_no varchar(50) )
		insert #tmp_part_no2 ( part_no ) 
			select distinct a.part_no from #tmp_part_no1 a ,zone_transfer b where a.part_no = b.part_no
				and status_d2 = 'Excess'
            order by 1

		if object_id('tempdb.dbo.#tmp_part_no_s') is not null DROP TABLE #tmp_part_no_s
		create table #tmp_part_no_s( id_loop int identity(1,1) ,zone_name varchar(50) ,part_no varchar(50) ,balance decimal(18,0) ,dt_request datetime )
		if object_id('tempdb.dbo.#tmp_part_no_e') is not null DROP TABLE #tmp_part_no_e
		create table #tmp_part_no_e( id_loop int identity(1,1) ,zone_name varchar(50) ,part_no varchar(50) ,balance decimal(18,0) ,dt_request datetime )

		-- select * from #tmp_part_no2

		SELECT @loop_count = COUNT(*) FROM #tmp_part_no2 
		SELECT @loop_index = 1 
		WHILE  @loop_count >= @loop_index  
	  		BEGIN 
				SELECT @part_no = part_no
					from #tmp_part_no2 a
					WHERE a.id_loop = @loop_index

				-- SELECT @part_no

				truncate table #tmp_part_no_s
				truncate table #tmp_part_no_e

				-- select * from zone_transfer

				insert #tmp_part_no_s ( zone_name ,part_no ,balance ,dt_request )
				select zone_name,part_no,balance_d1,dt_request from zone_transfer a where status_d1 = 'Shortage' and part_no = @part_no
				insert #tmp_part_no_e ( zone_name ,part_no ,balance )
				select zone_name,part_no,balance_d2 from zone_transfer a where status_d2 = 'Excess'   and part_no = @part_no

				select @qty_shortage = balance ,@zone_name_shortage = zone_name ,@dt_request = dt_request 
					from #tmp_part_no_s 
				
				-- select * from #tmp_part_no_e

				select @qty_balance  = 0
				select @qty_transfer = @qty_shortage
										
				SELECT @loop_count_1 = COUNT(*) FROM #tmp_part_no_e 
				SELECT @loop_index_1 = 1 

				WHILE  @loop_count_1 >= @loop_index_1  
	  				BEGIN 
						SELECT @zone_name_excess = a.zone_name	
							  ,@qty_excess   = a.balance
							from #tmp_part_no_e a
							WHERE a.id_loop = @loop_index_1

						if   @qty_transfer < 0
							 begin
							    SELECT @qty = case when @qty_excess + @qty_transfer > 0 then @qty_transfer * (-1)
												else @qty_excess  end

								if     @qty > 0  -- 從 excess 轉倉至 shortage 倉
									   begin

											-- select '轉倉 from ', @zone_name_excess ,@qty * (-1)

											insert #tmp_zone_demand ( part_no ,dt_request ,qty_request ,id_reference ,ref_no ,category ,sort ,stat_active ,stage )
											select part_no = @part_no
												  ,dt_request = @dt_request
												  ,qty_request = @qty * (-1)
												  ,id_reference = 0
												  ,ref_no = @zone_name_excess
												  ,category = '2-5.Demand'
												  ,sort = ''
												  ,stat_active = 1
												  ,stage = 'T1'		
									   end

								-- SELECT @qty_excess ,@zone_name_excess ,@qty_shortage ,@zone_name_shortage

							    SELECT @qty_balance = @qty_balance + @qty

							 end

						SELECT @qty_transfer = @qty_transfer + @qty_balance

						if   @qty_shortage >= 0
						     break

						SELECT @loop_index_1 = @loop_index_1 + 1  

					END

					IF  @qty_balance  >  0  -- + supply
						begin
							--select 'To:' ,@zone_name_shortage ,@qty_balance	
							insert #tmp_zone_supply ( part_no ,dt_supply ,qty_supply ,id_reference ,ref_no ,category ,sort ,stat_active ,stage )
							select part_no = @part_no
									,dt_request = @dt_request
									,qty_request = @qty_balance
									,id_reference = 0
									,ref_no = @zone_name_shortage
									,category = '1-5.Stock'
									,sort = ''
									,stat_active = 1
									,stage = 'T1'		

						end

				SELECT @loop_index = @loop_index + 1  
			
			END

			delete a from zone_demand a where stage = 'T1'
			delete a from zone_supply a where stage = 'T1'

			insert zone_demand ( part_no ,dt_request ,qty_request ,id_reference ,ref_no ,category ,sort ,stat_active ,stage )
				   select part_no ,dt_request ,qty_request ,id_reference ,ref_no ,category ,sort ,stat_active ,stage
				   from #tmp_zone_demand
			insert zone_supply ( part_no ,dt_supply  ,qty_supply ,id_reference ,ref_no ,category  ,sort ,stat_active ,stage )
				   select part_no ,dt_supply  ,qty_supply ,id_reference ,ref_no ,category  ,sort ,stat_active ,stage
				   from #tmp_zone_supply

			-- select * from #tmp_zone_demand a where part_no = '2041044KH110E' -- not exists ( select 1 from #tmp_zone_supply b where a.part_no = b.part_no )
			-- select * from #tmp_zone_supply a where part_no = '2041044KH110E'
			/*
				select * from zone_supply
				select * from zone_demand
				

			*/

		return

	end

DECLARE @ll_go tinyint
-- DECLARE @zone_name varchar(50)

if object_id('tempdb.dbo.#tmp_supply_demand') is not null drop table #tmp_supply_demand
CREATE TABLE #tmp_supply_demand ( id_loop int identity(1,1) ,part_no varchar(50) ,dt_request datetime ,qty_request decimal(18,0) ,id_reference int ,category varchar(50) ,qty_lot decimal(18,0) ,balance decimal(18,0)
								   ,stat_active tinyint ,dt_supply datetime ,category_bk varchar(50) ,balance_bk decimal(18,0) ,source_from varchar(50) ,qty_po_supply decimal(18,0) ,qty_from decimal(18,0) ,date_from datetime ,id int ,id_loop_d int ,id_loop_s int ,sort varchar(50)
								   ,dt_request2 datetime )
/*
if object_id('tempdb.dbo.#tmp_demand') is not null drop table #tmp_demand
CREATE TABLE #tmp_demand ( id_loop int identity(1,1) ,part_no varchar(50) ,dt_request datetime ,qty_request decimal(18,0) ,id_reference int ,category varchar(50) ,qty_lot decimal(18,0) ,sort varchar(50) ,ref_no varchar(50) )

if object_id('tempdb.dbo.#tmp_supply') is not null drop table #tmp_supply
CREATE TABLE #tmp_supply ( id_loop int identity(1,1) ,part_no varchar(50) ,dt_request datetime ,qty_request decimal(18,0) ,id_reference int ,category varchar(50) ,qty_lot decimal(18,0) ,balance decimal(18,0)
								   ,stat_active tinyint ,dt_supply datetime ,category_bk varchar(50) ,balance_bk decimal(18,0) ,source_from varchar(50) ,qty_po_supply decimal(18,0) ,qty_from decimal(18,0) ,date_from datetime ,sort varchar(50) ,ref_no varchar(50) )
*/
if object_id('tempdb.dbo.#tmp_demand') is not null drop table #tmp_demand
CREATE TABLE #tmp_demand ( id_loop int identity(1,1) ,part_no varchar(50) ,dt_request datetime ,qty_request decimal(18,0) ,id_reference int ,category varchar(50) ,qty_lot decimal(18,0) ,sort varchar(50) ,balance decimal(18,0) ,id_loop_s int ,stat_active tinyint ,ref_no varchar(50) 
						  ,dt_request2 datetime )

if object_id('tempdb.dbo.#tmp_supply') is not null drop table #tmp_supply
CREATE TABLE #tmp_supply ( id_loop int identity(1,1) ,part_no varchar(50) ,dt_request datetime ,qty_request decimal(18,0) ,id_reference int ,category varchar(50) ,qty_lot decimal(18,0) ,balance decimal(18,0)
								   ,stat_active tinyint ,dt_supply datetime ,category_bk varchar(50) ,balance_bk decimal(18,0) ,source_from varchar(50) ,qty_po_supply decimal(18,0) ,qty_from decimal(18,0) ,date_from datetime ,sort varchar(50) ,id_loop_d int ,stat_upd int ,ref_no varchar(50)
								   ,dt_request2 datetime )

if object_id('tempdb.dbo.#tmp_supply_demand_final') is not null drop table #tmp_supply_demand_final
CREATE TABLE #tmp_supply_demand_final ( id_loop int ,part_no varchar(50) ,dt_request datetime ,qty_request decimal(18,0) ,id_reference int ,category varchar(50) ,qty_lot decimal(18,0) ,balance decimal(18,0)
							     ,stat_active tinyint ,dt_supply datetime ,category_bk varchar(50) ,balance_bk decimal(18,0) ,source_from varchar(50) ,qty_po_supply decimal(18,0) ,qty_from decimal(18,0) ,date_from datetime ,id int ,id_loop_d int ,id_loop_s int 
								 ,process_no varchar(50) ,room_code varchar(50) 
								 ,zone_name varchar(50) ,status varchar(50) ,balance_last decimal(18,0) ,stat_roll tinyint ,part_property varchar(50) ,dt_request2 datetime 
								 ,amount_request decimal(18,0) )


/*
insert zone_demand ( part_no ,dt_request ,qty_request ,id_reference ,ref_no ,category ,sort ,stat_active ,stage )
		select part_no ,dt_request ,qty_request ,id_reference ,ref_no ,category ,sort ,stat_active ,stage
		from #tmp_zone_demand
insert zone_supply ( part_no ,dt_supply  ,qty_supply ,id_reference ,ref_no ,category  ,sort ,stat_active ,stage )
		select part_no ,dt_supply  ,qty_supply ,id_reference ,ref_no ,category  ,sort ,stat_active ,stage
		from #tmp_zone_supply

insert zone_demand ( part_no ,dt_request ,qty_request ,id_reference ,ref_no ,category ,sort ,stat_active ,stage )
select part_no      = b.part_no
	  ,dt_request   = a.time_from
	  ,qty_request  = (b.qty_pcprocess-b.qty_issue_stock+b.qty_return-b.qty_cutoff-b.qty_repl)
	  ,id_reference = b.id_pcprocessd
	  ,ref_no       = d.room_code
	  ,category     = '2-1.Demand'
	  ,sort         = ''
	  ,stat_active  = 1
	  ,stage        = 'S3'

a.id_pcprocess,a.time_from,qty_apply=(b.qty_pcprocess-b.qty_issue_stock+b.qty_return-b.qty_cutoff-b.qty_repl)
	,d.room_code,b.id_icim_comp,c.zone_name ,a.time_from
from pcprocess a with (nolock) ,pcprocessd b with (nolock) ,admfacility_line c(nolock)
	,icstockroom d with (nolock),wo_header e with (nolock) ,icim_manufacture f(nolock)
	,icim_comp g with (nolock)
	where a.id_pcprocess = b.id_pcprocess
		and a.id_wo_header = e.id_wo_header
		and a.stat_pcprocess >= 46 and a.stat_pcprocess <= 52
		and a.stat_void = 0
		and b.stat_void = 0
		and ( b.qty_pcprocess-b.qty_issue_stock+b.qty_return-b.qty_cutoff-b.qty_repl ) > 0
		-- and datediff(day ,a.time_from ,dateadd(day , 1, getdate() ) ) >= -1 -- 0
		and datediff(hour ,getdate(),a.time_from ) <= @hr
		and a.id_admfacility_line = c.id_admfacility_line
		and c.id_icstockroom_buffer_issue = d.id_icstockroom
		and substring(a.process_no,1,2) = 'S-'
		and e.wo_no not like 'D%'
		and a.stat_import = 1
		and b.id_icim_comp = f.id_icim_comp
		and f.qty_perset_allocate > 1
		and b.id_icim_comp = g.id_icim_comp
		and g.goods_id in (2)

*/

-- return

if object_id('tempdb.dbo.#tmp_demand_d1') is not null drop table #tmp_demand_d1
create table #tmp_demand_d1 ( id_pcprocess int ,time_from datetime ,qty_apply decimal(18,0)
							 ,room_code varchar(50) ,id_icim_comp int ,zone_name varchar(50) ,dt_request2 datetime ,id_reference int ,ref_no varchar(50) )

if      @stage in ('S4')
	    select 1

if      @stage in ('S1','S2','S3')
		begin

			insert #tmp_demand_d1 ( id_pcprocess ,time_from ,qty_apply 
							 ,room_code ,id_icim_comp ,zone_name ,dt_request2 ,id_reference ,ref_no )
			select a.id_pcprocess,a.time_from,qty_apply=(b.qty_pcprocess-b.qty_issue_stock+b.qty_return-b.qty_cutoff-b.qty_repl)
				,d.room_code,b.id_icim_comp,c.zone_name ,a.time_from ,id_reference = b.id_pcprocessd ,ref_no = d.room_code
			from pcprocess a with (nolock) ,pcprocessd b with (nolock) ,admfacility_line c(nolock)
				,icstockroom d with (nolock),wo_header e with (nolock) ,icim_manufacture f(nolock)
				,icim_comp g with (nolock)
				where a.id_pcprocess = b.id_pcprocess
					and a.id_wo_header = e.id_wo_header
					and a.stat_pcprocess >= 46 and a.stat_pcprocess <= 52
					and a.stat_void = 0
					and b.stat_void = 0
					and ( b.qty_pcprocess-b.qty_issue_stock+b.qty_return-b.qty_cutoff-b.qty_repl ) > 0
					-- and datediff(day ,a.time_from ,dateadd(day , 1, getdate() ) ) >= -1 -- 0
					and datediff(hour ,getdate(),a.time_from ) <= @hr
					and a.id_admfacility_line = c.id_admfacility_line
					and c.id_icstockroom_buffer_issue = d.id_icstockroom
					and substring(a.process_no,1,2) = 'S-'
					and e.wo_no not like 'D%'
					and a.stat_import = 1
					and b.id_icim_comp = f.id_icim_comp
					and f.qty_perset_allocate > 1
					and b.id_icim_comp = g.id_icim_comp
					and g.goods_id in (2)

			delete a from zone_demand a where stage = @stage

			insert zone_demand ( part_no ,dt_request ,qty_request ,id_reference ,ref_no ,category ,sort ,stat_active ,stage )
			select part_no      = b.part_no
				  ,dt_request   = a.dt_request2
				  ,qty_request  = a.qty_apply
				  ,id_reference = a.id_reference
				  ,ref_no       = a.ref_no
				  ,category     = '2-1.Demand'
				  ,sort         = ''
				  ,stat_active  = 1
				  ,stage        = @stage
			from #tmp_demand_d1 a ,icim_comp b with (nolock)
			where a.id_icim_comp = b.id_icim_comp

			-- select * from zone_demand where stage = 'S3'

		end

return


/*
if object_id('tempdb.dbo.#tmp_demand_d1') is not null drop table #tmp_demand_d1
create table #tmp_demand_d1 ( id_pcprocess int ,time_from datetime ,qty_apply decimal(18,0)
							 ,room_code varchar(50) ,id_icim_comp int ,zone_name varchar(50) ,dt_request2 datetime )
insert #tmp_demand_d1 ( id_pcprocess ,time_from ,qty_apply 
							 ,room_code ,id_icim_comp ,zone_name ,dt_request2 )
select a.id_pcprocess,a.time_from,qty_apply=(b.qty_pcprocess-b.qty_issue_stock+b.qty_return-b.qty_cutoff-b.qty_repl)
	,d.room_code,b.id_icim_comp,c.zone_name ,a.time_from
from pcprocess a with (nolock) ,pcprocessd b with (nolock) ,admfacility_line c(nolock)
	,icstockroom d with (nolock),wo_header e with (nolock) ,icim_manufacture f(nolock)
	,icim_comp g with (nolock)
	where a.id_pcprocess = b.id_pcprocess
		and a.id_wo_header = e.id_wo_header
		and a.stat_pcprocess >= 46 and a.stat_pcprocess <= 52
		and a.stat_void = 0
		and b.stat_void = 0
		and ( b.qty_pcprocess-b.qty_issue_stock+b.qty_return-b.qty_cutoff-b.qty_repl ) > 0
		-- and datediff(day ,a.time_from ,dateadd(day , 1, getdate() ) ) >= -1 -- 0
		and datediff(hour ,getdate(),a.time_from ) <= @hr
		and a.id_admfacility_line = c.id_admfacility_line
		and c.id_icstockroom_buffer_issue = d.id_icstockroom
		and substring(a.process_no,1,2) = 'S-'
		and e.wo_no not like 'D%'
		and a.stat_import = 1
		and b.id_icim_comp = f.id_icim_comp
		and f.qty_perset_allocate > 1
		and b.id_icim_comp = g.id_icim_comp
		and g.goods_id in (2)
*/		
		-- select id_icim_comp,* from pcprocessd
		-- select id_icim_comp,* from icim_comp

update a set zone_name = 'Not Define'
	from #tmp_demand_d1 a
		where a.zone_name is null

if object_id('tempdb.dbo.#tmp_zone_info') is not null drop table #tmp_zone_info
select a.zone_code ,a.zone_name 
			   ,lineside.id_icstockroom
			   ,lineside.room_code
               ,lineside.room_name
               ,in_id_icstockroom = line_intransit.id_icstockroom
               ,in_room_code = line_intransit.room_code
			   ,in_room_name = line_intransit.room_name 
			   ,stat_active  = convert(tinyint,0)
into #tmp_zone_info              
from admfacility_zone a 
	 left join icstockroom lineside (nolock) on a.id_icstockroom_lineside = lineside.id_icstockroom 
     left join icstockroom line_intransit (nolock) on a.id_icstockroom_line_intransit = line_intransit.id_icstockroom 
     ,admfacility b
where a.id_admfacility = b.id_admfacility 
	AND a.zone_category IN ('STOCK', 'FACTORY')

-- select * from #tmp_zone_info

IF   @stage IN ('S1','S2')
	 UPDATE a set stat_active = 1 from #tmp_zone_info a where a.zone_code in ('A1FWH','C1FWH','C2FWH','E1FWH')

-- select * from #tmp_zone_info

-- return

if object_id('tempdb.dbo.#tmp_demand_d2') is not null drop table #tmp_demand_d2
create table #tmp_demand_d2 ( id_loop int identity(1,1) ,zone_name varchar(50) ,room_code varchar(50) )
insert #tmp_demand_d2 ( zone_name ,room_code )
select distinct zone_code ,room_code from #tmp_zone_info where stat_active = 1
--select distinct zone_name,room_code from #tmp_demand_d1 order by 1

if object_id('tempdb.dbo.#tmp_demand_d21') is not null drop table #tmp_demand_d21
create table #tmp_demand_d21 ( id_loop int identity(1,1) ,zone_code varchar(50) ,room_code varchar(50) ,seq int )

insert #tmp_demand_d21( zone_code ,room_code ,seq )
select zone_code ,room_code ,2    from #tmp_zone_info where stat_active = 1
insert #tmp_demand_d21( zone_code ,room_code ,seq )
select zone_code ,in_room_code ,1 from #tmp_zone_info where stat_active = 1

-- select * from #tmp_demand_d21 

if object_id('tempdb.dbo.#tmp_demand_d5') is not null drop table #tmp_demand_d5
create table #tmp_demand_d5 ( id_loop int identity(1,1) ,zone_name varchar(50) ,room_code varchar(50) ,seq int )
insert #tmp_demand_d5 ( zone_name ,room_code ,seq )
select distinct zone_code,room_code ,seq from #tmp_demand_d21 order by seq

-- select * from #tmp_demand_d2
-- select * from #tmp_demand_d5

insert #tmp_demand_d5 ( zone_name ,room_code ,seq )
select zone_name ,room_code ,0 from #tmp_demand_d2 a
where not exists ( select 1 from #tmp_demand_d5 b where a.zone_name = b.zone_name and a.room_code = b.room_code )

-- return

/*
AC ,A ,K

SELECT * FROM #tmp_demand_d1
SELECT * FROM #tmp_demand_d2

*/

--select distinct zone_name,room_code from #tmp_demand_d1 order by 1

-- declare @loop_count int ,@loop_index int

if object_id('tempdb.dbo.#tmp_demand_d3') is not null drop table #tmp_demand_d3
create table #tmp_demand_d3 ( id_loop int identity(1,1) ,zone_name varchar(50) ,room_code varchar(50) )
insert #tmp_demand_d3 ( zone_name )
select distinct zone_name from #tmp_demand_d2 order by 1

SELECT @loop_count = count(*) from #tmp_demand_d3			
SELECT @loop_index = 1

WHILE  @loop_count >= @loop_index
BEGIN

	SELECT @zone_name = a.zone_name
	FROM   #tmp_demand_d3 a 
	WHERE  a.id_loop =  @loop_index				

		/*
		select @ll_go = 0

		go1:

		-- A1FWH,C1FWH,C2FWH,E1FWH 

		select @ll_go = @ll_go + 1

		-- select @ll_go,123

		if    @ll_go = 1
			  select @zone_name = 'A1FWH'
		if    @ll_go = 2
			  select @zone_name = 'C1FWH'
		if    @ll_go = 3
			  select @zone_name = 'C2FWH'
		if    @ll_go = 4
			  select @zone_name = 'E1FWH' 
		*/

		truncate table #tmp_demand
		truncate table #tmp_supply
		truncate table #tmp_supply_demand

		insert #tmp_demand ( part_no, dt_request, qty_request, id_reference ,category ,sort ,ref_no ,dt_request2 )
		select b.part_no
			  ,dt_request = convert(datetime,convert(varchar(8),case when a.time_from < getdate() then getdate() else a.time_from end ,112)) 
			  ,a.qty_apply,a.id_pcprocess,category='2-1.Demand'
			  ,sort = convert(varchar(50),convert(varchar(8),case when a.time_from < getdate() then getdate() else a.time_from end ,112))
			   -- + '-' + a.room_code )
			  ,a.room_code
			  ,a.dt_request2
		from #tmp_demand_d1 a ,icim_comp b with (nolock)
			where a.id_icim_comp = b.id_icim_comp
				and a.zone_name = @zone_name
			order by 2

		-- select * from #tmp_demand
		-- select * from #tmp_demand_d1

		-- return

		/*

		insert #tmp_demand ( part_no, dt_request, qty_request, id_reference ,category ,sort )
				SELECT b.partno 
					  ,dt_request = convert(datetime,convert(varchar(8),case when d.time_from < getdate() then getdate() else d.time_from end ,112))
					  ,( b.qty_apply - b.qty_actual ) ,a.id_reference ,'2-1.Demand'
					  ,''
				FROM joyDB.dbo.ictk a with (nolock) ,joyDB.dbo.ictkd b with (nolock) ,icstockroom c with (nolock)
					,pcprocess d with (nolock)
				WHERE a.id_ictr = b.id_ictr
					and a.stat_void = 0 and b.stat_void = 0
					and ( b.qty_apply - b.qty_actual ) > 0
					and a.dt_process is null
					and b.id_icstockroom = c.id_icstockroom
					and c.room_code = 'A1'
					and a.id_reference = d.id_pcprocess
					and d.stat_void = 0
					and datediff(day ,time_from ,dateadd(day , 1, getdate() ) ) >= 0
		*/

		insert #tmp_supply ( part_no, dt_request, qty_request, id_reference ,category ,qty_lot ,sort ,ref_no ,dt_request2 )
				select c.part_no
					   ,dt_request=convert(datetime,convert(varchar(8),getdate(),112))
					   ,sum(a.qty_onhand)
					   ,a.id_icidf ,'1-1.Stock',0 
					   ,sort = convert(varchar(50),convert(varchar(8),getdate(),112) + '-' + convert(varchar(10),d.seq) + '-' + b.room_code )
					   ,b.room_code
					   ,dt_request2=convert(datetime,convert(varchar(8),getdate(),112))
					 from icidf a with (nolock) 
						,icstockroom b with (nolock)
    					,icim_comp c with (nolock)
						,#tmp_demand_d5 d with (nolock)
		where a.id_icstockroom = b.id_icstockroom
				and a.id_icim_comp = c.id_icim_comp
				--and ( b.room_code in ('A1','1SWBUF','A1FWH','C1FWH','C2FWH','E1FWH','A6','A7','ASR','SMUNSE','STASK','TW43')
				--	 or substring(b.room_code,1,1) = 'K' )
				and a.qty_onhand > 0
				and b.stat_void = 0
				and exists ( select 1 from #tmp_demand z where c.part_no = z.part_no )
				and b.room_code = d.room_code
				and d.zone_name = @zone_name
				--and exists ( select 1 from #tmp_demand_d5 y where b.room_code = y.room_code and y.zone_name = @zone_name )
		group by c.part_no,a.id_icidf,b.room_code ,convert(varchar(50),convert(varchar(8),getdate(),112) + '-' + convert(varchar(10),d.seq) + '-' + b.room_code )
		
		-- select * from #tmp_supply
		-- select * from #tmp_demand_d5

		EXEC [zp_demand_supply_calculate]
		
		if object_id('tempdb.dbo.#tmp_result_balance') is not null drop table #tmp_result_balance
		select part_no,dt_request,id_loop=max(id_loop) into #tmp_result_balance from #tmp_supply_demand 
		group by part_no,dt_request

		if object_id('tempdb.dbo.#tmp_supply_demand_final_tmp') is not null drop table #tmp_supply_demand_final_tmp
		CREATE TABLE #tmp_supply_demand_final_tmp ( id_loop int ,part_no varchar(50) ,dt_request datetime ,qty_request decimal(18,0) ,id_reference int ,category varchar(50) ,qty_lot decimal(18,0) ,balance decimal(18,0)
										 ,stat_active tinyint ,dt_supply datetime ,category_bk varchar(50) ,balance_bk decimal(18,0) ,source_from varchar(50) ,qty_po_supply decimal(18,0) ,qty_from decimal(18,0) ,date_from datetime ,id int ,id_loop_d int ,id_loop_s int 
										 ,process_no varchar(50) ,room_code varchar(50) 
										 ,zone_name varchar(50) ,balance_last decimal(18,0) ,dt_request2 datetime )

		insert #tmp_supply_demand_final_tmp ( id_loop ,id ,part_no, dt_request, category ,qty_request, id_reference ,stat_active ,id_loop_d ,id_loop_s 
			  ,process_no ,room_code ,balance ,balance_last ,dt_request2 )
		select a.id_loop ,a.id ,a.part_no, a.dt_request, a.category ,a.qty_request, a.id_reference ,a.stat_active ,a.id_loop_d ,a.id_loop_s 
			  ,d.process_no 
			  ,room_code =  case when a.category in ('1-1.Stock')  then c.ref_no
					when a.category in ('2-1.Demand') then c.ref_no
			   end 
			  ,a.balance ,0
			  ,case when a.category in ('1-1.Stock')  then c.dt_request2
					when a.category in ('2-1.Demand') then b.dt_request2
			   end
		from #tmp_supply_demand a left join #tmp_demand b on a.id_loop_d = b.id_loop
								  left join #tmp_supply c on a.id_loop_s = c.id_loop
								  left join pcprocess d with (nolock) on b.id_reference = d.id_pcprocess
								  --left join icidf e with (nolock) on c.id_reference = e.id_icidf
								  --left join icstockroom f with (nolock) on e.id_icstockroom = f.id_icstockroom

		-- where a.part_no = '102000000054A'
		order by 1

		-- select * from #tmp_supply_demand_final_tmp
		-- select * from #tmp_demand

		/*
		select * from #tmp_demand a where exists ( select 1 from #tmp_supply b where a.part_no = b.part_no
			and b.ref_no = 'A1F-IN' )

		*/

		update a set balance_last = b.balance from #tmp_supply_demand_final_tmp a 
					 ,#tmp_supply_demand_final_tmp b
		where a.id_loop = convert(int ,b.id_loop + 1 )
			and a.part_no = b.part_no

		-- select * from #tmp_supply_demand_final_tmp
		-- 102000000176A       

		-- return

		/*

		select * from #tmp_demand
		select * from #tmp_supply_demand

		insert #tmp_supply_demand_final ( id_loop ,id ,part_no, dt_request, category ,qty_request, id_reference ,stat_active ,id_loop_d ,id_loop_s 
			  ,process_no ,room_code ,balance )
		select a.id_loop ,id ,a.part_no, a.dt_request, category='9-9.Balance' ,qty_request=a.balance, a.id_reference ,a.stat_active ,a.id_loop_d ,a.id_loop_s 
			  ,a.process_no ,a.room_code ,a.balance
		from #tmp_supply_demand_final a ,#tmp_result_balance b
		where a.id_loop = b.id_loop
		*/

		insert #tmp_supply_demand_final ( 
		id_loop ,id ,part_no, dt_request, category 
			  ,qty_request ,balance 
			  ,id_reference ,stat_active ,id_loop_d ,id_loop_s 
			  ,process_no ,room_code ,status 
			  ,zone_name ,balance_last ,dt_request2 )
		select id_loop ,id ,part_no, dt_request, category 
			  ,qty_request = qty_request * ( case when category in ('2-1.Demand') then -1 else 1 end ),balance 
			  ,id_reference ,stat_active ,id_loop_d ,id_loop_s 
			  ,process_no ,room_code ,status = case when balance < 0 then 'Shortage' else 'Allocate' end
			  ,zone_name = @zone_name
			  ,balance_last
			  ,dt_request2
		from #tmp_supply_demand_final_tmp
		order by 1

		/*
		select * from #tmp_supply_demand

		select * from #tmp_supply_demand_final_tmp

		*/

		/*
		if   @ll_go = 4
			 goto go2

		goto go1

		go2:

		*/


		SELECT @loop_index = @loop_index + 1

	END

-- return

/*
select part_no,process_no,* from #tmp_supply_demand_final_tmp where part_no = '61M1AB144890021'
select part_no,process_no,* from #tmp_supply_demand_final where part_no = '61M1AB144890021'
--select * from #tmp_demand where part_no = '61M1AB144890021' 
select * from #tmp_demand where part_no = '61M1AB144890021'  -- id_loop in (887,888,889,890)
select * from #tmp_supply where part_no = '61M1AB144890021' 

select * from #tmp_supply_demand where part_no = '61M1AB144890021'
select * from #tmp_demand where id_loop in (887,8,889,890)
select * from #tmp_demand where part_no = '61M1AB144890021'

select process_no,* from #tmp_demand_d1 a ,pcprocess b ,icim_comp c
where a.id_pcprocess = b.id_pcprocess
and a.id_icim_comp = c.id_icim_comp
and c.part_no = '61M1AB144890021' 

select * from #tmp_demand where id_loop = 452

*/

if object_id('tempdb.dbo.#tmp_result1') is not null drop table #tmp_result1
create table #tmp_result1 ( zone_name varchar(50) ,part_no varchar(50) ,id_loop_min int ,id_loop_max int 
						   ,qty_onhand decimal(18,0) ,qty_demand decimal(18,0) ,qty_supply decimal(18,0) ,qty_shortage decimal(18,0) ,qty_excess decimal(18,0) )
insert #tmp_result1 ( zone_name,part_no,id_loop_min,id_loop_max )
select zone_name,part_no,id_loop_min=min(id_loop),id_loop_max=max(id_loop)
from #tmp_supply_demand_final
group by zone_name,part_no

if object_id('tempdb.dbo.#tmp_result2') is not null drop table #tmp_result2
create table #tmp_result2 ( zone_name varchar(50) ,part_no varchar(50) ,id_loop_min int ,id_loop_max int 
						   ,qty_onhand decimal(18,0) ,qty_demand decimal(18,0) ,qty_supply decimal(18,0) ,qty_shortage decimal(18,0) ,qty_excess decimal(18,0)
						   ,status varchar(50) )

insert #tmp_result2 ( zone_name,part_no,id_loop_min,id_loop_max ,qty_onhand ,qty_demand ,qty_supply ,qty_shortage ,qty_excess )
select a.zone_name,a.part_no,a.id_loop_min,a.id_loop_max
	  ,qty_onhand = sum(case when b.category='1-1.Stock' then b.qty_request else 0 end ) 
	  ,qty_demand   = sum(case when b.category='2-1.Demand' then b.qty_request else 0 end ) 
	  ,qty_supply   = sum(case when b.category='2-1.Demand' and  b.balance_last >= 0 and b.balance >= 0 then b.qty_request 
	                           when b.category='2-1.Demand' and  b.balance_last >= 0 and b.balance < 0 then b.qty_request - b.balance
							   else 0 end ) * (-1)
	  ,qty_shortage = sum(case when b.category='2-1.Demand' and b.balance <  0 and a.id_loop_max = b.id_loop then b.balance else 0 end ) 
	  ,qty_access   = sum(case when b.category='2-1.Demand' and b.balance >  0 and a.id_loop_max = b.id_loop then b.balance else 0 end ) 
from #tmp_result1 a ,#tmp_supply_demand_final b
where a.zone_name = b.zone_name
	and a.part_no = b.part_no
group by a.zone_name,a.part_no,a.id_loop_min,a.id_loop_max

update a set status = case when qty_shortage < 0 then 'Shortage'
						   when qty_excess > 0 then 'Excess'
						   else 'Safe' end
	from #tmp_result2 a
	  
-- select * from #tmp_result1
-- select * from #tmp_supply_demand_final where part_no = '102000000176A'
-- select * from #tmp_supply_demand_final where part_no = '102000000460H'
-- select * from #tmp_supply_demand_final where part_no = '109200000153A' 

--select * from #tmp_supply_demand_final

/*
select zone_name,sum(qty_onhand)
 from #tmp_result2 group by zone_name

select sum(qty_request) from  #tmp_supply_demand_final
where zone_name = 'E1FWH'
and category = '1-1.Stock'

select * from #tmp_supply_demand_final

select part_no,qty_request,category,room_code,* from  #tmp_supply_demand_final
where zone_name = 'E1FWH'
and category = '1-1.Stock'
and part_no = '111000000015A'
order by 1

select * from #tmp_supply where part_no='111000000015A'
*/

/*
E1F-LS
E1F-LS
111000000015A       
111000000015A       
*/

/*
select part_no,count(*) from  #tmp_supply_demand_final
where zone_name = 'E1FWH'
and category = '1-1.Stock'
group by part_no
having count(*) > 1

select * from #tmp_supply_demand_final
where part_no='111000000015A'
       
*/


--select * from icim_property
/*
select a.zone_name,a.id_loop,* 
from  #tmp_supply_demand_final a join #tmp_result1 b
			on a.id_loop = b.id_loop_max
			and a.zone_name = b.zone_name
			and a.part_no = b.part_no
			--where a.part_no = '102000000158H'
order by 1,2

select * from #tmp_result1 where part_no = '102000000158H'

select zone_name,part_no,process_no,dt_request,* from #tmp_supply_demand_final
order by 1,2,3


where part_no = '102000000158H'

*/

if object_id('tempdb.dbo.#tmp_result3') is not null drop table #tmp_result3
create table #tmp_result3 ( zone_name varchar(50) ,part_no varchar(50) ,dt_request datetime ,id_loop_min int ,id_loop_max int 
						   ,qty_onhand decimal(18,0) ,qty_demand decimal(18,0) ,qty_supply decimal(18,0) ,qty_shortage decimal(18,0) ,qty_excess decimal(18,0) )
insert #tmp_result3 ( zone_name,part_no,dt_request ,id_loop_min,id_loop_max )
select zone_name,part_no,dt_request,id_loop_min=min(id_loop),id_loop_max=max(id_loop)
from #tmp_supply_demand_final
group by zone_name,part_no,dt_request

-- select * from #tmp_supply_demand_final
-- select * from #tmp_result3 order by 1,2

insert #tmp_supply_demand_final ( 
	id_loop ,id ,part_no, dt_request, category 
			,qty_request ,balance 
			,id_reference ,stat_active ,id_loop_d ,id_loop_s 
			,process_no ,room_code ,status 
			,zone_name ,balance_last ,dt_request2 )
	select a.id_loop ,a.id ,a.part_no, a.dt_request
	        ,category = '9-9.Balance' 
			,qty_request = a.balance ,a.balance 
			,a.id_reference ,a.stat_active ,a.id_loop_d ,a.id_loop_s 
			,a.process_no ,a.room_code ,status = case when a.balance < 0 then 'Shortage' else 'Allocate' end
			,a.zone_name 
			,a.balance_last
			,a.dt_request2
	from #tmp_supply_demand_final a join #tmp_result3 b
			on a.id_loop = b.id_loop_max
			and a.zone_name = b.zone_name
			and a.part_no = b.part_no
			and a.dt_request = b.dt_request

-----------------------------------------------------------------------------------------------

insert #tmp_supply_demand_final ( 
	id_loop ,id ,part_no, dt_request, category 
			,qty_request ,balance 
			,id_reference ,stat_active ,id_loop_d ,id_loop_s 
			,process_no ,room_code ,status 
			,zone_name ,balance_last ,dt_request2 )
	select a.id_loop ,a.id ,a.part_no, a.dt_request
	        ,category = '5-1.Allocate' 
			,qty_request = ( case when a.balance_last >= 0 and a.balance >= 0 then a.qty_request 
	                            when a.balance_last >= 0 and a.balance < 0  then a.qty_request - a.balance
							    else 0 end ) * (-1)
			,a.balance 
			,a.id_reference ,a.stat_active ,a.id_loop_d ,a.id_loop_s 
			,a.process_no ,a.room_code ,status = case when a.balance < 0 then 'Shortage' else 'Allocate' end
			,a.zone_name 
			,a.balance_last
			,a.dt_request2
from #tmp_supply_demand_final a
where a.category='2-1.Demand'

insert #tmp_supply_demand_final ( 
	id_loop ,id ,part_no, dt_request, category 
			,qty_request ,balance 
			,id_reference ,stat_active ,id_loop_d ,id_loop_s 
			,process_no ,room_code ,status 
			,zone_name ,balance_last ,dt_request2 )
	select a.id_loop ,a.id ,a.part_no, a.dt_request
	        ,category = '5-2.Shortage' 
			,qty_request = case when a.balance < 0 and a.balance_last < 0 then a.qty_request else a.balance end 
			,a.balance 
			,a.id_reference ,a.stat_active ,a.id_loop_d ,a.id_loop_s 
			,a.process_no ,a.room_code ,status = case when a.balance < 0 then 'Shortage' else 'Allocate' end
			,a.zone_name 
			,a.balance_last
			,a.dt_request2
from #tmp_supply_demand_final a
where a.category='2-1.Demand'
	and a.balance < 0

insert #tmp_supply_demand_final ( 
	id_loop ,id ,part_no, dt_request, category 
			,qty_request ,balance 
			,id_reference ,stat_active ,id_loop_d ,id_loop_s 
			,process_no ,room_code ,status 
			,zone_name ,balance_last ,dt_request2 )
	select b.id_loop ,b.id ,b.part_no, b.dt_request
	        ,category = '5-3.Excess' 
			,qty_request =  b.balance 
			,b.balance 
			,b.id_reference ,b.stat_active ,b.id_loop_d ,b.id_loop_s 
			,b.process_no ,b.room_code ,status = case when b.balance < 0 then 'Shortage' else 'Allocate' end
			,b.zone_name 
			,b.balance_last
			,b.dt_request2
from #tmp_result1 a ,#tmp_supply_demand_final b
where a.zone_name = b.zone_name
	and a.part_no = b.part_no
	and b.category='2-1.Demand'
	and b.balance > 0
	and a.id_loop_max = b.id_loop

-----------------------------------------------------------------------------------------------
update a set stat_roll = c.stat_roll 
		    ,part_property = d.icim_type19
			,amount_request = qty_request * (isnull(e.uc_stdmtl,0) + isnull(e.uc_stdlab,0) + isnull(e.uc_stdbur,0))
from #tmp_supply_demand_final a ,icim_comp b with(nolock),icim_manufacture c with(nolock) ,icim_property d with (nolock)
	,icim_accounting e with (nolock)
where a.part_no=b.part_no
--and b.id_admcomp=@id_admcomp
and b.id_icim_comp=c.id_icim_comp
and b.id_icim_comp=d.id_icim_comp
and b.id_icim_comp=e.id_icim_comp
-----------------------------------------------------------------------------------------------

if  @option = 1
	begin

		-- truncate table tab_inv_distri

		delete tab_inv_distri where stage = @stage

		insert tab_inv_distri (id_loop, part_no, dt_request, category, qty_request, balance, ref_no, room_code, status, zone_name, qty, report, stat_roll, part_property, dt_request2, dt_generate, amount_request, amount ,hr ,stage )
		select -- a.id_loop ,a.id ,a.id_reference ,a.id_loop_d ,a.id_loop_s ,a.stat_active  
			   --b.id_loop_min,b.id_loop_max 
			   a.id_loop,
			   a.part_no, a.dt_request, a.category 
			  ,a.qty_request ,a.balance   
			  ,ref_no = case when a.category in ('9-9.Balance') then '' 
							 when a.category in ('1-1.Stock','5-3.Excess')     then room_code
							 when a.category in ('2-1.Demand','5-1.Allocate','5-2.Shortage')  then a.process_no 
							 else '' end
			  ,a.room_code ,status = c.status 
			  ,a.zone_name
			  --,b.qty_onhand ,b.qty_demand ,b.qty_supply ,b.qty_shortage ,b.qty_excess
			  --,qty = case when c.status = 'Shortage' then b.qty_shortage
			  --            when c.status = 'Excess'   then b.qty_excess
			  --			  else 0 end
			  ,qty = case when a.category in ('5-2.Shortage') then a.qty_request 
						  when a.category in ('5-3.Excess') then a.qty_request 
						  else 0 end   
			  --,report = case when b.id_loop_min is not null and a.category not in ('9-9.Balance') then 'Summary' else 'Detail' end
			  ,report = case when a.category in ('5-2.Shortage','5-3.Excess') then 'Report-2'
							 else 'All' end 
			  ,stat_roll = case when stat_roll = 0 then '一對一' else '捲狀' end
			  ,part_property
			  ,a.dt_request2
			  ,dt_generate = getdate()
			  ,a.amount_request 
			  ,amount = case when a.category in ('5-2.Shortage') then a.amount_request 
						  when a.category in ('5-3.Excess') then a.amount_request 
						  else 0 end   		
			  ,hr = @hr
			  ,stage = @stage
		-- into tab_inv_distri
		from  #tmp_supply_demand_final a --left join #tmp_result2 b
					--on a.id_loop = b.id_loop_min
					--and a.zone_name = b.zone_name
					--and a.part_no = b.part_no
					left join #tmp_result2 c on a.zone_name = c.zone_name
												and a.part_no = c.part_no
	end

/*

select * from tab_inv_distri

truncate table tab_inv_distri

drop table #t1
select zone_name,part_no,id_loop=max(id_loop) into #t1
from tab_inv_distri where part_no = '102000000163H' 
--and category in ('1-1.Stock','2-1.Demand','9-9.Balance')
and category in ('9-9.Balance')
group by zone_name,part_no

select a.zone_name,a.part_no,b.balance,b.status
from #t1 a ,tab_inv_distri b
where a.id_loop = b.id_loop
and category in ('9-9.Balance')
and a.part_no = b.part_no



union all
select a.id ,a.part_no, a.dt_request, category='9-9.Balance' ,qty_request=a.balance, a.id_reference ,a.stat_active ,a.id_loop_d ,a.id_loop_s 
	  ,d.process_no ,f.room_code
from #tmp_supply_demand a ,#tmp_demand b ,#tmp_supply c ,pcprocess d with (nolock) ,icidf e with (nolock) ,icstockroom f with (nolock)
	where a.id_loop_d = b.id_loop
		and a.id_loop_s = c.id_loop
		and b.id_reference = d.id_pcprocess
		and c.id_reference = e.id_icidf
		and e.id_icstockroom = f.id_icstockroom

		select * from joyDB.dbo.pcprocess where stat_import = 1


*/

-- select * from #tmp_supply_demand where part_no = '102000000054A'

return






GO


