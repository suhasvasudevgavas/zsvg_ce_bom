CLASS zsvg_cl_bom_api DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_results_bom,
             BillOfMaterialHeaderUUID TYPE sysuuid_c36,
             BillOfMaterial           TYPE c LENGTH 8,
             BillOfMaterialCategory   TYPE c LENGTH 1,
             BillOfMaterialVariant    TYPE c LENGTH 2,
             BillOfMaterialVersion    TYPE c LENGTH 4,
             Material                 TYPE c LENGTH 40,
             Plant                    TYPE c LENGTH 4,
           END OF ty_results_bom,

           tty_results_bom TYPE TABLE OF ty_results_bom WITH KEY BillOfMaterialHeaderUUID.

    TYPES: BEGIN OF ty_d_bom,
             results TYPE tty_results_bom,
           END OF ty_d_bom.

    TYPES: BEGIN OF ty_data_bom,
             d TYPE ty_d_bom,
           END OF ty_data_bom.

    TYPES: BEGIN OF ty_results_bomitem,
             BillOfMaterialItemUUID     TYPE sysuuid_c36,
             BillOfMaterialHeaderUUID   TYPE sysuuid_c36,
             BillOfMaterialComponent    TYPE c LENGTH 40,
             BillOfMaterialItemCategory TYPE c LENGTH 1,
             BillOfMaterialItemNumber   TYPE c LENGTH 4,
             BillOfMaterialItemUnit     TYPE c LENGTH 3,
             BillOfMaterialItemQuantity TYPE c LENGTH 10,
           END OF ty_results_bomitem,

           tty_results_bomitem TYPE TABLE OF ty_results_bomitem WITH KEY BillOfMaterialItemUUID.

    TYPES: BEGIN OF ty_d_bomitem,
             results TYPE tty_results_bomitem,
           END OF ty_d_bomitem.

    TYPES: BEGIN OF ty_data_bomitem,
             d TYPE ty_d_bomitem,
           END OF ty_data_bomitem.

    DATA ls_data_bom     TYPE ty_data_bom.
    DATA ls_data_bomitem TYPE ty_data_bomitem.

    METHODS get_material_bom IMPORTING VALUE(io_request)     TYPE REF TO if_rap_query_request
                             RETURNING VALUE(rt_results_bom) TYPE tty_results_bom.

    METHODS get_material_bom_count RETURNING VALUE(rv_count) TYPE int8.

    METHODS get_material_bomitem IMPORTING VALUE(io_request)         TYPE REF TO if_rap_query_request
                                 RETURNING VALUE(rt_results_bomitem) TYPE tty_results_bomitem.

    METHODS get_material_bomitem_count RETURNING VALUE(rv_count) TYPE int8.
ENDCLASS.


