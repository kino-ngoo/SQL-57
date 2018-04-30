	

--CREATE procedure [dbo].[zp_update_rcvqty] @id_rcv int,@qty decimal(14,2),@id_iqcmaster int,@id_admuser int as

--set nocount on
/*
select * from ictr where apply_no = 'IR71000128J         '
select * from ictrd where id_ictr = 22413132
rollback
*/
--/*
begin tran
--rollback
declare @id_rcv int,@qty decimal(14,2),@id_iqcmaster int,@id_admuser int 
select @id_rcv =3201854 ,@qty = 3360,@id_iqcmaster =2135238 ,@id_admuser = 16636 
--*/
--exec zp_update_rcvqty 3201854,3360.00,2135238,16636

declare @dt_schedule datetime,@id_received int,@id_expect_received int,@source_id int
declare @config_value char(10)
declare @id_icim_comp int,@quantity decimal(14,2),@qty_iqc decimal(14,2)
declare @id_receive_invoice int,@id_ictr int,@rcv_no char(15),@rcvinv_no char(15)
declare @current_slip int,@id_admcomp int,@cr_subject int,@db_subject int,@qty_persale decimal(14,2)
declare @id_admfacility int,@apply_no char(20),@next_slip int,@id_icstockroom_rcv int
declare @today datetime,@sum_qty decimal(14,2),@allow_qty_rej decimal(14,2)
declare @user_id char(20),@location char(10),@id_ictrd int,@id_admslip_reason int,@up decimal(14,2)
declare @rc smallint,@id_icstockroom int,@qty_actual decimal(14,2),@id_ictr_exp int
declare @qty_rej decimal(14,2),@part_no  char(20),@descrip char(80),@up_cost  decimal(20,2),@stat_b2b int
declare @qty_iqc_allow decimal(14,2),@qty_reject_allow decimal(14,2),@sum_qty_iqc decimal(14,2),@sum_qty_reject	decimal(14,2)
declare @id_po_head int ,@config int,@buyer_part_no varchar(20),@cnt int,@quantity_sum decimal(14,2),@qty_re decimal(14,2)
select @today = getdate()
begin 
----------------------------------------------------
 select @user_id = user_id
   from admuser
  where id_admuser = @id_admuser

select @qty_re= @qty

select @id_receive_invoice = id_receive_invoice,@id_admcomp = id_admcomp,
	@rcv_no = receive_no,@id_admfacility = id_admfacility_receive ,
	@stat_b2b = stat_b2b
from receive
where id_receive = @id_rcv
and stat_void = 0 

select @current_slip = id_admslip,@rcvinv_no = receive_no 
from receive_invoice
where id_receive_invoice = @id_receive_invoice

select @id_ictr_exp = id_ictr 
from ictr
where tran_type = 'EXPIC' and 
      ref_no = @rcvinv_no and
      id_reference = @id_receive_invoice and		
      stat_void = 0 

 exec @next_slip = zp_get_next_admslip @id_admcomp,@current_slip,'IQCREJ'
 if @next_slip <= 0
  begin
   select -2
   return ---2
  end

 exec zp_getslipno @next_slip ,@today,@apply_no output
 if isnull (@apply_no,'') = ''
  begin 
   select -3
   return ---3
  end
  select '@apply_no ' = @apply_no 
--------------------------------------------------------------------
 begin 
 select @id_ictr = max (id_ictr)
   from ictr
  where tran_type = 'EXPIC' and 
        ref_no = @rcvinv_no and
        id_reference = @id_receive_invoice and		
        stat_void = 0 
 select id_ictr = identity (int,1,1),
	id_admcomp,
	id_admslip = @next_slip,
	id_admuser_applier = @id_admuser,
	id_admuser_processer = @id_admuser,
	ictr.cost_id ,
	ref_no = @rcv_no,
	source_code = ictr.source_code ,
	id_reference = @id_rcv,
	currency = ictr.currency,
	id_rate_type = ictr.id_rate_type,
	dt_exchange = @today,
	tran_type = 'IQCREJ',
	apply_no = @apply_no,
	dt_apply = @today,
	dt_process = @today,
	create_by = @user_id 
   into #ictr
