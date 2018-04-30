
-- IQC Classify
   SELECT iqc_classify.id_iqcclassify
         ,iqc_classify.group_code
		 ,iqc_classify.classify_descrip     
     FROM iqc_classify   iqc_classify


-- IQC NTRS
	 SELECT iqc_ntrs.id_iqc_ntrs,   
            iqc_ntrs.id_iqcclassify,   
            iqc_ntrs.iqc_type,   
            iqc_ntrs.gonext_condition,   
            iqc_ntrs.next_iqc_type,   
            iqc_ntrs.goprior_condition_all_reject,   
            iqc_ntrs.goprior_condition_iqc_times,   
            iqc_ntrs.prior_iqc_type,   
            iqc_ntrs.create_by,   
            iqc_ntrs.dt_create,   
            iqc_ntrs.update_by,   
            iqc_ntrs.dt_update,   
            iqc_ntrs.stat_void  
       FROM iqc_ntrs   iqc_ntrs   
	  WHERE iqc_ntrs.stat_void  = 0 
	  --AND iqc_ntrs.id_iqcclassify = :arg_id_iqc_classify


-- IQC
   SELECT  iqc_sample_rate.id_iqcclassify ,
           iqc_sample_rate.id_samplerate ,
           iqc_sample_rate.id_iqc_method ,
           iqc_sample_rate.qty_inspect_from ,
           iqc_sample_rate.qty_inspect_to ,
           iqc_sample_rate.qty_sample ,
           iqc_sample_rate.qty_samplerate     
        FROM iqc_sample_rate     iqc_sample_rate  
        WHERE ( iqc_sample_rate.id_iqcclassify = :arg_iqcclassify )


   SELECT *
     FROM iqc_classify
	      ,iqc_ntrs
	WHERE iqc_classify.id_iqcclassify = iqc_ntrs.id_iqcclassify
   
   SELECT *
     FROM codetable
	WHERE group_id = 632

-- ⁵⁷ all
   SELECT iqc_classify.group_code
		 ,iqc_classify.classify_descrip
		 ,*
       -- DISTINCT cd.descrip
	 FROM codetable cm
	     ,codetable cd
		 ,iqc_ntrs
		 ,iqc_classify
	   --,iqc_master
	WHERE cm.id_codetable = cd.id_codetable
	  AND cd.id_codetable = iqc_ntrs.iqc_type
	  AND iqc_classify.id_iqcclassify = iqc_ntrs.id_iqcclassify
	--AND iqc_master.id_iqc_methed = cd.id_codetable
      AND cm.group_id = 632
    ORDER BY cd.id_codetable


-- ⁵⁷ iac_type, next_iqc_type, prior_iqc_type
   SELECT iqc_classify.group_code
		 ,iqc_classify.classify_descrip
	   --,iqc_ntrs.iqc_type                     AS 'IQC Type'
		 ,id.descrip                            AS 'IQC Type'
         ,iqc_ntrs.gonext_condition             AS 'All Pass Times'
       --,iqc_ntrs.next_iqc_type                AS 'Next IQC'
         ,nid.descrip                           AS 'Next IQC'
         ,iqc_ntrs.goprior_condition_all_reject AS 'Previous(All Times)'
         ,iqc_ntrs.goprior_condition_iqc_times  AS 'Previous(All Reject)'
       --,iqc_ntrs.prior_iqc_type               AS 'Previous IQC'
         ,pid.descrip                           AS 'Previous IQC'
	   --,*
       -- DISTINCT cd.descrip
	 FROM codetable im
	     ,codetable id
		 ,codetable nim
	     ,codetable nid
 		 ,codetable pim
	     ,codetable pid
	   --,iqc_master
	   --,iqc_sample_rate
		 ,iqc_ntrs
		 ,iqc_classify
	WHERE im.id_codetable = id.id_codetable
	  AND nim.id_codetable = nid.id_codetable
	  AND pim.id_codetable = pid.id_codetable
	  AND id.id_codetable = iqc_ntrs.iqc_type
	  AND nid.id_codetable = iqc_ntrs.next_iqc_type
	  AND pid.id_codetable = iqc_ntrs.prior_iqc_type
	--AND iqc_master.id_iqc_method = iqc_sample_rate.id_iqc_method
	  AND iqc_classify.id_iqcclassify = iqc_ntrs.id_iqcclassify
      AND im.group_id = 632
    ORDER BY id.id_codetable

   SELECT * 
     FROM iqc_master
