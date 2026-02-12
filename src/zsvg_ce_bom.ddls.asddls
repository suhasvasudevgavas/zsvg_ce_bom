@EndUserText.label: 'CDS custom entity for BOM'

@Metadata.allowExtensions: true

@ObjectModel.query.implementedBy: 'ABAP:ZSVG_CL_CE_BOM'
define root custom entity zsvg_ce_bom

{
  key BillOfMaterial : abap.char(8);
  key Material : abap.char(40);
  key Plant : abap.char(4);
  key BillOfMaterialVariantUsage : abap.char(1);
  key BillOfMaterialVariant : abap.char(2);
}
