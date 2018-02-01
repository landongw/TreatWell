<%-- 
    Document   : setPrintLayout
    Created on : Nov 23, 2017, 7:41:09 PM
    Author     : Cori 5
--%>
<%@include file="../header.jsp"%>
<script>
    $(function () {
        displayPrintLayout();
    });


    function setMargins() {
        $('#main').css("margin-top", $('#margintop').val() + 'in');
        $('#main').css("margin-bottom", $('#marginBottom').val() + 'in');
        $('#main').css("margin-right", $('#marginRight').val() + 'in');
        $('#main').css("margin-left", $('#marginLeft').val() + 'in');
    }



    function editRow(id) {
        $('#layoutId').val(id);
        $.get('clinic.htm?action=getPrintLayoutById', {layoutId: id},
                function (obj) {
                    $('#marginTop').val(obj.TOP_MARGIN);
                    $('#marginBottom').val(obj.BOTTOM_MARGIN);
                    $('#addPrintLayout').modal('show');
                }, 'json');
    }


    function displayPrintLayout() {
        var $tbl = $('<table class="table table-striped table-bordered table-hover">');
        $tbl.append($('<thead>').append($('<tr>').append(
                $('<th class="center" width="5%">').html('Sr. #'),
                $('<th class="center" width="30%">').html('Top Margin'),
                $('<th class="center" width="30%">').html('Bottom Margin'),
                $('<th class="center" width="15%" colspan="1">').html('&nbsp;')
                )));
        $.get('clinic.htm?action=getPrintLayouts', {doctorId: $('#doctorId').val()},
                function (list) {
                    if (list !== null && list.length > 0) {
                        $tbl.append($('<tbody>'));
                        for (var i = 0; i < list.length; i++) {
                            var editHtm = '<i class="fa fa-pencil-square-o" aria-hidden="true" title="Click to Edit" style="cursor: pointer;" onclick="editRow(\'' + list[i].TW_PRINT_LAYOUT_ID + '\');"></i>';
                            var delHtm = '<i class="fa fa-trash-o" aria-hidden="true" title="Click to Delete" style="cursor: pointer;" onclick="deleteRow(\'' + list[i].TW_PRINT_LAYOUT_ID + '\');"></i>';
                            if ($('#can_edit').val() !== 'Y') {
                                editHtm = '&nbsp;';
                            }
                            if ($('#can_delete').val() !== 'Y') {
                                delHtm = '&nbsp;';
                            }
                            $tbl.append(
                                    $('<tr>').append(
                                    $('<td align="center">').html(eval(i + 1)),
                                    $('<td>').html(list[i].TOP_MARGIN),
                                    $('<td>').html(list[i].BOTTOM_MARGIN),
                                    $('<td align="center">').html(editHtm)
//                                    $('<td align="center">').html(delHtm)
                                    ));
                        }
                        $('#displayDiv').html('');
                        $('#displayDiv').append($tbl);
                        return false;
                    } else {
                        $('#displayDiv').html('');
                        $tbl.append(
                                $('<tr>').append(
                                $('<td class="center aligned negative" colspan="7">').html('<b>No data found.</b>')
                                ));
                        $('#displayDiv').append($tbl);
                        return false;
                    }
                }, 'json');
    }

    function saveData() {
        if ($.trim($('#marginTop').val()) === '') {
            $('#marginTop').notify('Margin Top is Required Field', 'error', {autoHideDelay: 15000});
            $('#marginTop').focus();
            return false;
        }

        if ($.trim($('#marginBottom').val()) === '') {
            $('#marginBottom').notify('Margin Bottom is Required Field', 'error', {autoHideDelay: 15000});
            $('#marginBottom').focus();
            return false;
        }
        
        var data = new FormData(document.getElementById('layoutForm'));
        $.ajax({
            url: 'clinic.htm?action=savePrintLayout',
            type: "POST",
            data: data,
            cache: false,
            dataType: 'json',
            processData: false, // tell jQuery not to process the data
            contentType: false   // tell jQuery not to set contentType

        }).done(function (data) {
             if (data.result === 'save_success') {
                $.bootstrapGrowl("Print Layout Data saved successfully.", {
                    ele: 'body',
                    type: 'success',
                    offset: {from: 'top', amount: 80},
                    align: 'right',
                    allow_dismiss: true,
                    stackup_spacing: 10
                });
                $('input:text').val('');
                displayPrintLayout();
                $('#addPrintLayout').modal('hide');
                return false;
            } else {
                $.bootstrapGrowl("Error in saving Print Layout. Please try again later.", {
                    ele: 'body',
                    type: 'error',
                    offset: {from: 'top', amount: 80},
                    align: 'right',
                    allow_dismiss: true,
                    stackup_spacing: 10
                });

                return false;
            }
        });
        return false;
    }

    function addLayoutDialog() {
        $('#layoutId').val('');
        $('#margintTop').val('');
        $('#marginBottom').val('');
        $('#addPrintLayout').modal('show');
    }
</script>
<div class="page-head">
    <!-- BEGIN PAGE TITLE -->
    <div class="page-title">
        <h1>Print Layout</h1>
    </div>
</div>

<div class="modal fade" id="addPrintLayout">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
                <h3 class="modal-title">Add Print Layout</h3>

            </div>
            <div class="modal-body">
                <div class="row">
                    <div class="col-md-12">
                        <div class="portlet box green">
                            <div class="portlet-title tabbable-line">
                                <div class="caption">
                                    Set Print Layout
                                </div>
                            </div>
                            <div class="portlet-body">
                                <form action="#" role="form" method="post" id="layoutForm" >   
                                    <input type="hidden" name="layoutId" id="layoutId" value="">
                                    <input type="hidden" name="doctorId" id="doctorId" value="${requestScope.refData.doctorId}">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Margin Top</label>
                                                <div>
                                                    <input type="text" class="form-control" name="marginTop" id="marginTop" placeholder="Margin Top In Inches" >
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Margin Bottom</label>
                                                <div>
                                                    <input type="text" class="form-control" name="marginBottom" id="marginBottom" placeholder="Margin Bottom In Inches" >
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Header Logo</label>
                                                <div>
                                                    <input type="file" class="form-control" name="headerLogo" id="headerLogo">
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Footer Logo</label>
                                                <div>
                                                    <input type="file" class="form-control" name="footerLogo" id="footerLogo" >
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-offset-8 col-md-4 text-right">
                                            <button type="button" class="btn blue" onclick="saveData();"><i class=""></i> Set Print Layout</button>
                                        </div>
                                    </div>
                                </form>         
                                <!--                <button type="button" class="btn btn-primary" onclick="saveData();">Save</button>
                                                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>-->
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<div class="row">
    <div class="col-md-12">
        <div class="portlet box green">
            <div class="portlet-title tabbable-line">
                <div class="caption">
                    Print Layout
                </div>
            </div>
            <div class="portlet-body">
                <input type="hidden" id="can_edit" value="${requestScope.refData.CAN_EDIT}">
                <input type="hidden" id="can_delete" value="${requestScope.refData.CAN_DELETE}">
                <form action="#" onsubmit="return false;" role="form" method="post">
                    <div class="row">
                        <div class="col-md-12 text-right" style="padding-top: 23px;">
                            <c:if test="${requestScope.refData.CAN_ADD=='Y'}">
                                <button type="button" class="btn blue" onclick="addLayoutDialog();"><i class="fa fa-plus-circle"></i> New Print Layout</button>
                            </c:if>
                        </div>
                    </div>
                    <br/>
                    <div class="row">
                        <div class="col-md-12">
                            <div id="displayDiv"></div>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<%@include file="../footer.jsp"%>