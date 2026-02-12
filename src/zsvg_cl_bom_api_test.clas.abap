CLASS zsvg_cl_bom_api_test DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zsvg_cl_bom_api_test IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA(lo_bom_api) = NEW zsvg_cl_bom_api( ).

    out->write( lo_bom_api->get_material_bom( ) ).
  ENDMETHOD.
ENDCLASS.
