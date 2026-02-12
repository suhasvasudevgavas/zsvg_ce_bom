CLASS zsvg_cl_bom_api DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES : BEGIN OF ty_bom,
              BillOfMaterial             TYPE c LENGTH 8,
              Material                   TYPE c LENGTH 40,
              Plant                      TYPE c LENGTH 4,
              BillOfMaterialVariantUsage TYPE c LENGTH 1,
              BillOfMaterialVariant      TYPE c LENGTH 2,
            END OF ty_bom,
            tty_bom TYPE TABLE OF ty_bom WITH KEY BillOfMaterial Material Plant BillOfMaterialVariantUsage BillOfMaterialVariant.

    TYPES: BEGIN OF ty_d,
             results TYPE tty_bom,
           END OF ty_d.

    TYPES: BEGIN OF ty_data,
             d TYPE ty_d,
           END OF ty_data.

    DATA ls_data TYPE ty_data.

    METHODS get_material_bom RETURNING VALUE(rt_bom) TYPE tty_bom.
ENDCLASS.


CLASS zsvg_cl_bom_api IMPLEMENTATION.
  METHOD get_material_bom.
    DATA(lv_url) = 'https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/API_BILL_OF_MATERIAL_SRV;v=0002/MaterialBOM?$top=50&$select=BillOfMaterial%2CBillOfMaterialVariant%2CMaterial%2CPlant%2CBillOfMaterialVariantUsage'.

    " 1.
    TRY.
        DATA(lo_dest) = cl_http_destination_provider=>create_by_url( i_url = CONV string( lv_url ) ).
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
                               CHANGING  data = ls_data ).

    rt_bom = ls_data-d-results.
  ENDMETHOD.
ENDCLASS.