from ictr
where id_ictr = @id_ictr 

select 'table = #ictr',* from #ictr
-- select @id_ictr = max(id_ictr) + 1  from ictr
exec @id_ictr  = zp_pub_GetIdentityvalue 'ictr','id_ictr' ,1

 insert into ictr
  (	id_ictr ,
	id_admcomp,
	id_admslip ,
	id_admuser_applier ,
	id_admuser_processer,
	cost_id ,
	ref_no ,
	source_code ,
	id_reference ,
	currency,
	id_rate_type ,
	dt_exchange ,
	tran_type ,
	apply_no ,
	dt_apply ,
	dt_process ,
	create_by )
 select @id_ictr ,
	id_admcomp,
	id_admslip ,
	id_admuser_applier ,
	id_admuser_processer,
	cost_id ,
	ref_no ,
	source_code ,
	id_reference ,
	currency,
	id_rate_type ,
	dt_exchange ,
	tran_type ,
	apply_no ,
	dt_apply ,
	dt_process ,
	create_by 
   from #ictr
 if @@error <> 0
  begin
	
   select -1
   return ---1
  end
 end  
select @id_icstockroom_rcv = id_icstockroom_receive 
   from admfacility
  where id_admfacility = @id_admfacility 

----------------------------------------------------
 declare cur_receive cursor for 
       select received.id_expect_received,
 	      sum_qty = sum(received.quantity),
	      sum_qty_iqc = sum(received.qty_iqc),
	      sum_qty_reject = sum(received.qty_reject)
	 from   received,
		expect_received ,
		icim_sale icim_sale, 
		icim_comp icim_comp ,
		icim_accounting icim_accounting
	 where 	received.source_id = expect_received.source_id and
		received.id_expect_received = expect_received.id_expect_received and 
		received.id_receive = @id_rcv and 
		received.stat_void = 0 and expect_received.stat_void = 0 and  
		received.id_icim_comp = icim_sale.id_icim_comp and
		received.id_icim_comp = icim_comp.id_icim_comp and
		received.id_icim_comp = icim_accounting.id_icim_comp 
	group by received.id_expect_received,expect_received.dt_schedule
	having sum(received.quantity) > 0 
	order by dt_schedule desc,received.id_expect_received 

       open cur_receive
       fetch cur_receive into @id_expect_received,@sum_qty , @sum_qty_iqc,@sum_qty_reject	
       while @@fetch_status = 0
 	Begin 

	select @source_id = source_id 
	from expect_received
	where id_expect_received = @id_expect_received 	       	
select '@source_id' = @source_id
	/*********check expect_received ????? ***********/	
	if @sum_qty > 0 and abs(@qty) > 0 
         begin
         
         select '@@sum_qty' = @sum_qty
	    select @qty_iqc_allow = @sum_qty_iqc,
		   @qty_reject_allow = @sum_qty_reject
	    from expect_received 
	    where id_expect_received =	@id_expect_received	    
	   
	
 	        
	    if @qty > 0
	     begin  	 	    	
            	Update popod 
 	      	Set qty_iqc = case when @qty_iqc_allow > @qty then (qty_iqc - @qty) else (qty_iqc - @qty_iqc_allow) end,
 	            qty_reject = case when @qty_iqc_allow > @qty then qty_reject + @qty else (qty_reject + @qty_iqc_allow) end,
 	            dt_update = @today,
	            update_by = @user_id	     
 	         From popod 	pod
 	        Where pod.id_popod = @source_id
	    	
		Update expect_received 
	        Set qty_iqc    = case when @qty_iqc_allow > @qty then (qty_iqc - @qty) else (qty_iqc - @qty_iqc_allow) end,
 	            qty_reject = case when @qty_iqc_allow > @qty then qty_reject + @qty else (qty_reject + @qty_iqc_allow) end,
		    update_by = @user_id,
		    dt_update = @today			
	        where id_expect_received = @id_expect_received;
		set @allow_qty_rej = case when @qty_iqc_allow > @qty then @qty else @qty_iqc_allow end
	     end
	    else  
	     begin
