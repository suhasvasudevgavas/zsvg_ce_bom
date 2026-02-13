@EndUserText.label: 'CDS custom entity for BOM ITEM'

@Metadata.allowExtensions: true

@ObjectModel.query.implementedBy: 'ABAP:ZSVG_CL_CE_BOMITEM'
define custom entity zsvg_ce_bomitem

{
  key BillOfMaterialItemUUID : sysuuid_c36;
  key BillOfMaterialHeaderUUID : sysuuid_c36;

      BillOfMaterialComponent : abap.char(40);
      BillOfMaterialItemCategory : abap.char(1);
      BillOfMaterialItemNumber : abap.char(4);

      BillOfMaterialItemUnit : abap.char(3);
      BillOfMaterialItemQuantity : abap.char(10);

      _bom : association to parent zsvg_ce_bom on $projection.BillOfMaterialHeaderUUID = _bom.BillOfMaterialHeaderUUID;
}
