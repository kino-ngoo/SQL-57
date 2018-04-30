

--/*
 --SELECT * FROM vw_orig_openpo

   SELECT c.vendor_no ,c.vendor_name ,c.dt_expire ,a.* 
     FROM vw_orig_openpo a ,admuser b ,vendor c
    WHERE a.id_buyer = b.id_admuser
	  AND a.id_vendor_order = c.id_vendor
	  AND b.dt_expire_user is not NULL 
    ORDER BY a.dt_schedule

   SELECT c.vendor_no ,c.vendor_name ,c.dt_expire ,a.* 
     FROM vw_orig_openpo a ,admuser b ,vendor c
    WHERE a.id_buyer = b.id_admuser
	  AND a.id_vendor_order = c.id_vendor
	  AND b.dt_expire_user is NULL 
	ORDER BY a.dt_schedule

   SELECT c.vendor_no ,c.vendor_name ,c.dt_expire ,a.* 
     FROM vw_orig_openpo a ,admuser b ,vendor c
    WHERE a.id_buyer = b.id_admuser
	  AND a.id_vendor_order = c.id_vendor
	  AND a.po_no like 'Y%'
	ORDER BY a.dt_schedule

-- partner_relation.stat_related_party = 1 Ãö«Y¥ø·~
SELECT partner_relation.id_admcomp,   
         partner_relation.id_partner_relation,   
         partner_relation.id_vendor,   
         partner_relation.id_oecust_br,   
         partner_relation.stat_void,
			oecust_br.cust_no,
			oecust_br.br_name,
			vendor.vendor_no,
			vendor.vendor_name,
			partner_relation.stat_related_party 
		,partner_relation.dt_create
 		,partner_relation.dt_update
		,partner_relation.create_by
		,partner_relation.update_by
		,partner_relation.remark -- add by renee 2012-07-09 for MR201207-028A
 FROM (partner_relation partner_relation  left join vendor vendor 
		 on partner_relation.id_vendor = vendor.id_vendor ) left join oecust_br oecust_br
		 on partner_relation.id_oecust_br = oecust_br.id_oecust_br
	where partner_relation.stat_void = 0  	
	and	partner_relation.id_admcomp = 9
	and partner_relation.stat_related_party = 1

--*/

--CREATE VIEW [dbo].[vw_orig_openpo] AS

   SELECT id_admcomp            = po.id_admcomp
         ,id_admslip            = po.id_admslip
         ,id_popod              = pod.id_popod
         ,id_popo               = po.id_popo
         ,id_popr               = pr.id_popr
         ,po_no                 = po.po_no
         ,linenumber            = pod.linenumber 
         ,dt_period             = CONVERT(datetime,CONVERT(char(10),GETDATE(),112))
         ,dt_schedule           = CONVERT(datetime,CONVERT(char(10),ISNULL(podsch.dt_schedule,DATEADD(year,10,GETDATE())),112))      --if podsch.dt_schedule is NULL then Geatedate+10year
         ,id_icstockroom        = pod.id_icstockroom
         ,id_icim_comp          = pod.id_icim_comp
         ,id_buyer              = po.id_buyer
         ,buyer_name            = ISNULL(buyer.user_name,'')
         ,buyer_id              = ISNULL(buyer.user_id,'')  
         ,id_vendor_order       = po.id_vendor_order
         ,up                    = pod.up
         ,qty_openpo            = SUM(podsch.qty_promise)
         ,qty_openpo_move_last5 = SUM(CASE WHEN CONVERT(datetime,CONVERT(char(10),ISNULL(podsch.dt_schedule,DATEADD(year,10,GETDATE())),112)) < DATEADD(day,-5,CONVERT(datetime,CONVERT(char(6),DATEADD(month,1,CONVERT(datetime,CONVERT(char(10),ISNULL(podsch.dt_schedule,DATEADD(year,10,GETDATE())),112))),112)+'01')) THEN podsch.qty_promise ELSE 0 END)
         ,qty_buy               = pod.qty_buy
         ,qty_pass              = pod.qty_pass
         ,qty_iqc               = pod.qty_iqc
         ,status_popo           = po.status_popo
         ,dept_id               = admdept.dept_id
         ,id_project            = pr.id_project 
         ,currency              = po.currency 
         ,po_type               = po.po_type
         ,stat_gotoreceiving    = pod.stat_gotoreceiving
         ,dt_need               = pod.dt_need
         ,slip.stat_supply
     FROM ((popo po with (nolock) 
LEFT JOIN admuser buyer with (nolock) ON po.id_admcomp = buyer.id_admcomp
                                     AND po.id_buyer = buyer.id_admuser
)
LEFT JOIN admdept admdept with (nolock) on po.cost_id = admdept.id_admdept
)
         ,admslip slip with (nolock)
         ,popr pr with (nolock) 
         ,popod pod with (nolock)      
         ,popodsch podsch with (nolock) 
    WHERE po.stat_void = 0
      AND po.id_admslip = slip.id_admslip
      AND po.dt_forceclose IS NULL
      AND pr.id_popr = po.id_popr 
      AND (po.status_po < 7 OR po.status_po = 10 )
      AND po.id_popo = pod.id_popo
      AND pod.stat_void = 0   
      AND pod.dt_forceclose IS NULL
      AND pod.status_popod <=2
      AND pod.qty_buy - pod.qty_pass - pod.qty_iqc > 0   
      AND po.po_no = podsch.po_no
      AND pod.linenumber = podsch.cust_linenumber
      AND ISNULL(podsch.cust_linenumber,'') <> ''
    GROUP BY po.id_admcomp
            ,po.id_admslip
            ,pod.id_popod
            ,po.id_popo
            ,pr.id_popr
            ,po.po_no
            ,pod.linenumber 
            ,CONVERT(datetime,CONVERT(char(10),ISNULL(podsch.dt_schedule,DATEADD(year,10,GETDATE())),112))
            ,pod.id_icstockroom
            ,pod.id_icim_comp
            ,po.id_buyer
            ,ISNULL(buyer.user_name,'')
            ,ISNULL(buyer.user_id,'')  
            ,po.id_vendor_order
            ,pod.up
            ,pod.qty_buy
            ,pod.qty_pass
            ,pod.qty_iqc 
            ,status_popo
            ,admdept.dept_id 
            ,pr.id_project  
            ,po.currency 
            ,po.po_type
            ,pod.stat_gotoreceiving
            ,pod.dt_need
            ,slip.stat_supply

