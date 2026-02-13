@EndUserText.label: 'CDS custom entity for BOM'

@Metadata.allowExtensions: true

@ObjectModel.query.implementedBy: 'ABAP:ZSVG_CL_CE_BOM'
define root custom entity zsvg_ce_bom

{
  key BillOfMaterialHeaderUUID : sysuuid_c36;

      BillOfMaterial : abap.char(8);
      BillOfMaterialCategory : abap.char(1);
      BillOfMaterialVariant : abap.char(2);
      BillOfMaterialVersion : abap.char(4);
      EngineeringChangeDocument : abap.char(12);
      Material : abap.char(40);
      Plant : abap.char(4);

      _bomitem : composition [0..*] of zsvg_ce_bomitem;
}
