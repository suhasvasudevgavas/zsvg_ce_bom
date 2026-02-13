CLASS zsvg_cl_ce_bomitem DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
ENDCLASS.


CLASS zsvg_cl_ce_bomitem IMPLEMENTATION.
  METHOD if_rap_query_provider~select.
    IF io_request->is_data_requested( ).
      io_response->set_data( NEW zsvg_cl_bom_api( )->get_material_bomitem( io_request = io_request ) ).
    ENDIF.

    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( NEW zsvg_cl_bom_api( )->get_material_bomitem_count( ) ).
    ELSE.
      io_response->set_total_number_of_records(
          lines( NEW zsvg_cl_bom_api( )->get_material_bomitem( io_request = io_request ) ) ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