UNION

   SELECT id_admcomp            = po.id_admcomp
         ,id_admslip            = po.id_admslip
         ,id_popod              = pod.id_popod
         ,id_popo               = po.id_popo
         ,id_popr               = pr.id_popr
         ,po_no                 = po.po_no
         ,linenumber            = pod.linenumber 
         ,dt_period             = CONVERT(datetime,CONVERT(char(10),GETDATE(),112))
         ,dt_schedule           = CONVERT(datetime,CONVERT(char(10),ISNULL(podsch.dt_schedule,DATEADD(year,10,GETDATE())),112))
         ,id_icstockroom        = pod.id_icstockroom
         ,id_icim_comp          = pod.id_icim_comp
         ,id_buyer              = po.id_buyer
         ,buyer_name            = ISNULL(buyer.user_name,'')
         ,buyer_id              = ISNULL(buyer.user_id,'')  
         ,id_vendor_order       = po.id_vendor_order
         ,up                    = pod.up
         ,qty_openpo            = SUM(podsch.qty_promise)
         ,qty_openpo_move_last5 = SUM(case when CONVERT(datetime,CONVERT(char(10),ISNULL(podsch.dt_schedule,DATEADD(year,10,GETDATE())),112)) < DATEADD(day,-5,CONVERT(datetime,CONVERT(char(6),DATEADD(month,1,CONVERT(datetime,CONVERT(char(10),ISNULL(podsch.dt_schedule,DATEADD(year,10,GETDATE())),112))),112)+'01')) then podsch.qty_promise else 0 end)
         ,qty_buy               = pod.qty_buy
         ,qty_pass              = pod.qty_pass
         ,qty_iqc               = pod.qty_iqc
         ,status_popo           = po.status_popo
         ,dept_id               = admdept.dept_id 
         ,id_project            = pr.id_project
         ,currency              = po.currency  
         ,po_type               = po.po_type
         ,stat_gotoreceiving    = pod.stat_gotoreceiving 
         ,dt_need               = pod.dt_need
         ,slip.stat_supply
     FROM ((popo po with (nolock) 
LEFT JOIN admuser buyer with (nolock) ON po.id_admcomp = buyer.id_admcomp
                                     AND po.id_buyer = buyer.id_admuser
)
LEFT JOIN admdept admdept with (nolock) on po.cost_id = admdept.id_admdept
)
         ,admslip slip with (nolock)
         ,popr pr with (nolock) 
         ,popod pod with (nolock)      
         ,popodsch podsch with (nolock) 
    WHERE po.stat_void = 0
      AND po.id_admslip = slip.id_admslip
      AND po.dt_forceclose IS NULL
      AND pr.id_popr = po.id_popr 
      AND (po.status_po < 7 OR po.status_po = 10 )
      AND po.id_popo = pod.id_popo
      AND pod.stat_void = 0
      AND pod.dt_forceclose IS NULL
      AND pod.status_popod IN (3,4)
      AND pod.qty_buy - pod.qty_pass - pod.qty_iqc > 0   
      AND po.po_no = podsch.po_no
      AND pod.seller_linenumber = podsch.cust_linenumber
      AND ISNULL(podsch.cust_linenumber,'') <> ''
    GROUP BY po.id_admcomp
            ,po.id_admslip
            ,pod.id_popod
            ,po.id_popo
            ,pr.id_popr
            ,po.po_no
            ,pod.linenumber 
            ,CONVERT(datetime,CONVERT(char(10),ISNULL(podsch.dt_schedule,DATEADD(year,10,GETDATE())),112))
            ,pod.id_icstockroom
            ,pod.id_icim_comp
            ,po.id_buyer
            ,ISNULL(buyer.user_name,'')
            ,ISNULL(buyer.user_id,'')  
            ,po.id_vendor_order
            ,pod.up
            ,pod.qty_buy
            ,pod.qty_pass
            ,pod.qty_iqc
            ,status_popo
            ,admdept.dept_id 
            ,pr.id_project 
            ,po.currency 
            ,po.po_type
            ,pod.stat_gotoreceiving
            ,pod.dt_need
            ,slip.stat_supply