CLASS zsvg_cl_bom_api IMPLEMENTATION.
  METHOD get_material_bom.
    DATA(lv_offset) = io_request->get_paging( )->get_offset( ).
    DATA(lv_page_size) = io_request->get_paging( )->get_page_size( ).

    DATA(lv_filter_sql_string) = io_request->get_filter( )->get_as_sql_string( ).

    IF lv_filter_sql_string IS INITIAL.
      DATA(lv_url) = |https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/API_BILL_OF_MATERIAL_SRV;v=0002/MaterialBOM?| &&
                   |$top={ lv_page_size }&$skip={ lv_offset }| &&
                   |&$select=BillOfMaterialHeaderUUID%2CBillOfMaterial%2CBillOfMaterialCategory%2CBillOfMaterialVariant%2CBillOfMaterialVersion%2CEngineeringChangeDocument%2CMaterial%2CPlant|.
    ELSE.
      REPLACE 'BILLOFMATERIALHEADERUUID' IN lv_filter_sql_string WITH 'BillOfMaterialHeaderUUID'.
      REPLACE ' = ''' IN lv_filter_sql_string WITH '%20eq%20guid'''.
      lv_url = |https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/API_BILL_OF_MATERIAL_SRV;v=0002/MaterialBOM?| &&
                     |$select=BillOfMaterialHeaderUUID%2CBillOfMaterial%2CBillOfMaterialCategory%2CBillOfMaterialVariant%2CBillOfMaterialVersion%2CEngineeringChangeDocument%2CMaterial%2CPlant| &&
                     |&$filter={ lv_filter_sql_string }|.
    ENDIF.

    " 1.
    TRY.
        DATA(lo_dest) = cl_http_destination_provider=>create_by_url( lv_url ).
      CATCH cx_http_dest_provider_error.
        " handle exception
    ENDTRY.

    " 2.
    TRY.
        DATA(lo_client) = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_dest ).
      CATCH cx_web_http_client_error.
        " handle exception
    ENDTRY.

    " 3.
    DATA(lo_req) = lo_client->get_http_request( ).

    " 4.
    TRY.
        lo_req->set_header_fields( i_fields = VALUE #( (  name = 'APIKey' value = 'rnvBFmeNMR8sjrTYQGENKXD6YZlz8UZ2' )
                                                       (  name = 'DataServiceVersion' value = '2.0' )
                                                       (  name = 'Accept' value = 'application/json' ) ) ).
      CATCH cx_web_message_error.
        " handle exception
    ENDTRY.

    " 5.
    TRY.
        DATA(lo_res) = lo_client->execute( i_method = if_web_http_client=>get ).
      CATCH cx_web_http_client_error.
        " handle exception
    ENDTRY.

    " 6.
    TRY.
        DATA(lv_status) = lo_res->get_status( ).
      CATCH cx_web_message_error.
        " handle exception
    ENDTRY.

    " 7.
    IF lv_status-code = 200.
      TRY.
          DATA(lv_text) = lo_res->get_text( ).
        CATCH cx_web_message_error.
          " handle exception
      ENDTRY.
    ENDIF.

    /ui2/cl_json=>deserialize( EXPORTING json = lv_text
                               CHANGING  data = ls_data_bom ).

    rt_results_bom = ls_data_bom-d-results.
  ENDMETHOD.

  METHOD get_material_bom_count.
    DATA(lv_url) = |https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/API_BILL_OF_MATERIAL_SRV;v=0002/MaterialBOM/$count|.

    " 1.
    TRY.
        DATA(lo_dest) = cl_http_destination_provider=>create_by_url( i_url = lv_url ).
      CATCH cx_http_dest_provider_error.
        " handle exception
    ENDTRY.

    " 2.
    TRY.
        DATA(lo_client) = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_dest ).
      CATCH cx_web_http_client_error.
        " handle exception
    ENDTRY.

    " 3.
    DATA(lo_req) = lo_client->get_http_request( ).

    " 4.
    TRY.
        lo_req->set_header_fields( i_fields = VALUE #( (  name = 'APIKey' value = 'rnvBFmeNMR8sjrTYQGENKXD6YZlz8UZ2' )
                                                       (  name = 'DataServiceVersion' value = '2.0' )
                                                       (  name = 'Accept' value = 'application/json' ) ) ).
      CATCH cx_web_message_error.
        " handle exception
    ENDTRY.

    " 5.
    TRY.
        DATA(lo_res) = lo_client->execute( i_method = if_web_http_client=>get ).
      CATCH cx_web_http_client_error.
        " handle exception
    ENDTRY.

    " 6.
    TRY.
        DATA(lv_status) = lo_res->get_status( ).
      CATCH cx_web_message_error.
        " handle exception
    ENDTRY.

    " 7.
    IF lv_status-code = 200.
      TRY.
          DATA(lv_count) = lo_res->get_text( ).
        CATCH cx_web_message_error.
          " handle exception
      ENDTRY.
    ENDIF.

    rv_count = CONV int8( lv_count ).
  ENDMETHOD.

  METHOD get_material_bomitem.
    DATA(lv_offset) = io_request->get_paging( )->get_offset( ).
    DATA(lv_page_size) = io_request->get_paging( )->get_page_size( ).

    DATA(lv_filter_sql_string) = io_request->get_filter( )->get_as_sql_string( ).

    REPLACE 'BILLOFMATERIALHEADERUUID' IN lv_filter_sql_string WITH 'BillOfMaterialHeaderUUID'.
    REPLACE ' = ''' IN lv_filter_sql_string WITH '%20eq%20guid'''.
    replaCE ' ' in lv_filter_sql_string wITH ''.

    DATA(lv_url) = |https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/API_BILL_OF_MATERIAL_SRV;v=0002| &&
                   |/MaterialBOMItem?| &&
                   |$filter={ lv_filter_sql_string }| &&
                   |&$select=BillOfMaterialItemUUID%2CBillOfMaterialHeaderUUID%2CBillOfMaterialComponent%2CBillOfMaterialItemCategory%2CBillOfMaterialItemNumber%2CBillOfMaterialItemUnit%2CBillOfMaterialItemQuantity|.

    " 1.
    TRY.
        DATA(lo_dest) = cl_http_destination_provider=>create_by_url( lv_url ).
      CATCH cx_http_dest_provider_error.
        " handle exception
    ENDTRY.

    " 2.
    TRY.
        DATA(lo_client) = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_dest ).
      CATCH cx_web_http_client_error inTO daTA(lo_ex).
        data(lv_msg) = lo_ex->get_text( ).
    ENDTRY.

    " 3.
    DATA(lo_req) = lo_client->get_http_request( ).

    " 4.
    TRY.
        lo_req->set_header_fields( i_fields = VALUE #( (  name = 'APIKey' value = 'rnvBFmeNMR8sjrTYQGENKXD6YZlz8UZ2' )
                                                       (  name = 'DataServiceVersion' value = '2.0' )
                                                       (  name = 'Accept' value = 'application/json' ) ) ).
      CATCH cx_web_message_error.
        " handle exception
    ENDTRY.

    " 5.
    TRY.
        DATA(lo_res) = lo_client->execute( i_method = if_web_http_client=>get ).
      CATCH cx_web_http_client_error.
        " handle exception
    ENDTRY.

    " 6.
    TRY.
        DATA(lv_status) = lo_res->get_status( ).
      CATCH cx_web_message_error.
        " handle exception
    ENDTRY.

    " 7.
    IF lv_status-code = 200.
      TRY.
          DATA(lv_text) = lo_res->get_text( ).
        CATCH cx_web_message_error.
          " handle exception
      ENDTRY.
    ENDIF.

    /ui2/cl_json=>deserialize( EXPORTING json = lv_text
                               CHANGING  data = ls_data_bomitem ).

 rt_results_bomitem = ls_data_bomitem-d-results.

  ENDMETHOD.

  METHOD get_material_bomitem_count.