--		select '@qty_reject_allow' = @qty_reject_allow
--		select '@qty' =@qty
		
		Update popod 
 	      	Set qty_iqc 	= case when @qty_reject_allow  > abs(@qty) then (qty_iqc - @qty) else (qty_iqc - (-1 * @qty_reject_allow) ) end,
 	            qty_reject  = case when @qty_reject_allow  > abs(@qty) then qty_reject + @qty else (qty_reject + (-1 * @qty_reject_allow) ) end,
 	            dt_update = @today,
	            update_by = @user_id	     
 	         From popod 	pod
 	        Where pod.id_popod = @source_id
	    	
		Update expect_received 
	        Set qty_iqc    = case when @qty_reject_allow > abs(@qty) then (qty_iqc - @qty) else (qty_iqc - (-1 * @qty_reject_allow)) end,
 	            qty_reject = case when @qty_reject_allow > abs(@qty) then qty_reject + @qty else (qty_reject + (-1 * @qty_reject_allow)) end,
		    update_by = @user_id,
		    dt_update = @today			
	        where id_expect_received = @id_expect_received;
		set @allow_qty_rej = case when @qty_reject_allow > abs(@qty) then @qty else (-1 * @qty_reject_allow) end 
	     end						

--	    select '@allow_qty_rej' = @allow_qty_rej	
 	declare cur_received cursor for
 	select dt_schedule = case when expect_received.dt_schedule is null 
					then (select dt_need from popod where id_popod = expect_received.source_id )
			           else expect_received.dt_schedule end	,
		received.id_received,
		received.source_id,
		received.id_icim_comp,
		received.quantity,
		received.qty_iqc,
		received.qty_reject,
		received.id_admreason,
		icim_comp.part_no,
		icim_comp.descrip,
		up_cost = ( icim_accounting.uc_stdmtl + icim_accounting.uc_stdlab + icim_accounting.uc_stdbur ) ,
		up = received.up,
		icim_sale.qty_persale		
 	from   received,
		expect_received ,
		icim_sale icim_sale, 
		icim_comp icim_comp ,
		icim_accounting icim_accounting
 	where 	received.source_id = expect_received.source_id and
		received.id_expect_received = expect_received.id_expect_received and 
		received.id_receive = @id_rcv and 
		received.stat_void = 0 and expect_received.stat_void = 0 and  
		received.id_icim_comp = icim_sale.id_icim_comp and
		received.id_icim_comp = icim_comp.id_icim_comp and
		received.id_icim_comp = icim_accounting.id_icim_comp and
		received.id_expect_received = @id_expect_received
	order by dt_schedule desc,received.id_expect_received 
 	
 	open cur_received
 	fetch cur_received into @dt_schedule ,@id_received ,@source_id,@id_icim_comp,
				 @quantity,@qty_iqc,@qty_rej,@id_admslip_reason,
				 @part_no ,@descrip,@up_cost ,@up  ,@qty_persale
 	while @@fetch_status = 0
 	 begin
 	  if @allow_qty_rej > 0 
 	   Begin 	
 	   select 'aaa'	
 	      Update received 
		 set qty_iqc 	= case when @qty_iqc > @allow_qty_rej then qty_iqc - @allow_qty_rej else qty_iqc - @qty_iqc  end,
 	             qty_reject = case when @qty_iqc > @allow_qty_rej then qty_reject + @allow_qty_rej else qty_reject + @qty_iqc  end,
		     id_iqcmaster = @id_iqcmaster,  	
 	             dt_update = @today,
		     update_by = @user_id		
		where id_received = @id_received and
		      id_expect_received = @id_expect_received;
 	 	      
 	       exec @cr_subject = zp_pub_Pcturned_get_cr_subject @id_admslip_reason,@id_icim_comp ,1,-1 
 	       exec @db_subject = zp_pub_Pcturned_get_dr_subject @id_admslip_reason,@id_icim_comp ,1,-1 


	 	exec @id_ictrd = zp_pub_GetIdentityvalue 'ictrd','id_ictrd' ,0

		   
 	        insert into ictrd
		    (	id_ictrd ,
		 	id_icim_comp,
			id_ictr ,
			id_icstockroom ,
			id_reference ,
			qty_apply ,
			qty_actual,
			up,
			up_cost ,
			sign ,
			partno ,
			descrip ,
			id_admslip_reason ,
			id_glsubject_db ,
			id_glsubject_cr ,
			location ,
			create_by,
			qty_persale)
		 select @id_ictrd + 1,
			id_icim_comp = @id_icim_comp,
			id_ictr = @id_ictr  ,
			id_icstockroom = @id_icstockroom_rcv,
			id_reference = @id_received ,
			qty_apply  = case when @qty_iqc > @allow_qty_rej then @allow_qty_rej else @qty_iqc end ,
			qty_actual = case when @qty_iqc > @allow_qty_rej then @allow_qty_rej else @qty_iqc end ,
			up = @up,
			up_cost = @up_cost,
			sign = -1 ,
			partno = @part_no,
			descrip = @descrip ,
			@id_admslip_reason ,
			id_glsubject_db = @cr_subject ,
			id_glsubject_cr = @db_subject,
			location ='',
			create_by = @user_id,
			@qty_persale
		   
		 if @@error <> 0
		  begin
		   close cur_received
		   deallocate cur_received
		   select -1
		   return ---1
 	 	  end 
		set @allow_qty_rej = case when @qty_iqc > @allow_qty_rej then 0 else @allow_qty_rej- @qty_iqc end 
 	   end
	   else 
	      if @allow_qty_rej < 0 
	      begin