UNION 

   SELECT id_admcomp            = po.id_admcomp
         ,id_admslip            = po.id_admslip
         ,id_popod              = pod.id_popod
         ,id_popo               = po.id_popo
         ,id_popr               = pr.id_popr
         ,po_no                 = po.po_no
         ,linenumber            = pod.linenumber 
         ,dt_period             = CONVERT(datetime,CONVERT(char(10),GETDATE(),112))
         ,dt_schedule           = CONVERT(datetime,CONVERT(char(10),ISNULL(pod.dt_schedule,DATEADD(year,10,GETDATE())),112))
         ,id_icstockroom        = pod.id_icstockroom
         ,id_icim_comp          = pod.id_icim_comp
         ,id_buyer              = po.id_buyer
         ,buyer_name            = ISNULL(buyer.user_name,'')
         ,buyer_id              = ISNULL(buyer.user_id,'')  
         ,id_vendor_order       = po.id_vendor_order
         ,up                    = pod.up
         ,qty_openpo            = pod.qty_buy - pod.qty_pass - pod.qty_iqc
         ,qty_openpo_move_last5 = CASE WHEN CONVERT(datetime,CONVERT(char(10),ISNULL(pod.dt_schedule,DATEADD(year,10,GETDATE())),112)) < DATEADD(day,-5,CONVERT(datetime,CONVERT(char(6),DATEADD(month,1,CONVERT(datetime,CONVERT(char(10),ISNULL(pod.dt_schedule,DATEADD(year,10,GETDATE())),112))),112)+'01')) THEN pod.qty_buy - pod.qty_pass - pod.qty_iqc ELSE 0 END
         ,qty_buy               = pod.qty_buy
         ,qty_pass              = pod.qty_pass
         ,qty_iqc               = pod.qty_iqc
         ,status_popo           = po.status_popo
         ,dept_id               = admdept.dept_id
         ,id_project            = pr.id_project  
         ,currency              = po.currency 
         ,po_type               = po.po_type
         ,stat_gotoreceiving    = pod.stat_gotoreceiving
         ,dt_need               = pod.dt_need
         ,slip.stat_supply
     FROM ((popo po with (nolock) 
LEFT JOIN admuser buyer with (nolock) ON po.id_admcomp = buyer.id_admcomp
                                     AND po.id_buyer = buyer.id_admuser
)
LEFT JOIN admdept admdept with (nolock) on po.cost_id = admdept.id_admdept
)  
         ,admslip slip with (nolock)
         ,popr pr with (nolock) 
         ,popod pod with (nolock) 
    WHERE po.stat_void = 0
      AND po.id_admslip = slip.id_admslip
      AND po.dt_forceclose IS NULL
      AND pr.id_popr = po.id_popr 
      AND (po.status_po < 7 OR po.status_po = 10 )
      AND po.id_popo = pod.id_popo
      AND pod.stat_void = 0
      AND pod.dt_forceclose IS NULL
      AND (pod.status_popod < 7 or pod.status_popod = 10 )
      AND pod.qty_buy - pod.qty_pass - pod.qty_iqc > 0   
      AND NOT EXISTS (SELECT 1 
                        FROM popodsch podsch with (nolock) 
                       WHERE podsch.po_no = po.po_no)




 




