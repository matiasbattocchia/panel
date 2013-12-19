require 'bundler/setup'
require 'datamancer'
require 'active_record'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

datos =
extract from: bases['entidades'], table: 'Sucursales', exclude: true do
  field 'CiaId', type: Integer
  field 'SucID', type: Integer
  field 'id_com_dni_gerente', map: 'DNI_Gerente_DL', strip: true, empty_default: 'SIN REGISTRAR'
  field 'ds_com_gerente', map: 'Gerente_DL', strip: true, empty_default: 'SIN REGISTRAR'
  field 'Estado', reject_unless: 1
end

datos =
transform datos do
  new_field 'id_com_gerente', ciaid * 100 + sucid
  new_field 'cd_com_gerente', 'vacío'
  new_field 'id_com_cuil_gerente', 'SIN REGISTRAR'
  del_field 'Estado'
  del_field 'CiaId'
  del_field 'SucID'
end

load datos, to: bases['panel'], table: 'lk_com_gerente', append: false