--		select '@allow_qty_rej' = @allow_qty_rej
 	         Update received 
		    set qty_iqc 	= case when @qty_rej > abs(@allow_qty_rej) then qty_iqc - @allow_qty_rej else qty_iqc - (-1* @qty_rej)  end,
 	            	qty_reject = case when @qty_rej > abs(@allow_qty_rej) then qty_reject + @allow_qty_rej else qty_reject + (-1 * @qty_rej) end,
		        id_iqcmaster = @id_iqcmaster,  	
 	                dt_update = @today,
		        update_by = @user_id		
		  where id_received = @id_received and
		        id_expect_received = @id_expect_received;
 	 	      
 	         exec @cr_subject = zp_pub_Pcturned_get_cr_subject @id_admslip_reason,@id_icim_comp ,1,-1 
 	         exec @db_subject = zp_pub_Pcturned_get_dr_subject @id_admslip_reason,@id_icim_comp ,1,-1 


		exec @id_ictrd = zp_pub_GetIdentityvalue 'ictrd','id_ictrd' ,0

 	    insert into ictrd
		    (	id_ictrd ,
		 	id_icim_comp,
			id_ictr ,
			id_icstockroom ,
			id_reference ,
			qty_apply ,
			qty_actual,
			up,
			up_cost ,
			sign ,
			partno ,
			descrip ,
			id_admslip_reason ,
			id_glsubject_db ,
			id_glsubject_cr ,
			location ,
			create_by,
			qty_persale)
		 select @id_ictrd + 1,
			id_icim_comp = @id_icim_comp,
			id_ictr = @id_ictr  ,
			id_icstockroom = @id_icstockroom_rcv,
			id_reference = @id_received ,
			qty_apply  = case when @qty_rej > abs(@allow_qty_rej) then @allow_qty_rej else -1*@qty_rej end ,
			qty_actual = case when @qty_rej > abs(@allow_qty_rej) then @allow_qty_rej else -1*@qty_rej end ,
			up = @up,
			up_cost = @up_cost,
			sign = -1 ,
			partno = @part_no,
			descrip = @descrip ,
			@id_admslip_reason ,
			id_glsubject_db = @cr_subject ,
			id_glsubject_cr = @db_subject,
			location ='',
			create_by = @user_id,
			@qty_persale
		   
		 if @@error <> 0
		  begin
		   close cur_received
		   deallocate cur_received
		   select -1
		   return ---1
 	 	  end 
		set @allow_qty_rej = case when @qty_rej > abs(@allow_qty_rej) then 0 else @allow_qty_rej + @qty_rej end 
	   end
	   			
 	   fetch cur_received into @dt_schedule ,@id_received ,@source_id,@id_icim_comp,
			           @quantity,@qty_iqc,@qty_rej,@id_admslip_reason,
				   @part_no ,@descrip,@up_cost,@up ,@qty_persale
 	   end
 	   close cur_received
 	   deallocate cur_received

	   if @qty > 0 
	    begin
	       set @qty = case when @qty_iqc_allow > @qty then 0 else @qty - @qty_iqc_allow end 
	    end
	   else
	    begin
	       set @qty = case when @qty_reject_allow > abs(@qty) then 0 else @qty + @qty_reject_allow end 
	    end
       end 	
      fetch cur_receive into @id_expect_received,@sum_qty , @sum_qty_iqc,@sum_qty_reject	
     end	  		
   close cur_receive
   deallocate cur_receive
