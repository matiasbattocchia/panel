require 'bundler/setup'
require 'datamancer'
require 'active_record'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

datos =
extract from: bases['entidades'], table: 'Tipos_Societarios', exclude: true do
  field 'id_com_tipo_social', map: 'TipoId', type: Integer
  field 'ds_com_tipo_social', map: 'Denominacion', strip: true
end

datos << {id_com_tipo_social: 0, ds_com_tipo_social: 'SIN REGISTRAR'}

datos =
transform datos do
  new_field 'cd_com_tipo_social', 'vacío'
end

load datos, to: bases['panel'], table: 'lk_com_tipo_social', append: false
