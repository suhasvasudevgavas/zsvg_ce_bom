CLASS zsvg_cl_ce_bom DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
ENDCLASS.


CLASS zsvg_cl_ce_bom IMPLEMENTATION.
  METHOD if_rap_query_provider~select.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(lv_offset) = io_request->get_paging( )->get_offset( ).
    DATA(lv_page_size) = io_request->get_paging( )->get_page_size( ).
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(lt_requested_elements) = io_request->get_requested_elements( ).
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(lt_sort_elements) = io_request->get_sort_elements( ).
    DATA(lv_filter_sql_string) = io_request->get_filter( )->get_as_sql_string( ).

    DATA(lt_bom) = NEW zsvg_cl_bom_api( )->get_material_bom( ).

    SELECT FROM @lt_bom AS bom
      FIELDS *
      WHERE (lv_filter_sql_string)
      INTO TABLE @DATA(lt_bom_filtered)
      UP TO @lv_page_size ROWS.

    IF io_request->is_data_requested( ).
      io_response->set_data( it_data = lt_bom_filtered ).
    ENDIF.

    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lines( lt_bom_filtered ) ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
