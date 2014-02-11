require 'bundler/setup'
require 'datamancer'
require 'active_record'
require 'csv'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')
id_plazos_fijos = extract(from: 'id_plazos_fijos.csv')

inversiones =
extract(from: bases['sinensup'], table: 'INV_INVERSIONES_RECIBIDAS_STOCK', exclude: true) do
  field 'id_com_compania', map: 'CIAID',
    type: Integer
  field 'id_tie_mes', map: 'periodo',
    type: Integer
  field 'id_ent_version_rectificativo', map: 'version_rectificativo'
  field 'id_inv_inversion', map: 'codigo_ssn',
    strip: true, reject_if: '696'
  field 'i_inv_valor_contable', map: 'valor_contable'
end

plazos_fijos =
extract(from: bases['sinensup'], table: 'INV_PLAZOS_FIJOS_RECIBIDOS', exclude: true) do
  field 'id_banco', map: 'BIC', strip: true
  field 'id_inv_subtipo_especie', map: 'ID_ssn_tipo_plazo_fijo',
    type: Integer
  field 'id_mon_moneda', map: 'id_ssn_moneda_origen',
    strip: true
  field 'tipo_tasa', strip: true
  field 'tasa', type: String
  
  field 'id_com_compania', map: 'CIAID',
    type: Integer
  field 'id_tie_mes', map: 'periodo',
    type: Integer
  field 'id_ent_version_rectificativo', map: 'version_rectificativo'
  field 'i_inv_valor_contable', map: 'valor_contable'
end

plazos_fijos =
transform plazos_fijos do
  new_field 'id_temporal', id_banco + tasa + tipo_tasa + id_mon_moneda + id_inv_subtipo_especie.to_s
 
  del_field 'id_banco'
  del_field 'tasa'
  del_field 'tipo_tasa'
  del_field 'id_mon_moneda'
  del_field 'id_inv_subtipo_especie'
end

plazos_fijos =
transform plazos_fijos, join: id_plazos_fijos, on: 'id_temporal' do
  del_field 'id_temporal'
end

load plazos_fijos, to: bases['panel'], table: 'ft_inversion', append: false
load inversiones, to: bases['panel'], table: 'ft_inversion', append: true