-------------------------------------------------------------
----------------------------------------------------------------------
/*Update by jill on 2005-11-18 */
 /* B2B Block */

select @quantity_sum = sum(quantity)
from received 
where id_receive = @id_rcv
and stat_void = 0 

 if @stat_b2b = 1 and @quantity_sum > @qty_re
   INSERT INTO deef_log  	( source_type,    content1,   content2, content3, content4, content5)  
		  VALUES ( 'IQC_B2BE', @rcv_no,'@quantity_sum=' + convert(char(10),@quantity_sum),   
			'@qty_re=' + convert(char(10),@qty_re),'part_no=' + convert(char(20),@buyer_part_no),
			  'create_by=' + @user_id)   

 if @stat_b2b = 1 and @quantity_sum = @qty_re
 begin
    select @config = convert(int,config_value)
    from admconfig
    where config_code = 'RUNSUB3B2'
    and id_admcomp = @id_admcomp


    select @id_po_head = b.id_po_head
    from receive a,po_head b
    where a.invoice_no = b.so_no
    and b.doc_type = 'SubCompany3B2'
    and a.receive_no = @rcv_no
    and isnull(send_to_url,'') <> ''
    and b.stat_doc > 5
    group by b.id_po_head

    select @buyer_part_no  = max(e.buyer_part_no)
    from receive a,
            po_head b,
            popod c,
            received d,
            po_detail e
    Where a.invoice_no = b.so_no
    and b.doc_type = 'SubCompany3B2'
    and a.receive_no = @rcv_no
    and b.id_po_head = @id_po_head
    and c.id_expect_received = d.id_expect_received 
    and a.stat_void = 0 
    and b.stat_void = 0 
    and c.stat_void = 0 
    and d.stat_void = 0 
    and a.id_receive = d.id_receive 
    and c.linenumber = e.buyer_linenumber
    and b.id_po_head = e.id_po_head 
    and e.stat_void = 0
    and b.stat_doc > 5

INSERT INTO deef_log  	( source_type,    content1,   content2, content3, content4, content5)  
		  VALUES ( 'IQC_B2B', @rcv_no,'id_po_head=' + convert(char(10),@id_po_head),   
			'id_receive=' + convert(char(10),@id_rcv),'part_no=' + convert(char(20),@buyer_part_no),
			  'create_by=' + @user_id)   



    exec zp_reject_to_pogateway_3B2 @id_po_head ,@buyer_part_no
    if @@error <> 0 
    begin
	   select -1
	   return ---1

--       Set @error_msg = 'Failed to call zp_reject_to_pogateway_3B2'
--       goto Exception
    end

    if @config = 0
    begin
      exec zp_get_subcompany3b2 @id_po_head
    end
    if @@error <> 0
    begin
	   select -1
	   return ---1

--       Set @error_msg = 'Failed to call zp_get_subcompany3b2'
--       goto Exception
    end 

--    goto ProcEnd

 end
----------------------------------------------------------------------
  select @config_value = config_value
   from admconfig
  where config_code = 'ICTR_TRIGG'
    and id_admcomp = @id_admcomp

 if @config_value = '1' 
 begin
  select 1
  return --1
 end
 else
 begin
  exec @rc = zp_transaction_ictr @id_ictr
  if @rc = -1
  begin
   select -1
   return ---1
  end
 end 
   select 1
   return --1
set nocount off
end