*  DATA(lv_filter_sql_string) = io_request->get_filter( )->get_as_sql_string( ).
*
*    REPLACE 'BILLOFMATERIALHEADERUUID' IN lv_filter_sql_string WITH 'BillOfMaterialHeaderUUID'.
*    REPLACE ' = ''' IN lv_filter_sql_string WITH '%20eq%20guid'''.
*    replaCE ' ' in lv_filter_sql_string wITH ''.
*
*    DATA(lv_url) = |https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/API_BILL_OF_MATERIAL_SRV;v=0002| &&
*                   |/MaterialBOMItem?| &&
*                   |$filter={ lv_filter_sql_string }| &&
*                   |/$count|.
*    " 1.
*    TRY.
*        DATA(lo_dest) = cl_http_destination_provider=>create_by_url( i_url = lv_url ).
*      CATCH cx_http_dest_provider_error.
*        " handle exception
*    ENDTRY.
*
*    " 2.
*    TRY.
*        DATA(lo_client) = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_dest ).
*      CATCH cx_web_http_client_error.
*        " handle exception
*    ENDTRY.
*
*    " 3.
*    DATA(lo_req) = lo_client->get_http_request( ).
*
*    " 4.
*    TRY.
*        lo_req->set_header_fields( i_fields = VALUE #( (  name = 'APIKey' value = 'rnvBFmeNMR8sjrTYQGENKXD6YZlz8UZ2' )
*                                                       (  name = 'DataServiceVersion' value = '2.0' )
*                                                       (  name = 'Accept' value = 'application/json' ) ) ).
*      CATCH cx_web_message_error.
*        " handle exception
*    ENDTRY.
*
*    " 5.
*    TRY.
*        DATA(lo_res) = lo_client->execute( i_method = if_web_http_client=>get ).
*      CATCH cx_web_http_client_error.
*        " handle exception
*    ENDTRY.
*
*    " 6.
*    TRY.
*        DATA(lv_status) = lo_res->get_status( ).
*      CATCH cx_web_message_error.
*        " handle exception
*    ENDTRY.
*
*    " 7.
*    IF lv_status-code = 200.
*      TRY.
*          DATA(lv_count) = lo_res->get_text( ).
*        CATCH cx_web_message_error.
*          " handle exception
*      ENDTRY.
*    ENDIF.
*
*    rv_count = CONV int8( lv_count ).
  ENDMETHOD.
ENDCLASS.
