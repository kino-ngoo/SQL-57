/*
Message                            
Item feed                I590   ITEM_MASTER 
Open PO                  I592   OPENPO
Work Order               I601   WORKORDER
WO reservations          I602   RESERVATION 
On Hand                  I605   ONHAND
In-Transit Inventory     I606   INSTRANSIT 
請在MISSQL_BK 執行
*/

declare @INPUT nvarchar(max) ,@OUTPUT nvarchar(max),@filename nvarchar(255),@folder varchar(60),@folder_t varchar(60),@code varchar(10),@code2 varchar(10), @date varchar(10)


select @code = 'I592'        --<< 請參考上面的對照表
select @code2 = 'PO'         --<< 請參考上面的對照表
select @date = '2017-09-28'  --<<請參考放資料的路徑，資料夾名稱

select @filename = '20170928_152542_ACCTON_OPENPO.xml' --<<改成自己的檔案名稱
select @folder = '\\srv_missqlbk\storedcerts\FTP\FILES\ibp\test\' + @date + '\'
select @folder_t = '/usr/sap/interfaces/SFTP/acctsftp/IBP/' + @code + '/' + @code2 + '/'

/*下方的皆不需額外修改，請修改上面的變數即可*/
-----------------------------------------------------------------------------------------------------------------------------------------------
--select '@filename'=@filename,'@folder'=@folder,'@folder_t'=@folder_t

select @INPUT = '
<INPUTSTRING>
    <ROWSET>
         <DATA>                        
            <FTPACCOUNT>acctsftp</FTPACCOUNT>    
              <FTPPASSWORD></FTPPASSWORD>        
            <FTPURL>64.43.237.233</FTPURL>
            <ACTION>SSH_SFTPUpload</ACTION>
              <SSHPATH>C:\storedcerts\CLR\CLRFTP\219.90.1.103_juniper_ssh_private.ppk</SSHPATH>             
            <SOURCEFILEPATH>' + @folder + @filename + '</SOURCEFILEPATH>        
            <TARGETFILEPATH>' + @folder_t + @filename  + '</TARGETFILEPATH>
        </DATA>
        </ROWSET>
</INPUTSTRING>'

--select cast(@INPUT as xml)

/*
<INPUTSTRING>
    <ROWSET>
         <DATA>                        
            <FTPACCOUNT>acctsftp</FTPACCOUNT>    
              <FTPPASSWORD></FTPPASSWORD>        
            <FTPURL>64.43.237.233</FTPURL>
            <ACTION>SSH_SFTPUpload</ACTION>
              <SSHPATH>C:\storedcerts\CLR\CLRFTP\219.90.1.103_juniper_ssh_private.ppk</SSHPATH>             
            <SOURCEFILEPATH>\\srv_missqlbk\storedcerts\FTP\FILES\ibp\test\2017-09-22\20170922_141008_ACCTON_OPENPO.xml</SOURCEFILEPATH>        
            <TARGETFILEPATH>/usr/sap/interfaces/SFTP/acctsftp/IBP/I592/PO/20170922_141008_ACCTON_OPENPO.xml</TARGETFILEPATH>
        </DATA>
        </ROWSET>
</INPUTSTRING>

<OUTPUTSTRING>
   <PROCESSENDTIME>2017/09/22 03:52:55</PROCESSENDTIME>
   <PROCESSSTARTTIME>2017/09/22 03:52:46</PROCESSSTARTTIME>
   <ROWSET>
      <DATA />
	</ROWSET>
</OUTPUTSTRING>

*/

exec gateway.dbo.zp_clr_ftp @INPUT , @OUTPUT output

select @INPUT
select @OUTPUT





