<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<!- ******************************************************************* ->
<!- * File: upload.reports.aspx                                       * ->
<!- *                                                                 * ->
<!- * Purpose: Uploads condition reports                              * ->
<!- *                                                                 * ->
<!- * Written by: m.samuel 7.9.2006                                   * ->
<!- *                                                                 * ->
<!- ******************************************************************* -> 

<%@ Import NameSpace="IBM.Data.DB2.iseries" %>
<%@ Import NameSpace="System.Data" %>
<%@ Import NameSpace="System.IO" %>
<%@ Import NameSpace="System.Runtime.InteropServices" %>
<!- ******************************************************************* ->
<!- *                      Define Script                              * ->
<!- ******************************************************************* ->  
<Script Runat="Server">

    Public strVin As String

    ' ******************************************************************* ->
    ' *                      Page Load Subroutine                       * ->
    ' ******************************************************************* -> 
    Sub Page_Load()

    End Sub
    ' ******************************************************************* ->
    ' *                      Upload Images Buttone Clicked              * ->
    ' ******************************************************************* -> 
    Sub Button_Click(s As Object, e As EventArgs)

        lblMessage.Text = ""

        If txtStock.Text = "" Then
            lblMessage.Text = "Please enter an Stock Number Number!"
        Else
            If inpFileUp.HasFile = False Then
                lblMessage.Text = "Please Select a File to Upload!"
            Else
                ' Create Folder
                System.IO.Directory.CreateDirectory("\\ats58\NTPInspections\" + txtStock.Text.Trim())

                If inpFileUp.PostedFile.ContentLength() <> 0 Then
                    inpFileUp.SaveAs("\\ats58\NTPInspections\" + txtStock.Text.Trim() + "\NtpInspectionForm.pdf")
                End If

                lblMessage.Text = "NTP Inspection Report Uploaded!"
            End If
        End If
    End Sub
    ' ******************************************************************* ->
    ' * Link load inspections                                           * ->
    ' ******************************************************************* -> 
    Sub Button_LoadInspections_Click(s As Object, e As EventArgs)

        lblMessage.Text = ""

        dgrdOrders.DataSource = Nothing
        dgrdOrders.DataBind()

        If txtStock.Text = "" Or Not IsNumeric(txtStock.Text) Then
            lblMessage.Text = "Please enter a valid Stock Number Number!"
        Else
            If System.IO.File.Exists("\\ats58\NTPInspections\" + txtStock.Text.Trim() + "\NtpInspectionForm.pdf") Then
                getInpsections()
                lblMessage.Text = "Uploaded NTP Inspection File of " & txtStock.Text.Trim() + ": "
            Else
                lblMessage.Text = "NTP Inspection File of " & txtStock.Text.Trim() + " not found!"
            End If
        End If
    End Sub
    ' *********************************************************************
    ' * getInspections() and bind to grid                                 *
    ' *********************************************************************	
    Sub getInpsections()

        Dim con As New iDB2Connection
        Dim dadInspections As iDB2DataAdapter
        Dim dstInspections As DataSet
        Dim cmdSelect As iDB2Command
        Dim strSelect As String

        con.ConnectionString = System.Configuration.ConfigurationManager.AppSettings("ConnString")
        con.Open()
        ' *-----------------------------------------------------------------* ->
        ' * Define SQL to info from header and detail file                  * ->
        ' *-----------------------------------------------------------------* ->  
        strSelect = "Select sdhsalno as saleNumber, shhstat as status, sdhstkno as stockNumber, shhbrn1 as branch, " + _
                    "substr(char(sdhinspdtu),5,2) || '-' ||  substr(char(sdhinspdtu),7,2) || '-' || substr(char(sdhinspdtu),1,4) as dateUploaded " + _
                    "from ais2000d.saldthst a join ais2000d.salhdhst b on a.sdhsalno = b.shhsalno " + _
                    "where sdhstkno = " + txtStock.Text.Trim() + _
                    " Union " + _
                    "Select sldsalno as saleNumber, sldstat as status, sldstkno as stockNumber, slhbrn1 as branch, " + _
                    "substr(char(sldinspdtu),5,2) || '-' ||  substr(char(sldinspdtu),7,2) || '-' || substr(char(sldinspdtu),1,4) as dateUploaded " + _
                    "from ais2000d.saldtl a join ais2000d.salhdr b on a.sldsalno = b.slhsalno " + _
                    "where slhstat not in ('Q','V') and sldstkno = " + txtStock.Text.Trim()

        cmdSelect = New iDB2Command(strSelect, con)
        cmdSelect.CommandTimeout = 0

        dadInspections = New iDB2DataAdapter(cmdSelect)
        dstInspections = New System.Data.DataSet
        dadInspections.Fill(dstInspections)
        dgrdOrders.DataSource = dstInspections
        dgrdOrders.DataBind()
        con.Close()

    End Sub

</script>
<!- ******************************************************************* ->
<!- *                       End Script                                * ->
<!- ******************************************************************* ->  
<html>
<title>Image Upload</title> 
<style type="text/css">
<!--
body {
	margin-left: 0px;
	margin-top: 0px;
	margin-right: 0px;
	margin-bottom: 0px;
}
.style1 {
	font-family: Arial, Helvetica, sans-serif;
	font-weight: bold;
}
.style2 {	font-family: Arial, Helvetica, sans-serif;
	font-size: small;
	font-style: italic;
	color: #0000FF;
}
.style3 {
	font-family: Arial, Helvetica, sans-serif;
	color: #0000FF;
}
    .auto-style1 {
        height: 30px;
    }
-->
</style>    

<body>

<form runat="Server">

<center>
<table>

 <tr>
    <td>
      <img src="../images/arrowlogoweb.gif">
     
  </tr>

    <tr>
        <td align="center">
           <b>Upload NTP Inspection Form</b>
      </td>       
    </tr>

    <tr>
        <td>&nbsp</td>
    </tr>

<tr> 
    <td>       

    <b>Enter Stock Number:</b>
    <asp:TextBox id="txtStock" runat="server"/>  
        
    </td>
    </tr>

 <tr>
      <td>&nbsp</td>
  </tr>
    
<tr>
    <td>
    <asp:FileUpload id="inpFileUp" runat="server" ForeColor="Red" />   
    </td>
</tr> 	
    
 <tr>
        <td>&nbsp</td>
 </tr>    	

<tr>
    <td class="auto-style1">          
    <asp:Button
    Text="Upload NTP Inspection File"
    OnClick="Button_Click"
    runat="server" />  

   <asp:Button
    Text="View NTP Inspection File"
    OnClick="Button_LoadInspections_Click"
    runat="server" /> 
        
    </td>
</tr> 

 <tr>
        <td>&nbsp</td>
 </tr>  

<tr>
    <td>
    <asp:label id="lblMessage" font-bold="true"  foreColor="#FF0000" runat="server"/>	
    </td>
</tr>

<tr>
        <td>&nbsp</td>
 </tr> 
    
 <tr>
    <td>

    <div align="center">                
    <asp:DataGrid
        ID="dgrdOrders"
        Width="99%"        
        AllowPaging="True"
        PagerStyle-Mode="NumericPages"
        PagerStyle-Position="TopAndBottom"
        PagerStyle-HorizontalAlign="center"
        PagerStyle-BackColor="#eeeeee"
        ItemStyle-HorizontalAlign = "center"             
        AutoGenerateColumns="False"
        CellPadding="1"                     
        runat="server">

        <HeaderStyle BackColor="#eeeeee" HorizontalAlign="Center" Font-Bold="True">
        </HeaderStyle>

     <Columns>

         <asp:BoundColumn
           HeaderText="Branch" 
           DataField="branch"/>       
         
          <asp:BoundColumn
           HeaderText="Sales Number" 
           DataField="saleNumber"/>    

	  <asp:BoundColumn
           HeaderText="Status" 
           DataField="status"/>      		     

         <asp:BoundColumn
           HeaderText="Stock Number" 
           DataField="stockNumber"/>  
            
         <asp:BoundColumn
           HeaderText="Date Uploaded" 
           DataField="dateUploaded"/>   
            
         <asp:TemplateColumn>
         <headertemplate>View</headertemplate>
         <itemtemplate>  
          <a href="javascript:;" onclick="window.open('http://corp.arrowtruck.com/NTPInspection/Forms/<%# DataBinder.Eval(Container.DataItem, "stockNumber") %>/NtpInspectionForm.pdf','myWin','location=yes,scrollbars=yes,resizable=yes,toolbar=yes,status=yes,width=400,height=400,top=0,left=0');">View File</a>    </itemtemplate>
        </asp:TemplateColumn>             
                          
     </Columns>

    </asp:DataGrid>
    </div>               


    </td>
</tr>


</table>	
</center>

</form>		

</body>
</html>
