

 select id_business_partner, * from receive where receive.receive_no in ('RI17102069_1', 'RI17102069_2')
select id_business_partner, * from receive where receive.receive_no in('RI17102069_2','RI17102069_1','RI17101984_13','RI17101982_38',
'RI17101982_37','RI17101982_36','RI17101982_35','RI17101982_34')

 select * from ictr where id_ictr in (22431399)

 select vendor_name, * from vendor  with(nolock) where id_vendor = 4307 --receive.id_business_partner

 select * from icim_comp where id_icim_comp = 222548

 select * from admslip where id_admslip = 675
 select * from admslip where id_admslip = 676

 select * from admslip where descrip like '%ÉD°Ó%'

 select * from admuser where user_logon = 'lindi_wang'

 select * from rec_ic, receive_relation --,receive
 where rec_ic.id_rec_ic = receive_relation.ref_id 
   and receive_relation.id_relation in ('3208338','3208339')  -- = receive.id_receive

 select * from expect_received where id_expect_received in ('4098705','4098706')

 select * from received where id_receive in ('3208338','3208339')

 select * from icstockroom where id_vendor = 4307

 SELECT  receive.id_receive,   
		receive.id_admcomp,   
		receive.id_receiver,
		receive.id_admfacility_apply,   
		receive.id_admfacility_receive,   
		receive.id_business_partner,   
		receive.receive_no,   
		receive.id_rate_type,
		receive.receive_type,   
		receive.cost_id,
		receive.currency,
		receive.source_code,   
		receive.dt_process,   
		receive.id_ictr,   
		receive.part_no,   
		receive.descrip,   
		receive.model_no,   
		receive.qty_reject,    
		receive.qty_inspect,   
		receive.qty_receive,   
		receive.id_icim_comp,   
		receive.id_receive_invoice,   
		receive.dt_create,   
		receive.create_by,   
		receive.dt_update,   
		receive.update_by,   
		receive.dt_received,
		receive.status_receive,
		receive.invoice_no,
		receive.vendor_deliver_no,
		stat_b2b=isnull(receive.stat_b2b,0),
		mark = (select count(distinct id_icstkroom) from received received  with(nolock)
			    where  receive.id_receive = received.id_receive and
		received.stat_void = 0 ),
		parnter = case when receive.source_code in ('PO','CS','PX') then (select vendor_name from vendor  with(nolock) where id_vendor = receive.id_business_partner) 
			      else '[NONE]' end ,
		receive.dt_arrival,
		carrier,
		receive.shipvia,
		tracking_ref_no,
		dt_inspect = case when iqc_master.dt_inspect   is null then   receive.dt_received  
						         when iqc_master.dt_inspect <  receive.dt_received then   receive.dt_received  else iqc_master.dt_inspect end , /*add by joyce at 2010/03/30 for Carol ask*/
		iqc_method = case when isnull(codetable.descrip,'')<>'' then  codetable.descrip else 'NO IQC' end , /*add by joyce at 2010/03/30 for Carol ask*/
		iqc_master.id_iqc_method, /*add by joyce at 2010/03/30 for Carol ask*/
         business_type =  convert(int,isnull((select    distinct isnull(expect_receive.business_type,0) 
									     from received  with(nolock),expect_receive  with(nolock),expect_received  with(nolock) 
									   where   received.id_receive = receive.id_receive
										  and received.id_expect_received = expect_received.id_expect_received
										  and expect_receive.id_expect_receive  = expect_received.id_expect_receive 
										  and received.stat_void = 0
										  and expect_received.stat_void = 0
										  and expect_receive.business_type in(2,60)								   
										  ),0))
        ,receive.id_admcomp_from /*add by joyce at 2010/09/24 */
       ,admcomp.comp_code /*add by joyce at 2010/09/24 */
	  ,popo.po_no /* add by violet at 2011-05-12 */
FROM receive
    left join iqc_master on receive.receive_no in (select ref_no from iqc_master) and
    receive.receive_no = iqc_master.ref_no 
    left join codetable  with(nolock)
    on iqc_master.id_iqc_method = codetable.id_codetable and codetable.stat_void=0
    left join admcomp with(nolock) on receive.id_admcomp = admcomp.id_admcomp and admcomp.stat_void = 0
    left join expect_receive with(nolock) on expect_receive.id_expect_receive=receive.id_expect_receive and expect_receive.stat_void=0 /* add by violet at 2011-05-12 */
    Left join popo with(nolock) on popo.id_popo=expect_receive.source_id and popo.stat_void=0 /* add by violet at 2011-05-12 */

where receive.stat_void = 0 and 
   receive.status_receive = 2 and
   receive.dt_process is null and
   receive.source_code in ('PO','CS','PX')


   
  SELECT received.id_received,   
         received.id_receive,   
         received.id_expect_received,   
         received.source_id,   
         received.id_icim_comp,   
         received.id_icstkroom, 
			received.quantity, 
         received.qty_pass,
         received.qty_iqc,
         received.qty_reject,
			received.qty_un_receive,
         received.up,   
         received.um,    
         received.id_admreason,   
         received.nocharge,   
         received.id_apinv,
			received.up_inv,
			received.id_received_match,
			received.id_glsubject_db,
			received.subject_no_db,
			received.id_glsubject_cr,
			received.subject_no_cr,
         received.dt_create,   
         received.create_by,   
         received.dt_update,   
         received.update_by,   
         received.stat_void,
         received_extension.part_no,
         received_extension.partners_reference_no,
         received_extension.model_no,
         received_extension.description,
         received_extension.brand,
         received_extension.goods_code,
         received_extension.comments,
	 		received.loc_iqc,
			received.currency_inv,
	 		received.qty_inv,
	 		received.dt_ap ,
			received.stat_apvh,
			received.stat_costvh,
			received.stat_accounting,
			received.amt_local_cost,
			received.id_admslip,
			received.currency,
			received.cost_id,
			received.invoice_no,
			expect_receive.id_expect_receive,
			expect_receive.id_rate_type,
			expect_receive.source_code,
			expect_receive.source_no,
			received.location,
			wh_loc = icidf_location.location,
			received.iccrm_no,
			received.stat_expic,
			received.stat_asset,
			stat_return = case when received.id_icstkroom = admfacility.id_icstockroom_return and admfacility.id_icstockroom_return <> 0 then 1 else 0 end
    FROM  ((received received left join received_extension received_extension on received.id_received =  received_extension.id_received)
			left join icidf_location icidf_location on  received.id_icstkroom = icidf_location.id_icstockroom and  received.id_icim_comp = icidf_location.id_icim_comp),
			expect_receive  expect_receive,
			expect_received expect_received,
			admfacility admfacility 
			
   where received.stat_void = 0
      and received.id_receive = :arg_id_receive 
	  and admfacility.id_admfacility = expect_receive.id_admfacility_receive
	  and expect_receive.id_expect_receive = expect_received.id_expect_receive 
	  and expect_received.id_expect_received = received.id_expect_received 
	  and expect_receive.stat_void = 0 
	  and expect_received.stat_void = 0 	


